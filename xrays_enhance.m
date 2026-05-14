close all
clear all
clc

%Image loading and processing
img_color=imread('cuboid_fracture.jpeg');
size_img_color=size(img_color);

I_original=rgb2gray(img_color);
I_original=double(I_original);
size_img=size(I_original);
original_image=I_original/max(max(I_original)); %Dividing for obtaining range [0,1]

%Plotting original image
figure(1)
imshow(original_image)
title('Original')

%Computing the blurring matrix
m=size_img(1);
blur=10;
r=m-blur+1;
H=zeros(r,m);
size(H)

for l=1:blur
    for i=1:r
        H(i,i+l-1)=1/blur;
    end
end

%Computing degraded Image
I_degraded=zeros(r,size_img(2));

for col=1:size_img(2)
    column=I_original(:,col);
    I_degraded(:,col)=H*column;
end
degraded_image=I_degraded/max(max(I_degraded));

figure(2)
imshow(degraded_image)
title('Degraded')

%Computing the pseudoinverse with matlab
H_plus=pinv(H);

%Computing the pseudoinverse manually with svd
tol=1e-12;
[U,S,V]=svd(H);
[emme,enne]=size(H);
s=diag(S);
ind_s=find(s<=tol);

if length(ind_s)==0
    r=min(emme,enne);
else
    r=ind_s(1)-1;
end

S_plus=blkdiag(diag(1./s(1:r)), zeros(enne-r,emme-r));
H_plus_manual=V*S_plus*U';

%Comparing results
display('Norm between H+ computed with pinv and H+ computed manually: ')
norm(H_plus-H_plus_manual)

%Restoring image
I_restored=zeros(size_img);
for col=1:size_img(2)
    column=I_degraded(:,col);
    I_restored(:,col)=H_plus_manual*column;
end
restored_image=I_restored/max(max(I_restored));
disp(['Norm of the difference between the original and the restored: ' num2str(norm(I_original - I_restored))]);
figure(3)
imshow(restored_image)
title('Restored')