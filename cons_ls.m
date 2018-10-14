original_Image=im2double(imread('GroundTruth1_1_1.jpg'));
Image=im2double(imread('Blure1_1.jpg'));
figure1=figure;
imshow(Image);
psnrvaluei=psnr(Image,original_Image);
ssimvaluei=ssim(Image,original_Image);

M=size(Image,1);
N=size(Image,2);
kernel=imread('Kernel1G.png');

kernel=im2double(rgb2hsv(kernel));
kernel=kernel(2:end,:,3);
K=mydft2(kernel,M,N);
gamma= 10000;
p=[0 0 -1  0;0 -1 4 -1 ; 0 0 -1 0 ;0 0 0 0];
P=abs(mydft2(p,M,N)).^2;
Sk= abs(K).^2;
Kc=conj(K);
image_d=Image;
for i=1:1:3
    I=mydft2(Image(:,:,i),1,1);
    I_d=I.*Kc./(Sk + gamma*P);
    image_d(:,:,i)=((real(myidft2(I_d))));    
end
figure1=figure;
image_f=rescale(image_d);
imshow(image_f);
psnrvaluef=psnr(image_f,original_Image);
ssimvaluef=ssim(image_f,original_Image);

