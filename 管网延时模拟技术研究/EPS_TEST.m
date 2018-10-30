clear;clc;close all;tic
% rmdir(output_net_filename,'s')
input_net_filename = 'C:\Users\hc042\Desktop\renxingjisuancode2\运算案例\anytown6.inp';
output_net_filename='C:\Users\hc042\Desktop\计算结果\111';
path('C:\Users\hc042\Desktop\renxingjisuancode2\readNet',path);
path('C:\Users\hc042\Desktop\renxingjisuancode2\EPS',path);
path('C:\Users\hc042\Desktop\renxingjisuancode2\getValue',path);
%% 读入原始管网
loadlibrary('epanet2.dll','epanet2.h'); %加载EPA动态链接库
load EPA_F.mat
[ t_read,net_data ] = read_net( input_net_filename,EPA_format);
if t_read ~=0
    disp('errors==================');
    disp('hanzhao_TEST');
    disp('line 5')
    return
end
output_net_filename_inp = input_net_filename;
MC_simulate_result_dir = output_net_filename;
mkdir(MC_simulate_result_dir)
PipeStatus = 0;
pipe_relative = 0; 

Hmin = 0;
Hdes = 20;
doa = 0.1;
circulation_num =30;

% [ Pressure,Demand,pattern,Length,system_L_cell,system_serviceability_cell,node_serviceability_cell] = ESP_net_test1( output_net_filename_inp,MC_simulate_result_dir,PipeStatus,pipe_relative,net_data,...
%     circulation_num,doa,Hmin,Hdes);
% [ Pressure,Demand,pattern,Length,system_L_cell,system_serviceability_cell,node_serviceability_cell] = ESP_net_test2( output_net_filename_inp,MC_simulate_result_dir,PipeStatus,pipe_relative,net_data,...
%     circulation_num,doa,Hmin,Hdes);
[ Pressure,Demand,pattern,Length,system_L_cell,system_serviceability_cell,node_serviceability_cell] = EPS_net_test4( output_net_filename_inp,MC_simulate_result_dir,PipeStatus,pipe_relative,net_data,...
    circulation_num,doa,Hmin,Hdes);
% rmdir(output_net_filename,'s')