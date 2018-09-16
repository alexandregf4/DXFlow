function [L] = CalculaL(k, m, dadosEntrada, estadosRede)

%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta fun��o calcula L para duas barras dadas, k e m.
%%%% A equa��o de c�lculo depende se k == m ou k ~= m.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 20/07/2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% OBS.: Fun��o ainda em fase de testes

%% C�lculo de L

L = 0;                                                              % Inicializa��o de L

if k == m                                                           % C�lculo de Lkk
%     [~, omegak] = PesquisaAdjacentes(k, dadosEntrada);             % Defini��o do conjunto omegak (barras adjacentes � barra k)
    [~, omegak] = ConjuntoOmegaK(k, dadosEntrada);    
    for x=1:length(omegak)
        % SOMATORIO Vm(Gkm*sin(thetakm) - Bkm*cos(thetakm))
        L = L + estadosRede.V(omegak(x)).*(dadosEntrada.G(k,omegak(x)).*sin(estadosRede.theta(k)-estadosRede.theta(omegak(x))) - dadosEntrada.B(k,omegak(x)).*cos(estadosRede.theta(k)-estadosRede.theta(omegak(x))));
    end
    % Vk * SOMATORIO
    L = -2.*estadosRede.V(k).*dadosEntrada.B(k,k) + L;                                       % Soma da parcela independente ao somat�rio da equa��o
    
else                                                                % C�lculo de Lkm
    % Vk*(Gkm*sin(thetakm) - Bkm*cos(thetakm))
    L = estadosRede.V(k).*(dadosEntrada.G(k,m).*sin(estadosRede.theta(k)-estadosRede.theta(m)) - dadosEntrada.B(k,m).*cos(estadosRede.theta(k)-estadosRede.theta(m)));
end
end