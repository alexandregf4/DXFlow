function [dadosEntradaNovo, estadosRedeNovo, PkmNovo, QkmNovo, PkmPerdasNovo] = CorrigeApresentacaoResultados(dadosEntrada, dadosEntradaAntigo, estadosRede, estadosRedeAntigo, Pkm, Qkm, PkmPerdas)

%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta função preenche dados faltantes resultado da retirada de barras
%%%% de ilhas sem referência de tensão para apresentação da resposta em
%%%% relação à numeração das barras de acordo com os dados de entrada. Para
%%%% a retirada das barras o novo sistema tem de ser renumerado, havendo
%%%% necessidade do processamento prévio, feito por esta função, para
%%%% readequar os dados de saída conforme a numeração inicial dos dados de
%%%% entrada.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%%
%%%% v1.0 - 06/12/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Verificação da necessidade de execução da função (ilhas sem referência)

% problema na funcão isfield quando a variavel nao existe
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

%% Preenchimento dos dados de linhas chaveáveis

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