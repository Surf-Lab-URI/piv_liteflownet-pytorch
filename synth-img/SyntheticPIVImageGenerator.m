clear
clc
% close all

numPairs = 1;

nX = 500;
nY = 500;

im1s = zeros(nY,nX,1,numPairs);
im2s = zeros(nY,nX,1,numPairs);
As = zeros(numPairs,1);

dt = 22.222e-3; %(s)
load("./images/demo/ExpAW5R2/CST_ExpAW5.mat")

nP = 15000;

tic
for n = 1:numPairs

    im1 = zeros(nY,nX,1);
    im2 = zeros(nY,nX,1);
    

    p1 = zeros(nP,2);
    p2 = p1;
    
    extraX = 1; 
    
    for i = 1:nP
        p1(i,1) = ceil(rand()*nY);
        p1(i,2) = ceil(rand()*nX*(1+extraX)-extraX*nX/2);
    end
    
    %%
    y = 1:nY;
    t = 10000;
    eta = y*t^(-0.5);
    A = rand();
    dx = 6;
    dxdy = 0.3;
    dudz = 24; %(1/s)
    z = y*CST.DX_W;
    u = y*0+0.03;%u = dudz*z;%y*dxdy/dt;%y*0 + dx/dt;%0.001*A*t*((1+2*eta.^2).*erfc(eta)-2./sqrt(pi).*eta.*exp(-eta.^2));
    % figure
    % plot(u,-y);
    %%
    for i = 1:nP
        p2(i,2) = round(p1(i,2)+dt*u(p1(i,1))/CST.DX_W);
        p2(i,1) = round(p1(i,1));
    end
    %%
    for i = 1:nP
        if p1(i,1) > 0 && p1(i,1) < nY && p1(i,2) > 0 && p1(i,2) < nX
            %im1(p1(i,1),p1(i,2)) = 1;
            A = rand();
            im1 = min(im1 + (80+80*A)*gauss2d(im1,1,p1(i,:)),255);
        end
    
        if p2(i,1) > 0 && p2(i,1) < nY && p2(i,2) > 0 && p2(i,2) < nX
            %im2(p2(i,1),p2(i,2)) = 1;
            A = rand();
            im2 = min(im2 + (80+80*A)*gauss2d(im2,1,p2(i,:)),255);

        end
    end

    figure(1)
    imagesc(im1);
    colormap gray

    figure(2)
    imagesc(im2);
    colormap gray

    im1s(:,:,1,n) = im1;
    im2s(:,:,1,n) = im2;
    As(n) = A;
    
end
toc
%%
clear cdir
cdir = sprintf('u%.2fmps_%dx%d_varint1/',u(1),nX,nY);
synthdir = '/home/surflab/GitRepos/piv_liteflownet-pytorch/images/synth/';
outdir = [synthdir, cdir];
mkdir(outdir)

f1 = [outdir, '1.tif'];
f2 = [outdir, '2.tif'];

imwrite(uint8(im1),f1);
imwrite(uint8(im2),f2);
%%
s = sprintf('Test%dx%d.mat',nX,nY);
save(s,'nX','nY','As','im1s','im2s','numPairs','-v7.3');

%%
function mat = gauss2d(mat, sigma, center)
    gsize = size(mat);
    [R,C] = ndgrid(1:gsize(1), 1:gsize(2));
    mat = gaussC(R,C, sigma, center);
end

function val = gaussC(x, y, sigma, center)
    xc = center(1);
    yc = center(2);
    exponent = ((x-xc).^2 + (y-yc).^2)./(2*sigma);
    val       = (exp(-exponent));
end