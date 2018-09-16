function [] = DelecaoArquivosPasta(nomePasta)

%% Cabe�alho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% Esta fun��o deleta todos os arquivos da pasta selecionada (nomePasta).
%%%%
%%%% Alexandre Gomes Fonseca   
%%%% v1 - 30/01/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Grava��o da pasta de origem

pastaOrigem = pwd;

%% Processamento dos arquivos dentro da pasta selecionada (nomePasta)

cd(strcat(pwd,'/',nomePasta));
arquivosPasta = dir;

%% Dele��o dos arquivos da pasta selecionada (nomePasta)

for k=1:length(arquivosPasta)
    if strcmp(arquivosPasta(k).name,'.')
    elseif strcmp(arquivosPasta(k).name,'..')
    else
        delete(arquivosPasta(k).name);
    end
end

%% Volta � pasta de origem

cd(pastaOrigem);
end
        