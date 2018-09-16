function [Pcalc, Qcalc] = CalculaEEFC2(dadosEntrada, estadosRede)
%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Fun��o que calcula o valor das Equa��es Est�ticas de Fluxo de Carga
%%%% para P e Q a partir dos dados de V, theta, G e B (matriz Y).
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 14/07/2014
%%%% v2 - 30/05/2015 / Adicionado balan�o de pot�ncia para ramos chave�veis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Inicializa��o das vari�veis em zero

Pcalc = zeros(dadosEntrada.nb,1);                                    
Qcalc = zeros(dadosEntrada.nb,1);

%% C�lculo de Pcalc e Qcalc

for k=1:dadosEntrada.nb
   if dadosEntrada.tipoBarra(dadosEntrada.barras(k,1),1) ~= 1                    % Se N�O for a barra VT
       [~, barrasAdjacentes] = ConjuntoOmegaK(k, dadosEntrada);
       for m=1:length(barrasAdjacentes)
           % SOMAT�RIO P: Vm[Gkm*cos(thetak - thetam) + Bkm*sin(thetak - thetam)]
           Pcalc(k,1) = Pcalc(k,1) + estadosRede.V(dadosEntrada.barras(barrasAdjacentes(m))).*(dadosEntrada.G(dadosEntrada.barras(k),dadosEntrada.barras(barrasAdjacentes(m))).*cos(estadosRede.theta(dadosEntrada.barras(k)) - estadosRede.theta(dadosEntrada.barras(barrasAdjacentes(m)))) + dadosEntrada.B(dadosEntrada.barras(k),dadosEntrada.barras(barrasAdjacentes(m))).*sin(estadosRede.theta(dadosEntrada.barras(k)) - estadosRede.theta(dadosEntrada.barras(barrasAdjacentes(m)))));
           if dadosEntrada.tipoBarra(dadosEntrada.barras(k,1),1) == 2            % Se a barra for PV
               Qcalc(k,1) = nan;                        % Coloca NaN na posi��o correspondente (N�O H� Q ESPECIFICADO)
           else                                         % Se a barra N�O for PV (Possui Q especificado)
               % SOMAT�RIO Q: Vm[Gkm*sin(thetak - thetam) - Bkm*cos(thetak - thetam)]
               Qcalc(k,1) = Qcalc(k,1) + estadosRede.V(dadosEntrada.barras(barrasAdjacentes(m))).*(dadosEntrada.G(dadosEntrada.barras(k),dadosEntrada.barras(barrasAdjacentes(m))).*sin(estadosRede.theta(dadosEntrada.barras(k)) - estadosRede.theta(dadosEntrada.barras(barrasAdjacentes(m)))) - dadosEntrada.B(dadosEntrada.barras(k),dadosEntrada.barras(barrasAdjacentes(m))).*cos(estadosRede.theta(dadosEntrada.barras(k)) - estadosRede.theta(dadosEntrada.barras(barrasAdjacentes(m)))));
           end
       end
       % Vk^2*Gkk + Vk * SOMAT�RIO P
       Pcalc(k,1) = estadosRede.V(dadosEntrada.barras(k,1),1).^2.*dadosEntrada.G(dadosEntrada.barras(k),dadosEntrada.barras(k)) + estadosRede.V(dadosEntrada.barras(k,1),1).*Pcalc(k,1);       % Multiplica��o de Vk ao somat�rio
       if dadosEntrada.tipoBarra(dadosEntrada.barras(k,1),1) ~= 2                % Se a barra N�O for PV (Possui Q especificado)
           % -Vk^2*Bkk + Vk * SOMAT�RIO Q
           Qcalc(k,1) = -estadosRede.V(dadosEntrada.barras(k,1),1).^2.*dadosEntrada.B(dadosEntrada.barras(k),dadosEntrada.barras(k)) + estadosRede.V(dadosEntrada.barras(k,1),1).*Qcalc(k,1);   % Multiplica��o de Vk ao somat�rio
       end
       
       %%%% Adi��o dos fluxos dos ramos chave�veis �s pot�ncias calculadas
       %%%% (balan�o de pot�ncia nas barras)
       
       [linhasAdjacentesChaveaveis, ~] = ConjuntoTauK(k, dadosEntrada);
       
       if ~isempty(linhasAdjacentesChaveaveis)
           for l=1:length(linhasAdjacentesChaveaveis)
               if k == dadosEntrada.de(linhasAdjacentesChaveaveis(l,1))
                   Pcalc(k,1) = Pcalc(k,1) + estadosRede.t(linhasAdjacentesChaveaveis(l,1));
                   Qcalc(k,1) = Qcalc(k,1) + estadosRede.u(linhasAdjacentesChaveaveis(l,1));
               elseif k == dadosEntrada.para(linhasAdjacentesChaveaveis(l,1))
                   Pcalc(k,1) = Pcalc(k,1) - estadosRede.t(linhasAdjacentesChaveaveis(l,1));
                   Qcalc(k,1) = Qcalc(k,1) - estadosRede.u(linhasAdjacentesChaveaveis(l,1));
               else
                   error('Erro: Linha chave�vel do conjunto tauk sem DE nem PARA');
               end
           end
       end
   else
       Pcalc(k,1) = nan;
       Qcalc(k,1) = nan;
   end
end
end