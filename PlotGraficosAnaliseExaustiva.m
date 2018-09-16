function [] = PlotGraficosAnaliseExaustiva(auxiliar, vetorNumeroAnalise, vetorIteracoes, vetorIteracoesP, vetorIteracoesQ, vetorVmin, vetorVmed, vetorVmax, vetorPerdas, somaPd, vetorCargaNaoAtendida, vetorTempoSimulacao, tabelaPossibilidades)
%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta função consolida os dados da análise exaustiva numa série de
%%%% gráficos.
%%%%
%%%% Alexandre Gomes Fonseca
%%%%
%%%% v1.0 - 26/01/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nome_pasta = 'Resultados ultima analise exaustiva';
legenda_x = 'Número do chaveamento (manobra)';

if ~isempty(vetorNumeroAnalise)
    %% Plot No Análise x No Iterações
    
    iteracoes = figure;
    hold on
    grid on
    if auxiliar.opcaoMetodo == 1
        if ~isempty(vetorIteracoes)
            bar(vetorNumeroAnalise, vetorIteracoes);
            title('Número de iterações necessárias na resolução pelo fluxo de potência estendido Newton-Raphson convencional');
            xlabel(legenda_x);
            ylabel('Número de iterações');
        else
            error('O vetor Iteracoes está vazio!');
        end
    elseif auxiliar.opcaoMetodo == 2
        if ~isempty(vetorIteracoesP) && ~isempty(vetorIteracoesQ)
            for k=1:length(vetorNumeroAnalise)
                temp(k,1) = vetorIteracoesP(k,1);
                temp(k,2) = vetorIteracoesQ(k,1);
            end
            bar(temp);
            title('Número de iterações necessárias na resolução pelo fluxo de potência estendido Newton-Raphson desacoplado rápido');
            xlabel('Número do chaveamento (manobra)');
            ylabel('Número de iterações');
            legend('P\theta','QV');
        else
            error('Um dos vetores (vetorIteracoesP ou vetorIteracoesQ) está vazio!');
        end
    else
        error('Opção de método inválida! O calculo não poderá ser realizado.');
    end
    saveas(iteracoes,[pwd '/' nome_pasta '/Ex_ITERACOES.fig']);
    hold off

    %% Plot No Análise x Tensões mínima média e máxima
    
    tensoes = figure;
    hold on
    grid on
    if ~isempty(vetorVmin) && ~isempty(vetorVmed) && ~isempty(vetorVmax)
        plot(vetorNumeroAnalise,vetorVmin,'-xk',vetorNumeroAnalise,vetorVmed,'--ob',vetorNumeroAnalise,vetorVmax,'-^r');
        title('Caracterização dos perfis de tensão');
        xlabel(legenda_x);
        ylabel('Tensão (pu)');
        legend('Vmin','Vmed','Vmax');
    end
    saveas(tensoes,[pwd '/' nome_pasta '/Ex_TENSOES.fig']);
    hold off
    
    %% Plot No Análise x Perdas (kW)
    
    perdas = figure;
    hold on
    grid on
    if ~isempty(vetorPerdas)
        bar(vetorNumeroAnalise,vetorPerdas);
        title('Caracterização das perdas');
        xlabel(legenda_x);
        ylabel('Perdas (kW)');
    end
    saveas(perdas,[pwd '/' nome_pasta '/Ex_PERDAS.fig']);
    hold off
    
    %% Plot No Análise x Carga não atendida (kW)
    
    carga = figure;
    hold on
    grid on
    if ~isempty(vetorCargaNaoAtendida) && ~isempty(somaPd)
        bar(vetorNumeroAnalise,vetorCargaNaoAtendida);
        plot(vetorNumeroAnalise,somaPd,'--r');
        title('Demanda não atendida');
        xlabel(legenda_x);
        ylabel('Potência (kW)');
        legend('Demanda não atendida','Demanda total do sistema');
    end
    saveas(carga,[pwd '/' nome_pasta '/Ex_CARGANAOATENDIDA.fig']);
    hold off
    
    %% Plot No Análise x Tempo de simulação absoluto (s)
    
    tempoAbsoluto = figure;
    hold on
    grid on
    if ~isempty(vetorTempoSimulacao)
        bar(vetorNumeroAnalise, vetorTempoSimulacao);
        title('Tempo de simulação');
        xlabel(legenda_x);
        ylabel('Tempo de simulação (s)');
    end
    saveas(tempoAbsoluto,[pwd '/' nome_pasta '/Ex_TEMPOSIMULACAOABSOLUTO.fig']);
    hold off
    
    %% Plot No Análise x Tempo de simulação relativo (%)
    
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
        title('Tempo de simulação');
        xlabel(legenda_x);
        ylabel('Tempo relativo ao chaveamento com todas as chaves fechadas (%)');
    end
    saveas(tempoRelativo,[pwd '/' nome_pasta '/Ex_TEMPOSIMULACAORELATIVO.fig']);
    hold off
    
else
    error('O vetor de numeração das análises está vazio!');
end
