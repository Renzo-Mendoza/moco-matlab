%% Extract video frames
video_path = "D:\WorkFolder\Workspace\Gut_motility\videos\v1.avi";

folder = fullfile(pwd,"images");
if ~exist(folder, 'dir')
   mkdir(folder)
end

vid_reader = VideoReader(video_path);
N          = ceil(log10(vid_reader.NumFrames));
for i = 1:vid_reader.NumFrames
    frame     = rgb2gray(read(vid_reader,i));
    file_name = sprintf("%0"+string(N)+"d%s", i, ".png");
    imwrite(frame, fullfile(folder, file_name));
end

%% Full MOCO;

% Smooth filter size
krn_size = [7, 7];
sigma    = 5;
kernel   = fspecial('gaussian', krn_size, sigma); 

% Parameters
templ_idx  = 1;
templ_name = sprintf("%0"+string(N)+"d%s", templ_idx, ".png");
max_len    = 256;
scl        = 2;
w          = 120;
srch_wdw   = 4;

% ROI coordinates (Y ; X)
p_i = [65; 550]; 
p_f = [200; 950];

% Template image
B     = double(imread(fullfile(folder, templ_name)));
B     = B(p_i(1):p_f(1),p_i(2):p_f(2));
B     = conv2(B, kernel, 'same');
[S,M] = std(B, [], 'all');
B     = (B - M) / S;

% Images and data
files = dir(fullfile(folder, '*.png'));
paths = cell(length(files), 1);
d     = zeros(2, length(files));

% Start moco with parpool for speed
parfor k = 1:length(files)
    paths{k,1} = fullfile(files(k).folder, files(k).name);
    I      = double(imread(paths{k,1}));
    A      = I(p_i(1):p_f(1),p_i(2):p_f(2));
    A      = conv2(A, kernel, 'same');
    [S,M]  = std(A, [], 'all');
    A      = (A - M) / S;
    d(:,k) = moco(A, B, w, srch_wdw, scl, max_len, "length", true);
end

%% Data post-processing and plot 
close all

% Outlier filtering
smooth_fact = 0.01;
dx = filloutliers(d(2,:)', "spline", "movmean",500);
dx = filloutliers(dx, "spline", "movmean",100);
dy = filloutliers(d(1,:)', "spline", "movmean",500);
dy = filloutliers(dy, "spline", "movmean",100);

figure
tiledlayout(2, 1, "TileSpacing", "compact", "Padding", "compact")
nexttile
plot(d(1,:)); hold on
plot(dy)
title("Y displacement")
xlim([1 length(dy)])

nexttile
plot(d(2,:));
hold on
plot(dx)
title("X displacement")
xlim([1 length(dx)])

%% Write video
vid = VideoWriter("video.avi");
vid.FrameRate = 30;

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

save_folder = fullfile(pwd,"images\moco");
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
    file_name = sprintf("%0"+string(N)+"d%s", i, ".png");
    imwrite(I, fullfile(save_folder, file_name));
end