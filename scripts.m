img1 = (imread("D:\WorkFolder\Workspace\Gut_motility\images\0001.jpg"));
img2 = (imread("D:\WorkFolder\Workspace\Gut_motility\images\6250.jpg"));
img3 = (imread("D:\WorkFolder\Workspace\Gut_motility\images\2350.jpg"));

%%
max_len    = 256;
max_area   = 256*256;
scl        = 2;
w          = 120;
srch_wdw   = 15;

% left
p_i = [65; 250]; % y , x
p_f = [160; 570];
% right
p_i = [65; 550]; % y , x
p_f = [200; 950];

A = double(img3(55:160,220:970));
B = double(img1(55:160,220:970));

A = double(img3(p_i(1):p_f(1),p_i(2):p_f(2)));
B = double(img1(p_i(1):p_f(1),p_i(2):p_f(2)));
C = double(img2(p_i(1):p_f(1),p_i(2):p_f(2)));
%downs_meth = "length"; %"area"

tic
d = moco(A, B, w, srch_wdw, scl, max_len, "length", false)
toc

tic
d = moco(C, B, w, srch_wdw, scl, max_len, "length", false)
toc
%%
p = [78; 266];
p = [90; 790];
xapf = @(x,pos,xl) pos(3)*(x-min(xl))/diff(xl)+pos(1);
yapf = @(y,pos,yl) pos(4)*(y-min(yl))/diff(yl)+pos(2);
xl = xlim;
yl = ylim;

figure
imshowpair(img1,img2)
hold on
scatter([p(2) p(2)+d(2)], [p(1) p(1)+d(1)])
drawArrow = @(x,y,varargin) quiver( x(1),y(1),x(2)-x(1),y(2)-y(1),0, varargin{:} );
drawArrow([p(2) p(2)+d(2)], [p(1) p(1)+d(1)], 'linewidth', 2, 'color', [1 1 1 0.1])
%% Full MOCO;

% Parameters
base_path = "D:\WorkFolder\Workspace\Gut_motility\images\";
templ_name = "0001.jpg";
max_len    = 256;
scl        = 2;
w          = 120;
srch_wdw   = 4;

% ROI coordinates
p_i = [55; 160];
p_f = [145; 960];%[230; 960];
p_i = [65; 550]; % y , x
p_f = [200; 950];

% Template image
B = double(imread(fullfile(base_path, templ_name)));
B = B(p_i(1):p_f(1),p_i(2):p_f(2));
[S,M] = std(B, [], 'all');
B = (B - M) / S;

% Images and data
files = dir(fullfile(base_path, '*.jpg'));
file_path = cell(length(files), 1);
d = zeros(2, length(files));
tic
parfor k = 1:length(files)
    file_path{k,1} = fullfile(files(k).folder, files(k).name);
    I = double(imread(file_path{k,1}));
    A = I(p_i(1):p_f(1),p_i(2):p_f(2));
    [S,M] = std(A, [], 'all');
    A = (A - M) / S;
    d(:,k) = moco(A, B, w, srch_wdw, scl, max_len, "length", true);
    k
end
toc
%%
close all
smooth_fact = 0.01;
dx = filloutliers(d(2,:)', "spline", "movmean",500);
dx = filloutliers(dx, "spline", "movmean",100);

dy = filloutliers(d(1,:)', "spline", "movmean",500);
dy = filloutliers(dy, "spline", "movmean",100);
dx_s = smooth(dx, smooth_fact, 'lowess');
plot(d(1,:));
hold on
plot(dy)
%%
vid = VideoWriter("vid.avi");
vid.FrameRate = 250;

close(vid)
open(vid)
for i = 1:length(file_path)
    i
    A = imread(file_path{i,1});
    [m,n] = size(A);
    s = round(dy(i),0); t = round(dx(i),0);
    if s >= 0 && t >= 0
        A_d = A(s+1:m,t+1:n);
        I = ExtendMatrix(A_d, [0 s], [0 t]);
    elseif s >= 0 && t <= 0
        A_d = A(s+1:m,1:n+t);
        I = ExtendMatrix(A_d, [0 s], [-t 0]);
    elseif s <= 0 && t >= 0
        A_d = A(1:m+s,t+1:n);
        I = ExtendMatrix(A_d, [-s 0], [0 t]);
    else
        A_d = A(1:m+s,1:n+t);
        I = ExtendMatrix(A_d, [-s 0], [-t 0]);
    end
    writeVideo(vid, I);
end
close(vid)
%%
moco(A, B, w, srch_wdw, scl, max_len, "length", true);

%%
iu = imread("D:\WorkFolder\Workspace\Gut_motility\images\4309.jpg");
iw = imread("D:\WorkFolder\Workspace\Gut_motility\images\4468.jpg");
figure
imshow(iu(p_i(1):p_f(1),p_i(2):p_f(2)))
figure
imshow(iw(p_i(1):p_f(1),p_i(2):p_f(2)))
