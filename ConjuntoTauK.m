function [linhasAdjacentesChaveaveis, barrasAdjacentesChaveaveis] = ConjuntoTauK(barraInteresse, dadosEntrada)

%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta fun��o retorna a numera��o das barras e linhas adjacentes � 
%%%% barra de interesse, ligadas por um ramo chave�vel.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 09/05/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% OBS.: Fun��o testada

%% Pesquisa das barras adjacentes � barra de interesse

de_chaveaveis = dadosEntrada.de(dadosEntrada.linhasChaveaveis);
para_chaveaveis = dadosEntrada.para(dadosEntrada.linhasChaveaveis);

temp1 = find(dadosEntrada.A(barraInteresse,:)~=0);                      % Vetor com os �ndices das linhas adjacentes � barra de interesse
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

%%%% La�o para encontrar as barras chave�veis adjacentes
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
        error('Erro! Linha adjacente chave�vel calculada errada. N�o h� correspondencia');
    end
end

barrasAdjacentesChaveaveis = sort(barrasAdjacentesChaveaveis);                % Organiza��o crescente do vetor de barras adjacentes � barra de interesse

end