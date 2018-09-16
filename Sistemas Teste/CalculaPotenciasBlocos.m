function [] = CalculaPotenciasBlocos(barraInteresse, nomeArquivo, caminhoArquivo, PkmPerdas, dadosEntrada)

%% Retirada das chaves abertas da matriz A

linhasChavesAbertas = dadosEntrada.linhasChaveaveis(find(dadosEntrada.statusChaves==0));        % Descoberta do n�mero das linhas que s�o chave�veis e t�m seus status como "ABERTA"
Amod = dadosEntrada.A;
Amod(:,linhasChavesAbertas) = 0;                                                                % Zerando todas as linhas das colunas que pertencem a ramos chave�veis abertos

%% Pesquisa das barras entre barraAnterior e barraPosterior
[barrasIlha, linhasIlha] = ConectividadeIlhas(barraInteresse, Amod, dadosEntrada);

%% Processamento das pot�ncias de cada bloco

dadosEntrada.Pd(isnan(dadosEntrada.Pd)) = 0;
dadosEntrada.Qd(isnan(dadosEntrada.Qd)) = 0;

PdBloco = 0;
QdBloco = 0;
perdasBloco = 0;

for k=1:length(barrasIlha)
    PdBloco = PdBloco + dadosEntrada.Pd(dadosEntrada.barras(barrasIlha(k)));
    QdBloco = QdBloco + dadosEntrada.Qd(dadosEntrada.barras(barrasIlha(k)));
end

if ~isempty(PkmPerdas)
    for k=1:length(linhasIlha)
        perdasBloco = perdasBloco + PkmPerdas(dadosEntrada.linhas(linhasIlha(k)));
    end
end

%% Apresenta��o dos resultados no prompt de comando
clc
fprintf('\n#### RESULTADOS ####');
fprintf('\nBarra escolhida: %d', barraInteresse);
fprintf('\nPot�ncia ativa total\t(Pd): %1.2f kW',PdBloco);
fprintf('\nPot�ncia reativa total\t(Qd): %1.2f kVAr',QdBloco);
fprintf('\nPot�ncia aparente\t(Sd): %1.2f kVA', sqrt(PdBloco.^2 + QdBloco.^2));
fprintf('\nPerdas\t\t\t: %1.2f kW', perdasBloco);
fprintf('\n')