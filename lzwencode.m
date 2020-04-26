function [output,out_comb,table] = lzwencode(X)
%函数输入
% X ： 输入一维矩阵
%函数输出
% output ：压缩后的十进制码流
% out_comb :转换成二进制码流并且合并后在转换成十进制码流
% table ： 编码过程中形成的字串表

X=im2uint8(X);%im2uint将归一化后的数据映射到0-255
vector=double(X);

tmp.c=0;
tmp.lastCode=-1;
tmp.prefix=[];
tmp.codeLength=1;

%初始化字串表
function []=newTable

tmp.c=0;
tmp.lastCode=-1;
tmp.prefix=[];
tmp.codeLength=1;
table.nextCode=2;

table.codes(1:65538)=tmp;

for c=1:257
    tmp.c=c;
    tmp.lastCode=-1;
    tmp.prefix=[];
    tmp.codeLength=1;
    table.codes(table.nextCode)=tmp;
    table.nextCode=table.nextCode+1;
end;

end

%执行添加字串表项工作
    function []=addCode(lastCode,c)
        tmp.c=c;
        tmp.lastCode=lastCode;
        tmp.prefix=[];
        tmp.codeLength=table.codes(lastCode).codeLength+1;
        table.codes(table.nextCode)=tmp;
        table.codes(lastCode).prefix=[table.codes(lastCode).prefix table.nextCode];
        table.nextCode=table.nextCode+1;
    end

%执行查表操作
    function code=findCode(lastCode, c)
        if(isempty(lastCode))
            code=c+1;
            return; %遇到return直接跳出循环
        else
            ii=table.codes(lastCode).prefix;
            jj=find([table.codes(ii).c]==c);%不明白
            code = ii(jj);
            return;
        end;
        code=[];
        return;
    end

newTable;
output=vector;
outputIndex=1;

%输出LZW_CLEAR的索引
output(outputIndex)=256;
outputIndex=outputIndex +1;

s1=[];%相当于P
tic;%保存当前时间
for index=1:length(vector),
    code=findCode(s1,vector(index));
    if ~isempty(code) %矩阵为空则返回1
        s1=code;
    else
        output(outputIndex)=s1-1;
        outputIndex=outputIndex+1;
        
        addCode(s1,vector(index));%添加记号映射s1 + vector(index)
        
        s1=findCode([],vector(index));
    end;
end;

%输出最后的s1
output(outputIndex)=s1-1;
outputIndex=outputIndex+1;
%输出最后的LZW_EOI的索引值
output(outputIndex)=257;
output((outputIndex+1):end)=[];

table.codes=table.codes(1:table.nextCode-1);

%转换成二进制码流并且合并后再转换成的十进制码流，以便于写入文件
out_comb=[];
for i=1:floor(outputIndex/8)
    out_tmp=[];
    for j=1:8
        out_tmp=[out_tmp dec2binvec(output(i*8-8+j),9)];
    end
    for i=1:9
        out_comb=[out_comb binvec2dec(out_tmp(i*8-7:i*8))];
    end
end
out_tmp=[];
for i =floor(outputIndex/8)*8+1:outputIndex
    out_tmp=[out_tmp dec2binvec(output(i),9)];
end
length_tmp=length(out_tmp);
out_comb_tmp=zeros(1,floor(length_tmp/8)*8+8);
out_comb_tmp(1:length_tmp)=out_tmp;
for i=1:floor(length_tmp/8)+1
    out_comb=[out_comb binvec2dec(out_comb_tmp(i*8-7:i*8))];
end
end

