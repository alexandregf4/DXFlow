function [deltaTheta, deltaV, deltaAkm, deltaTkm, deltaUkm] = RemontaVetores3(dadosEntrada, variavelDeltaX, barrasDeltaPQ, xvar)

%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta fun��o transforma o vetor xvar (delta) montado em blocos 
%%%% resultado da equa��o:
%%%%                        xvar = J^-1*delta_PQ
%%%%
%%%%                            [delta_theta1]
%%%%                            [delta_a21]
%%%%                            [delta_theta2]
%%%%                            [delta_V2]
%%%%                            [delta_theta3]
%%%%                            [delta_a13]
%%%%                            ........
%%%%                            ........
%%%%                            [delta_thetan]
%%%%                            [delta_Vn]
%%%%                            [delta_tkm]
%%%%                            [delta_ukm]
%%%%
%%%% em tr�s vetores separados:
%%%% [delta_theta1]  |     0      | [delta_a21] | [delta_tkm] | [delta_ukm]
%%%% [delta_theta2]  | [delta_V2] |      0      |             |
%%%% [delta_theta3]  |     0      | [delta_a13] |             |
%%%% ..............  | .......... | ........... |             |
%%%% [delta_thetan]  | [delta_Vn] |      0      |             |
%%%%                         
%%%% Os vetores delta_theta e delta_V possuem tamanho nb enquanto o vetor
%%%% delta_akm possui tamanho nl.
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 02/08/2014
%%%% v2 - 21/09/2014 / Adicionado vetor akm e restri��o da fun��o apenas
%%%% para remontar o vetor delta
%%%% v3 - 27/05/2015 / Adicionadas vari�veis tkm e ukm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Montagem dos vetores

linha_akm = dadosEntrada.linhasTrafosAutomaticos;

if size(xvar,1) ~= 2*dadosEntrada.npq+2*dadosEntrada.npqv+dadosEntrada.npv+2*dadosEntrada.nrc               % Erro se o vetor tiver um tamanho diferente de 2*npq + npv              
    error('O tamanho do vetor de entrada � diferente de 2*npq+2*npqv+npv+2nrc.\n\n');
end

if size(xvar,2) ~= 1                                    % Erro se o dado de entrada n�o for vetor
    error('O dado de entrada possui mais de uma coluna!');
end

deltaTheta = zeros(dadosEntrada.nb,1);                              % Inicializa��o do vetor delta_theta com tamanho nb
deltaV = zeros(dadosEntrada.nb,1);                                  % Inicializa��o do vetor delta_V com tamanho nb
deltaAkm = zeros(dadosEntrada.nl,1);                                % Inicializa��o do vetor delta_akm com tamanho nl
deltaTkm = NaN(dadosEntrada.nl,1);                                  % Inicializa��o do vetor delta_tkm com tamanho nl  
deltaUkm = NaN(dadosEntrada.nl,1);                                  % Inicializa��o do vetor delta_ukm com tamanho nl

for k=1:length(xvar)                                                % La�o para constru��o dos vetores delta_theta, delta_V e delta_akm
    
    indice_xvar_linhas_chaveaveis = ...
        k - (2*dadosEntrada.npq+2*dadosEntrada.npqv+dadosEntrada.npv);                         % �ndice de xvar sem a parte das vari�veis convencionais
    
    if strcmp(variavelDeltaX{k,1},'O')                              % Se nesta posi��o for theta
        deltaTheta(barrasDeltaPQ(k)) = xvar(k);                         % Vetor delta_theta recebe elemento do vetor dado de entrada
    elseif strcmp(variavelDeltaX{k,1},'V')                          % Se nesta posi��o for V
        deltaV(barrasDeltaPQ(k)) = xvar(k);                             % Vetor delta_V recebe elemento do vetor dado de entrada
    elseif strcmp(variavelDeltaX{k,1},'a')                          % Se nesta posi��o for a
        for h=1:length(linha_akm)                                       % La�o para encontrar a linha do vetor akm correspondente ao para igual � barras_delta_PQ (barra do antigo vetor V na mesma posi��o)
                if dadosEntrada.para(linha_akm(h)) == barrasDeltaPQ(k)
                    break;
                end
        end
        deltaAkm(linha_akm(h)) = xvar(k);                           % Vetor delta_akm recebe elemento do vetor dado de entrada
    elseif strcmp(variavelDeltaX{k,1},'t')                          % Se nessa posi��o for t (fluxo de pot. ativa em ramo chave�vel)
        if indice_xvar_linhas_chaveaveis > 0
            indice_t = (indice_xvar_linhas_chaveaveis + 1)/2;           % �ndice correto para procurar xvar nas linhas chave�veis
            deltaTkm(dadosEntrada.linhasChaveaveis(indice_t,1),1) = xvar(k);       % Vetor delta_tkm recebe elemento do vetor dado de entrada
        end
    elseif strcmp(variavelDeltaX{k,1},'u')                          % Se nessa posi��o for u (fluxo de pot. reativa em ramo chave�vel)
        if indice_xvar_linhas_chaveaveis > 0
            indice_u = indice_xvar_linhas_chaveaveis/2;
            deltaUkm(dadosEntrada.linhasChaveaveis(indice_u,1),1) = xvar(k);       % Vetor delta_ukm recebe elemento do vetor dado de entrada
        end
    else                                                            % Se n�o for nem theta, nem V, nem A, nem T, nem U, exibir erro
        error('Tipo inv�lido no vetor variavelDeltaX! Linha %d\n\n',k);
    end
end