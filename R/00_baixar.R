# =============================================================
# 00_baixar.R
# Objetivo: baixar os dados brutos e registrar a procedência
# Entrada:  nenhuma (internet)
# Saída:    dados/brutos/food_inspections_AAAA-MM-DD.csv
#           notas/log_downloads.csv (uma linha por download feito)
# Rodar:    sempre que quiser atualizar os dados
#           (no máximo um download por dia)
# =============================================================

# ---- 1. Configurações ----------------------------------------
data_download <- Sys.Date()          # carimbo da versão

fontes <- list(
  inspecoes = list(
    url     = "https://data.cityofchicago.org/api/views/4ijn-s7e5/rows.csv?accessType=DOWNLOAD",
    arquivo = paste0("dados/brutos/food_inspections_", data_download, ".csv")
  )
)

arquivo_log <- "notas/log_downloads.csv"

options(timeout = 600)

# ---- 2. Garantir que a pasta existe ---------------------------
dir.create("dados/brutos", recursive = TRUE, showWarnings = FALSE)

# ---- 3. Baixar e registrar (só se ainda não existir) ----------
for (nome in names(fontes)) {
  f <- fontes[[nome]]
  
  if (file.exists(f$arquivo)) {
    message("Já existe, não vou baixar de novo: ", f$arquivo)
  } else {
    download.file(f$url, destfile = f$arquivo, mode = "wb")
    message("Baixado: ", f$arquivo)
    
    log <- data.frame(
      fonte      = nome,
      url        = f$url,
      arquivo    = f$arquivo,
      baixado_em = format(Sys.time(), "%Y-%m-%d %H:%M"),
      tamanho_mb = round(file.size(f$arquivo) / 1e6, 1),
      md5        = unname(tools::md5sum(f$arquivo))
    )
    
    primeira_vez <- !file.exists(arquivo_log)
    write.table(log, arquivo_log, sep = ",", row.names = FALSE,
                append    = !primeira_vez,
                col.names = primeira_vez)
  }
}