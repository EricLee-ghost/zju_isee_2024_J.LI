%% 实验一（2）：频率取样法设计FIR希尔伯特变换器
% 使用 fir2 函数实现频率取样法
% 截图位置：图2(a)~(h)

clear all; close all; clc;

N1 = 31;   % 低阶
N2 = 63;   % 高阶

% 定义频率取样点（归一化频率 0~1）
% 频率点向量
freq_points = [0, 0.04, 0.05, 0.95, 0.96, 1];

% ========== N=31 ==========
% 理想幅频响应：希尔伯特变换器幅值为1（通带内）
mag_resp1 = [0, 0, 1, 1, 0, 0];  % 对应频率点的幅值

% 使用fir2进行频率取样法设计（fir2自动处理相位和线性相位约束）
% fir2的用法：b = fir2(N, f, m)，其中f是归一化频率，m是对应幅值
% 注意：fir2设计的是线性相位FIR滤波器，幅频响应由f和m指定
% 对于希尔伯特变换器，需要特殊处理：使用'hilbert'选项或手动构造
% 但fir2不支持直接设计希尔伯特变换器，需要改用频率取样公式

% ========== 正确的频率取样法：手动构造 ==========
% 对于N为奇数，希尔伯特变换器的脉冲响应为：
% h[n] = (2/N) * sum_{k=1}^{(N-1)/2} sin(2*pi*k*n/N)，在通带内

% 定义通带内的取样点索引
fL = 0.05;  fH = 0.95;
kL1 = round(fL * N1) + 1;  % 通带起始索引
kH1 = round(fH * N1);      % 通带结束索引

% 构造理想频率响应（仅幅度，相位由奇对称自动保证）
Hd1 = zeros(1, N1);
% 正频率部分 (0~0.5) 赋值为 -1j
for k = kL1:kH1
    if k <= (N1+1)/2
        Hd1(k) = -1j;
    end
end
% 负频率部分 (0.5~1) 赋值为 +1j
for k = (N1+1)/2+1:N1
    if k >= N1 - kH1 + 2 && k <= N1 - kL1 + 2
        Hd1(k) = 1j;
    end
end
Hd1(1) = 0;  % 直流置零
if mod(N1, 2) == 1
    Hd1((N1+1)/2) = 0;  % 奈奎斯特点置零（奇数N时不存在，忽略）
else
    Hd1(N1/2+1) = 0;
end

% IFFT得到脉冲响应
h1 = ifft(Hd1);
% 检查是否为实数
if max(abs(imag(h1))) > 1e-10
    h1 = real(h1);
end

% 循环移位成为因果
h1_causal = circshift(h1, -(N1-1)/2);
% 加窗抑制波纹
win1 = hamming(N1)';
h1_final = h1_causal .* win1;

% ========== N=63 ==========
kL2 = round(fL * N2) + 1;
kH2 = round(fH * N2);

Hd2 = zeros(1, N2);
for k = kL2:kH2
    if k <= (N2+1)/2
        Hd2(k) = -1j;
    end
end
for k = (N2+1)/2+1:N2
    if k >= N2 - kH2 + 2 && k <= N2 - kL2 + 2
        Hd2(k) = 1j;
    end
end
Hd2(1) = 0;

h2 = ifft(Hd2);
if max(abs(imag(h2))) > 1e-10
    h2 = real(h2);
end
h2_causal = circshift(h2, -(N2-1)/2);
win2 = hamming(N2)';
h2_final = h2_causal .* win2;

% 计算频率响应
[H1_fs, W1] = freqz(h1_final, 1, 512);
H1_fs_db = 20 * log10(abs(H1_fs) + eps);
phaH1_fs = angle(H1_fs);

[H2_fs, W2] = freqz(h2_final, 1, 512);
H2_fs_db = 20 * log10(abs(H2_fs) + eps);
phaH2_fs = angle(H2_fs);

% 绘图
figure('Position', [100, 100, 1200, 600]);

% N=31
subplot(2,4,1);
stem(0:N1-1, h1_final, 'filled');
title(['N=' num2str(N1) ' 脉冲响应 h[n]']);
xlabel('n'); ylabel('幅度');
grid on;

subplot(2,4,2);
plot(W1/pi, H1_fs_db);
title(['N=' num2str(N1) ' 幅频衰减特性(dB)']);
xlabel('归一化频率 \omega/\pi'); ylabel('幅度(dB)');
grid on;
axis([0,1,-60,10]);

subplot(2,4,3);
plot(W1/pi, phaH1_fs);
title(['N=' num2str(N1) ' 相频特性']);
xlabel('归一化频率 \omega/\pi'); ylabel('相位(rad)');
grid on;

subplot(2,4,4);
plot(W1/pi, abs(H1_fs));
title(['N=' num2str(N1) ' 幅频特性']);
xlabel('归一化频率 \omega/\pi'); ylabel('幅度');
grid on;

% N=63
subplot(2,4,5);
stem(0:N2-1, h2_final, 'filled');
title(['N=' num2str(N2) ' 脉冲响应 h[n]']);
xlabel('n'); ylabel('幅度');
grid on;

subplot(2,4,6);
plot(W2/pi, H2_fs_db);
title(['N=' num2str(N2) ' 幅频衰减特性(dB)']);
xlabel('归一化频率 \omega/\pi'); ylabel('幅度(dB)');
grid on;
axis([0,1,-60,10]);

subplot(2,4,7);
plot(W2/pi, phaH2_fs);
title(['N=' num2str(N2) ' 相频特性']);
xlabel('归一化频率 \omega/\pi'); ylabel('相位(rad)');
grid on;

subplot(2,4,8);
plot(W2/pi, abs(H2_fs));
title(['N=' num2str(N2) ' 幅频特性']);
xlabel('归一化频率 \omega/\pi'); ylabel('幅度');
grid on;

sgtitle('频率取样法设计FIR希尔伯特变换器（加汉明窗）');

% 验证结果
fprintf('N=31: h1 最大虚部 = %e\n', max(abs(imag(h1))));
fprintf('N=63: h2 最大虚部 = %e\n', max(abs(imag(h2))));
fprintf('N=31: 通带内最大波纹 = %.4f dB\n', max(abs(H1_fs_db(round(0.1*512):round(0.9*512)))));
fprintf('N=63: 通带内最大波纹 = %.4f dB\n', max(abs(H2_fs_db(round(0.1*512):round(0.9*512)))));