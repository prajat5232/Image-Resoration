function varargout = Image_editor(varargin)
% IMAGE_EDITOR MATLAB code for Image_editor.fig


% Edit the above text to modify the response to help Image_editor

% Last Modified by GUIDE v2.5 10-Oct-2018 16:03:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Image_editor_OpeningFcn, ...
                   'gui_OutputFcn',  @Image_editor_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Image_editor is made visible.
function Image_editor_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Image_editor wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Image_editor_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;




% Author - Rajat Patel,IIT Bombay





% --- Executes on button press in Load.
function pushbutton1_Callback(hObject, eventdata, handles)

global image  
[path,user_cance]=imgetfile(); % get input file path from user
if user_cance
    msgbox(sprintf('No file Selected'),'Error','Error');  % show error if user cancels
    return
end
% try and catch block for showing error if user selects invalid image file
try
image=im2double(imread(path));
catch
    msgbox(sprintf('Error! Please select a valid image file'),'Error','Error');
end   

axes(handles.axes1);   % display in original image window
imshow(image)
title('Blurred Image');

global I M N Z
M=size(image,1);
N=size(image,2);
Z=size(image,3);
I=zeros(size(image)); %to store dft of image
for i=1:1:Z  
    I(:,:,i)=mydft2(image(:,:,i),1,1);  
end




% --- Executes on button press in Save.
function pushbutton2_Callback(hObject, eventdata, handles)


global image_f    % global variable for latest edited image
[file,path] = uiputfile('*.jpg');   %get input from user for where to save file
filename = fullfile(path,file);
imwrite(image_f,filename);   %save image


% --- Executes on button press in kernel.
function kernel_Callback(hObject, eventdata, handles)


global K M N
prompt = {'Enter blur kernel no.(1-4)'}; %input values 
boxtitle = 'Input to select Blur kernel';
dims = [1 60];
definput = {'1'}; %default values
inputs  =  inputdlg(prompt,boxtitle,dims,definput); %input acquired as a string array
k_no=str2double(inputs);     
kernel=cell(1,4);
%Read all the kernels
kernel{1}=imread('Kernel1G.jpg');
kernel{2}=imread('Kernel2G.jpg');
 kernel{3}=imread('Kernel3G.jpg');
 kernel{4}=imread('Kernel4G.jpg');
kernel{5}=imread('Kernel5G.jpg');
kernel=kernel{k_no};
kernel=im2double((kernel));

K=mydft2(kernel,M,N); %dft of kernel


% --- Executes on button press in GroundTruth.
function GroundTruth_Callback(hObject, eventdata, handles)

global original_image  image 
[path,user_cance]=imgetfile(); % get input file path from user
if user_cance
    msgbox(sprintf('No file Selected'),'Error','Error');  % show error if user cancels
    return
end
% try and catch block for showing error if user selects invalid image file
try
original_image=im2double(imread(path));
catch
    msgbox(sprintf('Error! Please select a valid image file'),'Error','Error');
end   
axes(handles.axes2);  % display in  image window
imshow(original_image)
title('Original Image');
%calculate ssim and psnr for blurred image
ssimi=(ssim(image,original_image));
set(handles.text4,'String',strcat('SSIM_blurred_image =',num2str(ssimi)));
psnri=(psnr(image,original_image));
set(handles.text5,'String',strcat('PSNR_blurred_image =',num2str(psnri)));


% --- Executes on button press in inversefilter.
function inversefilter_Callback(hObject, eventdata, handles)

global image_f image original_image I M N Radius K Z
Ki=1./K; %inverse of dft kernel
%truncation of Ki
for i=1:1:M
    for j=1:1:N
        if (i-M/2)^2 + (j-N/2)^2 > Radius^2
          Ki(i,j)=0;
        end
    end
end
        
image_d=zeros(size(image));
%inverse filtering
for i=1:1:Z
    I_d=I(:,:,i).*Ki;
    image_d(:,:,i)=((real(myidft2(I_d))));  
end
image_f=rescale(image_d);
axes(handles.axes2);
imshow(image_f);
title('Image after Inverse filtering')
%compute ssim and psnr for deblurred image
try
ssimf=(ssim(image_f,original_image));
set(handles.text6,'String',strcat('SSIM_deblurred_image =',num2str(ssimf)));
psnrf=(psnr(image_f,original_image));
set(handles.text7,'String',strcat('PSNR_deblurred_image =',num2str(psnrf)));
catch
    set(handles.text7,'String','No Ground Truth');
end

% --- Executes on Radius movement.
function slider2_Callback(hObject, eventdata, handles)

global Radius
Radius=get(hObject,'Value');
set(handles.text8,'String',strcat('Truncation Radius =',num2str(Radius)));

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in weiner.
function weiner_Callback(hObject, eventdata, handles)

global image_f image original_image I  k_n K Z
Sk= abs(K).^2;       %psd of kernel
image_d=zeros(size(image));
%weiner filtering
for i=1:1:Z
    I_d=Sk.*I(:,:,i)./((Sk + k_n).*K);
    image_d(:,:,i)=((real(myidft2(I_d))));  
end
image_f=rescale(image_d);
axes(handles.axes2);
imshow(image_f);
title('Image after Weiner filtering')
%ssim and psnr of deblurred image
try
ssimf=(ssim(image_f,original_image));
set(handles.text6,'String',strcat('SSIM_deblurred_image =',num2str(ssimf)));
psnrf=(psnr(image_f,original_image));
set(handles.text7,'String',strcat('PSNR_deblurred_image =',num2str(psnrf)));
catch
    set(handles.text7,'String','No Ground Truth');
end
% --- Executes on slider movement.
function k_weiner_Callback(hObject, eventdata, handles)

global k_n
k_n=get(hObject,'Value');
k_n = 10*4^k_n;
set(handles.text9,'String',strcat('K =',num2str(k_n)));

% --- Executes during object creation, after setting all properties.
function k_weiner_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in LS.
function LS_Callback(hObject, eventdata, handles)
global image_f image original_image I  gamma K M N Z
%p in LS computation
p=[0 0 -1  0;0 -1 4 -1 ; 0 0 -1 0 ;0 0 0 0];
P=abs(mydft2(p,M,N)).^2; %dft of p
Sk= abs(K).^2; %psd of kernel
Kc=conj(K);   %conjugate of dft of kernel  
image_d=zeros(size(image));
%constrained lS filtering
for i=1:1:Z
    I_d=I(:,:,i).*Kc./(Sk + gamma*P);
    image_d(:,:,i)=((real(myidft2(I_d))));  
end

image_f=rescale(image_d);
axes(handles.axes2);
imshow(image_f);
title('Image after Constrained LS filtering')
%ssim and psnr of deblurred image
try
ssimf=(ssim(image_f,original_image));
set(handles.text6,'String',strcat('SSIM_deblurred_image =',num2str(ssimf)));
psnrf=(psnr(image_f,original_image));
set(handles.text7,'String',strcat('PSNR_deblurred_image =',num2str(psnrf)));
catch
    set(handles.text7,'String','No Ground Truth');
end

% --- Executes on slider movement.
function gamma_Callback(hObject, eventdata, handles)
global gamma
gamma=get(hObject,'Value');
gamma = 2^gamma;
set(handles.text10,'String',strcat('Gamma =',num2str(gamma)));


% --- Executes during object creation, after setting all properties.
function gamma_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
