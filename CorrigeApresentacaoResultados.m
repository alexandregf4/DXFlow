function [dadosEntradaNovo, estadosRedeNovo, PkmNovo, QkmNovo, PkmPerdasNovo] = CorrigeApresentacaoResultados(dadosEntrada, dadosEntradaAntigo, estadosRede, estadosRedeAntigo, Pkm, Qkm, PkmPerdas)

%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta fun��o preenche dados faltantes resultado da retirada de barras
%%%% de ilhas sem refer�ncia de tens�o para apresenta��o da resposta em
%%%% rela��o � numera��o das barras de acordo com os dados de entrada. Para
%%%% a retirada das barras o novo sistema tem de ser renumerado, havendo
%%%% necessidade do processamento pr�vio, feito por esta fun��o, para
%%%% readequar os dados de sa�da conforme a numera��o inicial dos dados de
%%%% entrada.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%%
%%%% v1.0 - 06/12/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Verifica��o da necessidade de execu��o da fun��o (ilhas sem refer�ncia)

% problema na func�o isfield quando a variavel nao existe
if ~isfield(dadosEntradaAntigo, 'barrasCortadas') || ~isfield(dadosEntradaAntigo, 'linhasCortadas') || ~isfield(dadosEntradaAntigo, 'linhasChaveaveisCortadas')
    dadosEntradaNovo = dadosEntrada;
    estadosRedeNovo = estadosRede;
    PkmNovo = Pkm;
    QkmNovo = Qkm;
    PkmPerdasNovo = PkmPerdas;
    return;
end

dadosEntradaNovo = dadosEntradaAntigo;
estadosRedeNovo = estadosRedeAntigo;

%% Preenchimento dos dados de barra

for k=1:dadosEntradaAntigo.nb
    
    indiceBarrasCortadas = find(dadosEntradaAntigo.barras(k) == dadosEntradaAntigo.barrasCortadas);
    
    if isempty(indiceBarrasCortadas)
        estadosRedeNovo.V(k,1) = 0;
        estadosRedeNovo.theta(k,1) = 0;
    else
        estadosRedeNovo.V(k,1) = estadosRede.V(indiceBarrasCortadas,1);
        estadosRedeNovo.theta(k,1) = estadosRede.theta(indiceBarrasCortadas,1);
    end
end

%% Preenchimento dos dados de linha

for k=1:dadosEntradaAntigo.nl
    
    indiceLinhasCortadas = find(dadosEntradaAntigo.linhas(k) == dadosEntradaAntigo.linhasCortadas);
    
    if isempty(indiceLinhasCortadas)
        PkmNovo(k,1) = 0;
        QkmNovo(k,1) = 0;
        PkmPerdasNovo(k,1) = 0;
    else
        PkmNovo(k,1) = Pkm(indiceLinhasCortadas,1);
        QkmNovo(k,1) = Qkm(indiceLinhasCortadas,1);
        PkmPerdasNovo(k,1) = PkmPerdas(indiceLinhasCortadas,1);
    end
end

%% Preenchimento dos dados de linhas chave�veis

for k=1:dadosEntradaAntigo.nrc
    
    indiceLinhasChaveaveisCortadas = find(dadosEntradaAntigo.linhasChaveaveis(k) == dadosEntradaAntigo.linhasChaveaveisCortadas);
    
    if isempty(indiceLinhasChaveaveisCortadas)
        PkmNovo(k,1) = 0;
        QkmNovo(k,1) = 0;
    else
        PkmNovo(k,1) = Pkm(indiceLinhasChaveaveisCortadas,1);
        QkmNovo(k,1) = Qkm(indiceLinhasChaveaveisCortadas,1);
    end
end
end