function [] = DelecaoArquivosPasta(nomePasta)

%% Cabeçalho

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% Esta função deleta todos os arquivos da pasta selecionada (nomePasta).
%%%%
%%%% Alexandre Gomes Fonseca   
%%%% v1 - 30/01/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Gravação da pasta de origem

pastaOrigem = pwd;

%% Processamento dos arquivos dentro da pasta selecionada (nomePasta)

cd(strcat(pwd,'/',nomePasta));
arquivosPasta = dir;

%% Deleção dos arquivos da pasta selecionada (nomePasta)

for k=1:length(arquivosPasta)
    if strcmp(arquivosPasta(k).name,'.')
    elseif strcmp(arquivosPasta(k).name,'..')
    else
        delete(arquivosPasta(k).name);
    end
end

%% Volta à pasta de origem

cd(pastaOrigem);
end
        