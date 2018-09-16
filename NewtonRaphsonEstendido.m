function [estadosRede, dadosEntrada, Pcalc, Qcalc, iteracao, historicoConvergencia, mismatches, J] = NewtonRaphsonEstendido(dadosEntrada, estadosRede, config, auxiliar)

%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Função que resolve o Subproblema 1 pelo método Newton-Raphson
%%%% convencional. Esta função também trata os ramos chaveáveis conforme a
%%%% técnica de nível de seção de barras (se houverem).
%%%%
%%%% Alexandre Gomes Fonseca
%%%% vNS - 10/05/2015 / Nível de Subestação adicionado
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Cálculo das injeções de potência iniciais

[Pcalc, Qcalc] = CalculaEEFC2(dadosEntrada, estadosRede);                                                                                               % Cálculo das Equações Estáticas de Fluxo de Carga para as potências ativa e reativa
[mismatches, barrasDeltaPQ, tipoDeltaPQ, potenciaDeltaPQ, variavelDeltaX] = MontaMismatches3(dadosEntrada, estadosRede, Pcalc, Qcalc);                  % Montagem dos vetores dos mismatches e xvar (variáveis V e theta) para resolução por blocos

%% Resolução do SUBPROBLEMA 1 do fluxo de carga pelo método de Newton-Raphson convencional

historicoConvergencia = [];
iteracao = 0;

while(norm(mismatches,Inf) > config.tolerancia)
    if auxiliar.tipoCalculo == 1
        fprintf('Iteração: %d\n',iteracao);
        fprintf('Norma infinita: %1.6f\n\n',norm(mismatches,Inf));
    end
    
    %%%% Erro caso número máximo de iterações seja atingido
    if iteracao >= config.maxIteracoes
        if auxiliar.tipoCalculo == 1
            convergencia = figure;
            plot(historicoConvergencia(:,1),historicoConvergencia(:,2),'-or');
            title('Convergência');
            xlabel('Iteração');
            ylabel('Norma infinita de delta P');
        end
        error('Número máximo de iterações atingido: %d\n\n', iteracao);
        return;
    end
    
    %%%% Atualização da matriz admitância
    if dadosEntrada.npqv ~= 0
        [dadosEntrada.Y, dadosEntrada.B, dadosEntrada.G] = montaY3(dadosEntrada);
    end
    
    %%%% Montagem da matriz Jacobiana
    J = MontaJBlocos3(dadosEntrada, estadosRede, barrasDeltaPQ, potenciaDeltaPQ, variavelDeltaX);
    
    %%%% Resolução do sistema linear
    xvar = J\mismatches;
    
    %%%% Atualização das variáveis
    [deltaTheta, deltaV, deltaAkm, deltaTkm, deltaUkm] = RemontaVetores3(dadosEntrada, variavelDeltaX, barrasDeltaPQ, xvar);                            % Transformação do vetor xvar (2*npq + 2*npqv + npv x 1) (em blocos) para theta, V (nb x 1) e akm (nl x 1)
    
    estadosRede.theta = estadosRede.theta + deltaTheta;                                                                                                 % Atualização do vetor theta (ângulos das tensões)
    estadosRede.V = estadosRede.V + deltaV;                                                                                                             % Atualização do vetor V (módulos das tensões)
    dadosEntrada.tap = dadosEntrada.tap + deltaAkm;                                                                                                     % Atualização do vetor tap (módulos dos taps dos transformadores)
    if ~isempty(estadosRede.t) && ~isempty(estadosRede.u)
        estadosRede.t = SomaNaN(estadosRede.t,deltaTkm);                                                                                                % Atualização do vetor t                                                                                                                                                                 
        estadosRede.u = SomaNaN(estadosRede.u,deltaUkm);                                                                                                % Atualização do vetor u
    end
        
    %%%% Atualização da contagem de iterações
    historicoConvergencia(iteracao+1,1) = iteracao;                                                                                                     % Gravação da iteração atual na matriz de histórico de convergência
    historicoConvergencia(iteracao+1,2) = norm(mismatches,Inf);                                                                                         % Gravação do valor da norma na matriz de histórico de convergência
    iteracao = iteracao + 1;                                                                                                                            % Atualização da contagem de iterações
    
    %%%% Atualização das potências injetadas nas barras e da diferença entre P especificado e P calculado
    [Pcalc, Qcalc] = CalculaEEFC2(dadosEntrada, estadosRede);                                                                                           % Cálculo das Equações Estáticas de Fluxo de Carga para as potências ativa e reativa
    [mismatches, barrasDeltaPQ, tipoDeltaPQ, potenciaDeltaPQ, variavelDeltaX] = MontaMismatches3(dadosEntrada, estadosRede, Pcalc, Qcalc);              % Montagem dos vetores dos mismatches e xvar (variáveis V e theta) para resolução por blocos
end