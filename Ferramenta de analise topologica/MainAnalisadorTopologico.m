%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Analisador topol�gico que retorna todas as barras conectadas entre 
%%%% dois pontos dados pelo usu�rio.
%%%% Este script utiliza as fun��es de an�lise de dados do DXFlow7.1 para
%%%% funcionar.
%%%% Esta ferramenta � especialmente �til para se analisar a conectividade
%%%% entre dois pontos desejados e saber a soma de pot�ncias em um bloco de
%%%% carga definido pelo usu�rio.
%%%% � necess�rio tomar cuidado quando a matriz incid�ncia apresenta mais
%%%% de um n�mero 1 na linha das barras Anterior e Posterior desejadas.
%%%%
%%%% Alexandre Gomes Fonseca
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% OBS.: FUN��O N�O VALIDADA PARA TODOS OS CASOS QUE ENVOLVEM TOPOLOGIA EM ANEL!

%% Entrada de dados pelo usu�rio no prompt
fprintf('#### ANALISADOR DE TOPOLOGIA v1 ####\n\n');
barraAnterior = input('Barra in�cio: ');
barraPosterior = input('Barra fim: ');
fprintf('\n');

%% Abertura do arquivo desejado (formato DXFLow7.1)
[nomeArquivo, pasta] = uigetfile({'*.xlsx';'*.xls'},'Selecione um arquivo com dados do sistema','Multiselect','off');
modoExecucao = 'MAC';
[dadosEntrada, estadosRede] = ExtraiDados4(pasta, nomeArquivo, modoExecucao);
Amod = dadosEntrada.A;

%% Modifica��o da matriz A - ramoAnterior
ramoAnterior = find(dadosEntrada.A(barraAnterior,:) == -1);

if length(ramoAnterior) > 1
    fprintf('Foram encontradas mais de uma linha precedente � barra anterior indicada:\n');
    for k=1:length(ramoAnterior)
        fprintf('Linha %d\n',ramoAnterior(k));
    end
    fprintf('\n');
    temp = input('Selecione quais delas o programa deve considerar: ');
    flag = false;
    for k=1:length(ramoAnterior)
        if temp == ramoAnterior(k)
            flag = true;
        end
    end
    if ~flag
        fprintf('\nSelecione uma das barras indicadas! O programa ser� fechado.\n');
        return;
    else
        ramoAnterior = temp;
    end
end

Amod(:,ramoAnterior) = 0;

%% Modifica��o da matriz A - ramoPosterior
ramoPosterior = find(dadosEntrada.A(barraPosterior,:) == 1);

if length(ramoPosterior) > 1
    fprintf('Foram encontradas mais de uma linha subsequente � barra posterior indicada:\n');
    for k=1:length(ramoPosterior)
        fprintf('Linha %d\n',ramoPosterior(k));
    end
    fprintf('\n');
    temp = input('Selecione quais delas o programa deve considerar: ');
    flag = false;
    for k=1:length(ramoPosterior)
        if temp == ramoPosterior(k)
            flag = true;
        end
    end
    if ~flag
        fprintf('\nSelecione uma das barras indicadas! O programa ser� fechado.\n');
        return;
    else
        ramoPosterior = temp;
    end
end

Amod(:,ramoPosterior) = 0;

%% Processamento topol�gico
[barrasIlha, linhasIlha] = ConectividadeIlhas(barraAnterior, Amod, dadosEntrada);
P = sum(dadosEntrada.Pd(barrasIlha));
Q = sum(dadosEntrada.Qd(barrasIlha));

%% Apresenta��o dos resultados
fprintf('#### RESULTADOS ####\n\n');
fprintf('Barras encontradas entre as barras %d e %d :\n',barraAnterior, barraPosterior);
for k=1:length(barrasIlha)
    fprintf('%d\n',barrasIlha(k));
end
fprintf('\nPot�ncia ativa total\t(P) : %1.2f kW\n', P);
fprintf('Pot�ncia reativa total\t(Q) : %1.2f kVAr\n', Q);
fprintf('Pot�ncia aparente \t(S) : %1.2f kVA\n\n', sqrt(P.^2 + Q.^2));

%% Plot das barras envolvidas
% if any(isempty(dadosEntrada.coordHorizontal)) || any(isempty(dadosEntrada.coordVertical))
% else
%     auxiliar.opcaoPlotUsuario = 'cartesiano';
%     estadosRede.V = zeros(length(barrasIlha),1);
%     PlotaTopologiaTensao(auxiliar, dadosEntrada, estadosRede);
% end