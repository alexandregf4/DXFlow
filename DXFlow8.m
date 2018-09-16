%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% DXFlow: Algoritmo de resolu��o de fluxo de carga pelo m�todo Newton-
%%%% Raphson convencional ou desacoplado r�pido no n�vel de se��o de barras
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%%
%%%% v1.0 - 03/08/2014
%%%% v2.0 - 21/09/2014 / Adicionado comutador autom�tico de tap (sem
%%%% m�ximo), nova tabela de entrada de dados.
%%%%        30/10/2014 / Corre��o de bugs relacionados ao controle
%%%% autom�tico de tap
%%%% v3.0 - 11/04/2015 / Adicionado o m�todo desacoplado r�pido para
%%%% resolu��o do fluxo de carga
%%%% v4.0 - 09/05/2015 / Adicionado o N�vel de Se��o de Barras para
%%%% tratamento de ramos chave�veis: Newton-Raphson convencional apenas!
%%%% v5.0 - 21/06/2015 / Adicionado o N�vel de Se��o de Barras desacoplado
%%%% r�pido.
%%%% v6.0 - 04/06/2015 / Entrada de dados modificada para inclus�o da
%%%% normaliza��o complexa por unidade. Adicionada fun��o que exporta os
%%%% dados para c�lculo no MATPOWER.
%%%% v7.0 - 25/10/2015 / Adicionada fun��o que trata ilhas sem tens�o.
%%%% v7.1 - 15/11/2015 / Vari�veis reorganizadas em estruturas de dados.
%%%% v8.0 - 23/01/2016 / Adicionado modo de an�lise com gr�ficos diversos
%%%% para um �nico sistema.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Interface com o usu�rio - carregamento, cria��o das vari�veis de entrada e mudan�a do modo de execu��o
clear 'vetorNumeroAnalise' 'vetorIteracoes' 'vetorIteracoesP' 'vetorIteracoesQ' 'vetorVmin' 'vetorVmed' 'vetorVmax' 'vetorPerdas' 'somaPd' 'vetorCargaNaoAtendida' 'vetorTempoSimulacao'

escolha = 0;

%%%% Menu de carregamento dos dados de entrada do sistema
while escolha ~= 1
    clc
    fprintf('**************************************************************************************\n');
    fprintf('*** DXFlow v8.0: software para an�lise de fluxo de carga e reconfigura��o de redes ***\n');
    fprintf('**************************************************************************************\n');
    
    fprintf('\n*** MENU PRINCIPAL ***\n\n');
    fprintf('ATEN��O: As op��es abaixo devem ser digitadas entre aspas simples\n');
    fprintf('ATEN��O: Uma vez executado um caso que tenha resultado, os resultados anteriores que est�o na pasta ser�o sobrescritos!\n');
    fprintf('ATEN��O: Para a AN�LISE EXAUSTIVA, coloque todas as chaves na posi��o FECHADA nos dados de entrada!\n');
    
    if exist('modo.mat','file')
        load modo
        if auxiliar.modoExecucao == 'WIN'
            fprintf('Atualmente executando no modo Windows. Caso deseje mudar as op��es, favor digitar M para acesso ao menu de modo de execu��o\n');
        elseif auxiliar.modoExecucao == 'MAC'
            fprintf('Atualmente executando no modo Mac / Unix. Caso deseje mudar as op��es, favor digitar M para acesso ao menu de modo de execu��o\n');
            fprintf('Nesta configura��o os resultados ser�o salvos apenas na extens�o .mat\n');
        end
    else
        fprintf('Modo de execu��o padr�o (Windows) selecionado. Caso deseje mudar para execu��o em Mac / Unix digite M para acesso ao menu de modo de execu��o\n');
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
            error('\nN�o existem dados anteriores a serem carregados. O programa ser� fechado.\n');
        end
    elseif opcao == 'n' || opcao == 'N'
        if exist('caminho_anterior.mat','file')                                                                                    % Verifica��o para abrir caminho anterior j� utilizado
            load('caminho_anterior.mat', 'pasta');
            [nomeArquivo, pasta] = uigetfile({'*.xlsx';'*.xls'},'Selecione um arquivo com dados do sistema',pasta);                % Abre janela de sele��o de arquivo
        else
            [nomeArquivo, pasta] = uigetfile({'*.xlsx';'*.xls'},'Selecione um arquivo com dados do sistema','Multiselect','off');  % Abre janela de sele��o de arquivo
        end
        if isequal(nomeArquivo,0)
            fprintf('Nenhum arquivo de dados foi selecionado pelo usu�rio. O programa foi fechado.\n\n');
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
        fprintf('*** MODO DE EXECU��O ***\n');
        if auxiliar.modoExecucao == 'WIN'
            fprintf('Sistema operacional: Windows\n');
        elseif auxiliar.modoExecucao == 'MAC'
            fprintf('Sistema operacional: Mac / Unix\n');
        end
        
        fprintf('\nATEN��O: As op��es abaixo devem ser digitadas entre aspas simples\n');
        opcaoMenuModo = input('Deseja modificar a configura��o de modo de execu��o? Pressione W para Windows ou M para Mac / Unix. Para voltar ao menu anterior, digite qualquer outra letra.\n');
        
        if opcaoMenuModo == 'w'|| opcaoMenuModo == 'W'
            auxiliar.modoExecucao = 'WIN';
            save('modo.mat','auxiliar');
        elseif opcaoMenuModo == 'm' || opcaoMenuModo == 'M'
            auxiliar.modoExecucao = 'MAC';
            save('modo.mat','auxiliar');
        end
    else
        fprintf('\n\nDigite uma op��o v�lida, ou digite S para sair!\n\n');
    end
end

%%%% Menu de escolha do m�todo de c�lculo
auxiliar.opcaoMetodo = 0;

fprintf('\n*** ESCOLHA DO M�TODO DE C�LCULO ***\n');

while auxiliar.opcaoMetodo == 0
    auxiliar.opcaoMetodo = input('\nDigite 1 para resolu��o pelo m�todo convencional, 2 para resolu��o pelo m�todo desacoplado r�pido ou S para sair: ');
    if auxiliar.opcaoMetodo == 2
        fprintf('\nM�todo desacoplado r�pido selecionado. Como devem ser montadas as matrizes?\n');
        auxiliar.opcaoDesacoplado = input('\nEscolha entre XX, XB, BX ou BB (digitar as letras correspondentes): ');
    elseif auxiliar.opcaoMetodo == 's' || auxiliar.opcaoMetodo == 'S'
        return;
    elseif auxiliar.opcaoMetodo == 1
    else
        fprintf('\n\nDigite uma op��o v�lida, ou digite S para sair!\n\n');
        auxiliar.opcaoMetodo = 0;
    end
end

%%%% Menu de escolha do tipo de c�lculo
auxiliar.tipoCalculo = 0;

while auxiliar.tipoCalculo == 0
    
    auxiliar.tipoCalculo = input('\nDigite ''e'' ou ''r'' se deseja que seja realizada a an�lise exaustiva (for�a bruta) do sistema carregado ou Enter para um �nico c�lculo baseado nos dados de entrada: ');
    
    if auxiliar.tipoCalculo ~= 0
        if isempty(dadosEntrada.nrc) || dadosEntrada.nrc == 0
            error('O n�mero de ramos chave�veis deve ser diferente de zero para que a an�lise exaustiva possa ser executada! O programa ser� fechado.\n\n');
        end
    end
    
    if ~isempty(auxiliar.tipoCalculo)
        auxiliar.tipoCalculo = lower(auxiliar.tipoCalculo);
        auxiliar.tipoCalculo = strtrim(auxiliar.tipoCalculo);
        if strcmp(auxiliar.tipoCalculo, 's')
            return;
        elseif strcmp(auxiliar.tipoCalculo, 'e')
            fprintf('\nAn�lise exaustiva selecionada. Processando...\n');
            DelecaoArquivosPasta('Resultados ultima analise exaustiva');
        elseif strcmp(auxiliar.tipoCalculo, 'r')
            fprintf('\nAn�lise exaustiva com reaproveitamento dos estados da rede anteriores selecionada. Processando...\n');
            DelecaoArquivosPasta('Resultados ultima analise exaustiva');
        elseif strcmp(auxiliar.tipoCalculo, 'y')
            fprintf('\nModo gr�fico de converg�ncia. Processando...\n');
            DelecaoArquivosPasta('Resultados ultima analise exaustiva');
        else
            fprintf('\n\nDigite uma op��o v�lida, ou digite S para sair!\n\n');
            auxiliar.tipoCalculo = 0;
        end
    else
        auxiliar.tipoCalculo = 1;
        DelecaoArquivosPasta('Resultados ultimo fluxo de potencia');
    end
end

opcaoMenuPlot = 0;

fprintf('\n*** APRESENTA��O VISUAL DOS RESULTADOS ***\n');

if ~any(isnan(dadosEntrada.coordHorizontal)) && ~any(isnan(dadosEntrada.coordVertical)) && length(dadosEntrada.coordHorizontal) == dadosEntrada.nb && length(dadosEntrada.coordVertical) == dadosEntrada.nb
    fprintf('\nForam detectadas coordenadas para as barras do sistema nos dados de entrada.\n');
    while opcaoMenuPlot == 0
        auxiliar.opcaoPlotUsuario = input('\nDigite 1 se as coordenadas foram entradas em formato cartesiano\nDigite 2 se as coordenadas foram entradas em formato georreferenciado\nDigite 0 se n�o deseja visualizar os resultados sobre a topologia do sistema.\n\nOp��o: ');
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
            fprintf('\n\nDigite uma op��o v�lida, ou digite S para sair!\n\n');
        end
    end
else
    fprintf('\nN�o foram detectadas coordenadas para as barras do sistema nos dados de entrada. N�o ser�o exibidas as tens�es sobre a topologia do sistema.\n');
    auxiliar.opcaoPlotUsuario = 'nenhum';
end

%% Vari�veis de configura��o/acompanhamento do m�todo

config.tolerancia = 10^-6;                                                                              % Toler�ncia para c�lculo das vari�veis
if auxiliar.opcaoMetodo == 1
    config.maxIteracoes = 10;                                                                           % N�mero m�ximo de itera��es para parada do programa por diverg�ncia (Newton-Raphson Convencional)
elseif auxiliar.opcaoMetodo == 2
    config.maxIteracoes = 30;                                                                           % N�mero m�ximo de itera��es para parada do programa por diverg�ncia (Newton-Raphson Desacoplado-R�pido)
end

%% Cria��o da tabela com todas as possibilidades de chaveamentos do sistema

if auxiliar.tipoCalculo == 'e' || auxiliar.tipoCalculo == 'r'
    headerTabelaPossibilidades = dadosEntrada.linhasChaveaveis';                                        % Header da tabela separado dos dados para que se possa trabalhar diretamente com os �ndices
    tabelaPossibilidades = npermutek([1 0], dadosEntrada.nrc);                                          % O n�mero de cada possibilidade de teste � dado pelo �ndice da matriz
    save(strcat(pwd,'/Resultados ultima analise exaustiva/Tabela_chaveamentos.mat'),'tabelaPossibilidades');
    save(strcat(pwd,'/Resultados ultima analise exaustiva/Tabela_chaveamentos_header.mat'),'headerTabelaPossibilidades');
    totalAnalises = size(tabelaPossibilidades, 1);
    dadosEntradaCompletoBackup = dadosEntrada;
    estadosRedeCompletoBackup = estadosRede;
elseif auxiliar.tipoCalculo == 'y'                                                                      % An�lise de converg�ncia
    anguloInicial = 0;
    anguloFinal = 90;
    anguloPasso = 1;
    listaAngulos = deg2rad([anguloInicial:anguloPasso:anguloFinal]');
    totalAnalises = length(listaAngulos);
else
    totalAnalises = 1;
end

for numeroAnalise=1:totalAnalises
    
    % Mudan�a a cada c�lculo para a forma��o do gr�fico
    if auxiliar.tipoCalculo == 'y'
        dadosEntrada.anguloPotenciaBase = listaAngulos(numeroAnalise,1);
    end
    
    auxiliar.numeroAnalise = numeroAnalise;
    
    if auxiliar.tipoCalculo == 'e'|| auxiliar.tipoCalculo == 'r'
        dadosEntradaCompletoBackup.statusChaves = tabelaPossibilidades(auxiliar.numeroAnalise,:)';                    % Chaveamento selecionado para itera��o da an�lise exaustiva
        [dadosEntrada, estadosRede, dadosEntradaAntigo, estadosRedeAntigo] = ProcessaRamosIlhados(dadosEntradaCompletoBackup, estadosRedeCompletoBackup);   % Processamento topol�gico
    end
    
    %%%% Op��o para utilizar os estados da rede anteriores como estado
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
    
    %% Resolu��o do SUBPROBLEMA 1:
    
    flagErro = false;
    try
        
        %%%% M�todo Newton-Raphson convencional
        if auxiliar.opcaoMetodo == 1
            
            iteracaoP = [];
            iteracaoQ = [];
            historicoConvergenciaP = [];
            historicoConvergenciaQ = [];
            tic
            [estadosRede, dadosEntrada, Pcalc, Qcalc, iteracao, historicoConvergencia, mismatches, J] = NewtonRaphsonEstendido(dadosEntrada, estadosRede, config, auxiliar);
            tempoSimulacao = toc;
            
            graficoConvergencia(numeroAnalise,1) = iteracao;      % gravando numero de itera��es XPF para fazer o gr�fico
        end
        
        %%%% M�todo Newton-Raphson desacoplado r�pido
        if auxiliar.opcaoMetodo == 2
            
            historicoConvergencia = [];
            iteracao = [];
            
            tic
            [estadosRede, Pcalc, Qcalc, iteracaoP, iteracaoQ, historicoConvergenciaP, historicoConvergenciaQ, mismatchesP, mismatchesQ, BP, BQ] = NewtonRaphsonEstendidoDR(auxiliar, config, dadosEntrada, estadosRede);
            tempoSimulacao = toc;
            
            graficoConvergencia(numeroAnalise,2) = iteracaoP;     % gravando numero de itera��es XFDPF para fazer o gr�fico
            graficoConvergencia(numeroAnalise,3) = iteracaoQ;
            
        else
%             error('Op��o de m�todo inv�lida! O calculo n�o poder� ser realizado.');
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
        fprintf('\nDIVERG�NCIA: An�lise n�mero %d\n', numeroAnalise);
        flagErro = true;
    end
    
    if auxiliar.tipoCalculo ~= 'y'
        
        %%%% Grav'ando dados da an�lise corrente para ser utilizado na pr�xima an�lise
        if strcmp(auxiliar.tipoCalculo, 'r')
            dadosEntradaAnaliseAnterior = dadosEntrada;
            estadosRedeAnaliseAnterior = estadosRede;
        end
        
        %% Resolu��o do SUBPROBLEMA 2 do fluxo de carga por substitui��o
        
        if ~flagErro
            %%%% La�o para c�lculo das pot�ncias geradas Pk e Qk para as barras VT e PV
            [Pcalc, Qcalc] = ResolveSubProblema2(dadosEntrada, estadosRede, Pcalc, Qcalc);
            %%%% C�lculo dos fluxos e perdas nas linhas
            [Pkm, Qkm, PkmPerdas, Pperdas, PperdasPerc, QkmPerdas, Qperdas, QperdasPerc] = CalculaFluxosPerdas4(dadosEntrada, estadosRede);
        end
        
        %% Apresenta��o dos resultados
        
        if ~flagErro
            ExibeResultados5(auxiliar, dadosEntrada, dadosEntradaAntigo, estadosRede, estadosRedeAntigo, Pkm, Qkm, PkmPerdas, Pperdas, Qperdas, PperdasPerc, historicoConvergencia, historicoConvergenciaP, historicoConvergenciaQ, iteracao, iteracaoP, iteracaoQ);
        end
        
        %% Grava��o das informa��es para os gr�ficos da an�lise exaustiva
        
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
                
                % vetorIteracoesP e vetorIteracoesQ (desacoplado r�pido)
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
fprintf('\nT�rmino da execu��o.\n\n');