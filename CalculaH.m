function [H] = CalculaH(k, m, dadosEntrada, estadosRede)

%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta fun��o calcula H para duas barras dadas, k e m.
%%%% A equa��o de c�lculo depende se k == m ou k ~= m.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 20/07/2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% OBS.: Fun��o ainda em fase de testes

%% C�lculo de H

H = 0;                                                              % Inicializa��o de H

if k == m                                                           % C�lculo de Hkk
%     [~, omegak] = PesquisaAdjacentes(k, dadosEntrada);             % Defini��o do conjunto omegak (barras adjacentes � barra k)
    [~, omegak] = ConjuntoOmegaK(k, dadosEntrada);
    for x=1:length(omegak)
        % SOMATORIO Vm(-Gkm*sin(thetakm) + Bkm*cos(thetakm))
        H = H + estadosRede.V(omegak(x)).*(-dadosEntrada.G(k,omegak(x)).*sin(estadosRede.theta(k)-estadosRede.theta(omegak(x))) + dadosEntrada.B(k,omegak(x)).*cos(estadosRede.theta(k)-estadosRede.theta(omegak(x))));
    end
    % Vk * SOMATORIO
    H = estadosRede.V(k).*H;                                        % Multiplica��o do somat�rio por Vk
    
else                                                                % C�lculo de Hkm
    % Vk*Vm*(Gkm*sin(thetakm) - Bkm*cos(thetakm))
    H = estadosRede.V(k).*estadosRede.V(m).*(dadosEntrada.G(k,m).*sin(estadosRede.theta(k)-estadosRede.theta(m)) - dadosEntrada.B(k,m).*cos(estadosRede.theta(k)-estadosRede.theta(m)));
end
end