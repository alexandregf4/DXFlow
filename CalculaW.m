function [W] = CalculaW(k, linha_akm, dadosEntrada, estadosRede)

%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta fun��o calcula W para duas barras dadas, k e m.
%%%% A equa��o de c�lculo depende se k == m ou k ~= m.
%%%% A submatriz W se refere � derivada de P em rela��o a akm. Esta
%%%% submatriz � utilizada para c�lculo do controle autom�tico de tap
%%%% dentro do algoritmo Newton-Raphson.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 24/08/2014
%%%% v2 - 28/10/2014 / Corre��o dos �ndices e das equa��es das derivadas 
%%%% dPkm/dakm e dPmk/dakm.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% OBS.: Fun��o ainda em fase de testes
%%%% OBS2.: linha_akm nesta fun��o � um escalar!

%% Defini��o das vari�veis

k_akm = dadosEntrada.de(dadosEntrada.linhas(linha_akm));                                                            % Barra k de akm
m_akm = dadosEntrada.para(dadosEntrada.linhas(linha_akm));                                                          % Barra m de akm

y = 1./complex(dadosEntrada.r,dadosEntrada.x);                                                                      % Vetor com as admit�ncias s�rie das linhas

akm = dadosEntrada.tap(dadosEntrada.linhas(linha_akm));                                                             % Valor de akm
amk = 1;                                                                                                            % Valor de amk

gkm = real(y(dadosEntrada.linhas(linha_akm)));                                                                      % Valor de gkm
bkm = imag(y(dadosEntrada.linhas(linha_akm)));                                                                      % Valor de bkm (s�rie - linha)

Vk = estadosRede.V(dadosEntrada.de(dadosEntrada.linhas(linha_akm)));                                                % Valor de Vk
Vm = estadosRede.V(dadosEntrada.para(dadosEntrada.linhas(linha_akm)));                                              % Valor de Vm

thetakm = estadosRede.theta(dadosEntrada.de(dadosEntrada.linhas(linha_akm))) - estadosRede.theta(dadosEntrada.para(dadosEntrada.linhas(linha_akm)));    % Valor de theta km
thetamk = estadosRede.theta(dadosEntrada.para(dadosEntrada.linhas(linha_akm))) - estadosRede.theta(dadosEntrada.de(dadosEntrada.linhas(linha_akm)));    % Valor de theta mk

phikm = dadosEntrada.phi(dadosEntrada.linhas(linha_akm));                                                           % Valor de phi km
phimk = 0;                                                                                                          % Valor de phi mk

%% C�lculo de W

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% OBSERVA��O:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% A inje��o de pot�ncia na barra Pk � dada por:
%%%%
%%%% Pk = Pkm + Pkn + Pko + ...
%%%% 
%%%% Se o tap se encontra entre as barras k e m, sendo de k para m 1:a,
%%%% temos:
%%%%
%%%% dPk/dakm = dPkm/dakm
%%%%
%%%% Na situa��o inversa temos:
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