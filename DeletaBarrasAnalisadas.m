function [novoVetorConectadas] = DeletaBarrasAnalisadas(vetorConectadas, vetorAnalisadas)

%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% Esta função deleta do vetor de barras/linhas conectadas as
%%%% barras/linhas já analisadas pelo algortimo_busca_ilha.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%%
%%%% v1 - 08/11/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Retirada das barras conectadas que já foram analisadas anteriormente

novoVetorConectadas = vetorConectadas;
a = 1;
indiceDelecao = [];
for p=1:length(vetorConectadas)
    for q=1:length(vetorAnalisadas)
        if vetorConectadas(p,1) == vetorAnalisadas(q,1)
            indiceDelecao(a,1) = p;
            a = a+1;
        end
    end
end

if ~isempty(indiceDelecao)
    novoVetorConectadas(indiceDelecao) = [];
end