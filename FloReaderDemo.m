%%
clear
clc
close all

load("./images/demo/ExpAW5R2/CST_ExpAW5.mat")
%outfname = "./images/demo/DemoOutput/PIV-LiteFlowNet-en/-0_2/flow/0798_out.flo"
%outfname = "./images/demo/DemoOutput/PIV-LiteFlowNet-en/-0_2/flow/DNS_turbulence_img1_out.flo";
%outfname = "./images/synth/dxdy0.1_500x500/PIV-LiteFlowNet-en/-0_2/flow/1_out.flo";
%outfname = "./images/synth/dxdy0.3_500x500_varint1/PIV-LiteFlowNet-en/-0_2/flow/1_out.flo";
%outfname = "./images/synth/dudz0.25_500x500_varint1/PIV-LiteFlowNet-en/-0_2/flow/1_out.flo";
%outfname = "./images/synth/dudz5.68_500x500_varint1/PIV-LiteFlowNet-en/-0_2/flow/1_out.flo";
% outfname = "./images/synth/dudz12.00_500x500/PIV-LiteFlowNet-en/-0_2/flow/1_out.flo";
%outfname = "./images/synth/dudz12.00_500x500_varint1/PIV-LiteFlowNet-en/-0_2/flow/1_out.flo";
% outfname = "./images/synth/dudz24.00_500x500_varint1/PIV-LiteFlowNet-en/-0_2/flow/1_out.flo";
% outfname = "./images/synth/u0.05mps_500x500_varint1/PIV-LiteFlowNet-en/-0_2/flow/1_out.flo";
% outfname = "./images/synth/u0.10mps_500x500_varint1/PIV-LiteFlowNet-en/-0_2/flow/1_out.flo";
% outfname = "./images/synth/u0.20mps_500x500_varint1/PIV-LiteFlowNet-en/-0_2/flow/1_out.flo";
% outfname = "./images/synth/u0.30mps_500x500_varint1/PIV-LiteFlowNet-en/-0_2/flow/1_out.flo";
% outfname = "./images/synth/u0.03mps_500x500_varint1/PIV-LiteFlowNet-en/-0_2/flow/1_out.flo";
% outfname = "./images/synth/u0.10mps_500x500/PIV-LiteFlowNet-en/-0_2/flow/1_out.flo";
% outfname = "./images/synth/u0.05mps_500x500/PIV-LiteFlowNet-en/-0_2/flow/1_out.flo";
outfname = "./images/synth/u0.03mps_500x500/PIV-LiteFlowNet-en/-0_2/flow/1_out.flo";
[u, v] = read_flo_file(outfname);
figno = '0063';
%% Quiver
x = 1:size(u,2);
y = 1:size(u,1);
[X,Y] = meshgrid(x,y);
figure
quiver(X(1:10:end, 1:10:end),-Y(1:10:end, 1:10:end),u(1:10:end, 1:10:end), -v(1:10:end, 1:10:end)); % flip v for image display
axis equal;
%% Colormap
f = figure('Position',[0,0,650,500])
x = (1:size(u,2))*CST.DX_W;
y = (1:size(u,1))*CST.DX_W;
imagesc(100*x,100*y,u*100*CST.DX_W/CST.DT_W)
hold on
daspect([1 1 1]); 
colormap gray
set(gca,'FontSize',24,'TickLabelInterpreter','latex')
xlabel('cm','Interpreter','latex')
ylabel('cm','Interpreter','latex')
c = colorbar;
c.Label.String = "Horizontal Velocity (cm/s)";
c.TickLabelInterpreter = "latex";
c.Label.Interpreter = "latex";
ti = char(outfname);
ti = ti(16:(end-39));
title(ti,'FontName',"FreeSerif",'Interpreter','none','FontSize',12);
fname = ['/home/surflab/Downloads/', figno, '_SynthDataMLPIV_', ti]
savefig([fname, '.fig'])
saveas(f,[fname, '.svg'])
exportgraphics(gca,[fname, '.jpg'],'Resolution',1200)

% fontname("Times")

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
