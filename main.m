%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%用于函数逼近的RBF神经网络
% 采用单输入单输出的3层BP网络
%基于聚类方法，RBF网隐层采用标准gaussian径向基函数，输出层采用线性激活函数即f(u)=u
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function main()
clear;
SamNum=100;                                                  %训练样本数
TestSamNum=101;                                              %测试样本数
ClusterNum=10;                                               %隐藏节点，即聚类样本数
InDim=1;                                                     %样本输入维数
OutDim=1;                                                    %样本输出维数
Overlap=1;                                                   %隐节点重叠洗漱

% 导入Excel数据
data = readtable('数据1.xlsx');
SamIn = table2array(data(:, 1:6)); 
SamOut = table2array(data(:, 7)); % 假设第7列是输出

%%根据目标函数获得样本输入输出
rand('state',sum(100*clock));
NoiseVar=0.1;
noise=NoiseVar*randn(1,SamNum);
SamIn=8*rand(1,SamNum)-4;
SamOutNoNoise=1.1*(1-SamIn+2*SamIn.^2).*exp(-SamIn.^2/2);
SamOut=SamOutNoNoise+noise;
TestSamIn=-4:0.08:4;
TestSamOut=1.1*(1-TestSamIn+2*TestSamIn.^2).*exp(-TestSamIn.^2/2);
hold on;
grid
plot(SamIn,SamOut,'k+');
plot(TestSamIn,TestSamOut,'k--');
xlabel('Input x');
ylabel('Output y');

%%RBF神经网络部分
Centers=SamIn(:,1:ClusterNum);
NumberInClusters=zeros(ClusterNum,1);               %各类中的样本数，初始化为零
IndexClusters=zeros(ClusterNum,SamNum);             %各类所含样本的索引号
while 1,
    NumberInClusters=zeros(ClusterNum,1);           %各类中的样本数，初始化为零
    IndexClusters=zeros(ClusterNum,SamNum);         %各类所含样本的索引号
    %按最小距离原则对所有的样本进行分类
    for i=1:SamNum
        AllDistance=dist(Centers',SamIn(:,i));
        [MinDist,Pos]=min(AllDistance);
        NumberInClusters(Pos)=NumberInClusters(Pos)+1;
        IndexInClusters(Pos,NumberInClusters(Pos))=i;
    end
    
   %保存旧的聚类中心
   OldCenters=Centers;
   
   %保存旧的聚类中心
   for i=1:ClusterNum
       Index=IndexInClusters(i,1:NumberInClusters(i));
       Centers(:,i)=mean(SamIn(:,Index)')';
   end
     
   %判断新旧聚类中心是否一致，如果是，则结束聚类
   EqualNum=sum(sum(Centers==OldCenters));
   if EqualNum==InDim*ClusterNum,break,end
end

%计算各隐节点的扩展常数(宽度)
AllDistances=dist(Centers',Centers);    %计算隐节点数据中心的距离（矩阵）
Maximum=max(max(AllDistances));         %找出其中最大的一个距离
for i=1:ClusterNum                      %将对角线上的0替换为较大的值
    AllDistances(i,i)=Maximum+1;
end
Spreads=Overlap*min(AllDistances)';     %以隐节点的最小距离为扩展常数

% 计算各隐节点的输出权值
Distance=dist(Centers',SamIn);          %计算各样本输入离各数据中心的距离
SpreadsMat=repmat(Spreads,1,SamNum);
HiddenUnitOut=radbas(Distance./SpreadsMat);                %计算隐节点输阵
HiddenUnitOutEx=[HiddenUnitOut' ones(SamNum,1)]';          %考虑偏移
W2Ex=SamOut*pinv(HiddenUnitOutEx);                         %求广义输出权值
W2=W2Ex(:,1:ClusterNum);                                  %输出权值
B2=W2Ex(:,ClusterNum+1)                                   %偏移;

% 测试
TestDistance=dist(Centers',TestSamIn);
TestSpreadsMat=repmat(Spreads,1,TestSamNum);
TestHiddenUnitOut=radbas(TestDistance./TestSpreadsMat);
TestNNOut= W2*TestHiddenUnitOut+B2;
plot(TestSamIn,TestNNOut,'r-.')

W2
B2