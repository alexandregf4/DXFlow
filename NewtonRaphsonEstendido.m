function [estadosRede, dadosEntrada, Pcalc, Qcalc, iteracao, historicoConvergencia, mismatches, J] = NewtonRaphsonEstendido(dadosEntrada, estadosRede, config, auxiliar)

%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Fun��o que resolve o Subproblema 1 pelo m�todo Newton-Raphson
%%%% convencional. Esta fun��o tamb�m trata os ramos chave�veis conforme a
%%%% t�cnica de n�vel de se��o de barras (se houverem).
%%%%
%%%% Alexandre Gomes Fonseca
%%%% vNS - 10/05/2015 / N�vel de Subesta��o adicionado
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% C�lculo das inje��es de pot�ncia iniciais

[Pcalc, Qcalc] = CalculaEEFC2(dadosEntrada, estadosRede);                                                                                               % C�lculo das Equa��es Est�ticas de Fluxo de Carga para as pot�ncias ativa e reativa
[mismatches, barrasDeltaPQ, tipoDeltaPQ, potenciaDeltaPQ, variavelDeltaX] = MontaMismatches3(dadosEntrada, estadosRede, Pcalc, Qcalc);                  % Montagem dos vetores dos mismatches e xvar (vari�veis V e theta) para resolu��o por blocos

%% Resolu��o do SUBPROBLEMA 1 do fluxo de carga pelo m�todo de Newton-Raphson convencional

historicoConvergencia = [];
iteracao = 0;

while(norm(mismatches,Inf) > config.tolerancia)
    if auxiliar.tipoCalculo == 1
        fprintf('Itera��o: %d\n',iteracao);
        fprintf('Norma infinita: %1.6f\n\n',norm(mismatches,Inf));
    end
    
    %%%% Erro caso n�mero m�ximo de itera��es seja atingido
    if iteracao >= config.maxIteracoes
        if auxiliar.tipoCalculo == 1
            convergencia = figure;
            plot(historicoConvergencia(:,1),historicoConvergencia(:,2),'-or');
            title('Converg�ncia');
            xlabel('Itera��o');
            ylabel('Norma infinita de delta P');
        end
        error('N�mero m�ximo de itera��es atingido: %d\n\n', iteracao);
        return;
    end
    
    %%%% Atualiza��o da matriz admit�ncia
    if dadosEntrada.npqv ~= 0
        [dadosEntrada.Y, dadosEntrada.B, dadosEntrada.G] = montaY3(dadosEntrada);
    end
    
    %%%% Montagem da matriz Jacobiana
    J = MontaJBlocos3(dadosEntrada, estadosRede, barrasDeltaPQ, potenciaDeltaPQ, variavelDeltaX);
    
    %%%% Resolu��o do sistema linear
    xvar = J\mismatches;
    
    %%%% Atualiza��o das vari�veis
    [deltaTheta, deltaV, deltaAkm, deltaTkm, deltaUkm] = RemontaVetores3(dadosEntrada, variavelDeltaX, barrasDeltaPQ, xvar);                            % Transforma��o do vetor xvar (2*npq + 2*npqv + npv x 1) (em blocos) para theta, V (nb x 1) e akm (nl x 1)
    
    estadosRede.theta = estadosRede.theta + deltaTheta;                                                                                                 % Atualiza��o do vetor theta (�ngulos das tens�es)
    estadosRede.V = estadosRede.V + deltaV;                                                                                                             % Atualiza��o do vetor V (m�dulos das tens�es)
    dadosEntrada.tap = dadosEntrada.tap + deltaAkm;                                                                                                     % Atualiza��o do vetor tap (m�dulos dos taps dos transformadores)
    if ~isempty(estadosRede.t) && ~isempty(estadosRede.u)
        estadosRede.t = SomaNaN(estadosRede.t,deltaTkm);                                                                                                % Atualiza��o do vetor t                                                                                                                                                                 
        estadosRede.u = SomaNaN(estadosRede.u,deltaUkm);                                                                                                % Atualiza��o do vetor u
    end
        
    %%%% Atualiza��o da contagem de itera��es
    historicoConvergencia(iteracao+1,1) = iteracao;                                                                                                     % Grava��o da itera��o atual na matriz de hist�rico de converg�ncia
    historicoConvergencia(iteracao+1,2) = norm(mismatches,Inf);                                                                                         % Grava��o do valor da norma na matriz de hist�rico de converg�ncia
    iteracao = iteracao + 1;                                                                                                                            % Atualiza��o da contagem de itera��es
    
    %%%% Atualiza��o das pot�ncias injetadas nas barras e da diferen�a entre P especificado e P calculado
    [Pcalc, Qcalc] = CalculaEEFC2(dadosEntrada, estadosRede);                                                                                           % C�lculo das Equa��es Est�ticas de Fluxo de Carga para as pot�ncias ativa e reativa
    [mismatches, barrasDeltaPQ, tipoDeltaPQ, potenciaDeltaPQ, variavelDeltaX] = MontaMismatches3(dadosEntrada, estadosRede, Pcalc, Qcalc);              % Montagem dos vetores dos mismatches e xvar (vari�veis V e theta) para resolu��o por blocos
end