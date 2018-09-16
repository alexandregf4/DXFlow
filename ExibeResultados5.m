function [] = ExibeResultados5(auxiliar, dadosEntrada, dadosEntradaAntigo, estadosRede, estadosRedeAntigo, Pkm, Qkm, PkmPerdas, Pperdas, Qperdas, PperdasPerc, historicoConvergencia, historicoConvergenciaP, historicoConvergenciaQ, iteracao, iteracaoP, iteracaoQ)

%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta fun��o exibe o resultado do fluxo de carga no prompt do matlab e
%%%% os salva num arquivo .xls.
%%%% S�o plotados os gr�ficos:
%%%% -> Converg�ncia (norma infinita de delta_PQ x itera��o)
%%%% -> Perfil de tens�o (m�dulo da tens�o x barra)
%%%%
%%%% S�o exibidos os resultados:
%%%% -> V, theta
%%%% -> Pk, Qk
%%%% -> Pkm, Qkm
%%%%
%%%%
%%%% Alexandre Gomes Fonseca
%%%%
%%%% v1.0 - 03/08/2014
%%%% v1.1 - 07/12/2014 / Modifica��o do salvamento das vari�veis, agora
%%%% salvando tamb�m no formato .mat. Introdu��o do "modo mac".
%%%% v3.0 - 12/04/2015 / Exibe resultados do m�todo desacoplado r�pido
%%%% v4.0 - 02/06/2015 / Exibe resultados dos ramos chave�veis
%%%% v5.0 - 05/07/2015 / Exibe topologia colorida pelo n�vel de tens�o e
%%%% apresenta os dados em pu e em kV (tratamento da normaliza��o)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Modifica��o dos dados (numera��o antiga das barras)

[dadosEntrada, estadosRede, Pkm, Qkm, PkmPerdas] = CorrigeApresentacaoResultados(dadosEntrada, dadosEntradaAntigo, estadosRede, estadosRedeAntigo, Pkm, Qkm, PkmPerdas);

%% Inicializa��o

warning('off','all');
warning;

nome_excel = strcat('Resultados', num2str(auxiliar.numeroAnalise), '.xlsx');
nome_planilha_trechos = 'Dados de linha';
nome_planilha_barras = 'Dados de barra';
if auxiliar.tipoCalculo == 1
    nome_pasta = 'Resultados ultimo fluxo de potencia';
else
    nome_pasta = 'Resultados ultima analise exaustiva';
end

if strcmp(auxiliar.modoExecucao,'WIN')
    caminho_excel = strcat(pwd, '\', nome_pasta, '\Resultado', nome_excel);
    caminho_mat = strcat(pwd, '\', nome_pasta, '\Resultado', num2str(auxiliar.numeroAnalise), '.mat');
elseif strcmp(auxiliar.modoExecucao,'MAC')
    caminho_excel = strcat(pwd, '/', nome_pasta, '/Resultado', nome_excel);
    caminho_mat = strcat(pwd, '/', nome_pasta, '/Resultado', num2str(auxiliar.numeroAnalise), '.mat');
end

resultados_trechos = {};
resultados_barras = {};

%% Planilha barras

%%%% Headers da tabela
resultados_barras{1,1} = 'Barra';
resultados_barras{1,2} = 'M�dulo da tens�o (pu)';
resultados_barras{1,3} = '�ngulo da tens�o (graus)';
resultados_barras{1,4} = 'Inje��o de pot�ncia ativa (kW)';
resultados_barras{1,5} = 'Inje��o de pot�ncia reativa (kVAr)';

%%%% Inser��o dos dados
for k=1:length(dadosEntrada.barras)
    resultados_barras{k+1,1} = dadosEntrada.barras(k);
    resultados_barras{k+1,2} = estadosRede.V(k);
    resultados_barras{k+1,3} = rad2deg(estadosRede.theta(k));
    resultados_barras{k+1,4} = dadosEntrada.Pg(k)-dadosEntrada.Pd(k);
    resultados_barras{k+1,5} = dadosEntrada.Qg(k)-dadosEntrada.Qd(k);
end

%% Planilha trechos

%%%% Headers da tabela
resultados_trechos{1,1} = 'Linha';
resultados_trechos{1,2} = 'DE';
resultados_trechos{1,3} = 'PARA';
resultados_trechos{1,4} = 'Fluxo ativo - t (kW)';
resultados_trechos{1,5} = 'Fluxo reativo - u (kVAr)';
resultados_trechos{1,6} = 'Perdas ativas totais (kW)';
resultados_trechos{1,7} = 'Perdas reativas totais (kVAr)';

%%%% Inser��o dos dados
for k=1:length(dadosEntrada.linhas)
    resultados_trechos{k+1,1} = dadosEntrada.linhas(k);
    resultados_trechos{k+1,2} = dadosEntrada.de(k);
    resultados_trechos{k+1,3} = dadosEntrada.para(k);
    resultados_trechos{k+1,4} = Pkm(k);
    resultados_trechos{k+1,5} = Qkm(k);
end

resultados_trechos{2,6} = Pperdas;
resultados_trechos{2,7} = Qperdas;

%% Salvamento dos resultados

delete(caminho_excel);                                                          % Dele��o de resultados anteriores .xlsx
delete(caminho_mat);                                                            % Dele��o de resultados anteriores .mat

if auxiliar.modoExecucao == 'WIN'
    xlswrite(caminho_excel, resultados_barras, nome_planilha_barras);
    xlswrite(caminho_excel, resultados_trechos, nome_planilha_trechos);
end

save(caminho_mat,'resultados_barras','resultados_trechos');

%% Gr�ficos

perfil_tensao = figure;
subplot(2,1,1)
hold on
grid on
% perfil_tensao = figure;
plot(dadosEntrada.barras,estadosRede.V,'-or');
title('Perfil de tens�o do sistema');
xlabel('Barra');
ylabel('M�dulo da tens�o (pu)');
% title('Voltage profile');
% xlabel('Bus');
% ylabel('Voltage module (pu)');
subplot(2,1,2)
hold on
grid on
plot(dadosEntrada.barras,rad2deg(estadosRede.theta),'-ob');
title('�ngulos das tens�es');
xlabel('Barra');
ylabel('�ngulo da tens�o (graus)');
% xlabel('Bus');
% ylabel('Voltage angle (degrees)');
hold off
saveas(perfil_tensao,[pwd '/' nome_pasta '/Perfil_tensao' num2str(auxiliar.numeroAnalise) '.fig']);

if auxiliar.opcaoMetodo == 1
    convergencia = figure;
    plot(historicoConvergencia(:,1),historicoConvergencia(:,2),'-or');
    title('Converg�ncia');
    xlabel('Itera��o');
    ylabel('Norma infinita de delta P');
elseif auxiliar.opcaoMetodo == 2
    convergencia = figure;
    hold on;
    plot(historicoConvergenciaP(:,1),historicoConvergenciaP(:,2),'--ob');
    plot(historicoConvergenciaQ(:,1),historicoConvergenciaQ(:,2),'-*r');
    title('Converg�ncia');
    xlabel('Itera��o');
    ylabel('Maior valor do vetor das diferen�as de pot�ncia');
%     xlabel('Iteration number');
%     ylabel('Higher mismatch value');
    legend('P\theta','QV');
    hold off;
end

saveas(convergencia,[pwd '/' nome_pasta '/Convergencia' num2str(auxiliar.numeroAnalise) '.fig']);

if auxiliar.tipoCalculo ~= 1
    close(perfil_tensao);
    close(convergencia);
end

%% Plot da tens�o sobre a topologia

PlotaTopologiaTensao(auxiliar, dadosEntrada, estadosRede, nome_pasta);

%% Plot do fluxo de pot�ncia e perdas sobre a topologia

PlotaTopologiaFluxoPotencia(auxiliar, dadosEntrada, nome_pasta, Pkm, Qkm, PkmPerdas);

%% Exibi��o dos resultados no prompt do MATLAB

if auxiliar.tipoCalculo == 1
    
    clc
    
    fprintf('\n***********************************');
    fprintf('\n*** Resultado do Fluxo de carga ***');
    fprintf('\n***********************************\n\n');
    if auxiliar.opcaoMetodo == 1
        fprintf('Resolu��o pelo m�todo Newton-Raphson tradicional\n');
    elseif auxiliar.opcaoMetodo == 2
        fprintf('Resolu��o pelo m�todo Newton-Raphson desacoplado r�pido\n');
    end
    fprintf('N�mero de itera��es necess�rias: %d\n',iteracao);
    fprintf('Pot�ncia ativa total gerada: %1.5f kW\n',abs(sum(dadosEntrada.Pg(~isnan(dadosEntrada.Pg)))));
    fprintf('Demanda ativa total: %1.5f kW\n',abs(sum(dadosEntrada.Pd(~isnan(dadosEntrada.Pd)))));
    fprintf('Demanda reativa total: %1.5f kVAr\n',abs(sum(dadosEntrada.Qd(~isnan(dadosEntrada.Qd)))));
    fprintf('Perdas ativas: %1.5f kW\n',Pperdas);
    fprintf('Perdas ativas percentuais: %1.2f',PperdasPerc);
    disp('%'); %%%% Gambiarra para aparecer o simbolo
    fprintf('\n\n');
    fprintf('Vari�veis de barra:\n');
    fprintf('Barra \t\t V (pu) \t\t\t theta (graus) \t\t Pk (kW) \t\t\t Qk(kVAr)\n');
    for k=1:length(dadosEntrada.barras)
        fprintf('%d \t\t\t %1.4f \t\t\t %2.4f \t\t\t %3.4f \t\t\t %4.4f\n',dadosEntrada.barras(k),estadosRede.V(k),rad2deg(estadosRede.theta(k)),(dadosEntrada.Pg(k)-dadosEntrada.Pd(k)),(dadosEntrada.Qg(k)-dadosEntrada.Qd(k)));
    end
    fprintf('\n');
    fprintf('Vari�veis de linha:\n');
    fprintf('Linha \t\t DE \t\t PARA \t\t Pkm (kW) \t\t\t Qkm (kVAr)\n');
    for k=1:length(dadosEntrada.linhas)
        if isempty(find(dadosEntrada.linhasChaveaveis == k))
            fprintf('%d \t\t\t %d \t\t\t %d \t\t\t %3.4f \t\t\t %4.4f\n',dadosEntrada.linhas(k),dadosEntrada.de(k),dadosEntrada.para(k),Pkm(k),Qkm(k));
        else
            fprintf('%d \t\t\t %d \t\t\t %d \t\t\t %3.4f(*) \t\t\t %4.4f(*)\n',dadosEntrada.linhas(k),dadosEntrada.de(k),dadosEntrada.para(k),Pkm(k),Qkm(k));
        end
    end
    fprintf('\n')
end
end