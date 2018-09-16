function [dadosEntrada, estadosRede, dadosEntradaAntigo, estadosRedeAntigo] = ProcessaRamosIlhados(dadosEntrada, estadosRede)

%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% Esta fun��o verifica a necessidade de processamento topol�gico de
%%%% ramos sem refer�ncia de tens�o. Ilhas sem refer�ncia s�o deletadas,
%%%% enquanto as ilhas com poss�veis refer�ncias t�m as mesmas designadas
%%%% por uma barra VT.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%%
%%%% v1 - 29/11/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Backup dos dados de entrada antes de sua modifica��o

dadosEntradaAntigo = dadosEntrada;
estadosRedeAntigo = estadosRede;

%% Retirada das chaves abertas da matriz A

linhasChavesAbertas = dadosEntrada.linhasChaveaveis(find(dadosEntrada.statusChaves==0));        % Descoberta do n�mero das linhas que s�o chave�veis e t�m seus status como "ABERTA"
Amod = dadosEntrada.A;
Amod(:,linhasChavesAbertas) = 0;                                                                % Zerando todas as linhas das colunas que pertencem a ramos chave�veis abertos

%% C�lculo dos piv�s nulos da matriz G

%%%% A'*A ou A*A'? O resultado final precisa ter tamanho (nbxnb)
% G = Amod*Amod.';                                                                              % C�lculo de uma matriz Ganho baseada na matriz incid�ncia modificada
% [~, U] = lu(G);
% pivosNulos = find(diag(U)<=1e-5);

[pivosNulos] = PesquisaPivosNulos(Amod);

numeroIlhas = length(pivosNulos);                                                      % N�mero de ilhas sem tens�o detectadas

%% Descoberta das ilhas sem tens�o

for k=1:numeroIlhas                                                                % Processamento topol�gico das ilhas sem tens�o
    [barrasIlha{k,1}, linhasIlha{k,1}] = ConectividadeIlhas(pivosNulos(k,1), Amod, dadosEntrada);
end

%%%% Retirada de duplicatas nas c�lulas barrasIlhas e linhasIlha
barrasIlha = RetiraDuplicatas(barrasIlha);
linhasIlha = RetiraDuplicatas(linhasIlha);
numeroIlhas = length(barrasIlha);
if length(barrasIlha) ~= length(linhasIlha)
    error('Erro na defini��o do n�mero de ilhas com m�ltiplas refer�ncias no sistema!');
end

%% Pesquisa das barras candidatas a refer�ncia
if numeroIlhas > 1
    
    contadorBarrasPV = ones(numeroIlhas,1);
    contadorIlhasComReferencia = 1;
    
    %%%% Montagem do vetor ilhasComReferencia
    for k=1:numeroIlhas
        for l=1:length(barrasIlha{k,1})
            if dadosEntrada.tipoBarra(dadosEntrada.barras(barrasIlha{k,1}(l,1))) == 1
                ilhasComReferencia(contadorIlhasComReferencia, 1) = k;
                ilhaReferenciaVT = k;                                                           % Sinaliza��o da barra VT original
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
    
    %%%% Montagem do vetor referenciasIlhas (barra de refer�ncia de cada ilha)
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
    
    %% Cria��o de tabelas de refer�ncia entre novo e antigo (antes e depois de retirar barras e linhas de ilhas sem refer�ncia)
    
    %     dadosEntradaAntigo = dadosEntrada;                                                          % Vetor original barras
    %
    %     dadosEntradaAntigo.barrasReduzido = dadosEntrada.barras;                                    % Vetor com a numera��o antiga, por�m reduzido (j� sem as barras sem refer�ncia)
    %     dadosEntradaAntigo.linhasReduzido = dadosEntrada.linhas;                                    % Vetor com a numera��o antiga, por�m reduzido (j� sem as linhas sem refer�ncia)
    %     for k=1:length(ilhasSemReferencia)
    %         dadosEntradaAntigo.barrasReduzido(dadosEntrada.barras(barrasIlha{ilhasSemReferencia(k),1})) = [];
    %         dadosEntradaAntigo.linhasReduzido(dadosEntrada.linhas(linhasIlha{ilhasSemReferencia(k),1})) = [];
    %     end
    
    %% Retirada das linhas e barras em ilhas sem refer�ncia (processamento: ilhasSemReferencia)
    if ~isempty(ilhasSemReferencia)
        
        %%%% Limpeza das vari�veis para reestrutura��o
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
            
            %%%% Vari�veis de barra
            estadosRede.theta = [estadosRede.theta; estadosRedeAntigo.theta(barrasIlha{ilhasComReferencia(k),1})];
            estadosRede.V = [estadosRede.V; estadosRedeAntigo.V(barrasIlha{ilhasComReferencia(k),1})];
            
            dadosEntrada.barras = [dadosEntrada.barras; dadosEntradaAntigo.barras(barrasIlha{ilhasComReferencia(k),1})];
            dadosEntrada.VbaseBarra = [dadosEntrada.VbaseBarra; dadosEntradaAntigo.VbaseBarra(barrasIlha{ilhasComReferencia(k),1})];
            dadosEntrada.tipoBarra = [dadosEntrada.tipoBarra; dadosEntradaAntigo.tipoBarra(barrasIlha{ilhasComReferencia(k),1})];
            dadosEntrada.Vesp = [dadosEntrada.Vesp; dadosEntradaAntigo.Vesp(barrasIlha{ilhasComReferencia(k),1})];
            dadosEntrada.Pesp = [dadosEntrada.Pesp; dadosEntradaAntigo.Pesp(barrasIlha{ilhasComReferencia(k),1})];
            dadosEntrada.Qesp = [dadosEntrada.Qesp; dadosEntradaAntigo.Qesp(barrasIlha{ilhasComReferencia(k),1})];
            dadosEntrada.Pg = [dadosEntrada.Pg; dadosEntradaAntigo.Pg(barrasIlha{ilhasComReferencia(k),1})];
            dadosEntrada.Pd = [dadosEntrada.Pd; dadosEntradaAntigo.Pd(barrasIlha{ilhasComReferencia(k),1})];
            dadosEntrada.Qg = [dadosEntrada.Qg; dadosEntradaAntigo.Qg(barrasIlha{ilhasComReferencia(k),1})];
            dadosEntrada.Qd = [dadosEntrada.Qd; dadosEntradaAntigo.Qd(barrasIlha{ilhasComReferencia(k),1})];
            dadosEntrada.bShBarra = [dadosEntrada.bShBarra; dadosEntradaAntigo.bShBarra(barrasIlha{ilhasComReferencia(k),1})];
            dadosEntrada.coordHorizontal = [dadosEntrada.coordHorizontal; dadosEntradaAntigo.coordHorizontal(barrasIlha{ilhasComReferencia(k),1})];
            dadosEntrada.coordVertical = [dadosEntrada.coordVertical; dadosEntradaAntigo.coordVertical(barrasIlha{ilhasComReferencia(k),1})];
            
            
            %%%% Linhas de transformadores
            if ~isempty(dadosEntrada.linhasTrafosAutomaticos)
                for l=1:length(linhasIlha{ilhasComReferencia(k),1})
                    indiceLinhasTrafos = 1;
                    while indiceLinhasChaveaveis < length(dadosEntrada.linhasChaveaveis)
                        if linhasIlha{ilhasComReferencia(k)}(l,1) == dadosEntrada.linhasTrafosAutomaticos(indiceLinhasTrafos,1)
                            dadosEntrada.linhasTrafosAutomaticos = [dadosEntrada.linhasTrafosAutomaticos; dadosEntradaAntigo.linhasTrafosAutomaticos(linhasIlha{ilhasComReferencia(k),1})];
                            dadosEntrada.VnomPrimTrafo = [dadosEntrada.VnomPrimTrafo; dadosEntradaAntigo.VnomPrimTrafo(linhasIlha{ilhasComReferencia(k),1})];
                            dadosEntrada.VnomSecTrafo = [dadosEntrada.VnomSecTrafo; dadosEntradaAntigo.VnomSecTrafo(linhasIlha{ilhasComReferencia(k),1})];
                            dadosEntrada.faixaRegulacao = [dadosEntrada.faixaRegulacao; dadosEntradaAntigo.faixaRegulacao(linhasIlha{ilhasComReferencia(k),1})];
                            dadosEntrada.numTapes = [dadosEntrada.numTapes; dadosEntradaAntigo.numTapes(linhasIlha{ilhasComReferencia(k),1})];
                            dadosEntrada.banda = [dadosEntrada.banda; dadosEntradaAntigo.banda(linhasIlha{ilhasComReferencia(k),1})];
                        else
                            indiceLinhasTrafos = indiceLinhasTrafos + 1;
                        end
                    end
                end
            end
            
            %%%% Vari�veis de linha
            
            estadosRede.t = [estadosRede.t; estadosRedeAntigo.t(linhasIlha{ilhasComReferencia(k),1})];
            estadosRede.u = [estadosRede.u; estadosRedeAntigo.u(linhasIlha{ilhasComReferencia(k),1})];
            
            dadosEntrada.linhas = [dadosEntrada.linhas; dadosEntradaAntigo.linhas(linhasIlha{ilhasComReferencia(k),1})];
            dadosEntrada.de = [dadosEntrada.de; dadosEntradaAntigo.de(linhasIlha{ilhasComReferencia(k),1})];
            dadosEntrada.para = [dadosEntrada.para; dadosEntradaAntigo.para(linhasIlha{ilhasComReferencia(k),1})];
            dadosEntrada.r = [dadosEntrada.r; dadosEntradaAntigo.r(linhasIlha{ilhasComReferencia(k),1})];
            dadosEntrada.x = [dadosEntrada.x; dadosEntradaAntigo.x(linhasIlha{ilhasComReferencia(k),1})];
            dadosEntrada.b = [dadosEntrada.b; dadosEntradaAntigo.b(linhasIlha{ilhasComReferencia(k),1})];
            dadosEntrada.VbaseLinha = [dadosEntrada.VbaseLinha; dadosEntradaAntigo.VbaseLinha(linhasIlha{ilhasComReferencia(k),1})];
            dadosEntrada.rConvencional = [dadosEntrada.rConvencional; dadosEntradaAntigo.rConvencional(linhasIlha{ilhasComReferencia(k),1})];
            dadosEntrada.xConvencional = [dadosEntrada.xConvencional; dadosEntradaAntigo.xConvencional(linhasIlha{ilhasComReferencia(k),1})];
            dadosEntrada.bConvencional = [dadosEntrada.bConvencional; dadosEntradaAntigo.bConvencional(linhasIlha{ilhasComReferencia(k),1})];
            dadosEntrada.tap = [dadosEntrada.tap; dadosEntradaAntigo.tap(linhasIlha{ilhasComReferencia(k),1})];
            dadosEntrada.phi = [dadosEntrada.phi; dadosEntradaAntigo.phi(linhasIlha{ilhasComReferencia(k),1})];
            
            %%%% Linhas chave�veis
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
            end
        end
        
        dadosEntrada.nl = length(dadosEntrada.linhas);
        dadosEntrada.nb = length(dadosEntrada.barras);
        
        barrasVT = dadosEntrada.barras(find(dadosEntrada.tipoBarra == 1),1);                    % Vetor com as barras VT
        barrasPV = dadosEntrada.barras(find(dadosEntrada.tipoBarra == 2),1);                    % Vetor com as barras PV
        barrasPQ = dadosEntrada.barras(find(dadosEntrada.tipoBarra == 3),1);                    % Vetor com as barras PQ
        barrasPQV = dadosEntrada.barras(find(dadosEntrada.tipoBarra == 4),1);                   % Vetor com as barras PQV
        
        dadosEntrada.npv = length(barrasPV);                                                    % N�mero de barras PV
        if isempty(dadosEntrada.npv)
            dadosEntrada.npv = 0;
        end
        dadosEntrada.npq = length(barrasPQ);                                                    % N�mero de barras PQ
        if isempty(dadosEntrada.npq)
            dadosEntrada.npq = 0;
        end
        dadosEntrada.npqv = length(barrasPQV);                                                  % N�mero de barras PQV
        if isempty(dadosEntrada.npqv)
            dadosEntrada.npqv = 0;
        end
        
        dadosEntrada.nrc = length(dadosEntrada.linhasChaveaveis);                           % N�mero de chaves modeladas no sistema
    end
    
    %% Modifica��o do vetor tipoBarra (processamento: ilhasComReferencia)
    
    %%%% Mudan�a para VT as barras assinaladas como ilhas com tens�o
    for k=1:length(ilhasComReferencia)
        dadosEntrada.tipoBarra(find(dadosEntrada.barras == referenciasIlhas(k,1)),1) = 1;
    end
    
    %%%% Recontagem do n�mero de barras PV ap�s a troca para VT
    barrasPV = dadosEntrada.barras(find(dadosEntrada.tipoBarra == 2),1);                        % Vetor com as barras PV
    dadosEntrada.npv = length(barrasPV);                                                        % N�mero de barras PV
    if isempty(dadosEntrada.npv)
        dadosEntrada.npv = 0;
    end
    
    %% Renumera��o de linhas e barras
    if ~isempty(ilhasSemReferencia)
        %%%% Lista para refer�ncia numera��o nova e antiga
        dadosEntradaAntigo.barrasCortadas = dadosEntrada.barras;
        dadosEntradaAntigo.linhasCortadas = dadosEntrada.linhas;
        dadosEntradaAntigo.deCortado = dadosEntrada.de;
        dadosEntradaAntigo.paraCortado = dadosEntrada.para;
        dadosEntradaAntigo.linhasChaveaveisCortadas = dadosEntrada.linhasChaveaveis;
        
        %%%% Renumera��o das barras
        for k=1:length(dadosEntrada.barras)
            dadosEntrada.barras(k,1) = k;
        end
        
        %%%% Renumera��o das linhas
        for k=1:length(dadosEntrada.linhas)
            dadosEntrada.linhas(k,1) = k;
        end
        
        %%%% Renumera��o do DE-PARA
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
        
        %%%% Renumera��o linhasChaveaveis
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
    
    %% Remontagem das matrizes do problema
    
    dadosEntrada.A = montaA(dadosEntrada);                                                      % Montagem da matriz incid�ncia barra-ramo
%     [dadosEntrada.Y, dadosEntrada.B, dadosEntrada.G] = montaY3(dadosEntrada);                   % Montagem da matriz admit�ncia
    
end
end