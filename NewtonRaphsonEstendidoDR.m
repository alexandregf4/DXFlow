function [estadosRede, Pcalc, Qcalc, iteracaoP, iteracaoQ, historicoConvergenciaP, historicoConvergenciaQ, mismatchesP, mismatchesQ, BP, BQ] = NewtonRaphsonEstendidoDR(auxiliar, config, dadosEntrada, estadosRede)

%% Cabe�alho
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta fun��o calcula os estados da rede pelo m�todo desacoplado r�pido
%%%% proposto no trabalho de Brian Stott. A vari�vel opcaoDesacoplado muda
%%%% a varia��o do m�todo, que pode ser:
%%%%
%%%% XX: B' = X     B'' = X
%%%% XB: B' = X     B'' = B (recomendado para melhor converg�ncia)
%%%% BX: B' = B     B'' = X (recomendado para melhor converg�ncia)
%%%% BB: B' = B     B'' = B
%%%%
%%%% No c�digo as matrizes B' e B'' s�o chamadas respectivamente de BP e
%%%% BQ.
%%%% A vers�o NS acrescenta a modelagem de chaves em n�vel de se��o de
%%%% barras.
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 12/04/2015
%%%% vNS - 13/06/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% C�lculo das inje��es de pot�ncia iniciais

[Pcalc, Qcalc] = CalculaEEFC2(dadosEntrada, estadosRede);                                   % C�lculo das Equa��es Est�ticas de Fluxo de Carga para as pot�ncias ativa e reativa
[mismatchesP, mismatchesQ, barrasMismatchesP, barrasMismatchesQ, ...
    tipoMismatchesP, tipoMismatchesQ, potenciaMismatchesP, ...
    potenciaMismatchesQ, variavelDeltaXP, ...
    variavelDeltaXQ] = MontaMismatchesDR4(Pcalc, Qcalc, dadosEntrada, estadosRede);         % Montagem dos vetores dos mismatches e xvar (vari�veis V e theta) para resolu��o por blocos

%% Montagem das matrizes B' e B''

[BP, BQ] = MontaBLinha4(auxiliar, dadosEntrada, barrasMismatchesP, barrasMismatchesQ, potenciaMismatchesP, variavelDeltaXP, potenciaMismatchesQ, variavelDeltaXQ);
BPinv = BP^-1;
BQinv = BQ^-1;

%% Resolu��o do SUBPROBLEMA 1 do fluxo de carga pelo m�todo de Newton-Raphson convencional
       
historicoConvergenciaP = [];
historicoConvergenciaQ = [];
iteracaoP = 0;
iteracaoQ = 0;
contadorP = 1;
contadorQ = 1;

while(norm([mismatchesP; mismatchesQ],Inf) > config.tolerancia)
    if auxiliar.tipoCalculo == 1
        fprintf('Itera��o P: %d\n',iteracaoP);
        fprintf('Norma infinita de P: %1.6f\n\n',norm(mismatchesP,Inf));
        fprintf('Itera��o Q: %d\n',iteracaoQ);
        fprintf('Norma infinita de Q: %1.6f\n\n',norm(mismatchesQ,Inf));
    end
    
    %%%% Erro caso n�mero m�ximo de itera��es seja atingido
    if iteracaoP >= config.maxIteracoes || iteracaoQ >= config.maxIteracoes
        if auxiliar.tipoCalculo == 1
            convergencia = figure;
            hold on;
            plot(historicoConvergenciaP(:,1),historicoConvergenciaP(:,2),'--ob');
            plot(historicoConvergenciaQ(:,1),historicoConvergenciaQ(:,2),'-*r');
            % title('Converg�ncia');
            xlabel('Itera��o');
            ylabel('Maior valor do vetor das diferen�as de pot�ncia');
            legend('Pot�ncia ativa','Pot�ncia reativa');
        end
        error('N�mero m�ximo de itera��es atingido! Itera��o P: %d Iteracao Q: %d\n\n', iteracaoP, iteracaoQ);
        return;
    end
        
    %%%% Atualiza��o da matriz admit�ncia
    if dadosEntrada.npqv ~= 0
        [dadosEntrada.Y, dadosEntrada.B, dadosEntrada.G] = montaY3(dadosEntrada);
    end
    
    %%%% Desacoplado r�pido com deslocamentos sucessivos
    
    %%%% Deslocamento em P
    deltaXP = BPinv*mismatchesP;
    [deltaTheta, deltaTkm] = RemontaVetorXP(dadosEntrada, variavelDeltaXP, barrasMismatchesP, deltaXP);
    estadosRede.theta = estadosRede.theta + deltaTheta;
    if ~isempty(dadosEntrada.linhasChaveaveis)
        estadosRede.t = SomaNaN(estadosRede.t,deltaTkm);                                        % Atualiza��o do vetor t  
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
        estadosRede.u = SomaNaN(estadosRede.u,deltaUkm);                                        % Atualiza��o do vetor u    
    end
    
%     fprintf('Norma dos mismatches de Q: %1.6f\n\n',norm(mismatchesQ,Inf));
    historicoConvergenciaQ(contadorQ,1) = iteracaoQ;                                                                                                    
    historicoConvergenciaQ(contadorQ,2) = norm(mismatchesQ,Inf);
    contadorQ = contadorQ + 1;
    iteracaoQ = iteracaoQ + 0.5;
        
    %%%% Atualiza��o das pot�ncias injetadas nas barras e da diferen�a entre P especificado e P calculado
    [Pcalc, Qcalc] = CalculaEEFC2(dadosEntrada, estadosRede);                                   % C�lculo das Equa��es Est�ticas de Fluxo de Carga para as pot�ncias ativa e reativa
    [mismatchesP, mismatchesQ, barrasMismatchesP, barrasMismatchesQ, ...
        tipoMismatchesP, tipoMismatchesQ, potenciaMismatchesP, ...
        potenciaMismatchesQ, variavelDeltaXP, ...
        variavelDeltaXQ] = MontaMismatchesDR4(Pcalc, Qcalc, dadosEntrada, estadosRede);         % Montagem dos vetores dos mismatches e xvar (vari�veis V e theta) para resolu��o por blocos
end
end