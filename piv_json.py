'''
Written by Kaushik Srinivasan
2025-09-23
Expected file structure:
dataset_root/
├ {basename}_img1.{ext}
├ {basename}_img2.{ext}  
├ {basename}_flow.flo
└ ...

Usage:
python piv_json.py --root <path> --output dataset.json
'''

import os
import json
import argparse
from glob import glob
from pathlib import Path
from typing import List, Dict, Tuple, Set
import random


def find_image_extensions(directory: str) -> Set[str]:
    supported_exts = {'.jpg', '.jpeg', '.png', '.bmp', '.tif', '.tiff', '.ppm'}
    found_exts = set()
    
    for ext in supported_exts:
        if glob(os.path.join(directory, f"*{ext}")) or glob(os.path.join(directory, f"*{ext.upper()}")):
            found_exts.add(ext)
    
    return found_exts


def find_valid_triplets(directory: str, flow_suffix: str = "flow", flow_ext: str = ".flo") -> List[str]:
    image_exts = find_image_extensions(directory)
    if not image_exts:
        raise ValueError(f"No supported image files found in {directory}")
    
    print(f"Found image extensions: {sorted(image_exts)}")
    
    flow_pattern = os.path.join(directory, f"*_{flow_suffix}{flow_ext}")
    flow_files = glob(flow_pattern)
    
    if not flow_files:
        raise ValueError(f"No flow files found with pattern: *_{flow_suffix}{flow_ext}")
    
    print(f"Found {len(flow_files)} potential flow files")
    
    valid_triplets = []
    missing_files = []
    
    for flow_file in sorted(flow_files):
        # Extract basename by removing the flow suffix and extension
        basename = os.path.basename(flow_file)
        basename = os.path.splitext(basename)[0]  # Remove extension
        basename = basename.rsplit('_', 1)[0]     # Remove _flow suffix
        
        # Check for corresponding image pairs
        img1_found = False
        img2_found = False
        
        for ext in image_exts:
            img1_path = os.path.join(directory, f"{basename}_img1{ext}")
            img2_path = os.path.join(directory, f"{basename}_img2{ext}")
            
            if os.path.isfile(img1_path) and os.path.isfile(img2_path):
                img1_found = True
                img2_found = True
                break
        
        if img1_found and img2_found:
            valid_triplets.append(os.path.basename(flow_file))
        else:
            missing_files.append({
                'flow': os.path.basename(flow_file),
                'basename': basename,
                'img1_found': img1_found,
                'img2_found': img2_found
            })
    
    print(f"Valid triplets found: {len(valid_triplets)}")
    if missing_files:
        print(f"Files with missing pairs: {len(missing_files)}")
        for missing in missing_files[:5]:  
            print(f"  {missing}")
        if len(missing_files) > 5:
            print(f"  ... and {len(missing_files) - 5} more")
    
    return valid_triplets


def split_dataset(file_list: List[str], train_ratio: float = 0.7, val_ratio: float = 0.2, 
                 test_ratio: float = 0.1, seed: int = 42) -> Dict[str, List[str]]:
    if abs(train_ratio + val_ratio + test_ratio - 1.0) > 1e-6:
        raise ValueError("Split ratios must sum to 1.0")
    
    random.seed(seed)
    shuffled_files = file_list.copy()
    random.shuffle(shuffled_files)
    
    n_total = len(shuffled_files)
    n_train = int(n_total * train_ratio)
    n_val = int(n_total * val_ratio)
    
    splits = {
        'train': shuffled_files[:n_train],
        'val': shuffled_files[n_train:n_train + n_val],
        'test': shuffled_files[n_train + n_val:]
    }
    
    print(f"Dataset split:")
    print(f"  Train: {len(splits['train'])} samples ({len(splits['train'])/n_total*100:.1f}%)")
    print(f"  Val:   {len(splits['val'])} samples ({len(splits['val'])/n_total*100:.1f}%)")
    print(f"  Test:  {len(splits['test'])} samples ({len(splits['test'])/n_total*100:.1f}%)")
    
    return splits


def validate_dataset_structure(directory: str, json_splits: Dict[str, List[str]], 
                              flow_suffix: str = "flow") -> bool:
    image_exts = find_image_extensions(directory)
    
    all_valid = True
    for split_name, file_list in json_splits.items():
        print(f"Validating {split_name} set ({len(file_list)} files)...")
        
        for flow_filename in file_list:
            flow_path = os.path.join(directory, flow_filename)
            if not os.path.isfile(flow_path):
                print(f"  ERROR: Flow file not found: {flow_filename}")
                all_valid = False
                continue
            
            basename = os.path.splitext(flow_filename)[0]
            basename = basename.rsplit('_', 1)[0]
            
            img_pair_found = False
            for ext in image_exts:
                img1_path = os.path.join(directory, f"{basename}_img1{ext}")
                img2_path = os.path.join(directory, f"{basename}_img2{ext}")
                
                if os.path.isfile(img1_path) and os.path.isfile(img2_path):
                    img_pair_found = True
                    break
            
            if not img_pair_found:
                print(f"  ERROR: Image pair not found for: {basename}")
                all_valid = False
    
    return all_valid


def generate_json(directory: str, output_path: str, train_ratio: float = 0.7, 
                 val_ratio: float = 0.2, test_ratio: float = 0.1, 
                 flow_suffix: str = "flow", flow_ext: str = ".flo", 
                 seed: int = 42, validate: bool = True) -> None:
    print(f"Scanning directory: {directory}")
    print(f"Looking for pattern: *_{flow_suffix}{flow_ext}")
    
    valid_files = find_valid_triplets(directory, flow_suffix, flow_ext)
    
    if not valid_files:
        raise ValueError("No valid file triplets found!")
    
    splits = split_dataset(valid_files, train_ratio, val_ratio, test_ratio, seed)
    
    if validate:
        print("\nValidating dataset structure...")
        if not validate_dataset_structure(directory, splits, flow_suffix):
            raise ValueError("Dataset validation failed!")
        print("Validation passed!")
    
    # Save JSON
    os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
    
    with open(output_path, 'w') as f:
        json.dump(splits, f, indent=2, sort_keys=True)
    
    print(f"\nJSON metadata saved to: {output_path}")
    
    print(f"\nExample entries:")
    for split_name, file_list in splits.items():
        if file_list:
            print(f"  {split_name}: {file_list[0]}")


def main():
    parser = argparse.ArgumentParser(
        description="Generate JSON metadata for PIV training pipeline",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    
    parser.add_argument('--root', '-r', required=True,
                        help='Root directory containing the dataset files')
    
    parser.add_argument('--output', '-o', required=True,
                        help='Output path for the JSON metadata file')
    
    parser.add_argument('--train-ratio', type=float, default=0.7,
                        help='Proportion of data for training')
    
    parser.add_argument('--val-ratio', type=float, default=0.2,
                        help='Proportion of data for validation')
    
    parser.add_argument('--test-ratio', type=float, default=0.1,
                        help='Proportion of data for testing')
    
    parser.add_argument('--flow-suffix', default='flow',
                        help='Suffix for flow files (e.g., "flow" for "basename_flow.flo")')
    
    parser.add_argument('--flow-ext', default='.flo',
                        help='Extension for flow files')
    
    parser.add_argument('--seed', type=int, default=42,
                        help='Random seed for reproducible splits')
    
    parser.add_argument('--no-validate', action='store_true',
                        help='Skip validation of dataset structure')
    
    args = parser.parse_args()
    
    if not os.path.isdir(args.root):
        raise ValueError(f"Root directory does not exist: {args.root}")
    
    if abs(args.train_ratio + args.val_ratio + args.test_ratio - 1.0) > 1e-6:
        raise ValueError("Split ratios must sum to 1.0")
    
    # Generate JSON
    generate_json(
        directory=args.root,
        output_path=args.output,
        train_ratio=args.train_ratio,
        val_ratio=args.val_ratio,
        test_ratio=args.test_ratio,
        flow_suffix=args.flow_suffix,
        flow_ext=args.flow_ext,
        seed=args.seed,
        validate=not args.no_validate
    )


if __name__ == '__main__':
    main()

