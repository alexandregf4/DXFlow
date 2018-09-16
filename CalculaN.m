function [N] = CalculaN(k, m, dadosEntrada, estadosRede)

%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta fun��o calcula N para duas barras dadas, k e m.
%%%% A equa��o de c�lculo depende se k == m ou k ~= m.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 20/07/2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% OBS.: Fun��o ainda em fase de testes

%% C�lculo de N

N = 0;                                                              % Inicializa��o de N

if k == m                                                           % C�lculo de Nkk
%     [~, omegak] = PesquisaAdjacentes(k, dadosEntrada);             % Defini��o do conjunto omegak (barras adjacentes � barra k)
    [~, omegak] = ConjuntoOmegaK(k, dadosEntrada);    
    for x=1:length(omegak)
        % SOMATORIO Vm(Gkm*cos(thetakm) + Bkm*sin(thetakm))
        N = N + estadosRede.V(omegak(x)).*(dadosEntrada.G(k,omegak(x)).*cos(estadosRede.theta(k)-estadosRede.theta(omegak(x))) + dadosEntrada.B(k,omegak(x)).*sin(estadosRede.theta(k)-estadosRede.theta(omegak(x))));
    end
    % Vk * SOMATORIO
    N = 2.*estadosRede.V(k).*dadosEntrada.G(k,k) + N;                                        % Soma da parcela independente ao somat�rio da equa��o
    
else                                                                % C�lculo de Nkm
    % Vk*(Gkm*cos(thetakm) + Bkm*sin(thetakm))
    N = estadosRede.V(k).*(dadosEntrada.G(k,m).*cos(estadosRede.theta(k)-estadosRede.theta(m)) + dadosEntrada.B(k,m).*sin(estadosRede.theta(k)-estadosRede.theta(m)));
end
end