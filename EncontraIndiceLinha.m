function [linha, flagLinhaInvertida] = EncontraIndiceLinha(k, m, dadosEntrada)

%% Cabeçalho
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Esta função encontra o número da linha entre duas barras dadas (k e m)
%%%%
%%%%                            |---------|
%%%%                            k  linha  m
%%%%
%%%% Quando nenhuma linha é encontrada a função retorna 0.
%%%% Se a linha for de k para m, flag_linha_invertida é 0, caso contrário é
%%%% 1.
%%%%
%%%% Alexandre Gomes Fonseca
%%%% v1 - 12/04/2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Processamento de erros

if isempty(find(dadosEntrada.barras==k))
    error('A barra k especificada (%d) não existe no sistema!',k);
elseif isempty(find(dadosEntrada.barras==m))
    error('A barra m especificada (%d) não existe no sistema!',m);
end

%% Pesquisa da barra

flag_linha_encontrada = false;
flagLinhaInvertida = false;

for tentativa = 1:2
    
    %%%% Tentativa 1: de = k, para = m
    if tentativa == 1
        k_var = k;
        m_var = m;
    %%%% Tentativa 2: linha invertida: de = m, para = k
    elseif tentativa == 2
        k_var = m;
        m_var = k;
    end   
        
        indices_candidatos_de = find(dadosEntrada.de == k_var);
        indices_candidatos_para = find(dadosEntrada.para == m_var);
        
        %%%% Pesquisa da linha
        if length(indices_candidatos_de) >= length(indices_candidatos_para)
            for u1 = 1:length(indices_candidatos_de)
                for u2 = 1:length(indices_candidatos_para)
                    if indices_candidatos_de(u1,1) == indices_candidatos_para(u2,1)
                        linha = dadosEntrada.linhas(indices_candidatos_de(u1),1);
                        flag_linha_encontrada = true;
                        if tentativa == 2
                            flagLinhaInvertida = true;
                        end
                        return;
                    end
                end
            end
        else
            for u2 = 1:length(indices_candidatos_para)
                for u1 = 1:length(indices_candidatos_de)
                    if indices_candidatos_para(u2,1) == indices_candidatos_de(u1,1)
                        linha = dadosEntrada.linhas(indices_candidatos_para(u2),1);
                        flag_linha_encontrada = true;
                        if tentativa == 2
                            flagLinhaInvertida = true;
                        end
                        return;
                    end
                end
            end
        end
end

%%%% Se a linha não foi encontrada, mesmo invertida, retornar 0
if flag_linha_encontrada == false
    linha = 0;
end

end