function [Pcalc, Qcalc] = ResolveSubProblema2(dadosEntrada, estadosRede, Pcalc, Qcalc)

Pcalc(isnan(Pcalc)) = 0;
Qcalc(isnan(Qcalc)) = 0;

for k=1:dadosEntrada.nb
   if dadosEntrada.tipoBarra(dadosEntrada.barras(k,1),1) == 1                                                       % Se barra VT, calcular Pk e Qk
       
%        [~, omega_k] = pesquisa_adjacentes(barras(k,1), A, linhas, barras);                              
    [~, omega_k] = ConjuntoOmegaK(dadosEntrada.barras(k,1), dadosEntrada);                                          % Definição do conjunto de barras adjacentes à barra k (omega_k)
    for m=1:length(omega_k)
           % SOMATÓRIO P: Vm[Gkm*cos(thetak - thetam) + Bkm*sin(thetak - thetam)]
           Pcalc(k,1) = Pcalc(k,1) + estadosRede.V(dadosEntrada.barras(omega_k(m))).*(dadosEntrada.G(dadosEntrada.barras(k),dadosEntrada.barras(omega_k(m))).*cos(estadosRede.theta(dadosEntrada.barras(k)) - estadosRede.theta(dadosEntrada.barras(omega_k(m)))) + dadosEntrada.B(dadosEntrada.barras(k),dadosEntrada.barras(omega_k(m))).*sin(estadosRede.theta(dadosEntrada.barras(k)) - estadosRede.theta(dadosEntrada.barras(omega_k(m)))));
           % SOMATÓRIO Q: Vm[Gkm*sin(thetak - thetam) - Bkm*cos(thetak - thetam)]
           Qcalc(k,1) = Qcalc(k,1) + estadosRede.V(dadosEntrada.barras(omega_k(m))).*(dadosEntrada.G(dadosEntrada.barras(k),dadosEntrada.barras(omega_k(m))).*sin(estadosRede.theta(dadosEntrada.barras(k)) - estadosRede.theta(dadosEntrada.barras(omega_k(m)))) - dadosEntrada.B(dadosEntrada.barras(k),dadosEntrada.barras(omega_k(m))).*cos(estadosRede.theta(dadosEntrada.barras(k)) - estadosRede.theta(dadosEntrada.barras(omega_k(m)))));
       end
       % Vk^2*Gkk + Vk * SOMATÓRIO P
       Pcalc(k,1) = estadosRede.V(dadosEntrada.barras(k,1),1).^2.*dadosEntrada.G(dadosEntrada.barras(k),dadosEntrada.barras(k)) + estadosRede.V(dadosEntrada.barras(k,1),1).*Pcalc(k,1);         % Multiplicação de Vk ao somatório
       % -Vk^2*Bkk + Vk * SOMATÓRIO Q
       Qcalc(k,1) = -estadosRede.V(dadosEntrada.barras(k,1),1).^2.*dadosEntrada.B(dadosEntrada.barras(k),dadosEntrada.barras(k)) + estadosRede.V(dadosEntrada.barras(k,1),1).*Qcalc(k,1);        % Multiplicação de Vk ao somatório
   
   elseif dadosEntrada.tipoBarra(dadosEntrada.barras(k,1),1) == 2                                                   % Se barra PV, calcular apenas Qk
%        [~, omega_k] = pesquisa_adjacentes(barras(k,1), A, linhas, barras);                              
       [~, omega_k] = ConjuntoOmegaK(dadosEntrada.barras(k,1), dadosEntrada);                                       % Definição do conjunto de barras adjacentes à barra k (omega_k)
       for m=1:length(omega_k)
           % SOMATÓRIO Q: Vm[Gkm*sin(thetak - thetam) - Bkm*cos(thetak - thetam)]
           Qcalc(k,1) = Qcalc(k,1) + estadosRede.V(dadosEntrada.barras(omega_k(m))).*(dadosEntrada.G(dadosEntrada.barras(k),dadosEntrada.barras(omega_k(m))).*sin(estadosRede.theta(dadosEntrada.barras(k)) - estadosRede.theta(dadosEntrada.barras(omega_k(m)))) - dadosEntrada.B(dadosEntrada.barras(k),dadosEntrada.barras(omega_k(m))).*cos(estadosRede.theta(dadosEntrada.barras(k)) - estadosRede.theta(dadosEntrada.barras(omega_k(m)))));
       end
       % -Vk^2*Bkk + Vk * SOMATÓRIO Q
       Qcalc(k,1) = -estadosRede.V(dadosEntrada.barras(k,1),1).^2.*dadosEntrada.B(dadosEntrada.barras(k),dadosEntrada.barras(k)) + estadosRede.V(dadosEntrada.barras(k,1),1).*Qcalc(k,1);        % Multiplicação de Vk ao somatório
   end
end


end