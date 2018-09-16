%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Analisador topológico que retorna todas as barras conectadas entre 
%%%% dois pontos dados pelo usuário.
%%%% Este script utiliza as funções de análise de dados do DXFlow7.1 para
%%%% funcionar.
%%%% Esta ferramenta é especialmente útil para se analisar a conectividade
%%%% entre dois pontos desejados e saber a soma de potências em um bloco de
%%%% carga definido pelo usuário.
%%%% É necessário tomar cuidado quando a matriz incidência apresenta mais
%%%% de um número 1 na linha das barras Anterior e Posterior desejadas.
%%%%
%%%% Alexandre Gomes Fonseca
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% OBS.: FUNÇÃO NÃO VALIDADA PARA TODOS OS CASOS QUE ENVOLVEM TOPOLOGIA EM ANEL!

%% Entrada de dados pelo usuário no prompt
fprintf('#### ANALISADOR DE TOPOLOGIA v1 ####\n\n');
barraAnterior = input('Barra início: ');
barraPosterior = input('Barra fim: ');
fprintf('\n');

%% Abertura do arquivo desejado (formato DXFLow7.1)
[nomeArquivo, pasta] = uigetfile({'*.xlsx';'*.xls'},'Selecione um arquivo com dados do sistema','Multiselect','off');
modoExecucao = 'MAC';
[dadosEntrada, estadosRede] = ExtraiDados4(pasta, nomeArquivo, modoExecucao);
Amod = dadosEntrada.A;

%% Modificação da matriz A - ramoAnterior
ramoAnterior = find(dadosEntrada.A(barraAnterior,:) == -1);

if length(ramoAnterior) > 1
    fprintf('Foram encontradas mais de uma linha precedente à barra anterior indicada:\n');
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
        fprintf('\nSelecione uma das barras indicadas! O programa será fechado.\n');
        return;
    else
        ramoAnterior = temp;
    end
end

Amod(:,ramoAnterior) = 0;

%% Modificação da matriz A - ramoPosterior
ramoPosterior = find(dadosEntrada.A(barraPosterior,:) == 1);

if length(ramoPosterior) > 1
    fprintf('Foram encontradas mais de uma linha subsequente à barra posterior indicada:\n');
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
        fprintf('\nSelecione uma das barras indicadas! O programa será fechado.\n');
        return;
    else
        ramoPosterior = temp;
    end
end

Amod(:,ramoPosterior) = 0;

%% Processamento topológico
[barrasIlha, linhasIlha] = ConectividadeIlhas(barraAnterior, Amod, dadosEntrada);
P = sum(dadosEntrada.Pd(barrasIlha));
Q = sum(dadosEntrada.Qd(barrasIlha));

%% Apresentação dos resultados
fprintf('#### RESULTADOS ####\n\n');
fprintf('Barras encontradas entre as barras %d e %d :\n',barraAnterior, barraPosterior);
for k=1:length(barrasIlha)
    fprintf('%d\n',barrasIlha(k));
end
fprintf('\nPotência ativa total\t(P) : %1.2f kW\n', P);
fprintf('Potência reativa total\t(Q) : %1.2f kVAr\n', Q);
fprintf('Potência aparente \t(S) : %1.2f kVA\n\n', sqrt(P.^2 + Q.^2));

%% Plot das barras envolvidas
% if any(isempty(dadosEntrada.coordHorizontal)) || any(isempty(dadosEntrada.coordVertical))
% else
%     auxiliar.opcaoPlotUsuario = 'cartesiano';
%     estadosRede.V = zeros(length(barrasIlha),1);
%     PlotaTopologiaTensao(auxiliar, dadosEntrada, estadosRede);
% end