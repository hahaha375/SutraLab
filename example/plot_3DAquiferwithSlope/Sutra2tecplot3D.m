% In Chinese (UTF-8)
% If your matlab cannot read the comment, use notepad++ and transfer the 
% text into UTF-8
% Notice! This method can only be used for 3D cases
% The corresponding data can be acquired from: https://doi.org/10.5281/zenodo.20506161
% 这个脚本用于读取结果信息，保存为tecplot格式并且快速画出结果图。针对三维模型
% 相关绘图数据可以从该链接下载：https://doi.org/10.5281/zenodo.20506161

filename = 'SUTRAmodelkuansmodel';
dataINP = readINP(filename);
dataNOD = readNOD(filename);
dataELE = readELE(filename);

checksteadystate(dataNOD);
% read the .NOD file result
% 读取浓度数据
n = 8;
target_variable = find(strcmp(dataNOD(n).label,'Concentration'));
x_id = strcmp(dataNOD(n).label,'X'); % find x data 寻找x的数据
y_id = strcmp(dataNOD(n).label,'Y'); % find y data 提取Z轴数据
z_id = strcmp(dataNOD(n).label,'Z'); % find z data 提取Z轴数据
xa = dataNOD(n).terms{x_id}; % x data be careful with the unit 注意x轴的单位
ya = dataNOD(n).terms{y_id}; % y data z轴的数据
za = dataNOD(n).terms{z_id}; % z data z轴的数据
con = dataNOD(n).terms{target_variable}; % concentration 读取浓度值
pre = dataNOD(n).terms{strcmp(dataNOD(n).label,'Pressure')}; % pressure 读取压力值
sat = dataNOD(n).terms{strcmp(dataNOD(n).label,'Saturation')}; % satuation 读取饱和度

% read the .ELE file result
% 读取速度数据
% n = n-1;
% x_id = find(strcmp(dataELE(n).label,'X origin')); % find x data 寻找x的数据
% y_id = find(strcmp(dataELE(n).label,'Y origin')); % find y data 提取Y轴数据
% z_id = find(strcmp(dataELE(n).label,'Z origin')); % find z data 提取Z轴数据
% u_id = find(strcmp(dataELE(n).label,'X velocity')); % find u data 寻找x方向速度
% v_id = find(strcmp(dataELE(n).label,'Y velocity')); % find v data 提取y方向速度
% w_id = find(strcmp(dataELE(n).label,'Z velocity')); % find w data 提取z方向速度
% xa2 = dataELE(n).terms{x_id};
% ya2 = dataELE(n).terms{y_id};
% za2 = dataELE(n).terms{z_id};
% u = dataELE(n).terms{u_id};
% v = dataELE(n).terms{v_id};
% w = dataELE(n).terms{w_id};
% fprintf('Processing velocity');
% Fu = scatteredInterpolant(xa2, ya2, za2, u, 'linear', 'linear');
% fprintf('.');
% Fv = scatteredInterpolant(xa2, ya2, za2, v, 'linear', 'linear');
% fprintf('.');
% Fw = scatteredInterpolant(xa2, ya2, za2, w, 'linear', 'linear');
% fprintf('.');
% uq = Fu(xa, ya, za);
% fprintf('.');
% vq = Fv(xa, ya, za);
% fprintf('.');
% wq = Fv(xa, ya, za);
fprintf('done \n');

% read the connectivity of the mesh (# Data set 22)
% 读取网格的连接方式
connectivity = [dataINP.ds22{1,2}, dataINP.ds22{1,3}, dataINP.ds22{1,4}, dataINP.ds22{1,5},...
    dataINP.ds22{1,6}, dataINP.ds22{1,7}, dataINP.ds22{1,8}, dataINP.ds22{1,9}];
% Draw the graph
% 画图 将单元格连接起来（绘图属性自己调）
% patch('Faces', connectivity, 'Vertices', [xa, za], 'FaceVertexCData', con, 'FaceColor', 'interp', 'EdgeColor', 'none');
% colormap jet
save('results.mat', 'dataNOD', 'dataELE', 'dataINP');
%% 将读取的数据写为tecplot可读取的文本格式
% Convert the data to tecplot format
% If you don't have tecplot on your computer, block the following code
% 如果没有tecplot，这下面的代码就可以屏蔽掉
% Writing for part 1
% data1 = [xa, ya, za, con, pre, sat, uq, vq, wq]; % This is the code for velocity;屏蔽掉读速度的代码，如果要读速度就屏蔽下一段
data1 = [xa, ya, za, con, pre, sat]; % This is the code for concentration
fid = fopen(strcat(filename, '.dat'), 'w');
fprintf(fid,'%s \n','TITLE = ""');
% fprintf(fid,'%s \n','VARIABLES = "X", "Y", "Z", "C", "P", "S", "u", "v", "w"'); % This is the code for velocity
fprintf(fid,'%s \n','VARIABLES = "X", "Y", "Z", "C", "P", "S"'); % This is the code for concentration
fprintf(fid,'ZONE N=%d, E=%d, F=FEPOINT, ET=BRICK\n', dataINP.nn, dataINP.ne);
%% Writing Part II
% fprintf(fid,'%1.7e  %1.7e  %1.7e  %1.7e %1.7e %1.7e %1.7e %1.7e %1.7e\n',
% data1'); % This is the code for velocity
fprintf(fid,'%1.7e  %1.7e  %1.7e  %1.7e %1.7e %1.7e\n', data1'); % This is the code for concentration
%% Writing Part III
fprintf(fid,'%d  %d  %d  %d %d  %d  %d  %d\n', connectivity');
fclose(fid);
system(['preplot', ' ', filename, '.dat', ' ', filename, '.plt']);
system(['del', ' ', filename, '.dat']);