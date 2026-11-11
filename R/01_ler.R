# =============================================================
# 01_ler.R
# Objetivo: localizar o CSV bruto mais recente, ler todas as
#           colunas como texto, padronizar os nomes e salvar
#           em .rds. Não converte tipos nem limpa dados
#           (isso é tarefa do 02_limpar.R).
# Entrada:  dados/brutos/food_inspections_AAAA-MM-DD.csv
#           (o mais recente)
# Saída:    dados/processados/inspecoes_lidas.rds
# Rodar:    depois de 00_baixar.R, sempre que houver um
#           download novo
# =============================================================

# ---- 1. Pacotes -----------------------------------------------
library(readr)
library(janitor)
library(stringr)

# ---- 2. Localizar o arquivo mais recente ----------------------
arquivos <- list.files(
  path       = "dados/brutos",
  pattern    = "^food_inspections_\\d{4}-\\d{2}-\\d{2}\\.csv$",
  full.names = TRUE
)

if (length(arquivos) == 0) {
  stop("Nenhum arquivo encontrado. Rode R/00_baixar.R primeiro.")
}

# Datas no formato AAAA-MM-DD ordenam igual ao tempo,
# então o maior nome é o arquivo mais recente.
arquivo_atual <- max(arquivos)

# ---- 3. Extrair a data do download do nome do arquivo ---------
# basename() garante que a data vem do NOME do arquivo,
# e não de alguma pasta do caminho.
data_download <- as.Date(
  str_extract(basename(arquivo_atual), "\\d{4}-\\d{2}-\\d{2}")
)

if (is.na(data_download)) {
  stop("Não consegui extrair a data do nome do arquivo: ", arquivo_atual)
}

message("Lendo: ", arquivo_atual, " (baixado em ", data_download, ")")

# ---- 4. Ler tudo como texto -----------------------------------
# Tudo como texto para nada se perder na leitura (IDs, CEPs,
# formatos inesperados). A conversão de tipos é feita no 02.
inspecoes <- read_csv(
  arquivo_atual,
  col_types = cols(.default = col_character()),
  progress  = FALSE
)

# ---- 5. Salvar ------------------------------------------------
dir.create("dados/processados", recursive = TRUE, showWarnings = FALSE)
saveRDS(inspecoes, "dados/processados/inspecoes_lidas.rds")

message("Arquivo lido: ", arquivo_atual)
message("Linhas: ", format(nrow(inspecoes), big.mark = ".", decimal.mark = ","),
        " | Colunas: ", ncol(inspecoes))
message("Salvo em: dados/processados/inspecoes_lidas.rds")