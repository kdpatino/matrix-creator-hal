%% CIC filter parameters %%%%%%
clear;
clc;

M = 1;              % Differential Delay
N = 3;              % Number of Stages
Fs = 3e6;           % (High) Sampling freq in Hz before decimation
Fd = 44.1e3;        % (Low) Sampling freq in Hz after decimation
R = round(Fs/Fd);   % Decimation factor

p = 1e3;
s = 0.25/p;

%%
L = 128;
% Normalization to Fo Output Frequency
Fc = 0.85;

B=14;

f_filter = [0:s:Fc];
f_lowpass = Fc+s:s:1;
f_comp = [f_filter f_lowpass];
m_filter = ones(1,length(f_filter));
m_filter(1)=1;
m_filter(2:end) = abs( R*M*sin(pi*f_filter(2:end)/R)./sin(pi*M*f_filter(2:end))).^N;
m_lowpass = zeros(1,length(f_lowpass));

m = [m_filter m_lowpass];
m_db = 20*log(m);
plot(f_comp,m_db)
%figure
coeff = fir2(L,f_comp,m);
%freqz(coeff,1,[],Fd);
%coeff= coeff/2;
coeffz = round(coeff*power(2,B-1)-1);

%% Generate coeff file
fid = fopen('coeff2.h','w');
fprintf(fid,'{');
fprintf(fid,'{ %d , { \n',Fd);
fprintf(fid,'%d\n',coeffz(2));
j=0;
for i = numel(coeffz):-1:3
  j=j+1;
  fprintf(fid,',%d \n',coeffz(i));
end
fprintf(fid,'}},\n',coeffz(i));
fclose(fid);

%%
Fc = Fd/2;
Fo = Fc/Fs

f = [0:s:1];
cic = (abs(sin(R*M*pi.*f)./(R*M*sin(pi.*f)))).^N;
cic(1) = 1;
cic_db = 20*log(cic);
Mp_db = 1./cic_db;

fp = [0:s:Fo];
ff = [Fo+s:s:2*Fo];
fc = [fp ff]

Mp = ones(1,length(fp));
Mp(1)=1;
Mp(2:end) = abs( R*M*sin(pi*fp(2:end))./sin(pi* R*M*fp(2:end))).^N;
Mf = flip(Mp);

Mc = [Mp Mf(2:end)];
Mc_lowpass = [Mp 1e-3.*ones(1,length(ff))];
Mc_db = 20*log(Mc);
Mc_lowpass_db = 20*log(Mc_lowpass);

figure;
plot(f,cic_db);
hold;
plot(fc,Mc_db,'--');
plot(fc,Mc_lowpass_db);
ylim([-100 100]);
title({'Designed Compensation Filter Response with', 'a Normalized Cutoff Frequency of (FS/R)/2'});
xlabel("Normalized Frequency Fs");
ylabel("Filter Magnitud Response DB");
legend({'CIC','CIC\_comp','CIC\_comp+lowpass'},'Location','southwest');
grid on

%%
fileData = fopen('mic_fir_example44100_raw_s16le_channel_0.raw');
%fileID = fopen('filter_matlab.raw','w','n');
coeff = fir1(L,0.95,'low');
dataRaw = fread(fileData,[1 44100*100],'int16');
result = filter(coeff,1,dataRaw);
freqz(coeff,1,[],44100);


figure;
plot(dataRaw); figure; plot(result);
%audiowrite('noise.wav',x/2^16,44100);
audiowrite('result.wav',result/2^16,44100);
%fwrite(fileID,result,'int16');
fclose(fileData);
%fclose(fileID);
%%

fileData = fopen('mic_44100_raw_s16le_channel_0.raw');
dataFilter = fread(fileData,[1 44100*5],'int16');
fileData = fopen('mic_fir_example44100_raw_s16le_channel_0.raw');
NoFilter = fread(fileData,[1 44100*5],'int16');
plot(NoFilter); hold; plot(dataFilter);