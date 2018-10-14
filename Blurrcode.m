

Image=im2double(imread('myimage.jpeg'));
figure
%Image=rgb2hsv(Image);
%Image=Image(:,:,3);
imshow(Image);
M=size(Image,1);
N=size(Image,2);
s='Kernel5G.jpg';
kernel=im2double(imread(s));

%kernel=(rgb2hsv(kernel));
%kernel=kernel(2:end,2:end,3);
K=mydft2(kernel,M,N);

image_d=Image;
for i=1:1:size(Image,3)
    I=mydft2(Image(:,:,i),1,1);
    I_d=I.*K;
    image_d(:,:,i)=(((real(myidft2(I_d)))));
    
end
sigma_u = 10^(-40/20);
image_dd=rescale(image_d);
%image_d=image_dd +  sigma_u*randn(size(image_d));
figure
imshow(image_dd);
%imwrite((image_d),'Blure2_1.jpg');
%imwrite(kernel,'Kernel4G.jpg');

