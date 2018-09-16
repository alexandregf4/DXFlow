function [dadosEntrada, estadosRede, dadosEntradaAntigo, estadosRedeAntigo] = ExtraiDados4(pasta, nomeArquivo, modoExecucao)

save('caminho_anterior.mat', 'pasta');

%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta fun��o extrai os dados do sistema a ser estudado que deve estar
%%%% em formato .xls com tr�s abas:
%%%%
%%%% Trechos
%%%% [N� do trecho] [Barra DE] [Barra PARA] [r (pu)] [x (pu)] [b (kVAr)]
%%%% [tap do trafo.] [phi do trafo. defasador] [chave?] [status chave]
%%%%
%%%% Barras
%%%% [N� da barra] [tipo da barra] [Vesp (pu)] [Pg (pu)] [Pd (pu)]
%%%% [Qg (pu)] [Qd (pu)] [bshunt de barra]
%%%%
%%%% Transformadores
%%%% [N� da linha] [Vnom prim�rio] [Vnom secund�rio] [Faixa de regula��o]
%%%% [N� de tapes]
%%%%
%%%% O tratamento dos dados inclui a montagem das matrizes incid�ncia
%%%% barra-ramo e imped�ncia.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%%
%%%% v1.0 - 29/06/2014
%%%% v1.1 - 20/07/2014 / Waitbar adicionada
%%%% v2.0 - 23/08/2014 / Aba "Transformadores" adicionada. Barra tipo PQV
%%%% criada para controle autom�tico de tens�o por transformadores com
%%%% comutadores de tap.
%%%% v2.1 - 07/12/2014 / "Modo mac" adicionado.
%%%% v3 - 09/05/2015 / Leitura dos estados das chaves para N�vel de Se��o
%%%% de barras.
%%%% v4 - 04/06/2015 / Modifica��o dos dados de entrada para inclus�o da
%%%% normaliza��o complexa por unidade. Dados de entrada em Ohms, Volts e
%%%% VAs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Abertura do .xls

if modoExecucao == 'WIN'
    caminho_arquivo = strcat(pasta,'\',nomeArquivo);   % Concatena��o da pasta com o nome do arquivo para Windows
elseif modoExecucao == 'MAC'
    caminho_arquivo = strcat(pasta,'/',nomeArquivo);   % Concatena��o da pasta com o nome do arquivo para Mac / Unix
end

WB = waitbar(0,'Carregando o arquivo, aguarde...');     % Inicializa��o da barra de espera do MATLAB
[pl_base_num, ~, ~] = xlsread(caminho_arquivo,'Base');
[pl_trechos_num, pl_trechos_txt, ~] = xlsread(caminho_arquivo,'Trechos');

waitbar(0.25);                                          % 25% conclu�do
[pl_barras_num, pl_barras_txt, pl_barras_raw] = xlsread(caminho_arquivo,'Barras');

waitbar(0.50);                                          % 50% conclu�do
[pl_transformadores_num, ~, ~] = xlsread(caminho_arquivo,'Transformadores');

[pl_barras_raw] = RetiraNaNCelula(pl_barras_raw);       % Retirada das c�lulas com valor NaN

%% Decodifica��o da planilha Base

if isnan(pl_base_num(1,1))                                                      % Se n�o h� m�dulo da pot�ncia base especificado...
    error('Valor de pot�ncia base n�o especificado!');                          % Exibir erro ao usu�rio
else
    dadosEntrada.moduloPotenciaBase = pl_base_num(1,1);                         % M�dulo da pot�ncia de base em kVA
    if isnan(pl_base_num(1,2))                                                  % Se n�o h� �ngulo especificado para a pot�ncia de base...
        dadosEntrada.anguloPotenciaBase = 0;                                    % Assumir �ngulo zero
    else
        dadosEntrada.anguloPotenciaBase = deg2rad(pl_base_num(1,2));            % �ngulo da pot�ncia de base em radianos
    end
end

%% Decodifica��o da planilha Barras

dadosEntrada.barras = pl_barras_num(:,1);                                       % Numera��o de cada barra
dadosEntrada.VbaseBarra = pl_barras_num(:,2);                                   % Tens�es base para bada barra

%%%% ATEN��O!
%%%% Para as barras VT, P e Q especificados ser�o desconsiderados
%%%% Para as barras PV, Q especificados ser�o desconsiderados
%%%% Para as barras PQ, V especificados ser�o desconsiderados

dadosEntrada.tipoBarra = zeros(length(dadosEntrada.barras),1);                  % Vetor com o tipo de cada barra
tempLChave = 1;
for k=2:size(pl_barras_txt,1)
    if strcmp(pl_barras_txt{k,5},'VT') || strcmp(pl_barras_txt{k,5},'vt')       %%%% An�lise das barras tipo VT
        if isempty(pl_barras_raw{k,6}) || pl_barras_raw{k,6} == 0               %%%% Erro se tens�o n�o especificada na barra VT
            error('Barra tipo VT sem tens�o especificada! (linha %d)',k);
        end
        dadosEntrada.tipoBarra(k-1,1) = 1;
        tempLChave = tempLChave+1;
    elseif strcmp(pl_barras_txt{k,5},'PV') || strcmp(pl_barras_txt{k,5},'pv')   %%%% An�lise das barras tipo PV
        if isempty(pl_barras_raw{k,6})                                          %%%% Erro se tens�o n�o especificada na barra PV
            error('Barra tipo PV sem tens�o especificada! (linha %d)',k);
        end
        if isempty(pl_barras_raw{k,7}) || isempty(pl_barras_raw{k,8})           %%%% Erro se pot�ncia ativa n�o especificada na barra PV
            error('Barra tipo PV sem pot�ncia ativa especificada! (linha %d)',k);
        end
        dadosEntrada.tipoBarra(k-1,1) = 2;
        tempLChave = tempLChave+1;
    elseif strcmp(pl_barras_txt{k,5},'PQ') || strcmp(pl_barras_txt{k,5},'pq')   %%%% An�lise das barras tipo PQ
        if isempty(pl_barras_raw{k,7}) || isempty(pl_barras_raw{k,8})           %%%% Erro se pot�ncia ativa n�o especificada na barra PQ
            error('Barra tipo PQ sem pot�ncia ativa especificada! (linha %d)',k);
        end
        if isempty(pl_barras_raw{k,9}) || isempty(pl_barras_raw{k,10})          %%%% Erro se pot�ncia reativa n�o especificada na barra PQ
            error('Barra tipo PQ sem pot�ncia reativa especificada! (linha %d)',k);
        end
        dadosEntrada.tipoBarra(k-1,1) = 3;
        tempLChave = tempLChave+1;
    elseif strcmp(pl_barras_txt{k,5},'PQV') || strcmp(pl_barras_txt{k,5},'pqv') %%%% An�lise das barras tipo PQV
        if isempty(pl_barras_raw{k,6})                                          %%%% Erro se tens�o n�o especificada na barra PQV
            error('Barra tipo PQV sem tens�o especificada! (linha %d)',k);
        end
        if isempty(pl_barras_raw{k,7}) || isempty(pl_barras_raw{k,8})           %%%% Erro se pot�ncia ativa n�o especificada na barra PQV
            error('Barra tipo PQV sem pot�ncia ativa especificada! (linha %d)',k);
        end
        if isempty(pl_barras_raw{k,9}) || isempty(pl_barras_raw{k,10})          %%%% Erro se pot�ncia reativa n�o especificada na barra PQV
            error('Barra tipo PQV sem pot�ncia reativa especificada! (linha %d)',k);
        end
        dadosEntrada.tipoBarra(k-1,1) = 4;
        tempLChave = tempLChave+1;
    else
        error('Valor inv�lido na coluna Tipo, linha %d do arquivo %s',k,nomeArquivo);  %%%% Erro se caracter inv�lido na coluna Tipo
    end
end

if find(dadosEntrada.tipoBarra == 0)
    fprintf('\nLinha %d do excel!\n',k);
    error('Valor inv�lido de tipo de barra detectado na vari�vel tipoBarra');
end

dadosEntrada.coordHorizontal = pl_barras_num(:,3);                              % Vetor com as coordenadas horizontais de cada barra
dadosEntrada.coordVertical = pl_barras_num(:,4);                                % Vetor com as coordenadas verticais de cada barra

dadosEntrada.Vesp = pl_barras_num(:,6);                                         % Vetor com a tens�o especificada de cada barra (kV)
dadosEntrada.Vesp = dadosEntrada.Vesp./dadosEntrada.VbaseBarra;                 % Vetor das tens�es especificadas em pu

dadosEntrada.Pg = pl_barras_num(:,7);                                           % Vetor com as pot�ncias ativas geradas em cada barra
dadosEntrada.Pd = pl_barras_num(:,8);                                           % Vetor com as pot�ncias ativas consumidas em cada barra
dadosEntrada.Qg = pl_barras_num(:,9);                                           % Vetor com as pot�ncias reativas geradas em cada barra
dadosEntrada.Qd = pl_barras_num(:,10);                                          % Vetor com as pot�ncias reativas consumidas em cada barra

bShBarraVar = pl_barras_num(:,11);                                              % Vetor com os shunts em cada barra
dadosEntrada.bShBarra = bShBarraVar./(dadosEntrada.VbaseBarra.^2*1000);         % Transforma��o do shunt de barra de kVAr para Siemens

barrasVT = dadosEntrada.barras(find(dadosEntrada.tipoBarra == 1),1);            % Vetor com as barras VT                 
barrasPV = dadosEntrada.barras(find(dadosEntrada.tipoBarra == 2),1);            % Vetor com as barras PV
barrasPQ = dadosEntrada.barras(find(dadosEntrada.tipoBarra == 3),1);            % Vetor com as barras PQ
barrasPQV = dadosEntrada.barras(find(dadosEntrada.tipoBarra == 4),1);           % Vetor com as barras PQV

waitbar(0.75);                                      % 75% conclu�do

%% Decodifica��o da planilha Trechos

dadosEntrada.linhas = pl_trechos_num(:,1);                       % Numera��o de cada linha
dadosEntrada.de = pl_trechos_num(:,2);                           % Vetor com as barras DE referidas ao vetor de linhas
dadosEntrada.para = pl_trechos_num(:,3);                         % Vetor com as barras PARA referidas ao vetor de linhas
dadosEntrada.r = pl_trechos_num(:,4);                            % Vetor com as resist�ncias de cada linha em Ohm/km
dadosEntrada.x = pl_trechos_num(:,5);                            % Vetor com as reat�ncias de cada linha em Ohm/km
dadosEntrada.b = pl_trechos_num(:,6);                            % Vetor com as reat�ncias shunt de cada lado da linha em S/km
dadosEntrada.b = dadosEntrada.b./2;                              % DIVIS�O DE TODAS AS ADMIT�NCIAS SHUNT DE LINHA POR 2
dist = pl_trechos_num(:,7);                                      % Vetor com as dist�ncias de cada linha em km

%%%% Transforma��o das imped�ncias das linhas para pu

dadosEntrada.VbaseLinha = zeros(length(dadosEntrada.para),1);

for k=1:length(dadosEntrada.para)                                                                       % Cria��o de um vetor de tens�es base para cada uma das linhas (REFER�NCIA: barra PARA)
    dadosEntrada.VbaseLinha(k,1) = max([dadosEntrada.VbaseBarra(dadosEntrada.barras(dadosEntrada.barras == dadosEntrada.de(dadosEntrada.linhas(k)))) dadosEntrada.VbaseBarra(dadosEntrada.barras(dadosEntrada.barras == dadosEntrada.para(dadosEntrada.linhas(k))))]);
end

dadosEntrada.r = dadosEntrada.r.*dist;                                                                  % Resist�ncias das linhas em Ohms
dadosEntrada.x = dadosEntrada.x.*dist;                                                                  % Reat�ncias das linhas em Ohms
dadosEntrada.b = dadosEntrada.b.*dist;                                                                  % Suscept�ncias shunt das linhas em S

dadosEntrada.rConvencional = dadosEntrada.r;                                                            % Resist�ncia em Ohms antes da normaliza��o complexa
dadosEntrada.xConvencional = dadosEntrada.x;                                                            % Reat�ncia indutiva s�rie em Ohms antes da normaliza��o complexa
dadosEntrada.bConvencional = dadosEntrada.b;                                                            % Suscept�ncia shunt em Siemens antes da normaliza��o complexa

moduloZkm = sqrt(dadosEntrada.r.^2 + dadosEntrada.x.^2);                                                % Composi��o das imped�ncias das linhas Z = R + jXl
anguloZkm = acos(dadosEntrada.r./moduloZkm);
zBase = (dadosEntrada.VbaseLinha.^2.*1000)./dadosEntrada.moduloPotenciaBase;
moduloZkmpu = moduloZkm./zBase;
dadosEntrada.r = moduloZkmpu.*cos(anguloZkm + dadosEntrada.anguloPotenciaBase);
dadosEntrada.x = moduloZkmpu.*sin(anguloZkm + dadosEntrada.anguloPotenciaBase);
dadosEntrada.b = dadosEntrada.b./(dadosEntrada.VbaseLinha.^2./dadosEntrada.moduloPotenciaBase*1000);    % Normaliza��o das suscept�ncias paralelas (APENAS PELO M�DULO DA POT�NCIA BASE)

%%%% Tratamento das chaves
dadosEntrada.linhasChaveaveis = zeros(length(dadosEntrada.linhas),1);                                   % Vetor com os �ndices das linhas (ramos) chave�veis
dadosEntrada.statusChaves = ones(length(dadosEntrada.linhas),1)*2;                                      % Vetor com os status de cada chave
tempLChave = 1;
for k=2:size(pl_trechos_txt,1)
    %%%% Identifica��o dos ramos chave�veis
    if pl_trechos_txt{k,8} == 'y' || pl_trechos_txt{k,8} == 'Y' || pl_trechos_txt{k,8} == 's' || pl_trechos_txt{k,8} == 'S'             % Condi��o para chave ativa
        dadosEntrada.linhasChaveaveis(tempLChave,1) = pl_trechos_num(k-1,1);
        %%%% Identifica��o dos estados das chaves
        if pl_trechos_txt{k,9} == 'c' || pl_trechos_txt{k,9} == 'C' || pl_trechos_txt{k,9} == 'a' || pl_trechos_txt{k,9} == 'A'         % Condi��o para chave aberta
            dadosEntrada.statusChaves(tempLChave,1) = 1;
        elseif pl_trechos_txt{k,9} == 'o' || pl_trechos_txt{k,9} == 'O' || pl_trechos_txt{k,9} == 'f' || pl_trechos_txt{k,9} == 'F'     % Condi��o para chave fechada
            dadosEntrada.statusChaves(tempLChave,1) = 0;
        else
            error('Valor inv�lido na coluna STATUS CHAVE, linha %d do arquivo %s',k,nomeArquivo);                                      % Erro se caracter inv�lido na tabela
        end
        if ~isnan(pl_trechos_num(k-1,4)) || ~isnan(pl_trechos_num(k-1,5)) || ~isnan(pl_trechos_num(k-1,6)) || ~isnan(pl_trechos_num(k-1,7))
            error('Ramos chave�veis n�o devem ter imped�ncias, admit�ncias shunt ou dist�ncias especificadas. Erro na linha %d',dadosEntrada.linhas(k-1,1));     %%%% Erro se houver imped�ncia especificada para ramos chave�veis
        end
        tempLChave = tempLChave+1;
    elseif pl_trechos_txt{k,8} == 'n' || pl_trechos_txt{k,8} == 'N'
        if ~isempty(pl_trechos_txt{k,9})                                                    % Erro se houver estado para ramo convencional
            error('Chaveamentos s�o inv�lidos para ramos convencionais!');
        end
        if isnan(pl_trechos_num(k-1,4)) || isnan(pl_trechos_num(k-1,5)) || isnan(pl_trechos_num(k-1,6)) || isnan(pl_trechos_num(k-1,7))
            error('Ramo convencional sem imped�ncia, admit�ncia ou dist�ncia especificada na linha %d',dadosEntrada.linhas(k-1,1));                  %%%% Erro se n�o houver imped�ncia ou admit�ncia shunt especificada para ramos convencionais
        end
    else
        error('Valor inv�lido na coluna CHAVE?, linha %d do arquivo %s',k,nomeArquivo);    % Erro se caracter inv�lido na tabela
    end
    
end

%% Decodifica��o da planilha Transformadores

if isempty(pl_transformadores_num) ~= 1                                                     % Verifica��o se a aba de Transformadores est� vazia na planilha

    dadosEntrada.linhasTrafos = pl_transformadores_num(:,1);                                % Vetor com as linhas nas quais existem transformadores
    dadosEntrada.VnomPrimTrafo = pl_transformadores_num(:,2);                               % Vetor com as tens�es nominais do prim�rio dos transformadores (V�LIDO APENAS PARA VERS�O COM ENTRADA DE DADOS EM ABSOLUTO)
    dadosEntrada.VnomSecTrafo = pl_transformadores_num(:,3);                                % Vetor com as tens�es nominais do secund�rio dos transformadores (V�LIDO APENAS PARA VERS�O COM ENTRADA DE DADOS EM ABSOLUTO)
    dadosEntrada.faixaRegulacao = pl_transformadores_num(:,4);                              % Vetor com as faixas de regula��o dos transformadores
    dadosEntrada.numTapes = pl_transformadores_num(:,5);                                    % Vetor com o n�mero de tapes dos transformadores (TOTAL PARA CIMA E PARA BAIXO)
    dadosEntrada.banda = dadosEntrada.faixaRegulacao./(dadosEntrada.numTapes./2);           % Vetor com a banda de cada transformador (UTILIZADA APENAS PARA TRANSFORMADORES C/ REGULA��O AUTOM�TICA)
    tapFixo = pl_transformadores_num(:,6);                                                  % Vetor com o tap fixo do transformador
    dadosEntrada.linhasTrafosAutomaticos = dadosEntrada.linhasTrafos(isnan(tapFixo));       % Vetor com n�meros das linhas nos quais os transformadores t�m comutadores autom�ticos de tap
    defasagemAngular = pl_transformadores_num(:,7);                                         % Vetor com phi do transformador (apenas fixo!)

    dadosEntrada.tap = ones(length(dadosEntrada.linhas),1);                                 % Inicializa��o do vetor a (tap nas linhas)
    dadosEntrada.phi = zeros(length(dadosEntrada.linhas),1);                                % Inicializa��o do vetor phi (defasagem angular nas linhas)

    %%%% Verifica��o de seguran�a: dois transformadores com comutadores
    %%%% autom�ticos n�o podem regular a tens�o da mesma barra. Logo, dois
    %%%% transformadores n�o podem ter a mesma barra para. (BARRA PARA
    %%%% UTILIZADA COMO REFER�NCIA DE BARRA A SER REGULADA)
    
    for k=1:length(dadosEntrada.linhasTrafosAutomaticos)
       
        if ~isempty(barrasPQV)                                                              % Verifica��o se existem barras do tipo PQV no sistema
            
            flag_erro = 1;                                                                  % Flag para acusar erro se a barra PARA de um transformador n�o possui barra tipo PQV correspondente

            for tempLChave=1:length(barrasPQV)                                                      % Varredura em todas as barras PQV
               if isequal(dadosEntrada.para(dadosEntrada.linhasTrafosAutomaticos(k)),barrasPQV(tempLChave))        
                    flag_erro = 0;                                                          % O flag come�a no estado de erro, e sai quando � encontrada uma barra do tipo PQV
               end
            end

            if flag_erro ~= 0
                error('Erro: o transformador da linha %d n�o possui sua barra PARA do tipo PQV!',k);
            end
            
        elseif isempty(barrasPQV) && ~isempty(dadosEntrada.linhasTrafosAutomaticos)         % Erro se existem transformadores com comutador autom�tico por�m n�o existem barras PQV definidas
            
            error('Erro: existem transformadores com regula��o autom�tica de tap, por�m n�o existem barras definidas como PQV no sistema!');
        
        end
        
        for h=k+1:length(dadosEntrada.linhasTrafosAutomaticos)
            if isequal(dadosEntrada.para(dadosEntrada.linhasTrafosAutomaticos(k)),dadosEntrada.para(dadosEntrada.linhasTrafosAutomaticos(h)))
                error('Erro: dois transformadores comutadores regulando a tens�o da mesma barra! Linhas %d e %d',k,h);
            end
       end
    end

    for k=1:length(dadosEntrada.linhasTrafos)
       if tapFixo(k,1) > (1 + dadosEntrada.faixaRegulacao(k,1)) || tapFixo(k,1) < (1 - dadosEntrada.faixaRegulacao(k,1))
           error('Tap especificado na linha %d da aba Transformadores fora da faixa de regula��o especificada!',k);
       end
       dadosEntrada.tap(dadosEntrada.linhasTrafos(k,1),1) = tapFixo(k,1);                       % Processamento das informa��es de transformadores com tap (fixo = n�mero, autom�tico = NaN)
       if isnan(defasagemAngular(k,1))
           error('Defasagem angular n�o especificada na linha %d da aba Transformadores!',k);
       end
       dadosEntrada.phi(dadosEntrada.linhasTrafos(k,1),1) = deg2rad(defasagemAngular(k,1));     % Processamento das informa��es de transformadores defasadores (apenas fixos)
    end
    
else
    
    dadosEntrada.linhasTrafos = [];                                             % Vetor com as linhas nas quais existem transformadores
    dadosEntrada.VnomPrimTrafo = [];                                            % Vetor com as tens�es nominais do prim�rio dos transformadores (V�LIDO APENAS PARA VERS�O COM ENTRADA DE DADOS EM ABSOLUTO)
    dadosEntrada.VnomSecTrafo = [];                                             % Vetor com as tens�es nominais do secund�rio dos transformadores (V�LIDO APENAS PARA VERS�O COM ENTRADA DE DADOS EM ABSOLUTO)
    dadosEntrada.faixaRegulacao = [];                                           % Vetor com as faixas de regula��o dos transformadores
    dadosEntrada.numTapes = [];                                                 % Vetor com o n�mero de tapes dos transformadores (TOTAL PARA CIMA E PARA BAIXO)
    dadosEntrada.banda = [];                                                    % Vetor com a banda de cada transformador (UTILIZADA APENAS PARA TRANSFORMADORES C/ REGULA��O AUTOM�TICA)
    tapFixo = [];                                                               % Vetor com o tap fixo do transformador
    dadosEntrada.linhasTrafosAutomaticos = [];                                  % Vetor com n�meros das linhas nos quais os transformadores t�m comutadores autom�ticos de tap
    defasagemAngular = [];                                                      % Vetor com phi do transformador (apenas fixo!)
    
    dadosEntrada.tap = ones(length(dadosEntrada.linhas),1);                     % Inicializa��o do vetor a (tap nas linhas)
    dadosEntrada.phi = zeros(length(dadosEntrada.linhas),1);                    % Inicializa��o do vetor phi (defasagem angular nas linhas)

end

%% Inicializa��o das vari�veis

estadosRede.theta = zeros(length(dadosEntrada.barras),1);                                                                        % Inicializa��o dos �ngulos das tens�es nas barras em zero (INCLUSIVE REFER�NCIA ANGULAR) --> EM RADIANOS!!!!
estadosRede.V = dadosEntrada.Vesp;                                                                                   % Inicializa��o dos m�dulos das tens�es nas barras com as tens�es especificadas pelas barras VT e PQ
estadosRede.V(find(isnan(estadosRede.V))) = 1;                                                          % Inicializa��o com m�dulo igual a 1 para o restante das barras
dadosEntrada.tap(find(isnan(dadosEntrada.tap))) = 1;                                                    % Inicializa��o dos taps autom�ticos em 1

% if any(dadosEntrada.linhasChaveaveis == 0)
%     error('Linhas numeradas com zero n�o s�o permitidas!');
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

%%%% Redu��o dos vetores dadosEntrada.linhasChaveaveis e statusChaves
dadosEntrada.linhasChaveaveis(find(dadosEntrada.linhasChaveaveis == 0)) = [];
dadosEntrada.statusChaves(find(dadosEntrada.statusChaves == 2)) = [];

%% Dimens�es do problema

dadosEntrada.nb = length(dadosEntrada.barras);                                  % N�mero de barras
dadosEntrada.nl = length(dadosEntrada.linhas);                                  % N�mero de linhas
dadosEntrada.nrc = length(dadosEntrada.linhasChaveaveis);                       % N�mero de chaves modeladas no sistema
if isempty(dadosEntrada.nrc)
    dadosEntrada.nrc = 0;
end
dadosEntrada.npv = length(barrasPV);                                            % N�mero de barras PV
if isempty(dadosEntrada.npv)
    dadosEntrada.npv = 0;
end
dadosEntrada.npq = length(barrasPQ);                                            % N�mero de barras PQ
if isempty(dadosEntrada.npq)
    dadosEntrada.npq = 0;
end
dadosEntrada.npqv = length(barrasPQV);                                          % N�mero de barras PQV
if isempty(dadosEntrada.npqv)
    dadosEntrada.npqv = 0;
end

waitbar(0.90);                                    % 90% conclu�do

%% Cria��o do arquivo de exporta��o para o MATPOWER

ExportaArquivoMatpower(modoExecucao, dadosEntrada, bShBarraVar);

%% Montagem dos vetores P especificado e Q especificado

%%%% TRATAMENTO DOS ELEMENTOS NaN:
%%%% Os elementos NaN s�o mantidos nas matrizes Pesp e Qesp, sinalizando
%%%% que estas barras n�o possuem pot�ncia especificada (barra PV ou VT)

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

dadosEntrada.A = montaA(dadosEntrada);                                          % Montagem da matriz incid�ncia barra-ramo
[dadosEntrada.Y, dadosEntrada.B, dadosEntrada.G] = montaY3(dadosEntrada);       % Montagem da matriz admit�ncia

%% Processamento de eventuais ilhas

[dadosEntrada, estadosRede, dadosEntradaAntigo, estadosRedeAntigo] = ProcessaRamosIlhados(dadosEntrada, estadosRede);

%% Salva os dados carregados da planilha

waitbar(1);                                         % 100% do progresso da barra

save('dados')                                       % Salva os dados do carregamento da planilha
close(WB);                                          % Fecha a barra de progresso
end