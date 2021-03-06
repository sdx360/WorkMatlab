function [CEImage] = CLA(Image,numTiles,Cliplimit)
[YRes,XRes]=size(Image);
CEImage=uint8(Image);
numBins=256;
XSize = round(XRes/numTiles(1));
YSize = round(YRes/numTiles(2));
%Determina las rangos de las secciones a explorar
sx = zeros(1,numTiles(1)+1); sx(1) = 1; sx(end) = XRes;
sy = zeros(1,numTiles(2)+1); sy(1) = 1; sy(end) = YRes;
for i=2:length(sx)-1
   sx(i) = sx(i-1)+XSize;
   sy(i) = sy(i-1)+YSize;
end
%tama�o de cada tile
dimTile =fix( [YRes,XRes] ./ numTiles);
numPixInTile = prod(dimTile);               %pixeles totales en cada tile
tileMappings = cell(numTiles);              %Cell array para los histogramas
for Row=1:numTiles(2)
    for Col=1:numTiles(1)
        %extraccion de cada title
        tile = CEImage(sy(Row):sy(Row+1),sx(Col):sx(Col+1));
        hist=imhist(tile,numBins);                             %Histograma de title
        tile_temp=histequal(hist,Cliplimit,numBins);           %corte del histograma
        tileMap = makeMap(tile_temp,[0 255],numPixInTile);     %Calculo de CDF
        tileMappings{Row,Col} = 0-tileMap;                         
    end 
end
%interpolacion bilineal
CEImage = interbi(CEImage, tileMappings, numTiles,dimTile);          
CEImage = uint8(abs(CEImage));
