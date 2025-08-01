%%
clear
clc
close all

load("./images/demo/ExpAW5R2/CST_ExpAW5.mat")
outfname = "./images/demo/DemoOutput/PIV-LiteFlowNet-en/-0_2/flow/0798_out.flo"
%outfname = "./images/demo/DemoOutput/PIV-LiteFlowNet-en/-0_2/flow/DNS_turbulence_img1_out.flo";
[u, v] = read_flo_file(outfname);
x = 1:size(u,2);
y = 1:size(u,1);
[X,Y] = meshgrid(x,y);
figure
quiver(X(1:10:end, 1:10:end),-Y(1:10:end, 1:10:end),u(1:10:end, 1:10:end), -v(1:10:end, 1:10:end)); % flip v for image display
axis equal;

figure
imagesc(u*CST.DX_W/CST.DT_W)
colormap gray
c = colorbar;
c.Label.String = "Horizontal Velocity (m/s)";
%%
function [u, v] = read_flo_file(filename)
    % READ_FLO_FILE Read a .flo optical flow file (Middlebury format)
    % Usage: [u, v] = read_flo_file('flow.flo')

    fid = fopen(filename, 'rb');
    if fid < 0
        error('Could not open %s', filename);
    end

    tag = fread(fid, 1, 'float32');
    if tag ~= 202021.25
        fclose(fid);
        error('Invalid .flo file (wrong tag: %f)', tag);
    end

    width  = fread(fid, 1, 'int32');
    height = fread(fid, 1, 'int32');

    % Read flow data (interleaved u and v)
    data = fread(fid, [2, width * height], 'float32');
    fclose(fid);

    % Reshape and separate u and v
    data = reshape(data, [2, width, height]);
    data = permute(data, [3 2 1]);  % (height, width, 2)
    u = data(:, :, 1);
    v = data(:, :, 2);
end
