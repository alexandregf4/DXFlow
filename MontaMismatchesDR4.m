function [mismatchesP, mismatchesQ, barrasMismatchesP, barrasMismatchesQ, tipoMismatchesP, tipoMismatchesQ, potenciaMismatchesP, potenciaMismatchesQ, variavelDeltaXP, variavelDeltaXQ] = MontaMismatchesDR4(Pcalc, Qcalc, dadosEntrada, estadosRede)

%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Função que monta os vetores mismatches P e Q (vetor independente) para
%%%% resolução de fluxo de carga por método Newton-Raphson desacoplado
%%%% rápido com matrizes B' e B''montadas por blocos.
%%%% Os vetores são montados na seguinte ordem: 
%%%%                                             mismatches P:
%%%%                                            [P1]    [theta1]
%%%%                                            [P2]    [theta2]
%%%%                                            [P3]    [theta3]
%%%%                                            [ftheta][tkm]
%%%%                                            ....    ....
%%%%
%%%%                                             mismatches Q
%%%%                                            [Q1]    [V1]
%%%%                                            [Q2]    [V2]
%%%%                                            [Q3]    [a34]       
%%%%                                            [fV]    [ukm]       (novo!)
%%%%                                            ....    ....
%%%%
%%%% A linha correspondente à potência reativa/tensão da barra não é
%%%% considerada quando esta barra for do tipo PV.
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 12/04/2015
%%%% ...
%%%% v4 - 13/06/2015 / Adicionados mismatches para modelagem no nível de
%%%% seção de barras
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Inicialização das variáveis em zero

mismatchesP = zeros(dadosEntrada.npq+dadosEntrada.npv+dadosEntrada.npqv,1);     % Inicialização do vetor dos mismatches da iteração P
mismatchesQ = zeros(dadosEntrada.npq+dadosEntrada.npqv,1);                      % Inicialização do vetor dos mismatches da iteração Q
indiceLinhaP = 1;                                                               % Variável que guarda o índice da linha do vetor mismatchesP
indiceLinhaQ = 1;                                                               % Variável que guarda o índice da linha do vetor mismatchesQ

%%%% tipoBarra:
%%%% 1 - VT
%%%% 2 - PV
%%%% 3 - PQ
%%%% 4 - PQV

%% Laço para preenchimento do vetor mismatchesP

%%%% Montagem do vetor mismatchesP para ramos convencionais

for k=1:dadosEntrada.nb
    if dadosEntrada.tipoBarra(dadosEntrada.barras(k,1),1) ~= 1                                                                      % Se a barra NÃO for do tipo VT (PQ ou PQV ou PV)
        mismatchesP(indiceLinhaP,1) = dadosEntrada.Pesp(dadosEntrada.barras(k,1),1) - Pcalc(dadosEntrada.barras(k,1),1);            % delta_P = Pesp - Pcalc
        barrasMismatchesP(indiceLinhaP,1) = dadosEntrada.barras(k,1);                                                               % Numeração da barra na posição correspondente à variável delta_PQ
        tipoMismatchesP(indiceLinhaP,1) = dadosEntrada.tipoBarra(dadosEntrada.barras(k,1),1);                                       % Tipo da barra na posição correspondente à variável delta_PQ
        potenciaMismatchesP{indiceLinhaP,1} = 'P';
        variavelDeltaXP{indiceLinhaP,1} = 'O';
        indiceLinhaP = indiceLinhaP + 1;
    end
end

%%%% Montagem do vetor de mismatches dos ramos chaveáveis referentes à
%%%% iteração P

mismatchesP_chaves = zeros(dadosEntrada.nrc,1);
temp_variavel_delta_x_P = {};
temp_potencia_mismatchesP = {};

if dadosEntrada.nrc ~= 0
   
    linha_mismatches_chaves = 1;
    
    for k=1:dadosEntrada.nrc
        if dadosEntrada.statusChaves(k,1) == 0                                                                                      % Se chave aberta, então mismatch(tkm) = tkm e mismatch(ukm) = ukm
            mismatchesP_chaves(linha_mismatches_chaves,1) = estadosRede.t(dadosEntrada.linhasChaveaveis(k,1),1);
            temp_variavel_delta_x_P{linha_mismatches_chaves,1} = 't';
            temp_potencia_mismatchesP{linha_mismatches_chaves,1} = 't_op';
            linha_mismatches_chaves = linha_mismatches_chaves + 1;
        elseif dadosEntrada.statusChaves(k,1) == 1                                                                                  % Se chave fechada, então mismatch(tkm) = thetak - thetam e mismatch(ukm) = Vk - Vm
            mismatchesP_chaves(linha_mismatches_chaves,1) = estadosRede.theta(dadosEntrada.de(dadosEntrada.linhasChaveaveis(k,1))) - estadosRede.theta(dadosEntrada.para(dadosEntrada.linhasChaveaveis(k,1)));
            temp_variavel_delta_x_P{linha_mismatches_chaves,1} = 't';
            temp_potencia_mismatchesP{linha_mismatches_chaves,1} = 't_cl';
            linha_mismatches_chaves = linha_mismatches_chaves + 1;
        else
            error('Status inválido para a chave da linha número %d.',linhas(k,1));
        end
    end
end

%%%% Anexando novos tipos de variáveis (t) referentes ao nível de seção de
%%%% barras nos vetores auxiliares

temp1 = variavelDeltaXP;
temp2 = potenciaMismatchesP;
variavelDeltaXP = {};
potenciaMismatchesP = {};
for k=1:length(temp1)
    variavelDeltaXP{k,1} = temp1(k,1);
    potenciaMismatchesP{k,1} = temp2(k,1);
end

for k=1:(length(variavelDeltaXP) + length(temp_variavel_delta_x_P))
    if k <= length(variavelDeltaXP) 
        variavel_delta_x_P_tot{k,1} = variavelDeltaXP{k,1};
        potencia_mismatchesP_tot{k,1} = potenciaMismatchesP{k,1};
    else
        k_temp = k - length(variavelDeltaXP);
        variavel_delta_x_P_tot{k,1} = temp_variavel_delta_x_P{k_temp,1};
        potencia_mismatchesP_tot{k,1} = temp_potencia_mismatchesP{k_temp,1};
    end
end

variavelDeltaXP = variavel_delta_x_P_tot;
potenciaMismatchesP = potencia_mismatchesP_tot;

mismatchesP = [mismatchesP; mismatchesP_chaves];

%% Laço para preenchimento do vetor mismatchesQ

%%%% Montagem do vetor mismatchesQ para ramos convencionais

for k=1:dadosEntrada.nb
    if dadosEntrada.tipoBarra(dadosEntrada.barras(k,1),1) ~= 1 && dadosEntrada.tipoBarra(dadosEntrada.barras(k,1),1) ~= 2                   % Se a barra NÃO for do tipo VT nem do tipo PV (PQ ou PQV)
        
        switch dadosEntrada.tipoBarra(dadosEntrada.barras(k,1),1)
            
            %%%% Barra PQ
            case 3
                mismatchesQ(indiceLinhaQ,1) = dadosEntrada.Qesp(dadosEntrada.barras(k,1),1) - Qcalc(dadosEntrada.barras(k,1),1);            % delta_Q = Qesp - Qcalc
                barrasMismatchesQ(indiceLinhaQ,1) = dadosEntrada.barras(k,1);                                                               % Numeração da barra na posição correspondente à variável delta_PQ
                tipoMismatchesQ(indiceLinhaQ,1) = dadosEntrada.tipoBarra(dadosEntrada.barras(k,1),1);                                       % Tipo da barra na posição correspondente à variável delta_PQ
                potenciaMismatchesQ{indiceLinhaQ,1} = 'Q';
                variavelDeltaXQ{indiceLinhaQ,1} = 'V';
                indiceLinhaQ = indiceLinhaQ + 1;
                
            %%%% Barra PQV
            case 4
                mismatchesQ(indiceLinhaQ,1) = dadosEntrada.Qesp(dadosEntrada.barras(k,1),1) - Qcalc(dadosEntrada.barras(k,1),1);            % delta_Q = Qesp - Qcalc
                barrasMismatchesQ(indiceLinhaQ,1) = dadosEntrada.barras(k,1);                                                               % Numeração da barra na posição correspondente à variável delta_PQ
                tipoMismatchesQ(indiceLinhaQ,1) = dadosEntrada.tipoBarra(dadosEntrada.barras(k,1),1);                                       % Tipo da barra na posição correspondente à variável delta_PQ
                potenciaMismatchesQ{indiceLinhaQ,1} = 'Q';
                variavelDeltaXQ{indiceLinhaQ,1} = 'a';
                indiceLinhaQ = indiceLinhaQ + 1;
        end
    end
end

%%%% Montagem do vetor de mismatches dos ramos chaveáveis referentes à
%%%% iteração P

mismatchesQ_chaves = zeros(dadosEntrada.nrc,1);
temp_variavel_delta_x_Q = {};
temp_potencia_mismatchesQ = {};

if dadosEntrada.nrc ~= 0
   
    linha_mismatches_chaves = 1;
    
    for k=1:dadosEntrada.nrc
        if dadosEntrada.statusChaves(k,1) == 0                                                                                               % Se chave aberta, então mismatch(tkm) = tkm e mismatch(ukm) = ukm
            mismatchesQ_chaves(linha_mismatches_chaves,1) = estadosRede.u(dadosEntrada.linhasChaveaveis(k,1),1);
            temp_variavel_delta_x_Q{linha_mismatches_chaves,1} = 'u';
            temp_potencia_mismatchesQ{linha_mismatches_chaves,1} = 'u_op';
            linha_mismatches_chaves = linha_mismatches_chaves + 1;
        elseif dadosEntrada.statusChaves(k,1) == 1                                                                                           % Se chave fechada, então mismatch(tkm) = thetak - thetam e mismatch(ukm) = Vk - Vm
            mismatchesQ_chaves(linha_mismatches_chaves,1) = estadosRede.V(dadosEntrada.de(dadosEntrada.linhasChaveaveis(k,1))) - estadosRede.V(dadosEntrada.para(dadosEntrada.linhasChaveaveis(k,1)));
            temp_variavel_delta_x_Q{linha_mismatches_chaves,1} = 'u';
            temp_potencia_mismatchesQ{linha_mismatches_chaves,1} = 'u_cl';
            linha_mismatches_chaves = linha_mismatches_chaves + 1;
        else
            error('Status inválido para a chave da linha número %d.',linhas(k,1));
        end
    end
end

%%%% Anexando novos tipos de variáveis (u) referentes ao nível de seção de
%%%% barras nos vetores auxiliares

temp1 = variavelDeltaXQ;
temp2 = potenciaMismatchesQ;
variavelDeltaXQ = {};
potenciaMismatchesQ = {};
for k=1:length(temp1)
    variavelDeltaXQ{k,1} = temp1(k,1);
    potenciaMismatchesQ{k,1} = temp2(k,1);
end

for k=1:(length(variavelDeltaXQ) + length(temp_variavel_delta_x_Q))
    if k <= length(variavelDeltaXQ) 
        variavel_delta_x_Q_tot{k,1} = variavelDeltaXQ{k,1};
        potencia_mismatchesQ_tot{k,1} = potenciaMismatchesQ{k,1};
    else
        k_temp = k - length(variavelDeltaXQ);
        variavel_delta_x_Q_tot{k,1} = temp_variavel_delta_x_Q{k_temp,1};
        potencia_mismatchesQ_tot{k,1} = temp_potencia_mismatchesQ{k_temp,1};
    end
end

variavelDeltaXQ = variavel_delta_x_Q_tot;
potenciaMismatchesQ = potencia_mismatchesQ_tot;

mismatchesQ = [mismatchesQ; mismatchesQ_chaves];

%% Verificação de erro de montagem dos vetores
if length(mismatchesP) ~= dadosEntrada.npq+dadosEntrada.nrc+dadosEntrada.npqv+dadosEntrada.npv                                                  
    error('Erro na montagem do vetor mismatchesP: O tamanho do vetor não condiz com o problema (length(delta_PQ) ~= npq+nrc+npqv+npv)');
elseif length(mismatchesQ) ~= dadosEntrada.npq+dadosEntrada.nrc+dadosEntrada.npqv
    error('Erro na montagem do vetor mismatchesQ: O tamanho do vetor não condiz com o problema (length(delta_PQ) ~= npq+nrc+npqv)');
end
end