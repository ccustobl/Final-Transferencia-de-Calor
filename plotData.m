%% Finite Volumes to Board Elements Temperature Converter
% Function that takes the Temperature obtained using the Finite Volumes
% method and interpolates the temperature of the Elements of the Board.
function TPlot_new = plotData(TPlot,eleSide,boardSide,mode)

% Elements in Board
switch mode
    case "Full"
        x = 0 : eleSide : boardSide;
        y = x;
        nElesX = length(x);
        nElesY = nElesX;
        nEles = nElesX*nElesY;
        [X,Y] = meshgrid(x,y);
    case "Quarter"
        x = boardSide/2 : eleSide : boardSide;
        y = x;
        nElesX = length(x);
        nElesY = nElesX;
        nEles = nElesX*nElesY;
        [X,Y] = meshgrid(x,y);
end
        
% Board's Elements Indexation
eles = zeros(nEles,2);
eles(:,1) = reshape(X',[],1);
eles(:,2) = reshape(Y',[],1);
elesIndex = zeros(nElesY,nElesX);
for iEle = 1:nEles
    i = (boardSide-eles(iEle,2))/eleSide + 1;
    switch mode
        case "Full"
            j = (eles(iEle,1))/eleSide + 1;
        case "Quarter"
            j = (eles(iEle,1)-boardSide/2)/eleSide + 1;
    end
            
    elesIndex(round(i),round(j)) = iEle;
end

% TPlot
TPlot_new = zeros(nElesX);
for iEle = 1:nEles
    [i,j] = find(elesIndex == iEle);

    if (i == 1 && j == 1) % Corner: NW

    elseif (i == 1 && j == nElesX) % Corner NE

    elseif (i == nElesY && j == 1) % Corner: SW

    elseif (i == nElesY && j == nElesX) % Corner: SE

    elseif i == nElesY % Border: N
        T_aux1 = TPlot(i-1,j-1)+ 1.5*(TPlot(i-1,j-1)-TPlot(i-1,j));
        T_aux2 = TPlot(i-2,j-1)+ 1.5*(TPlot(i-2,j-1)-TPlot(i-2,j));
        TPlot_new(i,j) = T_aux2+ 1.5*(T_aux1-T_aux2);
        
    elseif i == 1 % Border: S
        T_aux1 = TPlot(i+1,j)+(TPlot(i+1,j-1)-TPlot(i+1,j))/2;
        T_aux2 = TPlot(i,j)+(TPlot(i,j-1)-TPlot(i,j))/2;
        switch mode
            case "Full"
                TPlot_new(i,j) = T_aux1+ 1.5*(T_aux2-T_aux1);
            case "Quarter"
                TPlot_new(i,j) = T_aux1+ 1.5*(T_aux1-T_aux2);
        end
        
    elseif j == nElesX % Border: W
        T_aux1 = TPlot(i-1,j-2)+ (TPlot(i,j-2)-TPlot(i-1,j-2))/2;
        T_aux2 = TPlot(i-1,j-1)+ (TPlot(i,j-1)-TPlot(i-1,j-1))/2;
        TPlot_new(i,j) = T_aux1+ 1.5*(T_aux2-T_aux1);
        
    elseif j == 1 % Border: E
        T_aux1 = TPlot(i-1,j)+ (TPlot(i,j)-TPlot(i-1,j))/2;
        T_aux2 = TPlot(i-1,j+1)+ (TPlot(i,j+1)-TPlot(i-1,j+1))/2;
        TPlot_new(i,j) = T_aux1+ 1.5*(T_aux2-T_aux1);

    else % Internal
        T_aux1 = TPlot(i,j)+(TPlot(i,j)-TPlot(i,j-1))/2;
        T_aux2 = TPlot(i-1,j-1)+(TPlot(i-1,j)-TPlot(i-1,j-1))/2;
        TPlot_new(i,j) = T_aux2+(T_aux1-T_aux2)/2;
    end
end

for iEle = 1:nEles
    [i,j] = find(elesIndex == iEle);
    
    if (i == nElesY && j == nElesX) % Corner: NW    
        TPlot_new(i,j) = TPlot(i-1,j-1)+ (TPlot(i-1,j-1)-TPlot(i-2,j-2))/2;

    elseif (i == nElesY && j == 1) % Corner: NE
        TPlot_new(i,j) = TPlot(i-1,j)+ (TPlot(i-1,j)-TPlot(i-2,j+1))/2;

    elseif (i == 1 && j == nElesX) % Corner SW
       TPlot_new(i,j) = TPlot(i,j-1)+ (TPlot(i,j-1)-TPlot(i+1,j-2))/2;

    elseif (i == 1 && j == 1) % Corner: SE
        TPlot_new(i,j) = TPlot(i,j)+ (TPlot(i,j)-TPlot(i+1,j+1))/2;
    end
end