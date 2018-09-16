function [dadosEntrada, estadosRede, dadosEntradaAntigo, estadosRedeAntigo] = ProcessaRamosIlhados(dadosEntrada, estadosRede)

%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% Esta função verifica a necessidade de processamento topológico de
%%%% ramos sem referência de tensão. Ilhas sem referência são deletadas,
%%%% enquanto as ilhas com possíveis referências têm as mesmas designadas
%%%% por uma barra VT.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%%
%%%% v1 - 29/11/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Backup dos dados de entrada antes de sua modificação

dadosEntradaAntigo = dadosEntrada;
estadosRedeAntigo = estadosRede;

%% Retirada das chaves abertas da matriz A

linhasChavesAbertas = dadosEntrada.linhasChaveaveis(find(dadosEntrada.statusChaves==0));        % Descoberta do número das linhas que são chaveáveis e têm seus status como "ABERTA"
Amod = dadosEntrada.A;
Amod(:,linhasChavesAbertas) = 0;                                                                % Zerando todas as linhas das colunas que pertencem a ramos chaveáveis abertos

%% Cálculo dos pivôs nulos da matriz G

%%%% A'*A ou A*A'? O resultado final precisa ter tamanho (nbxnb)
% G = Amod*Amod.';                                                                              % Cálculo de uma matriz Ganho baseada na matriz incidência modificada
% [~, U] = lu(G);
% pivosNulos = find(diag(U)==1e-2);

[pivosNulos] = PesquisaPivosNulos(Amod);

numeroIlhas = length(pivosNulos);                                                      % Número de ilhas sem tensão detectadas

if numeroIlhas > 1

    %% Descoberta das ilhas sem tensão
    
    for k=1:numeroIlhas                                                                % Processamento topológico das ilhas sem tensão
        [barrasIlha{k,1}, linhasIlha{k,1}] = ConectividadeIlhas(pivosNulos(k,1), Amod, dadosEntrada);
    end
    
    %%%% Retirada de duplicatas nas células barrasIlhas e linhasIlha
    barrasIlha = RetiraDuplicatas(barrasIlha);
    linhasIlha = RetiraDuplicatas(linhasIlha);
    numeroIlhas = length(barrasIlha);
    if length(barrasIlha) ~= length(linhasIlha)
        error('Erro na definição do número de ilhas com múltiplas referências no sistema!');
    end
    
    %% Pesquisa das barras candidatas a referência
    
    contadorBarrasPV = ones(numeroIlhas,1);
    contadorIlhasComReferencia = 1;
    
    %%%% Montagem do vetor ilhasComReferencia
    for k=1:numeroIlhas
        for l=1:length(barrasIlha{k,1})
            if dadosEntrada.tipoBarra(dadosEntrada.barras(barrasIlha{k,1}(l,1))) == 1
                ilhasComReferencia(contadorIlhasComReferencia, 1) = k;
                ilhaReferenciaVT = k;                                                           % Sinalização da barra VT original
                contadorIlhasComReferencia = contadorIlhasComReferencia + 1;
            elseif dadosEntrada.tipoBarra(dadosEntrada.barras(barrasIlha{k,1}(l,1))) == 2
                listaBarrasPVIlhas{k,1}(contadorBarrasPV(k,1), 1) = barrasIlha{k,1}(l,1);
                contadorBarrasPV(k,1) = contadorBarrasPV(k,1) + 1;
                if ilhasComReferencia(contadorIlhasComReferencia-1,1) ~= k
                    ilhasComReferencia(contadorIlhasComReferencia, 1) = k;
                    contadorIlhasComReferencia = contadorIlhasComReferencia + 1;
                end
            end
        end
    end
    
    %%%% Montagem do vetor referenciasIlhas (barra de referência de cada ilha)
    for k=1:length(ilhasComReferencia)
        if ilhaReferenciaVT == k
            referenciasIlhas(k,1) = find(dadosEntrada.tipoBarra == 1);
        else
            referenciasIlhas(k,1) = max(listaBarrasPVIlhas{k,1});
        end
    end
    
    %%%% Montagem do vetor ilhasSemReferencia
    ilhasSemReferencia = [];
    if length(ilhasComReferencia) ~= numeroIlhas
        for k=1:numeroIlhas
            ilhasSemReferencia(k,1) = k;
        end
        ilhasSemReferencia(ilhasComReferencia) = [];
    end
    
    %% Criação de tabelas de referência entre novo e antigo (antes e depois de retirar barras e linhas de ilhas sem referência)
    
%     dadosEntradaAntigo = dadosEntrada;                                                          % Vetor original barras
%     
%     dadosEntradaAntigo.barrasReduzido = dadosEntrada.barras;                                    % Vetor com a numeração antiga, porém reduzido (já sem as barras sem referência)
%     dadosEntradaAntigo.linhasReduzido = dadosEntrada.linhas;                                    % Vetor com a numeração antiga, porém reduzido (já sem as linhas sem referência)
%     for k=1:length(ilhasSemReferencia)
%         dadosEntradaAntigo.barrasReduzido(dadosEntrada.barras(barrasIlha{ilhasSemReferencia(k),1})) = [];
%         dadosEntradaAntigo.linhasReduzido(dadosEntrada.linhas(linhasIlha{ilhasSemReferencia(k),1})) = [];
%     end
    
    %% Retirada das linhas e barras em ilhas sem referência (processamento: ilhasSemReferencia)
    if ~isempty(ilhasSemReferencia)
        
%         for k=1:length(ilhasSemReferencia)
%             %%%% Variáveis de barra
%             estadosRede.theta(dadosEntradaAntigo.barras(barrasIlha{ilhasSemReferencia(k),1})) = [];
%             estadosRede.V(dadosEntradaAntigo.barras(barrasIlha{ilhasSemReferencia(k),1})) = [];
%             
%             dadosEntrada.barras(dadosEntradaAntigo.barras(barrasIlha{ilhasSemReferencia(k),1})) = [];
%             dadosEntrada.VbaseBarra(dadosEntradaAntigo.barras(barrasIlha{ilhasSemReferencia(k),1})) = [];
%             dadosEntrada.tipoBarra(dadosEntradaAntigo.barras(barrasIlha{ilhasSemReferencia(k),1})) = [];
%             dadosEntrada.Vesp(dadosEntradaAntigo.barras(barrasIlha{ilhasSemReferencia(k),1})) = [];
%             dadosEntrada.Pesp(dadosEntradaAntigo.barras(barrasIlha{ilhasSemReferencia(k),1})) = [];
%             dadosEntrada.Qesp(dadosEntradaAntigo.barras(barrasIlha{ilhasSemReferencia(k),1})) = [];
%             dadosEntrada.Pg(dadosEntradaAntigo.barras(barrasIlha{ilhasSemReferencia(k),1})) = [];
%             dadosEntrada.Pd(dadosEntradaAntigo.barras(barrasIlha{ilhasSemReferencia(k),1})) = [];
%             dadosEntrada.Qg(dadosEntradaAntigo.barras(barrasIlha{ilhasSemReferencia(k),1})) = [];
%             dadosEntrada.Qd(dadosEntradaAntigo.barras(barrasIlha{ilhasSemReferencia(k),1})) = [];
%             dadosEntrada.bShBarra(dadosEntradaAntigo.barras(barrasIlha{ilhasSemReferencia(k),1})) = [];
%             dadosEntrada.coordHorizontal(dadosEntradaAntigo.barras(barrasIlha{ilhasSemReferencia(k),1})) = [];
%             dadosEntrada.coordVertical(dadosEntradaAntigo.barras(barrasIlha{ilhasSemReferencia(k),1})) = [];
%             dadosEntrada.nb = length(dadosEntrada.barras);
%             
%             barrasVT = dadosEntrada.barras(find(dadosEntrada.tipoBarra == 1),1);                    % Vetor com as barras VT
%             barrasPV = dadosEntrada.barras(find(dadosEntrada.tipoBarra == 2),1);                    % Vetor com as barras PV
%             barrasPQ = dadosEntrada.barras(find(dadosEntrada.tipoBarra == 3),1);                    % Vetor com as barras PQ
%             barrasPQV = dadosEntrada.barras(find(dadosEntrada.tipoBarra == 4),1);                   % Vetor com as barras PQV
%             
%             dadosEntrada.npv = length(barrasPV);                                                    % Número de barras PV
%             if isempty(dadosEntrada.npv)
%                 dadosEntrada.npv = 0;
%             end
%             dadosEntrada.npq = length(barrasPQ);                                                    % Número de barras PQ
%             if isempty(dadosEntrada.npq)
%                 dadosEntrada.npq = 0;
%             end
%             dadosEntrada.npqv = length(barrasPQV);                                                  % Número de barras PQV
%             if isempty(dadosEntrada.npqv)
%                 dadosEntrada.npqv = 0;
%             end
%             
%             % Em construção...
%             %%%% Linhas de transformadores
%             if ~isempty(dadosEntrada.linhasTrafosAutomaticos)
%                 for l=1:length(linhasIlha{ilhasSemReferencia(k),1})
%                     indiceLinhasTrafos = 1;
%                     while indiceLinhasChaveaveis < length(dadosEntrada.linhasChaveaveis)
%                         if linhasIlha{ilhasSemReferencia(k)}(l,1) == dadosEntrada.linhasTrafosAutomaticos(indiceLinhasTrafos,1)
%                             dadosEntrada.linhasTrafosAutomaticos(dadosEntradaAntigo.linhasTrafosAutomaticos(linhasIlha{ilhasSemReferencia(k),1})) = [];
%                             dadosEntrada.VnomPrimTrafo(dadosEntradaAntigo.linhasTrafosAutomaticos(linhasIlha{ilhasSemReferencia(k),1})) = [];
%                             dadosEntrada.VnomSecTrafo(dadosEntradaAntigo.linhasTrafosAutomaticos(linhasIlha{ilhasSemReferencia(k),1})) = [];
%                             dadosEntrada.faixaRegulacao(dadosEntradaAntigo.linhasTrafosAutomaticos(linhasIlha{ilhasSemReferencia(k),1})) = [];
%                             dadosEntrada.numTapes(dadosEntradaAntigo.linhasTrafosAutomaticos(linhasIlha{ilhasSemReferencia(k),1})) = [];
%                             dadosEntrada.banda(dadosEntradaAntigo.linhasTrafosAutomaticos(linhasIlha{ilhasSemReferencia(k),1})) = [];
%                         else
%                             indiceLinhasTrafos = indiceLinhasTrafos + 1;
%                         end
%                     end
%                 end
%             end
%         end
        
            %%%% Limpeza das variáveis para reestruturação
            estadosRede.theta = [];
            estadosRede.V = [];
            estadosRede.t = [];
            estadosRede.u = [];
            
            dadosEntrada.barras = [];
            dadosEntrada.VbaseBarra = [];
            dadosEntrada.tipoBarra = [];
            dadosEntrada.Vesp = [];
            dadosEntrada.Pesp = [];
            dadosEntrada.Qesp = [];
            dadosEntrada.Pg = [];
            dadosEntrada.Pd = [];
            dadosEntrada.Qg = [];
            dadosEntrada.Qd = [];
            dadosEntrada.bShBarra = [];
            dadosEntrada.coordHorizontal = [];
            dadosEntrada.coordVertical = [];
            
            dadosEntrada.linhasTrafosAutomaticos = [];
            dadosEntrada.VnomPrimTrafo = [];
            dadosEntrada.VnomSecTrafo = [];
            dadosEntrada.faixaRegulacao = [];
            dadosEntrada.numTapes = [];
            dadosEntrada.banda = [];
            
            dadosEntrada.linhas = [];
            dadosEntrada.de = [];
            dadosEntrada.para = [];
            dadosEntrada.r = [];
            dadosEntrada.x = [];
            dadosEntrada.b = [];
            dadosEntrada.VbaseLinha = [];
            dadosEntrada.rConvencional = [];
            dadosEntrada.xConvencional = [];
            dadosEntrada.bConvencional = [];
            dadosEntrada.tap = [];
            dadosEntrada.phi = [];
            
            dadosEntrada.linhasChaveaveis = [];
            dadosEntrada.statusChaves = [];

        for k=1:length(ilhasComReferencia)
            
            %%%% Variáveis de barra
            estadosRede.theta = [estadosRede.theta; estadosRedeAntigo.theta(barrasIlha{ilhasComReferencia(k),1})];
            estadosRede.V = [estadosRede.V; estadosRedeAntigo.V(barrasIlha{ilhasComReferencia(k),1})];
            
            dadosEntrada.barras = [dadosEntrada.barras; dadosEntradaAntigo.barras(barrasIlha{ilhasComReferencia(k),1})];
            dadosEntrada.VbaseBarra = [dadosEntrada.VbaseBarra; dadosEntradaAntigo.VbaseBarra(barrasIlha{ilhasComReferencia(k),1})];
            dadosEntrada.tipoBarra = dadosEntradaAntigo.tipoBarra(barrasIlha{ilhasComReferencia(k),1});
            dadosEntrada.Vesp = dadosEntradaAntigo.Vesp(barrasIlha{ilhasComReferencia(k),1});
            dadosEntrada.Pesp = dadosEntradaAntigo.Pesp(barrasIlha{ilhasComReferencia(k),1});
            dadosEntrada.Qesp = dadosEntradaAntigo.Qesp(barrasIlha{ilhasComReferencia(k),1});
            dadosEntrada.Pg = dadosEntradaAntigo.Pg(barrasIlha{ilhasComReferencia(k),1});
            dadosEntrada.Pd = dadosEntradaAntigo.Pd(barrasIlha{ilhasComReferencia(k),1});
            dadosEntrada.Qg = dadosEntradaAntigo.Qg(barrasIlha{ilhasComReferencia(k),1});
            dadosEntrada.Qd = dadosEntradaAntigo.Qd(barrasIlha{ilhasComReferencia(k),1});
            dadosEntrada.bShBarra = dadosEntradaAntigo.bShBarra(barrasIlha{ilhasComReferencia(k),1});
            dadosEntrada.coordHorizontal = dadosEntradaAntigo.coordHorizontal(barrasIlha{ilhasComReferencia(k),1});
            dadosEntrada.coordVertical = dadosEntradaAntigo.coordVertical(barrasIlha{ilhasComReferencia(k),1});

            dadosEntrada.nb = length(dadosEntrada.barras);
            
            barrasVT = dadosEntrada.barras(find(dadosEntrada.tipoBarra == 1),1);                    % Vetor com as barras VT
            barrasPV = dadosEntrada.barras(find(dadosEntrada.tipoBarra == 2),1);                    % Vetor com as barras PV
            barrasPQ = dadosEntrada.barras(find(dadosEntrada.tipoBarra == 3),1);                    % Vetor com as barras PQ
            barrasPQV = dadosEntrada.barras(find(dadosEntrada.tipoBarra == 4),1);                   % Vetor com as barras PQV
            
            dadosEntrada.npv = length(barrasPV);                                                    % Número de barras PV
            if isempty(dadosEntrada.npv)
                dadosEntrada.npv = 0;
            end
            dadosEntrada.npq = length(barrasPQ);                                                    % Número de barras PQ
            if isempty(dadosEntrada.npq)
                dadosEntrada.npq = 0;
            end
            dadosEntrada.npqv = length(barrasPQV);                                                  % Número de barras PQV
            if isempty(dadosEntrada.npqv)
                dadosEntrada.npqv = 0;
            end
            
            %%%% Linhas de transformadores
            if ~isempty(dadosEntrada.linhasTrafosAutomaticos)
                for l=1:length(linhasIlha{ilhasComReferencia(k),1})
                    indiceLinhasTrafos = 1;
                    while indiceLinhasChaveaveis < length(dadosEntrada.linhasChaveaveis)
                        if linhasIlha{ilhasComReferencia(k)}(l,1) == dadosEntrada.linhasTrafosAutomaticos(indiceLinhasTrafos,1)
                            dadosEntrada.linhasTrafosAutomaticos = dadosEntradaAntigo.linhasTrafosAutomaticos(linhasIlha{ilhasComReferencia(k),1});
                            dadosEntrada.VnomPrimTrafo = dadosEntradaAntigo.VnomPrimTrafo(linhasIlha{ilhasComReferencia(k),1});
                            dadosEntrada.VnomSecTrafo = dadosEntradaAntigo.VnomSecTrafo(linhasIlha{ilhasComReferencia(k),1});
                            dadosEntrada.faixaRegulacao = dadosEntradaAntigo.faixaRegulacao(linhasIlha{ilhasComReferencia(k),1});
                            dadosEntrada.numTapes = dadosEntradaAntigo.numTapes(linhasIlha{ilhasComReferencia(k),1});
                            dadosEntrada.banda = dadosEntradaAntigo.banda(linhasIlha{ilhasComReferencia(k),1});
                        else
                            indiceLinhasTrafos = indiceLinhasTrafos + 1;
                        end
                    end
                end
            end
            
            %%%% Variáveis de linha
            
            estadosRede.t = estadosRedeAntigo.t(linhasIlha{ilhasComReferencia(k),1});
            estadosRede.u = estadosRedeAntigo.u(linhasIlha{ilhasComReferencia(k),1});
            
            dadosEntrada.linhas = dadosEntradaAntigo.linhas(linhasIlha{ilhasComReferencia(k),1});
            dadosEntrada.de = dadosEntradaAntigo.de(linhasIlha{ilhasComReferencia(k),1});
            dadosEntrada.para = dadosEntradaAntigo.para(linhasIlha{ilhasComReferencia(k),1});
            dadosEntrada.r = dadosEntradaAntigo.r(linhasIlha{ilhasComReferencia(k),1});
            dadosEntrada.x = dadosEntradaAntigo.x(linhasIlha{ilhasComReferencia(k),1});
            dadosEntrada.b = dadosEntradaAntigo.b(linhasIlha{ilhasComReferencia(k),1});
            dadosEntrada.VbaseLinha = dadosEntradaAntigo.VbaseLinha(linhasIlha{ilhasComReferencia(k),1});
            dadosEntrada.rConvencional = dadosEntradaAntigo.rConvencional(linhasIlha{ilhasComReferencia(k),1});
            dadosEntrada.xConvencional = dadosEntradaAntigo.xConvencional(linhasIlha{ilhasComReferencia(k),1});
            dadosEntrada.bConvencional = dadosEntradaAntigo.bConvencional(linhasIlha{ilhasComReferencia(k),1});
            dadosEntrada.tap = dadosEntradaAntigo.tap(linhasIlha{ilhasComReferencia(k),1});
            dadosEntrada.phi = dadosEntradaAntigo.phi(linhasIlha{ilhasComReferencia(k),1});
            
            %%%% Linhas chaveáveis
            indiceLinhasChaveaveis = 1;
            
            if dadosEntradaAntigo.nrc ~= 0
                for l=1:length(linhasIlha{ilhasComReferencia(k),1})
                    for m=1:length(dadosEntradaAntigo.linhasChaveaveis)
                        if linhasIlha{ilhasComReferencia(k)}(l,1) == dadosEntradaAntigo.linhasChaveaveis(m,1)
                            dadosEntrada.linhasChaveaveis(indiceLinhasChaveaveis,1) = dadosEntradaAntigo.linhasChaveaveis(find(dadosEntradaAntigo.linhasChaveaveis == linhasIlha{ilhasComReferencia(k),1}(l,1)));
                            dadosEntrada.statusChaves(indiceLinhasChaveaveis,1) = dadosEntradaAntigo.statusChaves(find(dadosEntradaAntigo.linhasChaveaveis == linhasIlha{ilhasComReferencia(k),1}(l,1)));
                            indiceLinhasChaveaveis = indiceLinhasChaveaveis + 1;
                        end
                    end
                end
                dadosEntrada.nrc = length(dadosEntrada.linhasChaveaveis);                           % Número de chaves modeladas no sistema
            end
        end
        
        dadosEntrada.nl = length(dadosEntrada.linhas);
    
        %% Renumeração de linhas e barras
        
        %%%% Lista para referência numeração nova e antiga
        dadosEntradaAntigo.barrasCortadas = dadosEntrada.barras;
        dadosEntradaAntigo.linhasCortadas = dadosEntrada.linhas;
        dadosEntradaAntigo.deCortado = dadosEntrada.de;
        dadosEntradaAntigo.paraCortado = dadosEntrada.para;
        dadosEntradaAntigo.linhasChaveaveisCortadas = dadosEntrada.linhasChaveaveis;
        
        %%%% Renumeração das barras
        for k=1:length(dadosEntrada.barras)
            dadosEntrada.barras(k,1) = k;
        end
        
        %%%% Renumeração das linhas
        for k=1:length(dadosEntrada.linhas)
            dadosEntrada.linhas(k,1) = k;
        end
        
        %%%% Renumeração do DE-PARA
        flagDe = false;
        flagPara = false;
        for k=1:length(dadosEntradaAntigo.deCortado)
            for l=1:length(dadosEntradaAntigo.barrasCortadas)
                if dadosEntradaAntigo.deCortado(k) == dadosEntradaAntigo.barrasCortadas(l)
                    dadosEntrada.de(k) = dadosEntrada.barras(l);
                    flagDe = true;
                end
                if dadosEntradaAntigo.paraCortado(k) == dadosEntradaAntigo.barrasCortadas(l)
                    dadosEntrada.para(k) = dadosEntrada.barras(l);
                    flagPara = true;
                end
                if flagDe && flagPara
                    flagDe = false;
                    flagPara = false;
                    break;
                end
            end
        end
        
        %%%% Renumeração linhasChaveaveis
        if dadosEntrada.nrc ~= 0
            for k=1:length(dadosEntrada.linhasChaveaveis)
                for l=1:length(dadosEntrada.linhas)
                    if dadosEntradaAntigo.linhasChaveaveisCortadas(k) == dadosEntradaAntigo.linhasCortadas(l)
                        dadosEntrada.linhasChaveaveis(k) = dadosEntrada.linhas(l);
                        break;
                    end
                end
            end
        end
    end
    %% Modificação do vetor tipoBarra (processamento: ilhasComReferencia)
    
    %%%% Mudança para VT as barras assinaladas como ilhas com tensão
    for k=1:length(ilhasComReferencia)
        dadosEntrada.tipoBarra(dadosEntrada.barras(referenciasIlhas(k,1)),1) = 1;
    end
    
    %%%% Recontagem do número de barras PV após a troca para VT
    barrasPV = dadosEntrada.barras(find(dadosEntrada.tipoBarra == 2),1);                        % Vetor com as barras PV
    dadosEntrada.npv = length(barrasPV);                                                        % Número de barras PV
    if isempty(dadosEntrada.npv)
        dadosEntrada.npv = 0;
    end
    
    %% Remontagem das matrizes do problema
    
    dadosEntrada.A = montaA(dadosEntrada);                                                      % Montagem da matriz incidência barra-ramo
    [dadosEntrada.Y, dadosEntrada.B, dadosEntrada.G] = montaY3(dadosEntrada);                   % Montagem da matriz admitância
    
end
end