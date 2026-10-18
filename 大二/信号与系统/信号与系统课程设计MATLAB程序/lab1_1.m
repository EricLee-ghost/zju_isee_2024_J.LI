%% 实验一（1）：窗函数法设计FIR希尔伯特变换器
% 比较不同阶数（N=15与N=33）矩形窗设计的希尔伯特变换器

clear all; close all; clc;

N1 = 15;   % 低阶
N2 = 33;   % 高阶
Wc = pi/4;
wc = Wc/pi;   % 归一化截止频率

% 计算理想希尔伯特变换器的脉冲响应（非因果）
for n = -(N1-1)/2:(N1-1)/2
    k = n + (N1+1)/2;
    if k == (N1+1)/2
        hdn1(k) = 0;
    else
        hdn1(k) = 2 * sin(n*pi/2) * sin(n*pi/2) / (n*pi);
    end
end

for n = -(N2-1)/2:(N2-1)/2
    k = n + (N2+1)/2;
    if k == (N2+1)/2
        hdn2(k) = 0;
    else
        hdn2(k) = 2 * sin(n*pi/2) * sin(n*pi/2) / (n*pi);
    end
end

% 加矩形窗
wn1 = fir1(N1-1, wc, boxcar(N1));
wn2 = fir1(N2-1, wc, boxcar(N2));

hn1 = wn1' .* hdn1;
hn2 = wn2' .* hdn2;

% 计算频率响应
[H1, W] = freqz(hn1, 1, 512);
H1_db = 20 * log10(abs(H1));
phaH1 = angle(H1);

[H2, ~] = freqz(hn2, 1, 512);
H2_db = 20 * log10(abs(H2));
phaH2 = angle(H2);

% 绘图
figure('Position', [100, 100, 1200, 600]);

% N=15
subplot(2,4,1);
stem(0:N1-1, hn1, 'filled');
title('N=15 实际脉冲响应 h[n]');
xlabel('n'); ylabel('幅度');
grid on;

subplot(2,4,2);
plot(W/pi, H1_db);
title('N=15 幅频衰减特性(dB)');
xlabel('归一化频率 \omega/\pi'); ylabel('幅度(dB)');
grid on;
axis([0,1,-60,10]);

subplot(2,4,3);
plot(W/pi, phaH1);
title('N=15 相频特性');
xlabel('归一化频率 \omega/\pi'); ylabel('相位(rad)');
grid on;

subplot(2,4,4);
plot(W/pi, abs(H1));
title('N=15 幅频特性');
xlabel('归一化频率 \omega/\pi'); ylabel('幅度');
grid on;

% N=33
subplot(2,4,5);
stem(0:N2-1, hn2, 'filled');
title('N=33 实际脉冲响应 h[n]');
xlabel('n'); ylabel('幅度');
grid on;

subplot(2,4,6);
plot(W/pi, H2_db);
title('N=33 幅频衰减特性(dB)');
xlabel('归一化频率 \omega/\pi'); ylabel('幅度(dB)');
grid on;
axis([0,1,-60,10]);

subplot(2,4,7);
plot(W/pi, phaH2);
title('N=33 相频特性');
xlabel('归一化频率 \omega/\pi'); ylabel('相位(rad)');
grid on;

subplot(2,4,8);
plot(W/pi, abs(H2));
title('N=33 幅频特性');
xlabel('归一化频率 \omega/\pi'); ylabel('幅度');
grid on;

sgtitle('矩形窗FIR希尔伯特变换器：不同阶数对比');