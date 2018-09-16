function [dadosEntrada, estadosRede, dadosEntradaAntigo, estadosRedeAntigo] = ExtraiDados4(pasta, nomeArquivo, modoExecucao)

save('caminho_anterior.mat', 'pasta');

%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta função extrai os dados do sistema a ser estudado que deve estar
%%%% em formato .xls com três abas:
%%%%
%%%% Trechos
%%%% [Nº do trecho] [Barra DE] [Barra PARA] [r (pu)] [x (pu)] [b (kVAr)]
%%%% [tap do trafo.] [phi do trafo. defasador] [chave?] [status chave]
%%%%
%%%% Barras
%%%% [Nº da barra] [tipo da barra] [Vesp (pu)] [Pg (pu)] [Pd (pu)]
%%%% [Qg (pu)] [Qd (pu)] [bshunt de barra]
%%%%
%%%% Transformadores
%%%% [Nº da linha] [Vnom primário] [Vnom secundário] [Faixa de regulação]
%%%% [Nº de tapes]
%%%%
%%%% O tratamento dos dados inclui a montagem das matrizes incidência
%%%% barra-ramo e impedância.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%%
%%%% v1.0 - 29/06/2014
%%%% v1.1 - 20/07/2014 / Waitbar adicionada
%%%% v2.0 - 23/08/2014 / Aba "Transformadores" adicionada. Barra tipo PQV
%%%% criada para controle automático de tensão por transformadores com
%%%% comutadores de tap.
%%%% v2.1 - 07/12/2014 / "Modo mac" adicionado.
%%%% v3 - 09/05/2015 / Leitura dos estados das chaves para Nível de Seção
%%%% de barras.
%%%% v4 - 04/06/2015 / Modificação dos dados de entrada para inclusão da
%%%% normalização complexa por unidade. Dados de entrada em Ohms, Volts e
%%%% VAs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Abertura do .xls

if modoExecucao == 'WIN'
    caminho_arquivo = strcat(pasta,'\',nomeArquivo);   % Concatenação da pasta com o nome do arquivo para Windows
elseif modoExecucao == 'MAC'
    caminho_arquivo = strcat(pasta,'/',nomeArquivo);   % Concatenação da pasta com o nome do arquivo para Mac / Unix
end

WB = waitbar(0,'Carregando o arquivo, aguarde...');     % Inicialização da barra de espera do MATLAB
[pl_base_num, ~, ~] = xlsread(caminho_arquivo,'Base');
[pl_trechos_num, pl_trechos_txt, ~] = xlsread(caminho_arquivo,'Trechos');

waitbar(0.25);                                          % 25% concluído
[pl_barras_num, pl_barras_txt, pl_barras_raw] = xlsread(caminho_arquivo,'Barras');

waitbar(0.50);                                          % 50% concluído
[pl_transformadores_num, ~, ~] = xlsread(caminho_arquivo,'Transformadores');

[pl_barras_raw] = RetiraNaNCelula(pl_barras_raw);       % Retirada das células com valor NaN

%% Decodificação da planilha Base

if isnan(pl_base_num(1,1))                                                      % Se não há módulo da potência base especificado...
    error('Valor de potência base não especificado!');                          % Exibir erro ao usuário
else
    dadosEntrada.moduloPotenciaBase = pl_base_num(1,1);                         % Módulo da potência de base em kVA
    if isnan(pl_base_num(1,2))                                                  % Se não há ângulo especificado para a potência de base...
        dadosEntrada.anguloPotenciaBase = 0;                                    % Assumir ângulo zero
    else
        dadosEntrada.anguloPotenciaBase = deg2rad(pl_base_num(1,2));            % Ângulo da potência de base em radianos
    end
end

%% Decodificação da planilha Barras

dadosEntrada.barras = pl_barras_num(:,1);                                       % Numeração de cada barra
dadosEntrada.VbaseBarra = pl_barras_num(:,2);                                   % Tensões base para bada barra

%%%% ATENÇÃO!
%%%% Para as barras VT, P e Q especificados serão desconsiderados
%%%% Para as barras PV, Q especificados serão desconsiderados
%%%% Para as barras PQ, V especificados serão desconsiderados

dadosEntrada.tipoBarra = zeros(length(dadosEntrada.barras),1);                  % Vetor com o tipo de cada barra
tempLChave = 1;
for k=2:size(pl_barras_txt,1)
    if strcmp(pl_barras_txt{k,5},'VT') || strcmp(pl_barras_txt{k,5},'vt')       %%%% Análise das barras tipo VT
        if isempty(pl_barras_raw{k,6}) || pl_barras_raw{k,6} == 0               %%%% Erro se tensão não especificada na barra VT
            error('Barra tipo VT sem tensão especificada! (linha %d)',k);
        end
        dadosEntrada.tipoBarra(k-1,1) = 1;
        tempLChave = tempLChave+1;
    elseif strcmp(pl_barras_txt{k,5},'PV') || strcmp(pl_barras_txt{k,5},'pv')   %%%% Análise das barras tipo PV
        if isempty(pl_barras_raw{k,6})                                          %%%% Erro se tensão não especificada na barra PV
            error('Barra tipo PV sem tensão especificada! (linha %d)',k);
        end
        if isempty(pl_barras_raw{k,7}) || isempty(pl_barras_raw{k,8})           %%%% Erro se potência ativa não especificada na barra PV
            error('Barra tipo PV sem potência ativa especificada! (linha %d)',k);
        end
        dadosEntrada.tipoBarra(k-1,1) = 2;
        tempLChave = tempLChave+1;
    elseif strcmp(pl_barras_txt{k,5},'PQ') || strcmp(pl_barras_txt{k,5},'pq')   %%%% Análise das barras tipo PQ
        if isempty(pl_barras_raw{k,7}) || isempty(pl_barras_raw{k,8})           %%%% Erro se potência ativa não especificada na barra PQ
            error('Barra tipo PQ sem potência ativa especificada! (linha %d)',k);
        end
        if isempty(pl_barras_raw{k,9}) || isempty(pl_barras_raw{k,10})          %%%% Erro se potência reativa não especificada na barra PQ
            error('Barra tipo PQ sem potência reativa especificada! (linha %d)',k);
        end
        dadosEntrada.tipoBarra(k-1,1) = 3;
        tempLChave = tempLChave+1;
    elseif strcmp(pl_barras_txt{k,5},'PQV') || strcmp(pl_barras_txt{k,5},'pqv') %%%% Análise das barras tipo PQV
        if isempty(pl_barras_raw{k,6})                                          %%%% Erro se tensão não especificada na barra PQV
            error('Barra tipo PQV sem tensão especificada! (linha %d)',k);
        end
        if isempty(pl_barras_raw{k,7}) || isempty(pl_barras_raw{k,8})           %%%% Erro se potência ativa não especificada na barra PQV
            error('Barra tipo PQV sem potência ativa especificada! (linha %d)',k);
        end
        if isempty(pl_barras_raw{k,9}) || isempty(pl_barras_raw{k,10})          %%%% Erro se potência reativa não especificada na barra PQV
            error('Barra tipo PQV sem potência reativa especificada! (linha %d)',k);
        end
        dadosEntrada.tipoBarra(k-1,1) = 4;
        tempLChave = tempLChave+1;
    else
        error('Valor inválido na coluna Tipo, linha %d do arquivo %s',k,nomeArquivo);  %%%% Erro se caracter inválido na coluna Tipo
    end
end

if find(dadosEntrada.tipoBarra == 0)
    fprintf('\nLinha %d do excel!\n',k);
    error('Valor inválido de tipo de barra detectado na variável tipoBarra');
end

dadosEntrada.coordHorizontal = pl_barras_num(:,3);                              % Vetor com as coordenadas horizontais de cada barra
dadosEntrada.coordVertical = pl_barras_num(:,4);                                % Vetor com as coordenadas verticais de cada barra

dadosEntrada.Vesp = pl_barras_num(:,6);                                         % Vetor com a tensão especificada de cada barra (kV)
dadosEntrada.Vesp = dadosEntrada.Vesp./dadosEntrada.VbaseBarra;                 % Vetor das tensões especificadas em pu

dadosEntrada.Pg = pl_barras_num(:,7);                                           % Vetor com as potências ativas geradas em cada barra
dadosEntrada.Pd = pl_barras_num(:,8);                                           % Vetor com as potências ativas consumidas em cada barra
dadosEntrada.Qg = pl_barras_num(:,9);                                           % Vetor com as potências reativas geradas em cada barra
dadosEntrada.Qd = pl_barras_num(:,10);                                          % Vetor com as potências reativas consumidas em cada barra

bShBarraVar = pl_barras_num(:,11);                                              % Vetor com os shunts em cada barra
dadosEntrada.bShBarra = bShBarraVar./(dadosEntrada.VbaseBarra.^2*1000);         % Transformação do shunt de barra de kVAr para Siemens

barrasVT = dadosEntrada.barras(find(dadosEntrada.tipoBarra == 1),1);            % Vetor com as barras VT                 
barrasPV = dadosEntrada.barras(find(dadosEntrada.tipoBarra == 2),1);            % Vetor com as barras PV
barrasPQ = dadosEntrada.barras(find(dadosEntrada.tipoBarra == 3),1);            % Vetor com as barras PQ
barrasPQV = dadosEntrada.barras(find(dadosEntrada.tipoBarra == 4),1);           % Vetor com as barras PQV

waitbar(0.75);                                      % 75% concluído

%% Decodificação da planilha Trechos

dadosEntrada.linhas = pl_trechos_num(:,1);                       % Numeração de cada linha
dadosEntrada.de = pl_trechos_num(:,2);                           % Vetor com as barras DE referidas ao vetor de linhas
dadosEntrada.para = pl_trechos_num(:,3);                         % Vetor com as barras PARA referidas ao vetor de linhas
dadosEntrada.r = pl_trechos_num(:,4);                            % Vetor com as resistências de cada linha em Ohm/km
dadosEntrada.x = pl_trechos_num(:,5);                            % Vetor com as reatâncias de cada linha em Ohm/km
dadosEntrada.b = pl_trechos_num(:,6);                            % Vetor com as reatâncias shunt de cada lado da linha em S/km
dadosEntrada.b = dadosEntrada.b./2;                              % DIVISÃO DE TODAS AS ADMITÂNCIAS SHUNT DE LINHA POR 2
dist = pl_trechos_num(:,7);                                      % Vetor com as distâncias de cada linha em km

%%%% Transformação das impedâncias das linhas para pu

dadosEntrada.VbaseLinha = zeros(length(dadosEntrada.para),1);

for k=1:length(dadosEntrada.para)                                                                       % Criação de um vetor de tensões base para cada uma das linhas (REFERÊNCIA: barra PARA)
    dadosEntrada.VbaseLinha(k,1) = max([dadosEntrada.VbaseBarra(dadosEntrada.barras(dadosEntrada.barras == dadosEntrada.de(dadosEntrada.linhas(k)))) dadosEntrada.VbaseBarra(dadosEntrada.barras(dadosEntrada.barras == dadosEntrada.para(dadosEntrada.linhas(k))))]);
end

dadosEntrada.r = dadosEntrada.r.*dist;                                                                  % Resistências das linhas em Ohms
dadosEntrada.x = dadosEntrada.x.*dist;                                                                  % Reatâncias das linhas em Ohms
dadosEntrada.b = dadosEntrada.b.*dist;                                                                  % Susceptâncias shunt das linhas em S

dadosEntrada.rConvencional = dadosEntrada.r;                                                            % Resistência em Ohms antes da normalização complexa
dadosEntrada.xConvencional = dadosEntrada.x;                                                            % Reatância indutiva série em Ohms antes da normalização complexa
dadosEntrada.bConvencional = dadosEntrada.b;                                                            % Susceptância shunt em Siemens antes da normalização complexa

moduloZkm = sqrt(dadosEntrada.r.^2 + dadosEntrada.x.^2);                                                % Composição das impedâncias das linhas Z = R + jXl
anguloZkm = acos(dadosEntrada.r./moduloZkm);
zBase = (dadosEntrada.VbaseLinha.^2.*1000)./dadosEntrada.moduloPotenciaBase;
moduloZkmpu = moduloZkm./zBase;
dadosEntrada.r = moduloZkmpu.*cos(anguloZkm + dadosEntrada.anguloPotenciaBase);
dadosEntrada.x = moduloZkmpu.*sin(anguloZkm + dadosEntrada.anguloPotenciaBase);
dadosEntrada.b = dadosEntrada.b./(dadosEntrada.VbaseLinha.^2./dadosEntrada.moduloPotenciaBase*1000);    % Normalização das susceptâncias paralelas (APENAS PELO MÓDULO DA POTÊNCIA BASE)

%%%% Tratamento das chaves
dadosEntrada.linhasChaveaveis = zeros(length(dadosEntrada.linhas),1);                                   % Vetor com os índices das linhas (ramos) chaveáveis
dadosEntrada.statusChaves = ones(length(dadosEntrada.linhas),1)*2;                                      % Vetor com os status de cada chave
tempLChave = 1;
for k=2:size(pl_trechos_txt,1)
    %%%% Identificação dos ramos chaveáveis
    if pl_trechos_txt{k,8} == 'y' || pl_trechos_txt{k,8} == 'Y' || pl_trechos_txt{k,8} == 's' || pl_trechos_txt{k,8} == 'S'             % Condição para chave ativa
        dadosEntrada.linhasChaveaveis(tempLChave,1) = pl_trechos_num(k-1,1);
        %%%% Identificação dos estados das chaves
        if pl_trechos_txt{k,9} == 'c' || pl_trechos_txt{k,9} == 'C' || pl_trechos_txt{k,9} == 'a' || pl_trechos_txt{k,9} == 'A'         % Condição para chave aberta
            dadosEntrada.statusChaves(tempLChave,1) = 1;
        elseif pl_trechos_txt{k,9} == 'o' || pl_trechos_txt{k,9} == 'O' || pl_trechos_txt{k,9} == 'f' || pl_trechos_txt{k,9} == 'F'     % Condição para chave fechada
            dadosEntrada.statusChaves(tempLChave,1) = 0;
        else
            error('Valor inválido na coluna STATUS CHAVE, linha %d do arquivo %s',k,nomeArquivo);                                      % Erro se caracter inválido na tabela
        end
        if ~isnan(pl_trechos_num(k-1,4)) || ~isnan(pl_trechos_num(k-1,5)) || ~isnan(pl_trechos_num(k-1,6)) || ~isnan(pl_trechos_num(k-1,7))
            error('Ramos chaveáveis não devem ter impedâncias, admitâncias shunt ou distâncias especificadas. Erro na linha %d',dadosEntrada.linhas(k-1,1));     %%%% Erro se houver impedância especificada para ramos chaveáveis
        end
        tempLChave = tempLChave+1;
    elseif pl_trechos_txt{k,8} == 'n' || pl_trechos_txt{k,8} == 'N'
        if ~isempty(pl_trechos_txt{k,9})                                                    % Erro se houver estado para ramo convencional
            error('Chaveamentos são inválidos para ramos convencionais!');
        end
        if isnan(pl_trechos_num(k-1,4)) || isnan(pl_trechos_num(k-1,5)) || isnan(pl_trechos_num(k-1,6)) || isnan(pl_trechos_num(k-1,7))
            error('Ramo convencional sem impedância, admitância ou distância especificada na linha %d',dadosEntrada.linhas(k-1,1));                  %%%% Erro se não houver impedância ou admitância shunt especificada para ramos convencionais
        end
    else
        error('Valor inválido na coluna CHAVE?, linha %d do arquivo %s',k,nomeArquivo);    % Erro se caracter inválido na tabela
    end
    
end

%% Decodificação da planilha Transformadores

if isempty(pl_transformadores_num) ~= 1                                                     % Verificação se a aba de Transformadores está vazia na planilha

    dadosEntrada.linhasTrafos = pl_transformadores_num(:,1);                                % Vetor com as linhas nas quais existem transformadores
    dadosEntrada.VnomPrimTrafo = pl_transformadores_num(:,2);                               % Vetor com as tensões nominais do primário dos transformadores (VÁLIDO APENAS PARA VERSÃO COM ENTRADA DE DADOS EM ABSOLUTO)
    dadosEntrada.VnomSecTrafo = pl_transformadores_num(:,3);                                % Vetor com as tensões nominais do secundário dos transformadores (VÁLIDO APENAS PARA VERSÃO COM ENTRADA DE DADOS EM ABSOLUTO)
    dadosEntrada.faixaRegulacao = pl_transformadores_num(:,4);                              % Vetor com as faixas de regulação dos transformadores
    dadosEntrada.numTapes = pl_transformadores_num(:,5);                                    % Vetor com o número de tapes dos transformadores (TOTAL PARA CIMA E PARA BAIXO)
    dadosEntrada.banda = dadosEntrada.faixaRegulacao./(dadosEntrada.numTapes./2);           % Vetor com a banda de cada transformador (UTILIZADA APENAS PARA TRANSFORMADORES C/ REGULAÇÃO AUTOMÁTICA)
    tapFixo = pl_transformadores_num(:,6);                                                  % Vetor com o tap fixo do transformador
    dadosEntrada.linhasTrafosAutomaticos = dadosEntrada.linhasTrafos(isnan(tapFixo));       % Vetor com números das linhas nos quais os transformadores têm comutadores automáticos de tap
    defasagemAngular = pl_transformadores_num(:,7);                                         % Vetor com phi do transformador (apenas fixo!)

    dadosEntrada.tap = ones(length(dadosEntrada.linhas),1);                                 % Inicialização do vetor a (tap nas linhas)
    dadosEntrada.phi = zeros(length(dadosEntrada.linhas),1);                                % Inicialização do vetor phi (defasagem angular nas linhas)

    %%%% Verificação de segurança: dois transformadores com comutadores
    %%%% automáticos não podem regular a tensão da mesma barra. Logo, dois
    %%%% transformadores não podem ter a mesma barra para. (BARRA PARA
    %%%% UTILIZADA COMO REFERÊNCIA DE BARRA A SER REGULADA)
    
    for k=1:length(dadosEntrada.linhasTrafosAutomaticos)
       
        if ~isempty(barrasPQV)                                                              % Verificação se existem barras do tipo PQV no sistema
            
            flag_erro = 1;                                                                  % Flag para acusar erro se a barra PARA de um transformador não possui barra tipo PQV correspondente

            for tempLChave=1:length(barrasPQV)                                                      % Varredura em todas as barras PQV
               if isequal(dadosEntrada.para(dadosEntrada.linhasTrafosAutomaticos(k)),barrasPQV(tempLChave))        
                    flag_erro = 0;                                                          % O flag começa no estado de erro, e sai quando é encontrada uma barra do tipo PQV
               end
            end

            if flag_erro ~= 0
                error('Erro: o transformador da linha %d não possui sua barra PARA do tipo PQV!',k);
            end
            
        elseif isempty(barrasPQV) && ~isempty(dadosEntrada.linhasTrafosAutomaticos)         % Erro se existem transformadores com comutador automático porém não existem barras PQV definidas
            
            error('Erro: existem transformadores com regulação automática de tap, porém não existem barras definidas como PQV no sistema!');
        
        end
        
        for h=k+1:length(dadosEntrada.linhasTrafosAutomaticos)
            if isequal(dadosEntrada.para(dadosEntrada.linhasTrafosAutomaticos(k)),dadosEntrada.para(dadosEntrada.linhasTrafosAutomaticos(h)))
                error('Erro: dois transformadores comutadores regulando a tensão da mesma barra! Linhas %d e %d',k,h);
            end
       end
    end

    for k=1:length(dadosEntrada.linhasTrafos)
       if tapFixo(k,1) > (1 + dadosEntrada.faixaRegulacao(k,1)) || tapFixo(k,1) < (1 - dadosEntrada.faixaRegulacao(k,1))
           error('Tap especificado na linha %d da aba Transformadores fora da faixa de regulação especificada!',k);
       end
       dadosEntrada.tap(dadosEntrada.linhasTrafos(k,1),1) = tapFixo(k,1);                       % Processamento das informações de transformadores com tap (fixo = número, automático = NaN)
       if isnan(defasagemAngular(k,1))
           error('Defasagem angular não especificada na linha %d da aba Transformadores!',k);
       end
       dadosEntrada.phi(dadosEntrada.linhasTrafos(k,1),1) = deg2rad(defasagemAngular(k,1));     % Processamento das informações de transformadores defasadores (apenas fixos)
    end
    
else
    
    dadosEntrada.linhasTrafos = [];                                             % Vetor com as linhas nas quais existem transformadores
    dadosEntrada.VnomPrimTrafo = [];                                            % Vetor com as tensões nominais do primário dos transformadores (VÁLIDO APENAS PARA VERSÃO COM ENTRADA DE DADOS EM ABSOLUTO)
    dadosEntrada.VnomSecTrafo = [];                                             % Vetor com as tensões nominais do secundário dos transformadores (VÁLIDO APENAS PARA VERSÃO COM ENTRADA DE DADOS EM ABSOLUTO)
    dadosEntrada.faixaRegulacao = [];                                           % Vetor com as faixas de regulação dos transformadores
    dadosEntrada.numTapes = [];                                                 % Vetor com o número de tapes dos transformadores (TOTAL PARA CIMA E PARA BAIXO)
    dadosEntrada.banda = [];                                                    % Vetor com a banda de cada transformador (UTILIZADA APENAS PARA TRANSFORMADORES C/ REGULAÇÃO AUTOMÁTICA)
    tapFixo = [];                                                               % Vetor com o tap fixo do transformador
    dadosEntrada.linhasTrafosAutomaticos = [];                                  % Vetor com números das linhas nos quais os transformadores têm comutadores automáticos de tap
    defasagemAngular = [];                                                      % Vetor com phi do transformador (apenas fixo!)
    
    dadosEntrada.tap = ones(length(dadosEntrada.linhas),1);                     % Inicialização do vetor a (tap nas linhas)
    dadosEntrada.phi = zeros(length(dadosEntrada.linhas),1);                    % Inicialização do vetor phi (defasagem angular nas linhas)

end

%% Inicialização das variáveis

estadosRede.theta = zeros(length(dadosEntrada.barras),1);                                                                        % Inicialização dos ângulos das tensões nas barras em zero (INCLUSIVE REFERÊNCIA ANGULAR) --> EM RADIANOS!!!!
estadosRede.V = dadosEntrada.Vesp;                                                                                   % Inicialização dos módulos das tensões nas barras com as tensões especificadas pelas barras VT e PQ
estadosRede.V(find(isnan(estadosRede.V))) = 1;                                                          % Inicialização com módulo igual a 1 para o restante das barras
dadosEntrada.tap(find(isnan(dadosEntrada.tap))) = 1;                                                    % Inicialização dos taps automáticos em 1

% if any(dadosEntrada.linhasChaveaveis == 0)
%     error('Linhas numeradas com zero não são permitidas!');
% else
    if sum(dadosEntrada.linhasChaveaveis) ~= 0
        estadosRede.t = NaN(length(dadosEntrada.linhas),1);
        estadosRede.u = NaN(length(dadosEntrada.linhas),1);
        estadosRede.t(dadosEntrada.linhasChaveaveis(dadosEntrada.linhasChaveaveis ~= 0)) = 0;
        estadosRede.u(dadosEntrada.linhasChaveaveis(dadosEntrada.linhasChaveaveis ~= 0)) = 0;
    else
        estadosRede.t = [];
        estadosRede.u = [];
    end
% end

%%%% Redução dos vetores dadosEntrada.linhasChaveaveis e statusChaves
dadosEntrada.linhasChaveaveis(find(dadosEntrada.linhasChaveaveis == 0)) = [];
dadosEntrada.statusChaves(find(dadosEntrada.statusChaves == 2)) = [];

%% Dimensões do problema

dadosEntrada.nb = length(dadosEntrada.barras);                                  % Número de barras
dadosEntrada.nl = length(dadosEntrada.linhas);                                  % Número de linhas
dadosEntrada.nrc = length(dadosEntrada.linhasChaveaveis);                       % Número de chaves modeladas no sistema
if isempty(dadosEntrada.nrc)
    dadosEntrada.nrc = 0;
end
dadosEntrada.npv = length(barrasPV);                                            % Número de barras PV
if isempty(dadosEntrada.npv)
    dadosEntrada.npv = 0;
end
dadosEntrada.npq = length(barrasPQ);                                            % Número de barras PQ
if isempty(dadosEntrada.npq)
    dadosEntrada.npq = 0;
end
dadosEntrada.npqv = length(barrasPQV);                                          % Número de barras PQV
if isempty(dadosEntrada.npqv)
    dadosEntrada.npqv = 0;
end

waitbar(0.90);                                    % 90% concluído

%% Criação do arquivo de exportação para o MATPOWER

ExportaArquivoMatpower(modoExecucao, dadosEntrada, bShBarraVar);

%% Montagem dos vetores P especificado e Q especificado

%%%% TRATAMENTO DOS ELEMENTOS NaN:
%%%% Os elementos NaN são mantidos nas matrizes Pesp e Qesp, sinalizando
%%%% que estas barras não possuem potência especificada (barra PV ou VT)

dadosEntrada.Pesp = zeros(length(dadosEntrada.Pg),1);

for k=1:length(dadosEntrada.Pg)
    if isnan(dadosEntrada.Pg(k,1)) && ~isnan(dadosEntrada.Pd(k,1))
        dadosEntrada.Pesp(k,1) = -dadosEntrada.Pd(k,1);
    elseif isnan(dadosEntrada.Pg(k,1)) && isnan(dadosEntrada.Pd(k,1))
        dadosEntrada.Pesp(k,1) = nan;
    elseif ~isnan(dadosEntrada.Pg(k,1)) && isnan(dadosEntrada.Pd(k,1))
        dadosEntrada.Pesp(k,1) = dadosEntrada.Pg(k,1);
    elseif ~isnan(dadosEntrada.Pg(k,1)) && ~isnan(dadosEntrada.Pd(k,1))
        dadosEntrada.Pesp(k,1) = dadosEntrada.Pg(k,1) - dadosEntrada.Pd(k,1);
    end
end

dadosEntrada.Qesp = zeros(length(dadosEntrada.Qg),1);

for k=1:length(dadosEntrada.Qg)
    if isnan(dadosEntrada.Qg(k,1)) && ~isnan(dadosEntrada.Qd(k,1))
        dadosEntrada.Qesp(k,1) = -dadosEntrada.Qd(k,1);
    elseif isnan(dadosEntrada.Qg(k,1)) && isnan(dadosEntrada.Qd(k,1))
%         dadosEntrada.Qesp(k,1) = nan;
        dadosEntrada.Qesp(k,1) = 0;
    elseif ~isnan(dadosEntrada.Qg(k,1)) && isnan(dadosEntrada.Qd(k,1))
        dadosEntrada.Qesp(k,1) = dadosEntrada.Qg(k,1);
    elseif ~isnan(dadosEntrada.Qg(k,1)) && ~isnan(dadosEntrada.Qd(k,1))
        dadosEntrada.Qesp(k,1) = dadosEntrada.Qg(k,1) - dadosEntrada.Qd(k,1);
    end
end

Sesp = sqrt(dadosEntrada.Pesp.^2 + dadosEntrada.Qesp.^2);
Spu = Sesp./dadosEntrada.moduloPotenciaBase;

for k=1:length(Sesp)
    if dadosEntrada.Pesp(k,1) ~= 0 && Sesp(k,1) ~= 0
        anguloEsp(k,1) = -acos(dadosEntrada.Pesp(k,1)./Sesp(k,1));
    else
        anguloEsp(k,1) = 0;
    end
end

dadosEntrada.Pesp = Spu.*cos(anguloEsp + dadosEntrada.anguloPotenciaBase);
dadosEntrada.Qesp = Spu.*sin(anguloEsp + dadosEntrada.anguloPotenciaBase);

%% Montagem das matrizes do problema

dadosEntrada.A = montaA(dadosEntrada);                                          % Montagem da matriz incidência barra-ramo
[dadosEntrada.Y, dadosEntrada.B, dadosEntrada.G] = montaY3(dadosEntrada);       % Montagem da matriz admitância

%% Processamento de eventuais ilhas

[dadosEntrada, estadosRede, dadosEntradaAntigo, estadosRedeAntigo] = ProcessaRamosIlhados(dadosEntrada, estadosRede);

%% Salva os dados carregados da planilha

waitbar(1);                                         % 100% do progresso da barra

save('dados')                                       % Salva os dados do carregamento da planilha
close(WB);                                          % Fecha a barra de progresso
end