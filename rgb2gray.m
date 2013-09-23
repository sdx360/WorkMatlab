clear all; clc; close all;
i=imread('3A5.jpg');
a = 0.2989; be = 0.5870; c = 0.1140;
r=i(:,:,1);
g=i(:,:,2);
b=i(:,:,3);
z=(a*r)+(g*be)+(c*b);
figure;
subplot(2,1,1);
imshow(i);
title('Color');
subplot(2,1,2);
imshow(z);
title('Escala de grises');