function varargout = RobilliardGUI(varargin)
% ROBILLIARDGUI MATLAB code for RobilliardGUI.fig
%      ROBILLIARDGUI, by itself, creates a new ROBILLIARDGUI or raises the existing
%      singleton*.
%
%      H = ROBILLIARDGUI returns the handle to a new ROBILLIARDGUI or the handle to
%      the existing singleton*.
%
%      ROBILLIARDGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROBILLIARDGUI.M with the given input arguments.
%
%      ROBILLIARDGUI('Property','Value',...) creates a new ROBILLIARDGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RobilliardGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RobilliardGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RobilliardGUI

% Last Modified by GUIDE v2.5 17-May-2013 16:30:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @RobilliardGUI_OpeningFcn, ...
    'gui_OutputFcn',  @RobilliardGUI_OutputFcn, ...
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


% --- Executes just before RobilliardGUI is made visible.
function RobilliardGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RobilliardGUI (see VARARGIN)

% Choose default command line output for RobilliardGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Clear the terminal
clc;

% UIWAIT makes RobilliardGUI wait for user response (see UIRESUME)
% uiwait(handles.gui_figure);


% --- Outputs from this function are returned to the command line.
function varargout = RobilliardGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in load_image.
function load_image_Callback(hObject, eventdata, handles)
% hObject    handle to load_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of load_image

if (get(handles.load_image,'Value'))
    set(handles.img_address, 'Enable', 'on');
    
else
    set(handles.img_address, 'Enable', 'off');
end



function img_address_Callback(hObject, eventdata, handles)
% hObject    handle to img_address (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of img_address as text
%        str2double(get(hObject,'String')) returns contents of img_address as a double


% --- Executes during object creation, after setting all properties.
function img_address_CreateFcn(hObject, eventdata, handles)
% hObject    handle to img_address (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in align_button.
function align_button_Callback(hObject, eventdata, handles)
% hObject    handle to align_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cleanCameraConnection();
cam = videoinput('winvideo',1);
preview(cam);


% --- Executes on button press in close_figs.
function close_figs_Callback(hObject, eventdata, handles)
% hObject    handle to close_figs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of close_figs


% --- Executes on button press in run_button.
function run_button_Callback(hObject, eventdata, handles)
% hObject    handle to run_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clc;

if (get(handles.close_figs,'Value'))
    set(handles.gui_figure, 'HandleVisibility', 'off');
    close all;
    set(handles.gui_figure, 'HandleVisibility', 'on');
end

if (get(handles.load_image,'Value'))
    img = imread((get(handles.img_address,'String')));
    
    try
        Robilliard(img);
        
    catch last_error
        text = sprintf('\nRobilliard was ended due to an error:');
        disp(text);
        rethrow(last_error);
        
    end
    
else
    try
        Robilliard();
        
    catch
        cleanCameraConnection();
        
        text = sprintf('\nRobilliard was ended due to an error:');
        disp(text);
        rethrow(last_error);
        
    end
end










