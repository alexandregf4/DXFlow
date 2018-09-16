function [linhasAdjacentesChaveaveis, barrasAdjacentesChaveaveis] = ConjuntoTauK(barraInteresse, dadosEntrada)

%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta função retorna a numeração das barras e linhas adjacentes à 
%%%% barra de interesse, ligadas por um ramo chaveável.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 09/05/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% OBS.: Função testada

%% Pesquisa das barras adjacentes à barra de interesse

de_chaveaveis = dadosEntrada.de(dadosEntrada.linhasChaveaveis);
para_chaveaveis = dadosEntrada.para(dadosEntrada.linhasChaveaveis);

temp1 = find(dadosEntrada.A(barraInteresse,:)~=0);                      % Vetor com os índices das linhas adjacentes à barra de interesse
temp1 = temp1';

l = 1;
indices_linhas_adjacentes_chaveaveis = [];
for k=1:length(dadosEntrada.linhasChaveaveis)
    if ~isempty(find(temp1==dadosEntrada.linhasChaveaveis(k)))
        indices_linhas_adjacentes_chaveaveis(l,1) = find(temp1==dadosEntrada.linhasChaveaveis(k));
        l = l+1;
    end
end

linhasAdjacentesChaveaveis = temp1(indices_linhas_adjacentes_chaveaveis);

%%%% Laço para encontrar as barras chaveáveis adjacentes
l = 1;
barrasAdjacentesChaveaveis = [];
for k=1:length(linhasAdjacentesChaveaveis)
    if dadosEntrada.de(linhasAdjacentesChaveaveis(k)) == barraInteresse
        barrasAdjacentesChaveaveis(l,1) = dadosEntrada.para(linhasAdjacentesChaveaveis(k));
        l = l+1;
    elseif dadosEntrada.para(linhasAdjacentesChaveaveis(k)) == barraInteresse
        barrasAdjacentesChaveaveis(l,1) = dadosEntrada.de(linhasAdjacentesChaveaveis(k));
        l = l+1;
    else
        error('Erro! Linha adjacente chaveável calculada errada. Não há correspondencia');
    end
end

barrasAdjacentesChaveaveis = sort(barrasAdjacentesChaveaveis);                % Organização crescente do vetor de barras adjacentes à barra de interesse

end