function f=myidft2(F)

H= zeros(size(F,1),size(F,2));
for k=1:1:size(H,1)
    for m=1:1:size(H,2)
      H(k,m)=((-1)^(k+m));
    end
end
F=F.*H;
Fx= myidft(F);
f= transpose(myidft(transpose(Fx)));
f=f.*H;
end