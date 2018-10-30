% compare_main
% 2018-08-11 15:06:50
% �Ƚ������Լ�������ʱģ���뵥��ģ��Ĳ��
% ѡ�����ʱ/���ʱ������ʱ��㡣
% ���ļ���Ҫ'C:\Users\hc042\Desktop\renxingjisuancode2\'�к�����֧�֡�
%% Ԥ����
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
    path('C:\Users\hc042\Desktop\renxingjisuancode2\random_singleTime',path);%����ģ������ĺ�����
    path('C:\Users\hc042\Desktop\renxingjisuancode2\pdd',path);
    load EPA_F
end

%=========================================
input_net_filename=[lib_directory,'���㰸��','\','anytown6.inp'];
input_RR_filename=[lib_directory,'���㰸��','\','anytown_RR.txt'];
output_net_filename=['C:\Users\hc042\Desktop\������','\111',];
inpfile_lowest = [lib_directory,'���㰸��','\anytown6-lowest.inp'];
inpfile_highest = [lib_directory,'���㰸��','\anytown6-highest.inp'];
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
Hmin=0;%Hmin�ڵ���Сѹ��
Hdes=10;%Hdes�ڵ�����ѹ��;
doa=0.01;%PDD���㾫��
circulation_num=40;%PDDѭ������
%=========================================
% repair
RepairCrew={'a'};
%=========================================
% Monte Carlo
MC_MAX = 1;
%=========================================
% ND_Execut_probabilistic3�������
fid=fopen(input_RR_filename,'r');
RR_data=textscan(fid,'%s%f%f%s','delimiter','\t','headerlines',1);%��ȡ�������޸�������pipe_num*5: ��1�йܶκ�(�ַ�),2�ܳ�(km),3ƽ������(��/km),4�ܲ�(�ַ�)
fclose(fid);
parameter_pro_of_leak_area_filename=[lib_directory,'\����','\','parameter_pro.txt'];
fid=fopen(parameter_pro_of_leak_area_filename,'r');
par_data=textscan(fid,'%s%f','delimiter','\t','headerlines',1);%��
fclose(fid);
input_probablity_filename=[lib_directory,'\����','\','probability_of_leak_type.txt'];%ȷ����ϵй©���͸����ļ�
leak_probability_data=importdata(input_probablity_filename);%й©���͵ĸ���
pipe_break_rate=0.2;
mu=0.62;C=4427;
pipe_damage_num_max=1000;
%% ��ʱʹ�ã�����anytow6.inp�����ʱ�����ʱ�ļ����Թ�����ģ��ʹ�á�
% load EPA_F
% loadlibrary(libName,hfileName);
% [t, net_data ] = read_net( input_net_filename);
% % �������ʱ�ļ�
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
% inpfile_highest = [lib_directory,'���㰸��','\anytown6-highest.inp'];
% outdata = [];
% t_W=Write_Inpfile5(net_data_highest,EPA_format,outdata,inpfile_highest);% д���¹���inp
% % �������ʱ�ļ�
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
% inpfile_lowest = [lib_directory,'���㰸��','\anytown6-lowest.inp'];
% t_W=Write_Inpfile5(net_data_lowest,EPA_format,outdata,inpfile_lowest);% д���¹���inp
%%
if ~libisloaded(libName)
loadlibrary(libName,hfileName);
end
[ node_original_data_highest ] = get_node_value( inpfile_highest,libName );
[ node_original_data_lowest ] = get_node_value( inpfile_lowest ,libName);

%% ��ʽģ��
% load EPA_F
[t1, net_data ] = read_net( input_net_filename,EPA_format);
[t2, net_data_highest ] = read_net( inpfile_highest,EPA_format);
[t3, net_data_lowest ] = read_net( inpfile_lowest,EPA_format);
system_original_L_highest=sum(cell2mat(net_data_highest{5,2}(:,4)));%�ܵ������ܳ��ȣ�m��
system_original_L_lowest=sum(cell2mat(net_data_lowest{5,2}(:,4)));%�ܵ������ܳ��ȣ�m��
% for MC_i = 1:MC_MAX
for MC_i = 1:5
    MC_simulate_result_dir=[output_net_filename,'\MCģ���',num2str(MC_i)];
    mkdir(MC_simulate_result_dir)%��i������ļ���
    %[t_e,damage_pipe_info]=ND_Execut_probabilistic3(net_data,RR_data,leak_probability_data,pipe_break_rate,pipe_damage_num_max,C,mu,par_data);%����ND_Execut�ӳ��������ƻ���Ϣ
    damagefile = ['damage0',num2str(MC_i),'.txt'];%���ù̶����ƻ���Ϣ���Ա��ظ����顣
    [t_e,damage_pipe_info]=ND_Execut_deterministic(net_data,damagefile);
% [t_e,damage_pipe_info]=ND_Execut_deterministic(net_data,'damage.txt');
disp(['MCģ�����',num2str(MC_i)])
    t_w = write_Damagefile(damage_pipe_info,[MC_simulate_result_dir,'\damage.txt']);
    if t_e ~= 0
        disp('errors==================');
        disp('hanzhao');
        disp('ND_Execut_probabilistic3')
        disp('����')
        return
    end
    if ~isempty(damage_pipe_info{1})
        
        % ��ʱģ���ļ�
        output_net_filename_inp_GIRAFFE2=[MC_simulate_result_dir,'\damage_net_GIRAFFE2','.inp'];%��i��ģ���������inp�ļ�
        output_net_filename_inp=output_net_filename_inp_GIRAFFE2;
        % ���ʱ����ģ��
        output_net_filename_inp_highest_GIRAFFE2=[MC_simulate_result_dir,'\highest_damage_net_GIRAFFE2','.inp'];%��i��ģ���������inp�ļ�
        % ���ʱ����ģ��
        output_net_filename_inp_lowest_GIRAFFE2=[MC_simulate_result_dir,'\lowest_damage_net_GIRAFFE2','.inp'];%��i��ģ���������inp�ļ�
        %=========================================
        [t_W,pipe_relative]=damageNetInp2_GIRAFFE2(net_data,damage_pipe_info,EPA_format,output_net_filename_inp_GIRAFFE2);
        [~,~]=damageNetInp2_GIRAFFE2(net_data_highest,damage_pipe_info,EPA_format,output_net_filename_inp_highest_GIRAFFE2);
        [~,~]=damageNetInp2_GIRAFFE2(net_data_lowest,damage_pipe_info,EPA_format,output_net_filename_inp_lowest_GIRAFFE2);
        if t_W~=0
            disp('errors==================');
            disp('hanzhao:damageNetInp2_GIRAFFE2')
            disp(['MCģ�����',num2str(MC_i)])
            return
        end
        %%
        BreakPipe_order=num2cell(damage_pipe_info{1});
        [ Dp_Inspect_mat,Dp_Repair_mat ,Dp_Travel_mat1] = event_time2( damage_pipe_info,net_data);
        %         Dp_Travel_mat=Dp_Travel_mat1/1000;
        Dp_Travel_mat=Dp_Travel_mat1*0;% �������޸������ƶ�ʱ���Ӱ�졣
        % ���������ʱģ��
        %         disp('�������ģ��')
        MC_simulate_result_dir_random=[MC_simulate_result_dir,'\','random'];
        mkdir(MC_simulate_result_dir_random)
        %=================================
        % ��ʱģ���ļ�
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
        %             (MC_simulate_result_dir_random,MC_i,...�ļ��У�ģ�����
        %             BreakPipe_order,RepairCrew,...�ƻ��ܵ����޸����飬
        %             damage_pipe_info,net_data,...�ƻ���Ϣ��������Ϣ��
        %             EPA_format,...node_original_data,            system_original_L,...EPA��ʽ���ڵ�ԭ�����ݣ�ϵͳԭ���ܵ�����
        %             circulation_num,doa,Hmin,Hdes,...PDD�������������ȣ���Сˮѹ����Ҫˮѹ
        %             Dp_Inspect_mat,Dp_Repair_mat,Dp_Travel_mat,...���ʱ�䣬�޸�ʱ�䣬�ƶ�ʱ��
        %             output_net_filename_inp,pipe_relative);
%         [pop]=pipeDamage2priorityList(BreakPipe_order);%�����������
        pop=BreakPipe_order;%���ù̶����޸�����
        pop_cell{MC_i} = pop;
        [random_Fitness_EPS,BreakPipe_result,RepairCrew_result,random_F_EPS,random_system_L_EPS,random_system_serviceability_EPS,random_node_serviceability_EPS,random_node2_serviceability_EPS,random_node_calculate_dem_EPS,random_node_calculate_pre_EPS,random_timeStep_end_EPS,timeStep_EPS,activity_cell]...
            =fit4...
            (pop,...%�޸�����
            RepairCrew,...%�޸�����
            BreakPipe_order,...%�ƻ�����
            Dp_Inspect_mat,...%���ʱ��
            Dp_Repair_mat,Dp_Travel_mat,...original_junction_num,
            damage_pipe_info,net_data,...%�ƻ���Ϣ��������Ϣ��
            MC_i,0,0,MC_simulate_result_dir_random,MC_simulate_result_dir_random,MC_simulate_result_dir_random,...
            EPA_format,...node_original_data,
            circulation_num,doa,Hmin,Hdes,...node_original_dem,system_original_L,...
            output_net_filename_inp_GIRAFFE2,...%��Ҫ����Ĺ���
            pipe_relative,'on');%������Ⱥ������Ӧ��
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
        %         disp('EPSģ��==����')
        % ���ʱ����ģ��
       
        [random_Fitness,random_best_pop,random_BreakPipe_result,random_RepairCrew_result,...
            random_F,random_system_L,random_system_serviceability,random_node_serviceability,random_node2_serviceability,...
            random_node_calculate_dem,random_node_calculate_pre,random_timeStep_end] = random_priority(MC_simulate_result_dir_random,MC_i,...�ļ��У�ģ�����
            BreakPipe_order,RepairCrew,...�ƻ��ܵ����޸����飬
            damage_pipe_info,net_data_highest,...�ƻ���Ϣ��������Ϣ��
            EPA_format,node_original_data_highest,system_original_L_highest,...EPA��ʽ���ڵ�ԭ�����ݣ�ϵͳԭ���ܵ�����
            circulation_num,doa,Hmin,Hdes,...PDD�������������ȣ���Сˮѹ����Ҫˮѹ
            Dp_Inspect_mat,Dp_Repair_mat,Dp_Travel_mat,...���ʱ�䣬�޸�ʱ�䣬�ƶ�ʱ��
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
        %         disp('����ģ��==����')
        %         % ���ʱ����ģ��
        %
        [random_Fitness_lowest,random_best_pop_lowest,random_BreakPipe_result_lowest,random_RepairCrew_result_lowest,...
            random_F_lowest,random_system_L_lowest,random_system_serviceability_lowest,random_node_serviceability_lowest,random_node2_serviceability_lowest,...
            random_node_calculate_dem_lowest,random_node_calculate_pre_lowest,random_timeStep_end_lowest] = random_priority(MC_simulate_result_dir_random,MC_i,...�ļ��У�ģ�����
            BreakPipe_order,RepairCrew,...�ƻ��ܵ����޸����飬
            damage_pipe_info,net_data_lowest,...�ƻ���Ϣ��������Ϣ��
            EPA_format,node_original_data_lowest,system_original_L_lowest,...EPA��ʽ���ڵ�ԭ�����ݣ�ϵͳԭ���ܵ�����
            circulation_num,doa,Hmin,Hdes,...PDD�������������ȣ���Сˮѹ����Ҫˮѹ
            Dp_Inspect_mat,Dp_Repair_mat,Dp_Travel_mat,...���ʱ�䣬�޸�ʱ�䣬�ƶ�ʱ��
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
        %         disp('����ģ��==����')
        %}
        % ����GA�Ż�
        %         disp('�������ģ��==����')
        
    else
        disp('no damage');
        continue
    end
end
toc
%% ����

mid = cell(0,1);
for i =1: numel(pop_cell)
    mid = merge_cell(mid,pop_cell{i},1);
    mid2{1,i} = ['��',num2str(i),'����']; 
end
mid3 = [mid2;mid(:,2:end)];
xlswrite([output_net_filename,'\�޸�����.xls'],mid3)
% ����
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
    mid1{i,1} = ['��',num2str(i),'����'];
end
mid1=[cell(1,1);mid1];
mid2={'EPS','��ߵ㵥��ģ��','��͵㵥��ģ��','ģ�ⲽ��'};
mid3 = [mid2;mid];
mid4 = [mid1,mid3];
xlswrite([output_net_filename,'\����ֵ.xls'],mid4)
mid4
% ��������
%  random_system_serviceability_cell_EPS
%  random_system_serviceability_cell_highest
%  random_system_serviceability_cell_lowest

mid = [];
mid1 =[];
mid2=[];
mid3=[];
mid4=[];
mid = {'ʱ�䲽','EPS','��ߵ㵥��ģ��','��͵㵥��ģ��','�'};
% random_timeStep_cell{i}
for i = 1:numel(random_system_serviceability_cell_EPS)
    mid1 = random_timeStep_cell{i}./3600;
    mid2 = rem(mid1,1);
    loc = find(mid2==0);
    mid2 = [random_system_serviceability_cell_EPS{i}(loc)',random_system_serviceability_cell_highest{i}(1:end-1)',random_system_serviceability_cell_lowest{i}(1:end-1)'];
    mid3 = [mid1(loc)',mid2];
    mid4 = [mid;[num2cell(mid3),random_activity_cell{i}(loc)']];
    xlswrite([output_net_filename,'\',num2str(i),'������ˮ����.xls'],mid4)
end
% �ܵ�������������
% random_system_L_cell_EPS
% random_system_L_cell_highest
% random_system_L_cell_lowest
mid = [];
mid1 =[];
mid2=[];
mid3=[];
mid4=[];
mid = {'ʱ�䲽','EPS','��ߵ㵥��ģ��','��͵㵥��ģ��','�'};
for i = 1:numel(random_system_serviceability_cell_EPS)
   
    mid1 = random_timeStep_cell{i}./3600;
    mid23 = rem(mid1,1);
    loc = find(mid23==0);
    mid2 = [random_system_L_cell_EPS{i}(loc)',random_system_L_cell_highest{i}(1:end-1)',random_system_L_cell_lowest{i}(1:end-1)'];
    mid3 = [mid1(loc)',mid2];
    mid4 = [mid;[num2cell(mid3),random_activity_cell{i}(loc)']];
    xlswrite([output_net_filename,'\',num2str(i),'�����ܵ���������.xls'],mid4)
end
%}
toc