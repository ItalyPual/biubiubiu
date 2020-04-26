function [output,out_comb,table] = lzwencode(X)
%��������
% X �� ����һά����
%�������
% output ��ѹ�����ʮ��������
% out_comb :ת���ɶ������������Һϲ�����ת����ʮ��������
% table �� ����������γɵ��ִ���

X=im2uint8(X);%im2uint����һ���������ӳ�䵽0-255
vector=double(X);

tmp.c=0;
tmp.lastCode=-1;
tmp.prefix=[];
tmp.codeLength=1;

%��ʼ���ִ���
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

%ִ������ִ������
    function []=addCode(lastCode,c)
        tmp.c=c;
        tmp.lastCode=lastCode;
        tmp.prefix=[];
        tmp.codeLength=table.codes(lastCode).codeLength+1;
        table.codes(table.nextCode)=tmp;
        table.codes(lastCode).prefix=[table.codes(lastCode).prefix table.nextCode];
        table.nextCode=table.nextCode+1;
    end

%ִ�в�����
    function code=findCode(lastCode, c)
        if(isempty(lastCode))
            code=c+1;
            return; %����returnֱ������ѭ��
        else
            ii=table.codes(lastCode).prefix;
            jj=find([table.codes(ii).c]==c);%������
            code = ii(jj);
            return;
        end;
        code=[];
        return;
    end

newTable;
output=vector;
outputIndex=1;

%���LZW_CLEAR������
output(outputIndex)=256;
outputIndex=outputIndex +1;

s1=[];%�൱��P
tic;%���浱ǰʱ��
for index=1:length(vector),
    code=findCode(s1,vector(index));
    if ~isempty(code) %����Ϊ���򷵻�1
        s1=code;
    else
        output(outputIndex)=s1-1;
        outputIndex=outputIndex+1;
        
        addCode(s1,vector(index));%��ӼǺ�ӳ��s1 + vector(index)
        
        s1=findCode([],vector(index));
    end;
end;

%�������s1
output(outputIndex)=s1-1;
outputIndex=outputIndex+1;
%�������LZW_EOI������ֵ
output(outputIndex)=257;
output((outputIndex+1):end)=[];

table.codes=table.codes(1:table.nextCode-1);

%ת���ɶ������������Һϲ�����ת���ɵ�ʮ�����������Ա���д���ļ�
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

