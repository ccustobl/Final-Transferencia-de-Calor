clear
close all
clc

%% Mode Selection
mode = "Full"; % "Full"

%% Constants

% T Sources
topBorderT = 100; %°C
lowerBorderT = 0; %°C

% Heat Sink
hsLength = 100e-3; %m
hsWidth =  100e-3; %m
hsThickness = 1e-3; %m

%% Mesh Generation

% Square Volumes
eleSide = 10e-3;
volSide = eleSide;
DX = volSide;
DY = volSide;

%X Subdivision
x = DX/2 : DX : hsLength - DX/2;
nVolsX = length(x);

% Y Subdivision
y = DY/2 : DY : hsWidth - DY/2;
nVolsY = length(y);

% Grid Creation
[X,Y] = meshgrid(x,y);

% Volumes Indexation
nVols = nVolsY*nVolsX;
vols = zeros(nVols,2);
vols(:,1) = reshape(X',[],1);
vols(:,2) = reshape(Y',[],1);
index = zeros(nVolsX,nVolsY);
for iVol = 1:nVols
    i = (vols(iVol,1)+DX/2)/DX;
    j = (hsWidth-(vols(iVol,2)-DY/2))/DY;
    index(round(i),round(j)) = iVol;
end

%% Resolution

% A & BC 
BC = zeros(nVols,1);
A = sparse(nVols);

for iVol = 1:nVols
    [i,j] = find(index == iVol);
    if (i == nVolsX && j == nVolsY) % Corner: NW
        A(iVol,iVol) = -3*DX/DY - DY/DX;
        BC(iVol) = -2*DX/DY*lowerBorderT;
        A(iVol,iVol+nVolsX) = DX/DY;
        A(iVol,iVol-1) = DY/DX;
        
    elseif (i == nVolsX && j == 1) % Corner: NE
        A(iVol,iVol) = -3*DX/DY - DY/DX;
        BC(iVol) = -2*DX/DY*topBorderT;
        A(iVol,iVol-nVolsX) = DX/DY;
        A(iVol,iVol-1) = DY/DX;

    elseif (i == 1 && j == nVolsY) % Corner SW
        A(iVol,iVol) = -3*DX/DY - DY/DX;
        BC(iVol) = -2*DX/DY*lowerBorderT;
        A(iVol,iVol+nVolsY) = DX/DY;
        A(iVol,iVol+1) = DY/DX;

    elseif (i == 1 && j == 1) % Corner: SE
        A(iVol,iVol) = -3*DX/DY - DY/DX;
        BC(iVol) = -2*DX/DY*topBorderT;
        A(iVol,iVol-nVolsX) = DX/DY;
        A(iVol,iVol+1) = DY/DX;
        
    elseif i == nVolsX % Border: N
        A(iVol,iVol) = -(2*DX/DY + DY/DX);
        BC(iVol) = 0;
        A(iVol,iVol+nVolsX) = DX/DY;
        A(iVol,iVol-nVolsX) = DX/DY;
        A(iVol,iVol-1) = DY/DX;
        
    elseif i == 1 % Border: S
        A(iVol,iVol) = -(2*DX/DY + DY/DX);
        BC(iVol) = 0;
        A(iVol,iVol+nVolsX) = DX/DY;
        A(iVol,iVol-nVolsX) = DX/DY;
        A(iVol,iVol+1) = DY/DX;
        
    elseif j == nVolsY % Border: W
        A(iVol,iVol) = -3*DX/DY - 2*DY/DX;
        BC(iVol) = -2*DX/DY*lowerBorderT;
        A(iVol,iVol+nVolsY) = DX/DY;
        A(iVol,iVol-1) = DY/DX;
        A(iVol,iVol+1) = DY/DX;
        
    elseif j == 1 % Border: E        
        A(iVol,iVol) = -3*DX/DY - 2*DY/DX;
        BC(iVol) =  -2*DX/DY*topBorderT;
        A(iVol,iVol-nVolsX) = DX/DY;
        A(iVol,iVol-1) = DY/DX;
        A(iVol,iVol+1) = DY/DX;

    else % Internal
        A(iVol,iVol) = -(2*DX/DY + 2*DY/DX);
        BC(iVol) = 0;
        A(iVol,iVol+nVolsX) = DX/DY;
        A(iVol,iVol-nVolsX) = DX/DY;
        A(iVol,iVol-1) = DY/DX;
        A(iVol,iVol+1) = DY/DX;
    end
end
%A = sparse(A);

% Solver
T = A\BC;


%% Graphics

% Extra Calculaions
TPlot = reshape(T,nVolsX,nVolsY)';
[dTx, dTy] = gradient(TPlot);
X_Plot = 0:DX:hsWidth;
Y_Plot = 0:DY:hsLength;
TPlot_new = plotData(TPlot,eleSide,hsLength,"Full");

% Distribución de Temperaturas
figure('Name','Distribución de Temperaturas 2','NumberTitle','off')
hold on
surf(X_Plot,Y_Plot,TPlot_new)
% surf(X_Plot,Y_Plot,TPlot_new,"EdgeColor","none")
hold off
view(0,90)
colorbar
axis square
title('Distribución de Temperaturas','FontSize',22,'FontName','Times New Roman')
xlabel('Posición en X [m]','FontSize',22,'FontName','Times New Roman')
ylabel('Posición en Y [m]','FontSize',22,'FontName','Times New Roman')

% Isotermas y Flujo de Calor
figure('Name','Isotermas y Flujo de Calor 4','NumberTitle','off')
hold on
contour(X_Plot,Y_Plot,TPlot_new,15,'LineWidth',3)
quiver(X,Y,-dTx,-dTy,'Color','k')
mesh(0:DX:hsWidth,0:DY:hsLength,zeros(hsLength/eleSide+1))
hold off
alpha 0.1
grid on
colorbar
axis square
title('Isotermas y Flujo de Calor','FontSize',22,'FontName','Times New Roman')
xlabel('Posición en X [m]','FontSize',22,'FontName','Times New Roman')
ylabel('Posición en Y [m]','FontSize',22,'FontName','Times New Roman')
