function [BP, BQ] = MontaBLinha4(auxiliar, dadosEntrada, barrasMismatchesP, barrasMismatchesQ, potenciaMismatchesP, variavelDeltaXP, potenciaMismatchesQ, variavelDeltaXQ)

%% Cabe�alho
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta fun��o monta as matrizes B' e B'', invari�veis, do m�todo 
%%%% desacoplado r�pido, conforme a nomenclatura abaixo:
%%%%
%%%% XX: B' = X     B'' = X
%%%% XB: B' = X     B'' = B (recomendado para melhor converg�ncia)
%%%% BX: B' = B     B'' = X (recomendado para melhor converg�ncia)
%%%% BB: B' = B     B'' = B
%%%%
%%%% No c�digo as matrizes B' e B'' s�o chamadas respectivamente de BP e
%%%% BQ.
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 12/04/2015
%%%% ...
%%%% v4 - 13/06/2015 / Modificado para n�vel de se��o de barras desacoplado
%%%% r�pido.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Tratamento da op��o do m�todo desacoplado r�pido

%%%% Op��es para o m�todo desacoplado r�pido
%%%% 1 - XX
%%%% 2 - BX
%%%% 3 - XB
%%%% 4 - BB

if strcmp(lower(auxiliar.opcaoDesacoplado),'xx')
    auxiliar.opcaoDesacoplado = 1;
elseif strcmp(lower(auxiliar.opcaoDesacoplado),'bx')
    auxiliar.opcaoDesacoplado = 2;
elseif strcmp(lower(auxiliar.opcaoDesacoplado),'xb')
    auxiliar.opcaoDesacoplado = 3;
elseif strcmp(lower(auxiliar.opcaoDesacoplado),'bb')
    auxiliar.opcaoDesacoplado = 4;
else
    error('Op��o inv�lida selecionada para o m�todo desacoplado! O programa ser� terminado.');
end

%% Montagem da matriz B' (BP)

BP = zeros(dadosEntrada.npv+dadosEntrada.npq+dadosEntrada.npqv+dadosEntrada.nrc,dadosEntrada.npv+dadosEntrada.npq+dadosEntrada.npqv+dadosEntrada.nrc);

for l = 1: size(BP,1)
    for c = 1:size(BP,2)
        
        %%%% B' = X
        if auxiliar.opcaoDesacoplado == 1 || auxiliar.opcaoDesacoplado == 3
            
            %%%% Se � elemento diagonal
            if l==c
                
                %%%% Se a linha � referente a um mismatch de pot�ncia ativa
                if strcmp(potenciaMismatchesP{l,1},'P')
                    
                    %%%% Se a coluna � referente a um ramo chave�vel
                    if strcmp(variavelDeltaXP{c,1},'t')
                        BP(l,c) = CalculaT(auxiliar.opcaoDesacoplado, l, c, dadosEntrada, barrasMismatchesP);
                    %%%% Se a coluna � referente a um ramo convencional
                    else
                        [linhasAdjacentes, ~] = ConjuntoOmegaK(barrasMismatchesP(l,1), dadosEntrada);
                        for u=1:length(linhasAdjacentes)
                            % SOMATORIO 1/xkm
                            BP(l,c) = BP(l,c) + 1./(dadosEntrada.x(linhasAdjacentes(u,1),1));
                        end
                    end
                
                %%%% Se a linha n�o � referente a um mismatch de pot�ncia
                %%%% ativa (mismatches relativos aos ramos chave�veis)
                else
                    
                    %%%% Se chave mismatch se refere a uma chave fechada e
                    %%%% a coluna se refere � vari�vel theta
                    if strcmp(potenciaMismatchesP{l,1},'t_cl') && strcmp(variavelDeltaXP{c,1},'O')
                        BP(l,c) = CalculaC(auxiliar.opcaoDesacoplado, l, c, barrasMismatchesP, dadosEntrada);
                    
                    %%%% Se chave mismatch se refere a uma chave aberta e
                    %%%% a coluna se refere � vari�vel t
                    elseif strcmp(potenciaMismatchesP{l,1},'t_op') && strcmp(variavelDeltaXP{c,1},'t')
                        BP(l,c) = CalculaO(auxiliar.opcaoDesacoplado, l, c, dadosEntrada);
                    end
                end
                
            %%%% Se N�O � elemento diagonal
            else
                
                %%%% Se a linha � referente a um mismatch de pot�ncia ativa
                if strcmp(potenciaMismatchesP{l,1},'P')
                    
                    %%%% Se a coluna � referente a um ramo chave�vel
                    if strcmp(variavelDeltaXP{c,1},'t')
                        BP(l,c) = CalculaT(auxiliar.opcaoDesacoplado, l, c, dadosEntrada, barrasMismatchesP);
                        
                    %%%% Se a coluna � referente a um ramo convencional
                    else
                        [linha_encontrada, ~] = EncontraIndiceLinha(barrasMismatchesP(l,1), barrasMismatchesP(c,1), dadosEntrada);
                        if linha_encontrada ~= 0
                            if ~isnan(dadosEntrada.x(linha_encontrada,1))
                                BP(l,c) = -(1./dadosEntrada.x(linha_encontrada,1));
                            end
                        end
                    end
                 
                 %%%% Se a linha n�o � referente a um mismatch de pot�ncia
                 %%%% ativa (mismatches relativos aos ramos chave�veis)
                 else
                        
                    %%%% Se chave mismatch se refere a uma chave fechada e
                    %%%% a coluna se refere � vari�vel theta
                    if strcmp(potenciaMismatchesP{l,1},'t_cl') && strcmp(variavelDeltaXP{c,1},'O')
                        BP(l,c) = CalculaC(auxiliar.opcaoDesacoplado, l, c, barrasMismatchesP, dadosEntrada);
                    
                    %%%% Se chave mismatch se refere a uma chave aberta e
                    %%%% a coluna se refere � vari�vel t
                    elseif strcmp(potenciaMismatchesP{l,1},'t_op') && strcmp(variavelDeltaXP{c,1},'t')
                        BP(l,c) = CalculaO(auxiliar.opcaoDesacoplado, l, c, dadosEntrada);
                    end
                end
            end
            
        %%%% B' = B    
        elseif auxiliar.opcaoDesacoplado == 2 || auxiliar.opcaoDesacoplado == 4
            
            %%%% Se a linha � referente a um mismatch de pot�ncia ativa
            if strcmp(potenciaMismatchesP{l,1},'P')
            
                %%%% Se a coluna � referente a um ramo chave�vel
                if strcmp(variavelDeltaXP{c,1},'t')
                    BP(l,c) = CalculaT(auxiliar.opcaoDesacoplado, l, c, dadosEntrada, barrasMismatchesP);
                
                %%%% Se a coluna � referente a um ramo convencional
                else
                    BP(l,c) = -dadosEntrada.B(barrasMismatchesP(l,1), barrasMismatchesP(c,1));
                end
            
            %%%% Se a linha n�o � referente a um mismatch de pot�ncia
            %%%% ativa (mismatches relativos aos ramos chave�veis)
            else
                
                %%%% Se chave mismatch se refere a uma chave fechada e
                %%%% a coluna se refere � vari�vel theta
                if strcmp(potenciaMismatchesP{l,1},'t_cl') && strcmp(variavelDeltaXP{c,1},'O')
                    BP(l,c) = CalculaC(auxiliar.opcaoDesacoplado, l, c, barrasMismatchesP, dadosEntrada);
                    
                %%%% Se chave mismatch se refere a uma chave aberta e
                %%%% a coluna se refere � vari�vel t
                elseif strcmp(potenciaMismatchesP{l,1},'t_op') && strcmp(variavelDeltaXP{c,1},'t')
                    BP(l,c) = CalculaO(auxiliar.opcaoDesacoplado, l, c, dadosEntrada);
                end
            end
        end
    end
end

%% Montagem da matriz B'' (BQ)

BQ = zeros(dadosEntrada.npq+dadosEntrada.npqv+dadosEntrada.nrc,dadosEntrada.npq+dadosEntrada.npqv+dadosEntrada.nrc);

for l = 1: size(BQ,1)
    for c = 1:size(BQ,2)
        
        %%%% B' = X
        if auxiliar.opcaoDesacoplado == 1 || auxiliar.opcaoDesacoplado == 2
            
            %%%% Se � elemento diagonal
            if l==c
                
                %%%% Se a linha � referente a um mismatch de pot�ncia
                %%%% reativa
                if strcmp(potenciaMismatchesQ{l,1},'Q')
                    
                    %%%% Se a coluna � referente a um ramo chave�vel
                    if strcmp(variavelDeltaXQ{c,1},'u')
                        BQ(l,c) = CalculaU(auxiliar.opcaoDesacoplado, l, c, dadosEntrada, barrasMismatchesQ);
                    %%%% Se a coluna � referente a um ramo convencional
                    else
                        [linhasAdjacentes, ~] = ConjuntoOmegaK(barrasMismatchesQ(l,1), dadosEntrada);
                        for u=1:length(linhasAdjacentes)
                            % SOMATORIO 1/xkm
                            BQ(l,c) = BQ(l,c) + 1./(dadosEntrada.x(linhasAdjacentes(u,1),1));
                        end
                    end
                    
                else
                    %%%% Se chave mismatch se refere a uma chave fechada e
                    %%%% a coluna se refere � vari�vel V
                    if strcmp(potenciaMismatchesQ{l,1},'u_cl') && strcmp(variavelDeltaXQ{c,1},'V')
                        BQ(l,c) = CalculaD(auxiliar.opcaoDesacoplado, l, c, barrasMismatchesQ, dadosEntrada);
                        
                    %%%% Se chave mismatch se refere a uma chave aberta e
                    %%%% a coluna se refere � vari�vel u
                    elseif strcmp(potenciaMismatchesP{l,1},'u_op') && strcmp(variavelDeltaXP{c,1},'u')
                        BQ(l,c) = CalculaP(auxiliar.opcaoDesacoplado, l, c, dadosEntrada);
                    end
                end
                
            %%%% Se N�O � elemento diagonal
            else
                
                %%%% Se a linha � referente a um mismatch de pot�ncia
                %%%% reativa
                if strcmp(potenciaMismatchesQ{l,1},'Q')
                    
                    %%%% Se a coluna � referente a um ramo chave�vel
                    if strcmp(variavelDeltaXQ{c,1},'u')
                        BQ(l,c) = CalculaU(auxiliar.opcaoDesacoplado, l, c, dadosEntrada, barrasMismatchesQ);
                        
                        %%%% Se a coluna � referente a um ramo convencional
                    else
                        [linha_encontrada, ~] = EncontraIndiceLinha(barrasMismatchesQ(l,1), barrasMismatchesQ(c,1), dadosEntrada);
                        if linha_encontrada ~= 0
                            if ~isnan(dadosEntrada.x(linha_encontrada,1))
                                BQ(l,c) = -(1./dadosEntrada.x(linha_encontrada,1));
                            end
                        end
                    end
                    
                %%%% Se a linha n�o � referente a um mismatch de pot�ncia
                %%%% reativa (mismatches relativos aos ramos chave�veis)
                else
                    %%%% Se chave mismatch se refere a uma chave fechada e
                    %%%% a coluna se refere � vari�vel V
                    if strcmp(potenciaMismatchesQ{l,1},'u_cl') && strcmp(variavelDeltaXQ{c,1},'V')
                        BQ(l,c) = CalculaD(auxiliar.opcaoDesacoplado, l, c, barrasMismatchesQ, dadosEntrada);
                        
                    %%%% Se chave mismatch se refere a uma chave aberta e
                    %%%% a coluna se refere � vari�vel u
                    elseif strcmp(potenciaMismatchesQ{l,1},'u_op') && strcmp(variavelDeltaXQ{c,1},'u')
                        BQ(l,c) = CalculaP(auxiliar.opcaoDesacoplado, l, c, dadosEntrada);
                    end
                end
            end
                
            %%%% B' = B
            elseif auxiliar.opcaoDesacoplado == 3 || auxiliar.opcaoDesacoplado == 4
                
                %%%% Se a linha � referente a um mismatch de pot�ncia reativa
                if strcmp(potenciaMismatchesQ{l,1},'Q')
                    
                    %%%% Se a coluna � referente a um ramo chave�vel
                    if strcmp(variavelDeltaXQ{c,1},'u')
                        BQ(l,c) = CalculaU(auxiliar.opcaoDesacoplado, l, c, dadosEntrada, barrasMismatchesQ);
                        
                        %%%% Se a coluna � referente a um ramo convencional
                    else
                        BQ(l,c) = -dadosEntrada.B(barrasMismatchesQ(l,1), barrasMismatchesQ(c,1));
                    end
                    
                    %%%% Se a linha n�o � referente a um mismatch de pot�ncia
                    %%%% reativa (mismatches relativos aos ramos chave�veis)
                else
                    
                    %%%% Se chave mismatch se refere a uma chave fechada e
                    %%%% a coluna se refere � vari�vel V
                    if strcmp(potenciaMismatchesQ{l,1},'u_cl') && strcmp(variavelDeltaXQ{c,1},'V')
                        BQ(l,c) = CalculaD(auxiliar.opcaoDesacoplado, l, c, barrasMismatchesQ, dadosEntrada);
                        
                        %%%% Se chave mismatch se refere a uma chave aberta e
                        %%%% a coluna se refere � vari�vel t
                    elseif strcmp(potenciaMismatchesQ{l,1},'u_op') && strcmp(variavelDeltaXQ{c,1},'u')
                        BQ(l,c) = CalculaP(auxiliar.opcaoDesacoplado, l, c, dadosEntrada);
                    end
                end
            end
        end
    end
end