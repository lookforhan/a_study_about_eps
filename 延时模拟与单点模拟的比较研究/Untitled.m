
clear;close all; clc;tic
load EPA_F
lib_directory='C:\Users\hc042\Desktop\renxingjisuancode2\';
libName = 'epanet2';hfileName = 'epanet2.h';
if ~libisloaded(libName)
loadlibrary(libName,hfileName);
end
MC_i=1;
input_net_filename=[lib_directory,'���㰸��','\','anytown6.inp'];
input_RR_filename=[lib_directory,'���㰸��','\','anytown_RR.txt'];
output_net_filename=['C:\Users\hc042\Desktop\������','\111',];
[t1, net_data ] = read_net( input_net_filename);
[t_e,damage_pipe_info]=ND_Execut_deterministic(net_data,'damage.txt');
    MC_simulate_result_dir=[output_net_filename,'\MCģ���',num2str(MC_i)];
    mkdir(MC_simulate_result_dir)%��i������ļ���
output_net_filename_inp_GIRAFFE2=[MC_simulate_result_dir,'\damage_net_GIRAFFE2','.inp'];%��i��ģ���������inp�ļ�
[t_W,pipe_relative]=damageNetInp2_GIRAFFE2(net_data,damage_pipe_info,EPA_format,output_net_filename_inp_GIRAFFE2);