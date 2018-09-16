function [W] = CalculaW(k, linha_akm, dadosEntrada, estadosRede)

%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta função calcula W para duas barras dadas, k e m.
%%%% A equação de cálculo depende se k == m ou k ~= m.
%%%% A submatriz W se refere à derivada de P em relação a akm. Esta
%%%% submatriz é utilizada para cálculo do controle automático de tap
%%%% dentro do algoritmo Newton-Raphson.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 24/08/2014
%%%% v2 - 28/10/2014 / Correção dos índices e das equações das derivadas 
%%%% dPkm/dakm e dPmk/dakm.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% OBS.: Função ainda em fase de testes
%%%% OBS2.: linha_akm nesta função é um escalar!

%% Definição das variáveis

k_akm = dadosEntrada.de(dadosEntrada.linhas(linha_akm));                                                            % Barra k de akm
m_akm = dadosEntrada.para(dadosEntrada.linhas(linha_akm));                                                          % Barra m de akm

y = 1./complex(dadosEntrada.r,dadosEntrada.x);                                                                      % Vetor com as admitâncias série das linhas

akm = dadosEntrada.tap(dadosEntrada.linhas(linha_akm));                                                             % Valor de akm
amk = 1;                                                                                                            % Valor de amk

gkm = real(y(dadosEntrada.linhas(linha_akm)));                                                                      % Valor de gkm
bkm = imag(y(dadosEntrada.linhas(linha_akm)));                                                                      % Valor de bkm (série - linha)

Vk = estadosRede.V(dadosEntrada.de(dadosEntrada.linhas(linha_akm)));                                                % Valor de Vk
Vm = estadosRede.V(dadosEntrada.para(dadosEntrada.linhas(linha_akm)));                                              % Valor de Vm

thetakm = estadosRede.theta(dadosEntrada.de(dadosEntrada.linhas(linha_akm))) - estadosRede.theta(dadosEntrada.para(dadosEntrada.linhas(linha_akm)));    % Valor de theta km
thetamk = estadosRede.theta(dadosEntrada.para(dadosEntrada.linhas(linha_akm))) - estadosRede.theta(dadosEntrada.de(dadosEntrada.linhas(linha_akm)));    % Valor de theta mk

phikm = dadosEntrada.phi(dadosEntrada.linhas(linha_akm));                                                           % Valor de phi km
phimk = 0;                                                                                                          % Valor de phi mk

%% Cálculo de W

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% OBSERVAÇÃO:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% A injeção de potência na barra Pk é dada por:
%%%%
%%%% Pk = Pkm + Pkn + Pko + ...
%%%% 
%%%% Se o tap se encontra entre as barras k e m, sendo de k para m 1:a,
%%%% temos:
%%%%
%%%% dPk/dakm = dPkm/dakm
%%%%
%%%% Na situação inversa temos:
%%%%
%%%% Pm = Pmp + Pmq + Pmk + ...
%%%%
%%%% dPm/dakm = dPmk/dakm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if k == k_akm                       %                        1:a    
    % dPkm/dakm                     % Se P = Pk      Pk |----akm----| Pm
    
    W = 2*akm*Vk^2*gkm - Vk*Vm*(gkm*cos(thetakm + phikm) + bkm*sin(thetakm + phikm));
%     W = -Vm*Vk*(gkm*cos(thetamk + phimk) + bkm*sin(thetamk + phimk));
elseif k == m_akm                   %                        1:a
    % dPmk/dakm                     % Se P = Pm      Pk |----akm----| Pm
    
    W = -Vm*Vk*(gkm*cos(thetamk + phimk) + bkm*sin(thetamk + phimk));
%     W = 2*akm*Vk^2*gkm - Vk*Vm*(gkm*cos(thetakm + phikm) + bkm*sin(thetakm + phikm));
else
    
    W = 0;
       
end

% W = -W;
end