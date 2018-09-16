%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% DXFlow: Algoritmo de resolução de fluxo de carga pelo método Newton-
%%%% Raphson convencional ou desacoplado rápido no nível de seção de barras
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%%
%%%% v1.0 - 03/08/2014
%%%% v2.0 - 21/09/2014 / Adicionado comutador automático de tap (sem
%%%% máximo), nova tabela de entrada de dados.
%%%%        30/10/2014 / Correção de bugs relacionados ao controle
%%%% automático de tap
%%%% v3.0 - 11/04/2015 / Adicionado o método desacoplado rápido para
%%%% resolução do fluxo de carga
%%%% v4.0 - 09/05/2015 / Adicionado o Nível de Seção de Barras para
%%%% tratamento de ramos chaveáveis: Newton-Raphson convencional apenas!
%%%% v5.0 - 21/06/2015 / Adicionado o Nível de Seção de Barras desacoplado
%%%% rápido.
%%%% v6.0 - 04/06/2015 / Entrada de dados modificada para inclusão da
%%%% normalização complexa por unidade. Adicionada função que exporta os
%%%% dados para cálculo no MATPOWER.
%%%% v7.0 - 25/10/2015 / Adicionada função que trata ilhas sem tensão.
%%%% v7.1 - 15/11/2015 / Variáveis reorganizadas em estruturas de dados.
%%%% v8.0 - 23/01/2016 / Adicionado modo de análise com gráficos diversos
%%%% para um único sistema.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Interface com o usuário - carregamento, criação das variáveis de entrada e mudança do modo de execução
clear 'vetorNumeroAnalise' 'vetorIteracoes' 'vetorIteracoesP' 'vetorIteracoesQ' 'vetorVmin' 'vetorVmed' 'vetorVmax' 'vetorPerdas' 'somaPd' 'vetorCargaNaoAtendida' 'vetorTempoSimulacao'

escolha = 0;

%%%% Menu de carregamento dos dados de entrada do sistema
while escolha ~= 1
    clc
    fprintf('**************************************************************************************\n');
    fprintf('*** DXFlow v8.0: software para análise de fluxo de carga e reconfiguração de redes ***\n');
    fprintf('**************************************************************************************\n');
    
    fprintf('\n*** MENU PRINCIPAL ***\n\n');
    fprintf('ATENÇÃO: As opções abaixo devem ser digitadas entre aspas simples\n');
    fprintf('ATENÇÃO: Uma vez executado um caso que tenha resultado, os resultados anteriores que estão na pasta serão sobrescritos!\n');
    fprintf('ATENÇÃO: Para a ANÁLISE EXAUSTIVA, coloque todas as chaves na posição FECHADA nos dados de entrada!\n');
    
    if exist('modo.mat','file')
        load modo
        if auxiliar.modoExecucao == 'WIN'
            fprintf('Atualmente executando no modo Windows. Caso deseje mudar as opções, favor digitar M para acesso ao menu de modo de execução\n');
        elseif auxiliar.modoExecucao == 'MAC'
            fprintf('Atualmente executando no modo Mac / Unix. Caso deseje mudar as opções, favor digitar M para acesso ao menu de modo de execução\n');
            fprintf('Nesta configuração os resultados serão salvos apenas na extensão .mat\n');
        end
    else
        fprintf('Modo de execução padrão (Windows) selecionado. Caso deseje mudar para execução em Mac / Unix digite M para acesso ao menu de modo de execução\n');
        auxiliar.modoExecucao = 'WIN';
        save('modo.mat','auxiliar');
    end
    
    opcao = input('\nDigite C para carregar dados anteriores, N para utilizar novos dados ou S para sair: ');
    
    if opcao == 'c' || opcao == 'C'
        if exist('dados.mat','file')
            load dados
            fprintf('\nDados anteriores carregados com sucesso!\n\n');
            escolha = 1;
        else
            error('\nNão existem dados anteriores a serem carregados. O programa será fechado.\n');
        end
    elseif opcao == 'n' || opcao == 'N'
        if exist('caminho_anterior.mat','file')                                                                                    % Verificação para abrir caminho anterior já utilizado
            load('caminho_anterior.mat', 'pasta');
            [nomeArquivo, pasta] = uigetfile({'*.xlsx';'*.xls'},'Selecione um arquivo com dados do sistema',pasta);                % Abre janela de seleção de arquivo
        else
            [nomeArquivo, pasta] = uigetfile({'*.xlsx';'*.xls'},'Selecione um arquivo com dados do sistema','Multiselect','off');  % Abre janela de seleção de arquivo
        end
        if isequal(nomeArquivo,0)
            fprintf('Nenhum arquivo de dados foi selecionado pelo usuário. O programa foi fechado.\n\n');
            return;
        end
        [dadosEntrada, estadosRede, dadosEntradaAntigo, estadosRedeAntigo] = ExtraiDados4(pasta, nomeArquivo, auxiliar.modoExecucao);
        fprintf('\nNovos dados gerados com sucesso!\n\n');
        escolha = 1;
    elseif opcao == 's' || opcao == 'S'
        escolha = 1;
        return;
    elseif opcao == 'm' || opcao == 'M'
        clc
        fprintf('*** MODO DE EXECUÇÃO ***\n');
        if auxiliar.modoExecucao == 'WIN'
            fprintf('Sistema operacional: Windows\n');
        elseif auxiliar.modoExecucao == 'MAC'
            fprintf('Sistema operacional: Mac / Unix\n');
        end
        
        fprintf('\nATENÇÃO: As opções abaixo devem ser digitadas entre aspas simples\n');
        opcaoMenuModo = input('Deseja modificar a configuração de modo de execução? Pressione W para Windows ou M para Mac / Unix. Para voltar ao menu anterior, digite qualquer outra letra.\n');
        
        if opcaoMenuModo == 'w'|| opcaoMenuModo == 'W'
            auxiliar.modoExecucao = 'WIN';
            save('modo.mat','auxiliar');
        elseif opcaoMenuModo == 'm' || opcaoMenuModo == 'M'
            auxiliar.modoExecucao = 'MAC';
            save('modo.mat','auxiliar');
        end
    else
        fprintf('\n\nDigite uma opção válida, ou digite S para sair!\n\n');
    end
end

%%%% Menu de escolha do método de cálculo
auxiliar.opcaoMetodo = 0;

fprintf('\n*** ESCOLHA DO MÉTODO DE CÁLCULO ***\n');

while auxiliar.opcaoMetodo == 0
    auxiliar.opcaoMetodo = input('\nDigite 1 para resolução pelo método convencional, 2 para resolução pelo método desacoplado rápido ou S para sair: ');
    if auxiliar.opcaoMetodo == 2
        fprintf('\nMétodo desacoplado rápido selecionado. Como devem ser montadas as matrizes?\n');
        auxiliar.opcaoDesacoplado = input('\nEscolha entre XX, XB, BX ou BB (digitar as letras correspondentes): ');
    elseif auxiliar.opcaoMetodo == 's' || auxiliar.opcaoMetodo == 'S'
        return;
    elseif auxiliar.opcaoMetodo == 1
    else
        fprintf('\n\nDigite uma opção válida, ou digite S para sair!\n\n');
        auxiliar.opcaoMetodo = 0;
    end
end

%%%% Menu de escolha do tipo de cálculo
auxiliar.tipoCalculo = 0;

while auxiliar.tipoCalculo == 0
    
    auxiliar.tipoCalculo = input('\nDigite ''e'' ou ''r'' se deseja que seja realizada a análise exaustiva (força bruta) do sistema carregado ou Enter para um único cálculo baseado nos dados de entrada: ');
    
    if auxiliar.tipoCalculo ~= 0
        if isempty(dadosEntrada.nrc) || dadosEntrada.nrc == 0
            error('O número de ramos chaveáveis deve ser diferente de zero para que a análise exaustiva possa ser executada! O programa será fechado.\n\n');
        end
    end
    
    if ~isempty(auxiliar.tipoCalculo)
        auxiliar.tipoCalculo = lower(auxiliar.tipoCalculo);
        auxiliar.tipoCalculo = strtrim(auxiliar.tipoCalculo);
        if strcmp(auxiliar.tipoCalculo, 's')
            return;
        elseif strcmp(auxiliar.tipoCalculo, 'e')
            fprintf('\nAnálise exaustiva selecionada. Processando...\n');
            DelecaoArquivosPasta('Resultados ultima analise exaustiva');
        elseif strcmp(auxiliar.tipoCalculo, 'r')
            fprintf('\nAnálise exaustiva com reaproveitamento dos estados da rede anteriores selecionada. Processando...\n');
            DelecaoArquivosPasta('Resultados ultima analise exaustiva');
        elseif strcmp(auxiliar.tipoCalculo, 'y')
            fprintf('\nModo gráfico de convergência. Processando...\n');
            DelecaoArquivosPasta('Resultados ultima analise exaustiva');
        else
            fprintf('\n\nDigite uma opção válida, ou digite S para sair!\n\n');
            auxiliar.tipoCalculo = 0;
        end
    else
        auxiliar.tipoCalculo = 1;
        DelecaoArquivosPasta('Resultados ultimo fluxo de potencia');
    end
end

opcaoMenuPlot = 0;

fprintf('\n*** APRESENTAÇÃO VISUAL DOS RESULTADOS ***\n');

if ~any(isnan(dadosEntrada.coordHorizontal)) && ~any(isnan(dadosEntrada.coordVertical)) && length(dadosEntrada.coordHorizontal) == dadosEntrada.nb && length(dadosEntrada.coordVertical) == dadosEntrada.nb
    fprintf('\nForam detectadas coordenadas para as barras do sistema nos dados de entrada.\n');
    while opcaoMenuPlot == 0
        auxiliar.opcaoPlotUsuario = input('\nDigite 1 se as coordenadas foram entradas em formato cartesiano\nDigite 2 se as coordenadas foram entradas em formato georreferenciado\nDigite 0 se não deseja visualizar os resultados sobre a topologia do sistema.\n\nOpção: ');
        if auxiliar.opcaoPlotUsuario == 1
            auxiliar.opcaoPlotUsuario = 'cartesiano';
            opcaoMenuPlot = 1;
        elseif auxiliar.opcaoPlotUsuario == 2
            auxiliar.opcaoPlotUsuario = 'georreferenciado';
            opcaoMenuPlot = 1;
        elseif auxiliar.opcaoPlotUsuario == 0
            auxiliar.opcaoPlotUsuario = 'nenhum';
            opcaoMenuPlot = 1;
        elseif auxiliar.opcaoPlotUsuario == 'S' || auxiliar.opcaoPlotUsuario == 's'
            return;
        else
            opcaoMenuPlot = 0;
            fprintf('\n\nDigite uma opção válida, ou digite S para sair!\n\n');
        end
    end
else
    fprintf('\nNão foram detectadas coordenadas para as barras do sistema nos dados de entrada. Não serão exibidas as tensões sobre a topologia do sistema.\n');
    auxiliar.opcaoPlotUsuario = 'nenhum';
end

%% Variáveis de configuração/acompanhamento do método

config.tolerancia = 10^-6;                                                                              % Tolerância para cálculo das variáveis
if auxiliar.opcaoMetodo == 1
    config.maxIteracoes = 10;                                                                           % Número máximo de iterações para parada do programa por divergência (Newton-Raphson Convencional)
elseif auxiliar.opcaoMetodo == 2
    config.maxIteracoes = 30;                                                                           % Número máximo de iterações para parada do programa por divergência (Newton-Raphson Desacoplado-Rápido)
end

%% Criação da tabela com todas as possibilidades de chaveamentos do sistema

if auxiliar.tipoCalculo == 'e' || auxiliar.tipoCalculo == 'r'
    headerTabelaPossibilidades = dadosEntrada.linhasChaveaveis';                                        % Header da tabela separado dos dados para que se possa trabalhar diretamente com os índices
    tabelaPossibilidades = npermutek([1 0], dadosEntrada.nrc);                                          % O número de cada possibilidade de teste é dado pelo índice da matriz
    save(strcat(pwd,'/Resultados ultima analise exaustiva/Tabela_chaveamentos.mat'),'tabelaPossibilidades');
    save(strcat(pwd,'/Resultados ultima analise exaustiva/Tabela_chaveamentos_header.mat'),'headerTabelaPossibilidades');
    totalAnalises = size(tabelaPossibilidades, 1);
    dadosEntradaCompletoBackup = dadosEntrada;
    estadosRedeCompletoBackup = estadosRede;
elseif auxiliar.tipoCalculo == 'y'                                                                      % Análise de convergência
    anguloInicial = 0;
    anguloFinal = 90;
    anguloPasso = 1;
    listaAngulos = deg2rad([anguloInicial:anguloPasso:anguloFinal]');
    totalAnalises = length(listaAngulos);
else
    totalAnalises = 1;
end

for numeroAnalise=1:totalAnalises
    
    % Mudança a cada cálculo para a formação do gráfico
    if auxiliar.tipoCalculo == 'y'
        dadosEntrada.anguloPotenciaBase = listaAngulos(numeroAnalise,1);
    end
    
    auxiliar.numeroAnalise = numeroAnalise;
    
    if auxiliar.tipoCalculo == 'e'|| auxiliar.tipoCalculo == 'r'
        dadosEntradaCompletoBackup.statusChaves = tabelaPossibilidades(auxiliar.numeroAnalise,:)';                    % Chaveamento selecionado para iteração da análise exaustiva
        [dadosEntrada, estadosRede, dadosEntradaAntigo, estadosRedeAntigo] = ProcessaRamosIlhados(dadosEntradaCompletoBackup, estadosRedeCompletoBackup);   % Processamento topológico
    end
    
    %%%% Opção para utilizar os estados da rede anteriores como estado
    %%%% inicial, caso a topologia seja a mesma
    if numeroAnalise > 1
        if strcmp(auxiliar.tipoCalculo, 'r')
            if length(dadosEntrada.barras) == length(dadosEntradaAnaliseAnterior.barras)
                if all(dadosEntradaAnaliseAnterior.barras == dadosEntrada.barras)
                    estadosRede.V = estadosRedeAnaliseAnterior.V;
                    estadosRede.theta = estadosRedeAnaliseAnterior.theta;
                    estadosRede.t = estadosRedeAnaliseAnterior.t;
                    estadosRede.u = estadosRedeAnaliseAnterior.u;
                end
            end
        end
    end
    
    %% Resolução do SUBPROBLEMA 1:
    
    flagErro = false;
    try
        
        %%%% Método Newton-Raphson convencional
        if auxiliar.opcaoMetodo == 1
            
            iteracaoP = [];
            iteracaoQ = [];
            historicoConvergenciaP = [];
            historicoConvergenciaQ = [];
            tic
            [estadosRede, dadosEntrada, Pcalc, Qcalc, iteracao, historicoConvergencia, mismatches, J] = NewtonRaphsonEstendido(dadosEntrada, estadosRede, config, auxiliar);
            tempoSimulacao = toc;
            
            graficoConvergencia(numeroAnalise,1) = iteracao;      % gravando numero de iterações XPF para fazer o gráfico
        end
        
        %%%% Método Newton-Raphson desacoplado rápido
        if auxiliar.opcaoMetodo == 2
            
            historicoConvergencia = [];
            iteracao = [];
            
            tic
            [estadosRede, Pcalc, Qcalc, iteracaoP, iteracaoQ, historicoConvergenciaP, historicoConvergenciaQ, mismatchesP, mismatchesQ, BP, BQ] = NewtonRaphsonEstendidoDR(auxiliar, config, dadosEntrada, estadosRede);
            tempoSimulacao = toc;
            
            graficoConvergencia(numeroAnalise,2) = iteracaoP;     % gravando numero de iterações XFDPF para fazer o gráfico
            graficoConvergencia(numeroAnalise,3) = iteracaoQ;
            
        else
%             error('Opção de método inválida! O calculo não poderá ser realizado.');
        end
        
        graficoConvergencia(numeroAnalise,4) = rad2deg(dadosEntrada.anguloPotenciaBase);    % gravando o angulo base
        
        if auxiliar.tipoCalculo == 'y' && numeroAnalise == totalAnalises
            GraficoConvergencia(graficoConvergencia, auxiliar.opcaoMetodo);
            return;
        end
        
    catch ME
        if auxiliar.opcaoMetodo == 1
            for k=0:config.maxIteracoes
                historicoConvergencia(k+1,1) = k;
            end
        elseif auxiliar.opcaoMetodo == 2
            for k=0:config.maxIteracoes
                historicoConvergenciaP(k+1,1) = k;
                historicoConvergenciaQ(k+1,1) = k;
            end
        end
        fprintf('\nDIVERGÊNCIA: Análise número %d\n', numeroAnalise);
        flagErro = true;
    end
    
    if auxiliar.tipoCalculo ~= 'y'
        
        %%%% Grav'ando dados da análise corrente para ser utilizado na próxima análise
        if strcmp(auxiliar.tipoCalculo, 'r')
            dadosEntradaAnaliseAnterior = dadosEntrada;
            estadosRedeAnaliseAnterior = estadosRede;
        end
        
        %% Resolução do SUBPROBLEMA 2 do fluxo de carga por substituição
        
        if ~flagErro
            %%%% Laço para cálculo das potências geradas Pk e Qk para as barras VT e PV
            [Pcalc, Qcalc] = ResolveSubProblema2(dadosEntrada, estadosRede, Pcalc, Qcalc);
            %%%% Cálculo dos fluxos e perdas nas linhas
            [Pkm, Qkm, PkmPerdas, Pperdas, PperdasPerc, QkmPerdas, Qperdas, QperdasPerc] = CalculaFluxosPerdas4(dadosEntrada, estadosRede);
        end
        
        %% Apresentação dos resultados
        
        if ~flagErro
            ExibeResultados5(auxiliar, dadosEntrada, dadosEntradaAntigo, estadosRede, estadosRedeAntigo, Pkm, Qkm, PkmPerdas, Pperdas, Qperdas, PperdasPerc, historicoConvergencia, historicoConvergenciaP, historicoConvergenciaQ, iteracao, iteracaoP, iteracaoQ);
        end
        
        %% Gravação das informações para os gráficos da análise exaustiva
        
        if auxiliar.tipoCalculo ~=1
            % vetorNumeroAnalise
            if ~exist('vetorNumeroAnalise')
                vetorNumeroAnalise = [];
            end
            vetorNumeroAnalise = [vetorNumeroAnalise; numeroAnalise];
            
            % vetorIteracoes
            if auxiliar.opcaoMetodo == 1
                
                vetorIteracoesP = [];
                vetorIteracoesQ = [];
                
                if ~exist('vetorIteracoes')
                    vetorIteracoes = [];
                end
                vetorIteracoes = [vetorIteracoes; historicoConvergencia(end,1)];
                
                % vetorIteracoesP e vetorIteracoesQ (desacoplado rápido)
            elseif auxiliar.opcaoMetodo == 2
                
                vetorIteracoes = [];
                
                if ~exist('vetorIteracoesP')
                    vetorIteracoesP = [];
                end
                vetorIteracoesP = [vetorIteracoesP; historicoConvergenciaP(end,1)];
                
                if ~exist('vetorIteracoesQ')
                    vetorIteracoesQ = [];
                end
                vetorIteracoesQ = [vetorIteracoesQ; historicoConvergenciaQ(end,1)];
            end
            
            % vetorTempoSimulacao
            if ~exist('vetorTempoSimulacao')
                vetorTempoSimulacao = [];
            end
            if ~flagErro
                vetorTempoSimulacao = [vetorTempoSimulacao; tempoSimulacao];
            else
                vetorTempoSimulacao = [vetorTempoSimulacao; 0];
            end
            
            % vetorVmin
            if ~exist('vetorVmin')
                vetorVmin = [];
            end
            if ~flagErro
                vetorVmin = [vetorVmin; min(estadosRede.V(estadosRede.V ~= 0))];
            else
                vetorVmin = [vetorVmin; 0];
            end
            
            % vetorVmed
            if ~exist('vetorVmed')
                vetorVmed = [];
            end
            if ~flagErro
                vetorVmed = [vetorVmed; mean(estadosRede.V(estadosRede.V ~= 0))];
            else
                vetorVmed = [vetorVmed; 0];
            end
            
            % vetorVmax
            if ~exist('vetorVmax')
                vetorVmax = [];
            end
            if ~flagErro
                vetorVmax = [vetorVmax; max(estadosRede.V(estadosRede.V ~= 0))];
            else
                vetorVmax = [vetorVmax; 0];
            end
            
            % vetorPerdas
            if ~exist('vetorPerdas')
                vetorPerdas = [];
            end
            if ~flagErro
                vetorPerdas = [vetorPerdas; Pperdas];
            else
                vetorPerdas = [vetorPerdas; 0];
            end
            
            temp = dadosEntrada.Pd;
            temp(isnan(temp)) = 0;
            
            temp2 = dadosEntradaCompletoBackup.Pd;
            temp2(isnan(temp2)) = 0;
            
            % somaPd
            if ~exist('somaPd')
                somaPd = [];
            end
            somaPd = [somaPd; sum(temp2)];
            
            % vetorCargaNaoAtendida
            if ~exist('vetorCargaNaoAtendida')
                vetorCargaNaoAtendida = [];
            end
            if ~flagErro
                vetorCargaNaoAtendida = [vetorCargaNaoAtendida; sum(temp2) - sum(temp(dadosEntrada.barras))];
            else
                vetorCargaNaoAtendida = [vetorCargaNaoAtendida; sum(temp2)];
            end
            
        end
        
    end
    
end

if auxiliar.tipoCalculo == 'e'|| auxiliar.tipoCalculo == 'r'
    PlotGraficosAnaliseExaustiva(auxiliar, vetorNumeroAnalise, vetorIteracoes, vetorIteracoesP, vetorIteracoesQ, vetorVmin, vetorVmed, vetorVmax, vetorPerdas, somaPd, vetorCargaNaoAtendida, vetorTempoSimulacao, tabelaPossibilidades);
end
fprintf('\nTérmino da execução.\n\n');