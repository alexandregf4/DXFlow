function [mismatches, barrasDeltaPQ, tipoDeltaPQ, potenciaDeltaPQ, variavelDeltaX] = MontaMismatches3(dadosEntrada, estadosRede, Pcalc, Qcalc)

%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Fun��o que monta os vetores delta_PQ (vetor independente) para
%%%% resolu��o de fluxo de carga por m�todo Newton-Raphson com matriz
%%%% Jacobiana montada por blocos.
%%%% Os vetores s�o montados na seguinte ordem: [P1]    [theta1]
%%%%                                            [Q1]    [V1]
%%%%                                            [P2]    [theta2]
%%%%                                            [Q2]    [V2]
%%%%                                            [P3]    [theta3]
%%%%                                            [Q3]    [a34]       (novo!)
%%%%                                            ....    ....
%%%%                                       [mismatch(t12)]  [t12]   (novo!)
%%%%                                       [mismatch(u12)]  [u12]
%%%%                                       [mismatch(t23)]  [t23]
%%%%                                       [mismatch(u23)]  [u23]
%%%%                                         ....           .....
%%%%
%%%% A linha correspondente � pot�ncia reativa/tens�o da barra n�o �
%%%% considerada quando esta barra for do tipo PV.
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 14/07/2014
%%%% v2 - 24/08/2014 / Adicionada vari�vel auxiliar para vetor de
%%%% inc�gnitas x e suporte ao controle autom�tico de tap (barras PQV)
%%%% v3 - 10/05/2015 / Adicionados mismatches para os ramos chave�veis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Montagem do vetor de mismatches das pot�ncias ativa e reativa

mismatchesPotencias = zeros(2*dadosEntrada.npq+2*dadosEntrada.npqv+dadosEntrada.npv,1);              % Inicializa��o do vetor delta_PQ
indiceLinha = 1;                           % Vari�vel que guarda o �ndice da linha para montagem dos vetores

for k=1:dadosEntrada.nb
   if dadosEntrada.tipoBarra(dadosEntrada.barras(k,1),1) ~= 1        % Se a barra N�O for do tipo VT
       mismatchesPotencias(indiceLinha,1) = dadosEntrada.Pesp(dadosEntrada.barras(k,1),1) - Pcalc(dadosEntrada.barras(k,1),1);               % delta_PQ = Pesp - Pcalc
       barrasDeltaPQ(indiceLinha,1) = dadosEntrada.barras(k,1);                                       % Numera��o da barra na posi��o correspondente � vari�vel delta_PQ
       tipoDeltaPQ(indiceLinha,1) = dadosEntrada.tipoBarra(dadosEntrada.barras(k,1),1);                           % Tipo da barra na posi��o correspondente � vari�vel delta_PQ
       potenciaDeltaPQ(indiceLinha,1) = 'P';
       variavelDeltaX(indiceLinha,1) = 'O';
       indiceLinha = indiceLinha + 1;
       if dadosEntrada.tipoBarra(dadosEntrada.barras(k,1),1) ~= 2    % Se a barra N�O for do tipo PV
           mismatchesPotencias(indiceLinha,1) = dadosEntrada.Qesp(dadosEntrada.barras(k,1),1) - Qcalc(dadosEntrada.barras(k,1),1);           % delta_PQ = Qesp - Qcalc
           barrasDeltaPQ(indiceLinha,1) = dadosEntrada.barras(k,1);                                   % Numera��o da barra na posi��o correspondente � vari�vel delta_PQ
           tipoDeltaPQ(indiceLinha,1) = dadosEntrada.tipoBarra(dadosEntrada.barras(k,1),1);                       % Tipo da barra na posi��o correspondente � vari�vel delta_PQ
           potenciaDeltaPQ(indiceLinha,1) = 'Q';
           if dadosEntrada.tipoBarra(dadosEntrada.barras(k,1),1) == 3
               variavelDeltaX(indiceLinha,1) = 'V';
           elseif dadosEntrada.tipoBarra(dadosEntrada.barras(k,1),1) == 4
               variavelDeltaX(indiceLinha,1) = 'a';
           end
           indiceLinha = indiceLinha + 1;
       end
   end
end

%% Montagem do vetor de mismatches dos ramos chave�veis

tempVariavelDeltaX = {};
mismatchesChaves = zeros(dadosEntrada.nrc,1);

if dadosEntrada.nrc ~= 0
   
    temp_potencia_delta_PQ = [];
    linha_mismatches_chaves = 1;
    
    for k=1:dadosEntrada.nrc
        if dadosEntrada.statusChaves(k,1) == 0                                                           % Se chave aberta, ent�o mismatch(tkm) = tkm e mismatch(ukm) = ukm
            mismatchesChaves(linha_mismatches_chaves,1) = estadosRede.t(dadosEntrada.linhasChaveaveis(k,1),1);
            tempVariavelDeltaX{linha_mismatches_chaves,1} = 't';
            temp_potencia_delta_PQ{linha_mismatches_chaves,1} = 't_op';
            linha_mismatches_chaves = linha_mismatches_chaves + 1;
            mismatchesChaves(linha_mismatches_chaves,1) = estadosRede.u(dadosEntrada.linhasChaveaveis(k,1),1);
            tempVariavelDeltaX{linha_mismatches_chaves,1} = 'u';
            temp_potencia_delta_PQ{linha_mismatches_chaves,1} = 'u_op';
            linha_mismatches_chaves = linha_mismatches_chaves + 1;
        elseif dadosEntrada.statusChaves(k,1) == 1                                                       % Se chave fechada, ent�o mismatch(tkm) = thetak - thetam e mismatch(ukm) = Vk - Vm
            mismatchesChaves(linha_mismatches_chaves,1) = estadosRede.theta(dadosEntrada.de(dadosEntrada.linhasChaveaveis(k,1))) - estadosRede.theta(dadosEntrada.para(dadosEntrada.linhasChaveaveis(k,1)));
            tempVariavelDeltaX{linha_mismatches_chaves,1} = 't';
            temp_potencia_delta_PQ{linha_mismatches_chaves,1} = 't_cl';
            linha_mismatches_chaves = linha_mismatches_chaves + 1;
            tempVariavelDeltaX{linha_mismatches_chaves,1} = 'u';
            temp_potencia_delta_PQ{linha_mismatches_chaves,1} = 'u_cl';
            mismatchesChaves(linha_mismatches_chaves,1) = estadosRede.V(dadosEntrada.de(dadosEntrada.linhasChaveaveis(k,1))) - estadosRede.V(dadosEntrada.para(dadosEntrada.linhasChaveaveis(k,1)));
            linha_mismatches_chaves = linha_mismatches_chaves + 1;
        else
            error('Status inv�lido para a chave da linha n�mero %d.',linhas(k,1));
        end
    end
end

%%%% Anexando novos tipos de vari�veis referentes ao n�vel de se��o de barras
temp1 = variavelDeltaX;
temp2 = potenciaDeltaPQ;
variavelDeltaX = {};
potenciaDeltaPQ = {};
for k=1:length(temp1)
    variavelDeltaX{k,1} = temp1(k,1);
    potenciaDeltaPQ{k,1} = temp2(k,1);
end

for k=1:(length(variavelDeltaX) + length(tempVariavelDeltaX))
    if k <= length(variavelDeltaX) 
        variavel_delta_x_tot{k,1} = variavelDeltaX{k,1};
        potencia_delta_PQ_tot{k,1} = potenciaDeltaPQ{k,1};
    else
        k_temp = k - length(variavelDeltaX);
        variavel_delta_x_tot{k,1} = tempVariavelDeltaX{k_temp,1};
        potencia_delta_PQ_tot{k,1} = temp_potencia_delta_PQ{k_temp,1};
    end
end

variavelDeltaX = variavel_delta_x_tot;
potenciaDeltaPQ = potencia_delta_PQ_tot;

%% Verifica��o de erros de montagem

if length(mismatchesPotencias) ~= 2*dadosEntrada.npq+2*dadosEntrada.npqv+dadosEntrada.npv                                     %%%% Verifica��o de erro de montagem do vetor de mismatches das pot�ncias                                                 
    error('Erro na montagem do vetor mismatches_potencias: O tamanho do vetor n�o condiz com o problema (length(mismatches_potencias) ~= 2*npq+2*npqv+npv)');
end

if length(mismatchesChaves) ~= 2*dadosEntrada.nrc                                                   %%%% Verifica��o de erro de montagem do vetor de mismatches dos ramos chave�veis
    error('Erro na montagem do vetor mismatches_chaves: O tamanho do vetor n�o condiz com o problema (length(mismatches_chaves) ~= 2*nch)');
end

%% Montagem do vetor completo
mismatches = [mismatchesPotencias; mismatchesChaves];

end