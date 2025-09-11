%% Extract video frames
video_path = ""; % Set video path

folder = fullfile(pwd, "images");
if ~exist(folder, 'dir')
   mkdir(folder)
end

vid_reader = VideoReader(video_path);
N          = ceil(log10(vid_reader.NumFrames));
for i = 1:vid_reader.NumFrames
    frame     = rgb2gray(read(vid_reader,i));
    file_name = sprintf("%0" + string(N) + "d%s", i, ".png");
    imwrite(frame, fullfile(folder, file_name));
end

%% Set parameter and select ROI

% Images paths 
folder = fullfile(pwd, "images");
files  = dir(fullfile(folder, '*.png'));
paths  = cell(length(files), 1);
N      = ceil(log10(length(dir(fullfile(folder, '\*.png')))));

% Smooth filter size
krn_size = [7, 7];
sigma    = 5;
kernel   = fspecial('gaussian', krn_size, sigma); 

% Parameters
templ_idx  = 1;
templ_name = sprintf("%0" + string(N) + "d%s", templ_idx, ".png");
max_len    = 256;
scl        = 2;
w          = 120; % Maximum expected displacement
srch_wdw   = 4;

% Select ROI coordinates
disp_idx = length(files);
B        = double(imread(fullfile(folder, templ_name))); % Read template image
D        = double(imread(fullfile(folder,sprintf("%0" + string(N) + "d%s", disp_idx, ".png")))); % Image for comparing
fig = figure;
fig.WindowState = 'maximized';
imshowpair(B, D); 
xlabel('Draw a rectangle to select ROI', 'fontsize', 14, 'fontweight', 'bold'); 
axis equal; axis tight;
colormap('gray');
set(gca, 'XTick', [], 'YTick', []);
roi = drawrectangle;
fig.WindowButtonDownFcn = @(src,~)CallBackFunction(src);
flag = false;
while ~flag
    if roi.Position(3) < w || roi.Position(4) < w
        xlabel("Double click to accept ROI: W = " + string(ceil(roi.Position(3))) + ...
            ", H = " + string(ceil(roi.Position(4))) + "\color{red} (W, H < "+string(w) + ")", ...
            'fontsize', 14, 'fontweight', 'bold'); 
    else
        xlabel("Double click to accept ROI: W = " + string(ceil(roi.Position(3))) + ...
            ", H = " + string(ceil(roi.Position(4)))+ "\color{green} (W, H >= "+string(w) + ")", ...
            'fontsize', 14, 'fontweight', 'bold');
    end
    pause(0.1)
end

if roi.Position(3) < w || roi.Position(4) < w
    disp("Select an ROI with sides greater than the maximum expected displacement (w)")
else
    disp("ROI selected.")
    x_i = ceil(roi.Position(1)); 
    y_i = ceil(roi.Position(2));
    x_f = ceil(roi.Position(1) + rect(3)); 
    y_f = ceil(roi.Position(2) + roi.Position(4));
end

close(fig)

%% Full moco

% Set template image
B     = double(imread(fullfile(folder, templ_name)));
B     = B(y_i:y_f,x_i:x_f);
B     = conv2(B, kernel, 'same');
[S,M] = std(B, [], 'all');
B     = (B - M) / S;

% Start moco with parpool for speed
d = zeros(2, length(files));
parfor k = 1:length(files)
    paths{k,1} = fullfile(files(k).folder, files(k).name);
    I      = double(imread(paths{k,1}));
    A      = I(y_i:y_f,x_i:x_f);
    A      = conv2(A, kernel, 'same');
    [S,M]  = std(A, [], 'all');
    A      = (A - M) / S;
    d(:,k) = moco(A, B, w, srch_wdw, scl, max_len, "length", true);
end

%% Data post-processing and plot 
close all

% Outlier filtering
smooth_fact = 0.01;
dx = filloutliers(d(2,:)', "spline", "movmean", 500);
dx = filloutliers(dx, "spline", "movmean", 100);
dy = filloutliers(d(1,:)', "spline", "movmean", 500);
dy = filloutliers(dy, "spline", "movmean", 100);

figure
tiledlayout(2, 1, "TileSpacing", "compact", "Padding", "compact")
nexttile
plot(d(1,:), "DisplayName", "moco"); hold on
plot(dy, "DisplayName", "filtered")
title("Y displacement")
xlim([1 length(dy)])
grid on
ylabel("pxl")
xlabel("frame")
legend

nexttile
plot(d(2,:), "DisplayName", "moco");
hold on
plot(dx, "DisplayName", "filtered")
title("X displacement")
xlim([1 length(dx)])
grid on
ylabel("pxl")
xlabel("frame")
legend

%% Write video
vid = VideoWriter(fullfile(pwd, "moco-video.avi"));
vid.FrameRate = 100;

open(vid)
for i = 1:length(paths)
    A     = imread(paths{i,1});
    [m,n] = size(A);
    s     = round(dy(i),0); t = round(dx(i),0);
    if s >= 0 && t >= 0
        A_d = A(s+1:m,t+1:n);
        I   = ExtendMatrix(A_d, [0 s], [0 t]);
    elseif s >= 0 && t <= 0
        A_d = A(s+1:m,1:n+t);
        I   = ExtendMatrix(A_d, [0 s], [-t 0]);
    elseif s <= 0 && t >= 0
        A_d = A(1:m+s,t+1:n);
        I   = ExtendMatrix(A_d, [-s 0], [0 t]);
    else
        A_d = A(1:m+s,1:n+t);
        I   = ExtendMatrix(A_d, [-s 0], [-t 0]);
    end
    writeVideo(vid, I);
end
close(vid)

%% Write images

save_folder = fullfile(pwd, "images\moco");
if ~exist(save_folder, 'dir')
   mkdir(save_folder)
end

for i = 1:length(paths)
    A     = imread(paths{i,1});
    [m,n] = size(A);
    s     = round(dy(i),0); t = round(dx(i),0);
    if s >= 0 && t >= 0
        A_d = A(s+1:m,t+1:n);
        I   = ExtendMatrix(A_d, [0 s], [0 t]);
    elseif s >= 0 && t <= 0
        A_d = A(s+1:m,1:n+t);
        I   = ExtendMatrix(A_d, [0 s], [-t 0]);
    elseif s <= 0 && t >= 0
        A_d = A(1:m+s,t+1:n);
        I   = ExtendMatrix(A_d, [-s 0], [0 t]);
    else
        A_d = A(1:m+s,1:n+t);
        I   = ExtendMatrix(A_d, [-s 0], [-t 0]);
    end
    file_name = sprintf("%0" + string(N) + "d%s", i, ".png");
    imwrite(I, fullfile(save_folder, file_name));
end

%% Functions

function CallBackFunction(fig) % Detect double click
    if strcmp(fig.SelectionType, 'open')
        assignin('base', 'flag', true); 
    end
end