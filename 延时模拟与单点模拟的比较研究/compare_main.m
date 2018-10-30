% compare_main
% 2018-08-11 15:06:50
% 比较在韧性计算中延时模拟与单点模拟的差别
% 选择（最高时/最低时）两个时间点。
% 本文件需要'C:\Users\hc042\Desktop\renxingjisuancode2\'中函数的支持。
%% 预处理
clear;close all; clc;tic
lib_directory='C:\Users\hc042\Desktop\renxingjisuancode2\';
funcName = 'compare_main';
libName = 'epanet2';hfileName = 'epanet2.h';
if libisloaded(libName)
    unloadlibrary (libName)
end
% loadlibrary(libName,hfileName);
% if errcode~=0
%     disp([funcName,'errors==================']);
%     disp("errcode = loadlibrary(libName);")
% end
% unloadlibrary (libName)
try
    load EPA_F
catch
    path('C:\Users\hc042\Desktop\renxingjisuancode2\toolkit',path);
    path('C:\Users\hc042\Desktop\renxingjisuancode2\readNet',path);
    path('C:\Users\hc042\Desktop\renxingjisuancode2\damageNet',path);
    path('C:\Users\hc042\Desktop\renxingjisuancode2\EPS',path);
    path('C:\Users\hc042\Desktop\renxingjisuancode2\getValue',path);
    path('C:\Users\hc042\Desktop\renxingjisuancode2\eventTime',path);
    path('C:\Users\hc042\Desktop\renxingjisuancode2\random',path);
    path('C:\Users\hc042\Desktop\renxingjisuancode2\random_singleTime',path);%单点模拟所需的函数。
    path('C:\Users\hc042\Desktop\renxingjisuancode2\pdd',path);
    load EPA_F
end

%=========================================
input_net_filename=[lib_directory,'运算案例','\','anytown6.inp'];
input_RR_filename=[lib_directory,'运算案例','\','anytown_RR.txt'];
output_net_filename=['C:\Users\hc042\Desktop\计算结果','\111',];
inpfile_lowest = [lib_directory,'运算案例','\anytown6-lowest.inp'];
inpfile_highest = [lib_directory,'运算案例','\anytown6-highest.inp'];
if isdir(output_net_filename)
    try
    rmdir(output_net_filename,'s')
    catch
        keyboard
    end
end
mkdir(output_net_filename);
%=========================================
%PDD
Hmin=0;%Hmin节点最小压力
Hdes=10;%Hdes节点需求压力;
doa=0.01;%PDD计算精度
circulation_num=40;%PDD循环次数
%=========================================
% repair
RepairCrew={'a'};
%=========================================
% Monte Carlo
MC_MAX = 1;
%=========================================
% ND_Execut_probabilistic3输入参数
fid=fopen(input_RR_filename,'r');
RR_data=textscan(fid,'%s%f%f%s','delimiter','\t','headerlines',1);%读取管线震害修复率数据pipe_num*5: 第1列管段号(字符),2管长(km),3平均震害率(处/km),4管材(字符)
fclose(fid);
parameter_pro_of_leak_area_filename=[lib_directory,'\参数','\','parameter_pro.txt'];
fid=fopen(parameter_pro_of_leak_area_filename,'r');
par_data=textscan(fid,'%s%f','delimiter','\t','headerlines',1);%读
fclose(fid);
input_probablity_filename=[lib_directory,'\参数','\','probability_of_leak_type.txt'];%确定关系泄漏类型概率文件
leak_probability_data=importdata(input_probablity_filename);%泄漏类型的概率
pipe_break_rate=0.2;
mu=0.62;C=4427;
pipe_damage_num_max=1000;
%% 临时使用：生成anytow6.inp的最高时和最低时文件，以供单点模拟使用。
% load EPA_F
% loadlibrary(libName,hfileName);
% [t, net_data ] = read_net( input_net_filename);
% % 生成最高时文件
% net_data{10,2} =[];
% net_data_highest = net_data;
% demand = net_data{15,2};
% demand_highest = demand;
% num = numel(demand(:,1));
% for n = 1:num
%     demand_highest{n,2} = demand{n,2} * 0.39;
%     demand_highest{n,3} = '';
% end
% net_data_highest{15,2} = demand_highest;
% inpfile_highest = [lib_directory,'运算案例','\anytown6-highest.inp'];
% outdata = [];
% t_W=Write_Inpfile5(net_data_highest,EPA_format,outdata,inpfile_highest);% 写入新管网inp
% % 生成最低时文件
% net_data_lowest = net_data;
% demand = net_data{15,2};
% demand_lowest = demand;
% num = numel(demand(:,1));
% for n = 1:num
%     demand_lowest{n,2} = demand{n,2} * 0.18;
%     demand_lowest{n,3} = '';
% end
% net_data_lowest{15,2} = demand_lowest;
% net_data_highest{15,2} = demand_highest;
% inpfile_lowest = [lib_directory,'运算案例','\anytown6-lowest.inp'];
% t_W=Write_Inpfile5(net_data_lowest,EPA_format,outdata,inpfile_lowest);% 写入新管网inp
%%
if ~libisloaded(libName)
loadlibrary(libName,hfileName);
end
[ node_original_data_highest ] = get_node_value( inpfile_highest,libName );
[ node_original_data_lowest ] = get_node_value( inpfile_lowest ,libName);

%% 正式模拟
% load EPA_F
[t1, net_data ] = read_net( input_net_filename,EPA_format);
[t2, net_data_highest ] = read_net( inpfile_highest,EPA_format);
[t3, net_data_lowest ] = read_net( inpfile_lowest,EPA_format);
system_original_L_highest=sum(cell2mat(net_data_highest{5,2}(:,4)));%管道运行总长度（m）
system_original_L_lowest=sum(cell2mat(net_data_lowest{5,2}(:,4)));%管道运行总长度（m）
% for MC_i = 1:MC_MAX
for MC_i = 1:5
    MC_simulate_result_dir=[output_net_filename,'\MC模拟第',num2str(MC_i)];
    mkdir(MC_simulate_result_dir)%第i次输出文件夹
    %[t_e,damage_pipe_info]=ND_Execut_probabilistic3(net_data,RR_data,leak_probability_data,pipe_break_rate,pipe_damage_num_max,C,mu,par_data);%调用ND_Execut子程序生成破坏信息
    damagefile = ['damage0',num2str(MC_i),'.txt'];%利用固定的破坏信息，以便重复试验。
    [t_e,damage_pipe_info]=ND_Execut_deterministic(net_data,damagefile);
% [t_e,damage_pipe_info]=ND_Execut_deterministic(net_data,'damage.txt');
disp(['MC模拟次数',num2str(MC_i)])
    t_w = write_Damagefile(damage_pipe_info,[MC_simulate_result_dir,'\damage.txt']);
    if t_e ~= 0
        disp('errors==================');
        disp('hanzhao');
        disp('ND_Execut_probabilistic3')
        disp('出错')
        return
    end
    if ~isempty(damage_pipe_info{1})
        
        % 延时模拟文件
        output_net_filename_inp_GIRAFFE2=[MC_simulate_result_dir,'\damage_net_GIRAFFE2','.inp'];%第i次模拟输出管网inp文件
        output_net_filename_inp=output_net_filename_inp_GIRAFFE2;
        % 最高时单次模拟
        output_net_filename_inp_highest_GIRAFFE2=[MC_simulate_result_dir,'\highest_damage_net_GIRAFFE2','.inp'];%第i次模拟输出管网inp文件
        % 最低时单次模拟
        output_net_filename_inp_lowest_GIRAFFE2=[MC_simulate_result_dir,'\lowest_damage_net_GIRAFFE2','.inp'];%第i次模拟输出管网inp文件
        %=========================================
        [t_W,pipe_relative]=damageNetInp2_GIRAFFE2(net_data,damage_pipe_info,EPA_format,output_net_filename_inp_GIRAFFE2);
        [~,~]=damageNetInp2_GIRAFFE2(net_data_highest,damage_pipe_info,EPA_format,output_net_filename_inp_highest_GIRAFFE2);
        [~,~]=damageNetInp2_GIRAFFE2(net_data_lowest,damage_pipe_info,EPA_format,output_net_filename_inp_lowest_GIRAFFE2);
        if t_W~=0
            disp('errors==================');
            disp('hanzhao:damageNetInp2_GIRAFFE2')
            disp(['MC模拟次数',num2str(MC_i)])
            return
        end
        %%
        BreakPipe_order=num2cell(damage_pipe_info{1});
        [ Dp_Inspect_mat,Dp_Repair_mat ,Dp_Travel_mat1] = event_time2( damage_pipe_info,net_data);
        %         Dp_Travel_mat=Dp_Travel_mat1/1000;
        Dp_Travel_mat=Dp_Travel_mat1*0;% 不考虑修复队伍移动时间的影响。
        % 随机次序延时模拟
        %         disp('随机次序模拟')
        MC_simulate_result_dir_random=[MC_simulate_result_dir,'\','random'];
        mkdir(MC_simulate_result_dir_random)
        %=================================
        % 延时模拟文件
        %         [random_Fitness,...
        %             random_best_pop,...
        %             random_BreakPipe_result,...
        %             random_RepairCrew_result,...
        %             random_F,...
        %             random_system_L,...
        %             random_system_serviceability,...
        %             random_node_serviceability,...
        %             random_node2_serviceability,...
        %             random_node_calculate_dem,...
        %             random_node_calculate_pre,...
        %             random_timeStep_end] = random_priority2...
        %             (MC_simulate_result_dir_random,MC_i,...文件夹，模拟次数
        %             BreakPipe_order,RepairCrew,...破坏管道，修复队伍，
        %             damage_pipe_info,net_data,...破坏信息，管网信息，
        %             EPA_format,...node_original_data,            system_original_L,...EPA格式，节点原本数据，系统原本管道长度
        %             circulation_num,doa,Hmin,Hdes,...PDD迭代次数，精度，最小水压，需要水压
        %             Dp_Inspect_mat,Dp_Repair_mat,Dp_Travel_mat,...检查时间，修复时间，移动时间
        %             output_net_filename_inp,pipe_relative);
%         [pop]=pipeDamage2priorityList(BreakPipe_order);%产生随机次序
        pop=BreakPipe_order;%采用固定的修复次序
        pop_cell{MC_i} = pop;
        [random_Fitness_EPS,BreakPipe_result,RepairCrew_result,random_F_EPS,random_system_L_EPS,random_system_serviceability_EPS,random_node_serviceability_EPS,random_node2_serviceability_EPS,random_node_calculate_dem_EPS,random_node_calculate_pre_EPS,random_timeStep_end_EPS,timeStep_EPS,activity_cell]...
            =fit4...
            (pop,...%修复次序
            RepairCrew,...%修复队伍
            BreakPipe_order,...%破坏次序
            Dp_Inspect_mat,...%检查时间
            Dp_Repair_mat,Dp_Travel_mat,...original_junction_num,
            damage_pipe_info,net_data,...%破坏信息，管网信息，
            MC_i,0,0,MC_simulate_result_dir_random,MC_simulate_result_dir_random,MC_simulate_result_dir_random,...
            EPA_format,...node_original_data,
            circulation_num,doa,Hmin,Hdes,...node_original_dem,system_original_L,...
            output_net_filename_inp_GIRAFFE2,...%需要计算的管网
            pipe_relative,'on');%评价种群个体适应度
        random_Fitness_cell_EPS{MC_i,1}=random_Fitness_EPS;
        random_F_cell_EPS{MC_i,1}=random_F_EPS;
        random_system_L_cell_EPS{MC_i,1}=random_system_L_EPS;
        random_system_serviceability_cell_EPS{MC_i,1}=random_system_serviceability_EPS;
        random_node_serviceability_cell_EPS{MC_i,1}=random_node_serviceability_EPS;
        random_node2_serviceability_cell_EPS{MC_i,1}=random_node2_serviceability_EPS;
        random_node_calculate_dem_cell_EPS{MC_i,1}=random_node_calculate_dem_EPS;
        random_node_calculate_pre_cell_EPS{MC_i,1}=random_node_calculate_pre_EPS;
        random_timeStep_end_cell_EPS{MC_i,1}=random_timeStep_end_EPS;
        random_timeStep_cell {MC_i,1}=timeStep_EPS;
        random_activity_cell{MC_i,1} = activity_cell;
        %         disp('EPS模拟==结束')
        % 最高时单次模拟
       
        [random_Fitness,random_best_pop,random_BreakPipe_result,random_RepairCrew_result,...
            random_F,random_system_L,random_system_serviceability,random_node_serviceability,random_node2_serviceability,...
            random_node_calculate_dem,random_node_calculate_pre,random_timeStep_end] = random_priority(MC_simulate_result_dir_random,MC_i,...文件夹，模拟次数
            BreakPipe_order,RepairCrew,...破坏管道，修复队伍，
            damage_pipe_info,net_data_highest,...破坏信息，管网信息，
            EPA_format,node_original_data_highest,system_original_L_highest,...EPA格式，节点原本数据，系统原本管道长度
            circulation_num,doa,Hmin,Hdes,...PDD迭代次数，精度，最小水压，需要水压
            Dp_Inspect_mat,Dp_Repair_mat,Dp_Travel_mat,...检查时间，修复时间，移动时间
            pop);%
        random_Fitness_cell_highest{MC_i,1}=random_Fitness;
        random_F_cell_highest{MC_i,1}=random_F;
        random_system_L_cell_highest{MC_i,1}=random_system_L;
        random_system_serviceability_cell_highest{MC_i,1}=random_system_serviceability;
        random_node_serviceability_cell_highest{MC_i,1}=random_node_serviceability;
        random_node2_serviceability_cell_highest{MC_i,1}=random_node2_serviceability;
        random_node_calculate_dem_cell_highest{MC_i,1}=random_node_calculate_dem;
        random_node_calculate_pre_cell_highest{MC_i,1}=random_node_calculate_pre;
        random_timeStep_end_cell_highest{MC_i,1}=random_timeStep_end;
        %         disp('单点模拟==结束')
        %         % 最低时单次模拟
        %
        [random_Fitness_lowest,random_best_pop_lowest,random_BreakPipe_result_lowest,random_RepairCrew_result_lowest,...
            random_F_lowest,random_system_L_lowest,random_system_serviceability_lowest,random_node_serviceability_lowest,random_node2_serviceability_lowest,...
            random_node_calculate_dem_lowest,random_node_calculate_pre_lowest,random_timeStep_end_lowest] = random_priority(MC_simulate_result_dir_random,MC_i,...文件夹，模拟次数
            BreakPipe_order,RepairCrew,...破坏管道，修复队伍，
            damage_pipe_info,net_data_lowest,...破坏信息，管网信息，
            EPA_format,node_original_data_lowest,system_original_L_lowest,...EPA格式，节点原本数据，系统原本管道长度
            circulation_num,doa,Hmin,Hdes,...PDD迭代次数，精度，最小水压，需要水压
            Dp_Inspect_mat,Dp_Repair_mat,Dp_Travel_mat,...检查时间，修复时间，移动时间
            pop);%
        random_Fitness_cell_lowest{MC_i,1}=random_Fitness_lowest;
        random_F_cell_lowest{MC_i,1}=random_F_lowest;
        random_system_L_cell_lowest{MC_i,1}=random_system_L_lowest;
        random_system_serviceability_cell_lowest{MC_i,1}=random_system_serviceability_lowest;
        random_node_serviceability_cell_lowest{MC_i,1}=random_node_serviceability_lowest;
        random_node2_serviceability_cell_lowest{MC_i,1}=random_node2_serviceability_lowest;
        random_node_calculate_dem_cell_lowest{MC_i,1}=random_node_calculate_dem_lowest;
        random_node_calculate_pre_cell_lowest{MC_i,1}=random_node_calculate_pre_lowest;
        random_timeStep_end_cell_lowest{MC_i,1}=random_timeStep_end_lowest;
        %         disp('单点模拟==结束')
        %}
        % 进行GA优化
        %         disp('随机次序模拟==结束')
        
    else
        disp('no damage');
        continue
    end
end
toc
%% 后处理

mid = cell(0,1);
for i =1: numel(pop_cell)
    mid = merge_cell(mid,pop_cell{i},1);
    mid2{1,i} = ['第',num2str(i),'工况']; 
end
mid3 = [mid2;mid(:,2:end)];
xlswrite([output_net_filename,'\修复次序.xls'],mid3)
% 韧性
% random_Fitness_cell_EPS
% random_Fitness_cell_highest
% random_Fitness_cell_lowest
% random_timeStep_end_cell_EPS
% random_timeStep_end_cell_highest
% random_timeStep_end_cell_lowest
mid = [];
mid1 =[];
mid2=[];
mid3=[];
mid = [random_Fitness_cell_EPS,random_Fitness_cell_highest,random_Fitness_cell_lowest,random_timeStep_end_cell_lowest];
for i = 1:numel(random_Fitness_cell_EPS)
    mid1{i,1} = ['第',num2str(i),'工况'];
end
mid1=[cell(1,1);mid1];
mid2={'EPS','最高点单点模拟','最低点单点模拟','模拟步长'};
mid3 = [mid2;mid];
mid4 = [mid1,mid3];
xlswrite([output_net_filename,'\韧性值.xls'],mid4)
mid4
% 性能曲线
%  random_system_serviceability_cell_EPS
%  random_system_serviceability_cell_highest
%  random_system_serviceability_cell_lowest

mid = [];
mid1 =[];
mid2=[];
mid3=[];
mid4=[];
mid = {'时间步','EPS','最高点单点模拟','最低点单点模拟','活动'};
% random_timeStep_cell{i}
for i = 1:numel(random_system_serviceability_cell_EPS)
    mid1 = random_timeStep_cell{i}./3600;
    mid2 = rem(mid1,1);
    loc = find(mid2==0);
    mid2 = [random_system_serviceability_cell_EPS{i}(loc)',random_system_serviceability_cell_highest{i}(1:end-1)',random_system_serviceability_cell_lowest{i}(1:end-1)'];
    mid3 = [mid1(loc)',mid2];
    mid4 = [mid;[num2cell(mid3),random_activity_cell{i}(loc)']];
    xlswrite([output_net_filename,'\',num2str(i),'工况供水能力.xls'],mid4)
end
% 管道工作长度曲线
% random_system_L_cell_EPS
% random_system_L_cell_highest
% random_system_L_cell_lowest
mid = [];
mid1 =[];
mid2=[];
mid3=[];
mid4=[];
mid = {'时间步','EPS','最高点单点模拟','最低点单点模拟','活动'};
for i = 1:numel(random_system_serviceability_cell_EPS)
   
    mid1 = random_timeStep_cell{i}./3600;
    mid23 = rem(mid1,1);
    loc = find(mid23==0);
    mid2 = [random_system_L_cell_EPS{i}(loc)',random_system_L_cell_highest{i}(1:end-1)',random_system_L_cell_lowest{i}(1:end-1)'];
    mid3 = [mid1(loc)',mid2];
    mid4 = [mid;[num2cell(mid3),random_activity_cell{i}(loc)']];
    xlswrite([output_net_filename,'\',num2str(i),'工况管道工作长度.xls'],mid4)
end
%}
toc