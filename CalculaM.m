function [M] = CalculaM(k, m, dadosEntrada, estadosRede)

%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta fun��o calcula M para duas barras dadas, k e m.
%%%% A equa��o de c�lculo depende se k == m ou k ~= m.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 20/07/2014
%%%% v2 - 20/09/2014 / Adi��o de phikm como forma de generalizar o
%%%% equacionamento da derivada
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% OBS.: Fun��o ainda em fase de testes

%% C�lculo de M

M = 0;                                                              % Inicializa��o de M

if k == m                                                           % C�lculo de Mkk
%     [~, omegak] = PesquisaAdjacentes(k, dadosEntrada);             % Defini��o do conjunto omegak (barras adjacentes � barra k)
    [~, omegak] = ConjuntoOmegaK(k, dadosEntrada);    
    for x=1:length(omegak)
        % SOMATORIO Vm(Gkm*cos(thetakm) + Bkm*sin(thetakm))
        M = M + estadosRede.V(omegak(x)).*(dadosEntrada.G(k,omegak(x)).*cos(estadosRede.theta(k)-estadosRede.theta(omegak(x))) + dadosEntrada.B(k,omegak(x)).*sin(estadosRede.theta(k)-estadosRede.theta(omegak(x))));
    end
    % Vk * SOMATORIO
    M = estadosRede.V(k).*M;                                                    % Multiplica��o do somat�rio por Vk
    
else                                                                % C�lculo de Mkm
    % -Vk*Vm*(Gkm*cos(thetakm) + Bkm*sin(thetakm))
    M = -estadosRede.V(k).*estadosRede.V(m).*(dadosEntrada.G(k,m).*cos(estadosRede.theta(k)-estadosRede.theta(m)) + dadosEntrada.B(k,m).*sin(estadosRede.theta(k)-estadosRede.theta(m)));
end
end