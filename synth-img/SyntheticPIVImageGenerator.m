clear
clc
close all

numPairs = 5000;

nX = 100;
nY = 100;

im1s = zeros(nY,nX,1,numPairs);
im2s = zeros(nY,nX,1,numPairs);
As = zeros(numPairs,1);

dt = 0.4;

nP = 500;

tic
for n = 1:numPairs

    im1 = zeros(nY,nX,1);
    im2 = zeros(nY,nX,1);
    

    p1 = zeros(nP,2);
    p2 = p1;
    
    extraX = 0.5; 
    
    for i = 1:nP
        p1(i,1) = ceil(rand()*nY);
        p1(i,2) = ceil(rand()*nX*(1+extraX)-extraX*nX/2);
    end
    
    %%
    y = 1:nY;
    t = 10000;
    eta = y*t^(-0.5);
    A = rand();
    u = 0.001*A*t*((1+2*eta.^2).*erfc(eta)-2./sqrt(pi).*eta.*exp(-eta.^2));
    % figure
    % plot(u,-y);
    %%
    for i = 1:nP
        p2(i,2) = round(p1(i,2)+dt*u(p1(i,1)));
        p2(i,1) = round(p1(i,1));
    end
    %%
    for i = 1:nP
        if p1(i,1) > 0 && p1(i,1) < nY && p1(i,2) > 0 && p1(i,2) < nX
            im1(p1(i,1),p1(i,2)) = 1;
        end
    
        if p2(i,1) > 0 && p2(i,1) < nY && p2(i,2) > 0 && p2(i,2) < nX
            im2(p2(i,1),p2(i,2)) = 1;
        end
    end

    % figure(1)
    % imagesc(im1);
    % 
    % figure(2)
    % imagesc(im2);

    im1s(:,:,1,n) = im1;
    im2s(:,:,1,n) = im2;
    As(n) = A;
    
end
toc

s = sprintf('TrainingData%dx%d.mat',nX,nY);
save(s,'nX','nY','As','im1s','im2s','numPairs','-v7.3');