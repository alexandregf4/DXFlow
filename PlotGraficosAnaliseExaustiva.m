function [] = PlotGraficosAnaliseExaustiva(auxiliar, vetorNumeroAnalise, vetorIteracoes, vetorIteracoesP, vetorIteracoesQ, vetorVmin, vetorVmed, vetorVmax, vetorPerdas, somaPd, vetorCargaNaoAtendida, vetorTempoSimulacao, tabelaPossibilidades)
%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta fun��o consolida os dados da an�lise exaustiva numa s�rie de
%%%% gr�ficos.
%%%%
%%%% Alexandre Gomes Fonseca
%%%%
%%%% v1.0 - 26/01/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nome_pasta = 'Resultados ultima analise exaustiva';
legenda_x = 'N�mero do chaveamento (manobra)';

if ~isempty(vetorNumeroAnalise)
    %% Plot No An�lise x No Itera��es
    
    iteracoes = figure;
    hold on
    grid on
    if auxiliar.opcaoMetodo == 1
        if ~isempty(vetorIteracoes)
            bar(vetorNumeroAnalise, vetorIteracoes);
            title('N�mero de itera��es necess�rias na resolu��o pelo fluxo de pot�ncia estendido Newton-Raphson convencional');
            xlabel(legenda_x);
            ylabel('N�mero de itera��es');
        else
            error('O vetor Iteracoes est� vazio!');
        end
    elseif auxiliar.opcaoMetodo == 2
        if ~isempty(vetorIteracoesP) && ~isempty(vetorIteracoesQ)
            for k=1:length(vetorNumeroAnalise)
                temp(k,1) = vetorIteracoesP(k,1);
                temp(k,2) = vetorIteracoesQ(k,1);
            end
            bar(temp);
            title('N�mero de itera��es necess�rias na resolu��o pelo fluxo de pot�ncia estendido Newton-Raphson desacoplado r�pido');
            xlabel('N�mero do chaveamento (manobra)');
            ylabel('N�mero de itera��es');
            legend('P\theta','QV');
        else
            error('Um dos vetores (vetorIteracoesP ou vetorIteracoesQ) est� vazio!');
        end
    else
        error('Op��o de m�todo inv�lida! O calculo n�o poder� ser realizado.');
    end
    saveas(iteracoes,[pwd '/' nome_pasta '/Ex_ITERACOES.fig']);
    hold off

    %% Plot No An�lise x Tens�es m�nima m�dia e m�xima
    
    tensoes = figure;
    hold on
    grid on
    if ~isempty(vetorVmin) && ~isempty(vetorVmed) && ~isempty(vetorVmax)
        plot(vetorNumeroAnalise,vetorVmin,'-xk',vetorNumeroAnalise,vetorVmed,'--ob',vetorNumeroAnalise,vetorVmax,'-^r');
        title('Caracteriza��o dos perfis de tens�o');
        xlabel(legenda_x);
        ylabel('Tens�o (pu)');
        legend('Vmin','Vmed','Vmax');
    end
    saveas(tensoes,[pwd '/' nome_pasta '/Ex_TENSOES.fig']);
    hold off
    
    %% Plot No An�lise x Perdas (kW)
    
    perdas = figure;
    hold on
    grid on
    if ~isempty(vetorPerdas)
        bar(vetorNumeroAnalise,vetorPerdas);
        title('Caracteriza��o das perdas');
        xlabel(legenda_x);
        ylabel('Perdas (kW)');
    end
    saveas(perdas,[pwd '/' nome_pasta '/Ex_PERDAS.fig']);
    hold off
    
    %% Plot No An�lise x Carga n�o atendida (kW)
    
    carga = figure;
    hold on
    grid on
    if ~isempty(vetorCargaNaoAtendida) && ~isempty(somaPd)
        bar(vetorNumeroAnalise,vetorCargaNaoAtendida);
        plot(vetorNumeroAnalise,somaPd,'--r');
        title('Demanda n�o atendida');
        xlabel(legenda_x);
        ylabel('Pot�ncia (kW)');
        legend('Demanda n�o atendida','Demanda total do sistema');
    end
    saveas(carga,[pwd '/' nome_pasta '/Ex_CARGANAOATENDIDA.fig']);
    hold off
    
    %% Plot No An�lise x Tempo de simula��o absoluto (s)
    
    tempoAbsoluto = figure;
    hold on
    grid on
    if ~isempty(vetorTempoSimulacao)
        bar(vetorNumeroAnalise, vetorTempoSimulacao);
        title('Tempo de simula��o');
        xlabel(legenda_x);
        ylabel('Tempo de simula��o (s)');
    end
    saveas(tempoAbsoluto,[pwd '/' nome_pasta '/Ex_TEMPOSIMULACAOABSOLUTO.fig']);
    hold off
    
    %% Plot No An�lise x Tempo de simula��o relativo (%)
    
    for lin=1:size(tabelaPossibilidades,1)
        if tabelaPossibilidades(lin,:) == 1
            indiceChaveamentoBase = lin;
            break;
        end
    end
    
    tempoSimulacaoBase = vetorTempoSimulacao(indiceChaveamentoBase);
    save(strcat(pwd,'/Resultados ultima analise exaustiva/tempo_simulacao_base.mat'),'tempoSimulacaoBase');
    vetorTempoSimulacao = ((vetorTempoSimulacao./tempoSimulacaoBase)-1).*100;
    
    tempoRelativo = figure;
    hold on
    grid on
    if ~isempty(vetorTempoSimulacao)
        bar(vetorNumeroAnalise,vetorTempoSimulacao);
        title('Tempo de simula��o');
        xlabel(legenda_x);
        ylabel('Tempo relativo ao chaveamento com todas as chaves fechadas (%)');
    end
    saveas(tempoRelativo,[pwd '/' nome_pasta '/Ex_TEMPOSIMULACAORELATIVO.fig']);
    hold off
    
else
    error('O vetor de numera��o das an�lises est� vazio!');
end
