function [Z] = CalculaZ(k, linha_akm, dadosEntrada, estadosRede)

%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta fun��o calcula Z para duas barras dadas, k e m.
%%%% A equa��o de c�lculo depende se k == m ou k ~= m.
%%%% A submatriz Z se refere � derivada de Q em rela��o a akm. Esta
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

k_akm = dadosEntrada.de(dadosEntrada.linhas(linha_akm));                                              % Barra k de akm
m_akm = dadosEntrada.para(dadosEntrada.linhas(linha_akm));                                            % Barra m de akm

y = 1./complex(dadosEntrada.r,dadosEntrada.x);                                                        % Vetor com as admit�ncias s�rie das linhas

akm = dadosEntrada.tap(dadosEntrada.linhas(linha_akm));                                               % Valor de akm
amk = 1;                                                                    % Valor de amk

gkm = real(y(dadosEntrada.linhas(linha_akm)));                                           % Valor de gkm
bkm = imag(y(dadosEntrada.linhas(linha_akm)));                                           % Valor de bkm (s�rie - linha de transmiss�o)
bkm_shunt = dadosEntrada.b(dadosEntrada.linhas(linha_akm));                                           % Valor de bkm (shunt - linha de transmiss�o)

Vk = estadosRede.V(dadosEntrada.de(dadosEntrada.linhas(linha_akm)));                                              % Valor de Vk
Vm = estadosRede.V(dadosEntrada.para(dadosEntrada.linhas(linha_akm)));                                            % Valor de Vm

thetakm = estadosRede.theta(dadosEntrada.de(dadosEntrada.linhas(linha_akm))) - estadosRede.theta(dadosEntrada.para(dadosEntrada.linhas(linha_akm)));    % Valor de theta km
thetamk = estadosRede.theta(dadosEntrada.para(dadosEntrada.linhas(linha_akm))) - estadosRede.theta(dadosEntrada.de(dadosEntrada.linhas(linha_akm)));    % Valor de theta mk

phikm = dadosEntrada.phi(dadosEntrada.linhas(linha_akm));                                             % Valor de phi km
phimk = 0;                                                                  % Valor de phi mk

%% C�lculo de Z

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% OBSERVA��O:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% A inje��o de pot�ncia na barra Pk � dada por:
%%%%
%%%% Qk = Qkm + Qkn + Qko + ...
%%%% 
%%%% Se o tap se encontra entre as barras k e m, sendo de k para m 1:a,
%%%% temos:
%%%%
%%%% dQk/dakm = dQkm/dakm
%%%%
%%%% Na situa��o inversa temos:
%%%%
%%%% Qm = Qmp + Qmq + Qmk + ...
%%%%
%%%% dQm/dakm = dQmk/dakm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if k == k_akm                       %                        1:a    
    % dQkm/dakm                     % Se Q = Qk      Qk |----akm----| Qm
    
    Z = -2*akm*Vk^2*(bkm - bkm_shunt) - Vk*Vm*(gkm*sin(thetakm + phikm) - bkm*cos(thetakm + phikm));
%     Z = -Vm*Vk*(gkm*sin(thetamk + phimk) - bkm*cos(thetamk + phimk));
elseif k == m_akm                   %                        1:a
    % dQmk/dakm                     % Se Q = Qm      Qk |----akm----| Qm

    Z = -Vm*Vk*(gkm*sin(thetamk + phimk) - bkm*cos(thetamk + phimk));
%     Z = -2*akm*Vk^2*(bkm - bkm_shunt) - Vk*Vm*(gkm*sin(thetakm + phikm) - bkm*cos(thetakm + phikm));
else
    
    Z = 0;
       
end

% Z = -Z;
end