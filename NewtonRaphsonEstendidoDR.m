function [estadosRede, Pcalc, Qcalc, iteracaoP, iteracaoQ, historicoConvergenciaP, historicoConvergenciaQ, mismatchesP, mismatchesQ, BP, BQ] = NewtonRaphsonEstendidoDR(auxiliar, config, dadosEntrada, estadosRede)

%% Cabeçalho
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta função calcula os estados da rede pelo método desacoplado rápido
%%%% proposto no trabalho de Brian Stott. A variável opcaoDesacoplado muda
%%%% a variação do método, que pode ser:
%%%%
%%%% XX: B' = X     B'' = X
%%%% XB: B' = X     B'' = B (recomendado para melhor convergência)
%%%% BX: B' = B     B'' = X (recomendado para melhor convergência)
%%%% BB: B' = B     B'' = B
%%%%
%%%% No código as matrizes B' e B'' são chamadas respectivamente de BP e
%%%% BQ.
%%%% A versão NS acrescenta a modelagem de chaves em nível de seção de
%%%% barras.
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 12/04/2015
%%%% vNS - 13/06/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Cálculo das injeções de potência iniciais

[Pcalc, Qcalc] = CalculaEEFC2(dadosEntrada, estadosRede);                                   % Cálculo das Equações Estáticas de Fluxo de Carga para as potências ativa e reativa
[mismatchesP, mismatchesQ, barrasMismatchesP, barrasMismatchesQ, ...
    tipoMismatchesP, tipoMismatchesQ, potenciaMismatchesP, ...
    potenciaMismatchesQ, variavelDeltaXP, ...
    variavelDeltaXQ] = MontaMismatchesDR4(Pcalc, Qcalc, dadosEntrada, estadosRede);         % Montagem dos vetores dos mismatches e xvar (variáveis V e theta) para resolução por blocos

%% Montagem das matrizes B' e B''

[BP, BQ] = MontaBLinha4(auxiliar, dadosEntrada, barrasMismatchesP, barrasMismatchesQ, potenciaMismatchesP, variavelDeltaXP, potenciaMismatchesQ, variavelDeltaXQ);
BPinv = BP^-1;
BQinv = BQ^-1;

%% Resolução do SUBPROBLEMA 1 do fluxo de carga pelo método de Newton-Raphson convencional
       
historicoConvergenciaP = [];
historicoConvergenciaQ = [];
iteracaoP = 0;
iteracaoQ = 0;
contadorP = 1;
contadorQ = 1;

while(norm([mismatchesP; mismatchesQ],Inf) > config.tolerancia)
    if auxiliar.tipoCalculo == 1
        fprintf('Iteração P: %d\n',iteracaoP);
        fprintf('Norma infinita de P: %1.6f\n\n',norm(mismatchesP,Inf));
        fprintf('Iteração Q: %d\n',iteracaoQ);
        fprintf('Norma infinita de Q: %1.6f\n\n',norm(mismatchesQ,Inf));
    end
    
    %%%% Erro caso número máximo de iterações seja atingido
    if iteracaoP >= config.maxIteracoes || iteracaoQ >= config.maxIteracoes
        if auxiliar.tipoCalculo == 1
            convergencia = figure;
            hold on;
            plot(historicoConvergenciaP(:,1),historicoConvergenciaP(:,2),'--ob');
            plot(historicoConvergenciaQ(:,1),historicoConvergenciaQ(:,2),'-*r');
            % title('Convergência');
            xlabel('Iteração');
            ylabel('Maior valor do vetor das diferenças de potência');
            legend('Potência ativa','Potência reativa');
        end
        error('Número máximo de iterações atingido! Iteração P: %d Iteracao Q: %d\n\n', iteracaoP, iteracaoQ);
        return;
    end
        
    %%%% Atualização da matriz admitância
    if dadosEntrada.npqv ~= 0
        [dadosEntrada.Y, dadosEntrada.B, dadosEntrada.G] = montaY3(dadosEntrada);
    end
    
    %%%% Desacoplado rápido com deslocamentos sucessivos
    
    %%%% Deslocamento em P
    deltaXP = BPinv*mismatchesP;
    [deltaTheta, deltaTkm] = RemontaVetorXP(dadosEntrada, variavelDeltaXP, barrasMismatchesP, deltaXP);
    estadosRede.theta = estadosRede.theta + deltaTheta;
    if ~isempty(dadosEntrada.linhasChaveaveis)
        estadosRede.t = SomaNaN(estadosRede.t,deltaTkm);                                        % Atualização do vetor t  
    end
    
%     fprintf('Norma dos mismatches de P: %1.6f\n',norm(mismatchesP,Inf));
    historicoConvergenciaP(contadorP,1) = iteracaoP;                                                                                                    
    historicoConvergenciaP(contadorP,2) = norm(mismatchesP,Inf);                                                                                        
    contadorP = contadorP + 1;
    iteracaoP = iteracaoP + 0.5;
    
    %%%% Deslocamento em Q
    deltaXQ = BQinv*mismatchesQ;
    [deltaV, deltaAkm, deltaUkm] = RemontaVetorXQ(dadosEntrada, variavelDeltaXQ, dadosEntrada.linhasTrafosAutomaticos, barrasMismatchesQ, deltaXQ);
    estadosRede.V = estadosRede.V + deltaV;
    dadosEntrada.tap = dadosEntrada.tap + deltaAkm;
    if ~isempty(dadosEntrada.linhasChaveaveis)
        estadosRede.u = SomaNaN(estadosRede.u,deltaUkm);                                        % Atualização do vetor u    
    end
    
%     fprintf('Norma dos mismatches de Q: %1.6f\n\n',norm(mismatchesQ,Inf));
    historicoConvergenciaQ(contadorQ,1) = iteracaoQ;                                                                                                    
    historicoConvergenciaQ(contadorQ,2) = norm(mismatchesQ,Inf);
    contadorQ = contadorQ + 1;
    iteracaoQ = iteracaoQ + 0.5;
        
    %%%% Atualização das potências injetadas nas barras e da diferença entre P especificado e P calculado
    [Pcalc, Qcalc] = CalculaEEFC2(dadosEntrada, estadosRede);                                   % Cálculo das Equações Estáticas de Fluxo de Carga para as potências ativa e reativa
    [mismatchesP, mismatchesQ, barrasMismatchesP, barrasMismatchesQ, ...
        tipoMismatchesP, tipoMismatchesQ, potenciaMismatchesP, ...
        potenciaMismatchesQ, variavelDeltaXP, ...
        variavelDeltaXQ] = MontaMismatchesDR4(Pcalc, Qcalc, dadosEntrada, estadosRede);         % Montagem dos vetores dos mismatches e xvar (variáveis V e theta) para resolução por blocos
end
end