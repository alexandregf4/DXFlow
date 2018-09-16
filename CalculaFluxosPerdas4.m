function [Pkm, Qkm, PkmPerdas, Pperdas, PperdasPerc, QkmPerdas, Qperdas, QperdasPerc] = CalculaFluxosPerdas4(dadosEntrada, estadosRede)

%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta função calcula os fluxos ativos (t) e reativos (u) em todos os 
%%%% ramos do sistema nas duas direções (km e mk). As perdas são
%%%% contabilizadas pela soma dos fluxos em ambas as direções e são
%%%% exibidas em número absoluto (pu) ou relativo em relação à demanda
%%%% aparente total (S).
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%%
%%%% v1 - 17/08/2014
%%%% v2 - 20/09/2014 / Correção das equações de fluxo, adição do tap ao
%%%% equacionamento.
%%%% v3 - 02/06/2015 / Adição dos ramos chaveáveis.
%%%% v4 - 11/07/2015 / Rotação inversa implementada.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Rotação inversa das impedâncias

if dadosEntrada.anguloPotenciaBase ~= 0
    
    zb = (dadosEntrada.VbaseLinha.^2.*1000)./dadosEntrada.moduloPotenciaBase;
    zcpu = sqrt(dadosEntrada.r.^2 + dadosEntrada.x.^2);
    angulo_cpu = acos(dadosEntrada.r./zcpu);
    
    dadosEntrada.r = zcpu.*zb.*cos(angulo_cpu - dadosEntrada.anguloPotenciaBase);       % R (ohm)
    dadosEntrada.x = zcpu.*zb.*sin(angulo_cpu - dadosEntrada.anguloPotenciaBase);       % X (ohm)
    
%% Rotação inversa dos fluxos em ramos chaveáveis
    
    if ~isempty(dadosEntrada.linhasChaveaveis)
        
        Skmcpu = sqrt(estadosRede.t.^2 + estadosRede.u.^2);
        
        for k=1:dadosEntrada.nl
            if ~isnan(Skmcpu(k,1))
                if Skmcpu(k,1) ~= 0
                    if estadosRede.t(k,1) > 0 && estadosRede.u(k,1) > 0
                        angulo_skmcpu(k,1) = acos(estadosRede.t(k,1)./Skmcpu(k,1));
                    elseif estadosRede.t(k,1) < 0 && estadosRede.u(k,1) < 0
                        angulo_skmcpu(k,1) = -acos(estadosRede.t(k,1)./Skmcpu(k,1));
                    elseif estadosRede.t(k,1) > 0 && estadosRede.u(k,1) < 0
                        angulo_skmcpu(k,1) = -acos(estadosRede.t(k,1)./Skmcpu(k,1));
                    elseif estadosRede.t(k,1) < 0 && estadosRede.u(k,1) > 0
                        angulo_skmcpu(k,1) = acos(estadosRede.t(k,1)./Skmcpu(k,1));
                    end
                else
                    angulo_skmcpu(k,1) = 0;
                end
            else
                angulo_skmcpu(k,1) = NaN;
            end
        end
        
        estadosRede.t = Skmcpu.*dadosEntrada.moduloPotenciaBase.*cos(angulo_skmcpu - dadosEntrada.anguloPotenciaBase);
        estadosRede.u = Skmcpu.*dadosEntrada.moduloPotenciaBase.*sin(angulo_skmcpu - dadosEntrada.anguloPotenciaBase);
        
    end
else
    zb = (dadosEntrada.VbaseLinha.^2.*1000)./dadosEntrada.moduloPotenciaBase;
    dadosEntrada.r = dadosEntrada.r.*zb;
    dadosEntrada.x = dadosEntrada.x.*zb;
end

%% Cálculo dos fluxos ativo (Pkm) e reativo (Qkm) nas linhas do sistema

gkm = real(1./complex(dadosEntrada.r,dadosEntrada.x));
bkm = imag(1./complex(dadosEntrada.r,dadosEntrada.x));

for p=1:dadosEntrada.nl
    
    if ~isempty(find(dadosEntrada.linhasChaveaveis == p))
        
        Pkm(p,1) = estadosRede.t(dadosEntrada.linhasChaveaveis(find(dadosEntrada.linhasChaveaveis == p)));
        Pmk(p,1) = -estadosRede.t(dadosEntrada.linhasChaveaveis(find(dadosEntrada.linhasChaveaveis == p)));
        Qkm(p,1) = estadosRede.u(dadosEntrada.linhasChaveaveis(find(dadosEntrada.linhasChaveaveis == p)));
        Qmk(p,1) = -estadosRede.u(dadosEntrada.linhasChaveaveis(find(dadosEntrada.linhasChaveaveis == p)));
        
    else
        
        %%%% Definição das variáveis (facilitar a equação)
        
        akm = dadosEntrada.tap(dadosEntrada.linhas(p));                   % 1 : a -> akm
        amk = 1;                                % a : 1 -> amk
        
        gkm_linha = gkm(dadosEntrada.linhas(p));
        bkm_linha = bkm(dadosEntrada.linhas(p));
        bkm_shunt = dadosEntrada.b(dadosEntrada.linhas(p));
        
        Vk = estadosRede.V(dadosEntrada.de(dadosEntrada.linhas(p))).*dadosEntrada.VbaseLinha(dadosEntrada.linhas(p)).*1000;
        Vm = estadosRede.V(dadosEntrada.para(dadosEntrada.linhas(p))).*dadosEntrada.VbaseLinha(dadosEntrada.linhas(p)).*1000;
        
        thetakm = estadosRede.theta(dadosEntrada.de(dadosEntrada.linhas(p))) - estadosRede.theta(dadosEntrada.para(dadosEntrada.linhas(p)));
        thetamk = estadosRede.theta(dadosEntrada.para(dadosEntrada.linhas(p))) - estadosRede.theta(dadosEntrada.de(dadosEntrada.linhas(p)));
        
        phikm = dadosEntrada.phi(dadosEntrada.linhas(p));
        phimk = 0;
        
        %%%% Equaçoes dos fluxos de potência ativa [kW]
        
        Pkm(p,1) = ((akm*Vk)^2*gkm_linha - akm*Vk*Vm*(gkm_linha*cos(thetakm + phikm) + bkm_linha*sin(thetakm + phikm)))./1000;
        Pmk(p,1) = ((amk*Vm)^2*gkm_linha - akm*Vm*Vk*(gkm_linha*cos(thetamk + phimk) + bkm_linha*sin(thetamk + phimk)))./1000;
        
        %%%% Equações dos fluxos de potência reativa [kVAr]
        
        Qkm(p,1) = (-(akm*Vk)^2*(bkm_linha - bkm_shunt) - akm*Vk*Vm*(gkm_linha*sin(thetakm + phikm) - bkm_linha*cos(thetakm + phikm)))./1000;
        Qmk(p,1) = (-(amk*Vm)^2*(bkm_linha - bkm_shunt) - akm*Vm*Vk*(gkm_linha*sin(thetamk + phimk) - bkm_linha*cos(thetamk + phimk)))./1000;
        
    end
        
end

%% Cálculo das perdas ativas e reativas do sistema

Pperdas = sum(Pkm + Pmk);
Qperdas = sum(Qkm + Qmk);
PkmPerdas = Pkm + Pmk;
QkmPerdas = Qkm + Qmk;

P = sum(dadosEntrada.Pd(dadosEntrada.Pd > 0));
Q = sum(dadosEntrada.Qd(dadosEntrada.Qd > 0));
S = sqrt(P.^2+Q.^2);

PperdasPerc = (Pperdas./P).*100;
QperdasPerc = (Qperdas./S).*100;

end