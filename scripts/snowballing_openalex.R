# =====================================================================
# Snowballing bidirecional (backward + forward) via OpenAlex
# RSL Grupo 1 — GQPC 2026.2 — FGP-IA / CRISP-ML(Q)
# Base metodológica: Wohlin (2014), EASE.
#
# O que o script faz:
#   1. Lê o corpus deduplicado e pega o conjunto inicial (códigos INC).
#   2. Busca no OpenAlex as referências (backward) e as citações
#      (forward) de cada estudo do conjunto inicial.
#   3. Aplica os filtros objetivos do protocolo (ano, idioma, tipo).
#   4. Marca o que já está no corpus (duplicata) e o que é novo.
#   5. Dá um sinal por palavras-chave no título para priorizar a triagem.
#   6. Salva um CSV para a triagem dupla e um resumo para o PRISMA.
#
# Requisitos: pacotes httr, jsonlite, dplyr, readr, stringr
#   install.packages(c("httr", "jsonlite", "dplyr", "readr", "stringr"))
# =====================================================================

library(httr)
library(jsonlite)
library(dplyr)
library(readr)
library(stringr)

# Faz o R trabalhar na pasta onde está este script (RStudio) — evita
# "arquivo não encontrado" e saída gravada em outra pasta.
if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  caminho <- tryCatch(rstudioapi::getSourceEditorContext()$path, error = function(e) "")
  if (nzchar(caminho)) setwd(dirname(caminho))
}
message("Pasta de trabalho: ", getwd())

# ---------------------------------------------------------------------
# 1. CONFIGURAÇÃO — ajuste aqui
# ---------------------------------------------------------------------
ARQ_CORPUS   <- "corpus_deduplicado.csv"   # gerado na deduplicação
CODIGOS_SEED <- c("INC")                   # depois da triagem: use os incluídos finais
MAILTO       <- "seu.email@aluno.unb.br"   # OpenAlex pede um e-mail ("polite pool")
ANO_MIN      <- 2016                       # CI4
DATA_CORTE   <- "2026-09-27"               # mesma data da busca nas bases
IDIOMAS_OK   <- c("en", "pt")              # CI5
TIPOS_OK     <- c("article", "review", "conference-paper", "book-chapter")  # CI3; o resto vira CE2/CE5
ARQ_SAIDA    <- "snowballing_rodada1.csv"
PAUSA        <- 0.2                        # segundos entre chamadas (educação com a API)
API_KEY      <- ""                         # opcional: chave gratuita do OpenAlex, se exigida

# ---------------------------------------------------------------------
# 2. Funções auxiliares
# ---------------------------------------------------------------------

# Normaliza DOI: minúsculas, sem prefixo doi.org
normaliza_doi <- function(x) {
  x <- tolower(trimws(x))
  x <- str_remove(x, "^https?://(dx\\.)?doi\\.org/")
  ifelse(is.na(x) | x == "", NA, x)
}

# Normaliza título: só letras e dígitos
normaliza_titulo <- function(x) {
  str_replace_all(tolower(x), "[^a-z0-9]", "")
}

# Chamada à API com tratamento de erro (devolve NULL se falhar)
chama_api <- function(url) {
  if (nzchar(API_KEY)) url <- paste0(url, "&api_key=", API_KEY)
  for (tentativa in 1:3) {
    Sys.sleep(PAUSA * tentativa)
    resp <- tryCatch(GET(url, timeout(60), user_agent(paste0("RSL-GQPC (mailto:", MAILTO, ")"))),
                     error = function(e) { message("  erro de conexão: ", conditionMessage(e)); NULL })
    if (is.null(resp)) next
    cod <- status_code(resp)
    if (cod == 200) return(fromJSON(content(resp, "text", encoding = "UTF-8"), simplifyVector = FALSE))
    if (cod == 404) return(NULL)                      # DOI não indexado no OpenAlex
    message("  aviso: HTTP ", cod, " (tentativa ", tentativa, ") em ", substr(url, 1, 90))
    if (!(cod %in% c(429, 500, 502, 503))) break      # só repete em erros temporários
  }
  NULL
}

# Transforma um registro do OpenAlex em uma linha de tabela
extrai_registro <- function(w) {
  tibble(
    openalex_id = sub("https://openalex.org/", "", w$id %||% NA),
    doi         = normaliza_doi(w$doi %||% NA),
    titulo      = w$display_name %||% NA,
    ano         = w$publication_year %||% NA,
    data_pub    = w$publication_date %||% NA,
    tipo        = w$type %||% NA,
    idioma      = w$language %||% NA,
    veiculo     = w$primary_location$source$display_name %||% NA
  )
}
`%||%` <- function(a, b) if (is.null(a)) b else a

# Busca um trabalho pelo DOI
busca_por_doi <- function(doi) {
  chama_api(paste0("https://api.openalex.org/works/doi:", doi, "?mailto=", MAILTO))
}

# Busca vários trabalhos pelo ID OpenAlex (lotes de até 50)
busca_por_ids <- function(ids) {
  if (length(ids) == 0) return(tibble())
  lotes <- split(ids, ceiling(seq_along(ids) / 50))
  bind_rows(lapply(lotes, function(l) {
    url <- paste0("https://api.openalex.org/works?filter=openalex:",
                  paste(l, collapse = "|"), "&per-page=50&mailto=", MAILTO)
    r <- chama_api(url)
    if (is.null(r)) return(tibble())
    bind_rows(lapply(r$results, extrai_registro))
  }))
}

# Forward: todos que citam um trabalho (paginação por cursor)
busca_citantes <- function(id) {
  saida <- list(); cursor <- "*"
  repeat {
    url <- paste0("https://api.openalex.org/works?filter=cites:", id,
                  ",to_publication_date:", DATA_CORTE,
                  "&per-page=200&cursor=", URLencode(cursor, reserved = TRUE),
                  "&mailto=", MAILTO)
    r <- chama_api(url)
    if (is.null(r) || length(r$results) == 0) break
    saida <- c(saida, lapply(r$results, extrai_registro))
    cursor <- r$meta$next_cursor
    if (is.null(cursor)) break
  }
  bind_rows(saida)
}

# ---------------------------------------------------------------------
# 2b. Teste de conexão (para cedo, com mensagem clara)
# ---------------------------------------------------------------------
teste <- chama_api(paste0("https://api.openalex.org/works/doi:10.48550/arxiv.1706.03762?mailto=", MAILTO))
if (is.null(teste)) stop("Sem resposta do OpenAlex. Verifique internet, proxy/VPN da instituição ",
                         "ou se a API passou a exigir chave (preencha API_KEY).")
message("Conexão com o OpenAlex: OK")

# ---------------------------------------------------------------------
# 3. Conjunto inicial
# ---------------------------------------------------------------------
if (!file.exists(ARQ_CORPUS)) stop("Não encontrei '", ARQ_CORPUS, "' em ", getwd(),
                                   ". Coloque o CSV na mesma pasta do script ou informe o caminho completo.")
corpus <- read_csv(ARQ_CORPUS, show_col_types = FALSE) %>%
  mutate(doi_n = normaliza_doi(DOI), tit_n = normaliza_titulo(Titulo))

seed <- corpus %>% filter(Codigo %in% CODIGOS_SEED, !is.na(doi_n))
message("Conjunto inicial: ", nrow(seed), " estudos com DOI")

# ---------------------------------------------------------------------
# 4. Backward e forward
# ---------------------------------------------------------------------
resultados <- list()
sem_match  <- character()

for (i in seq_len(nrow(seed))) {
  s <- seed[i, ]
  message(sprintf("[%d/%d] %s", i, nrow(seed), s$ID))
  w <- busca_por_doi(s$doi_n)
  if (is.null(w)) { sem_match <- c(sem_match, s$ID); next }
  wid <- sub("https://openalex.org/", "", w$id)

  # Backward: referências do estudo
  refs <- unlist(lapply(w$referenced_works, function(x) sub("https://openalex.org/", "", x)))
  b <- busca_por_ids(refs)
  if (nrow(b) > 0) resultados[[length(resultados) + 1]] <- mutate(b, direcao = "backward", seed_id = s$ID)

  # Forward: quem cita o estudo
  f <- busca_citantes(wid)
  if (nrow(f) > 0) resultados[[length(resultados) + 1]] <- mutate(f, direcao = "forward", seed_id = s$ID)
}

if (length(resultados) == 0) stop("Nenhum resultado obtido: nenhum DOI do conjunto inicial foi encontrado no OpenAlex.")

cand <- bind_rows(resultados) %>% filter(!is.na(titulo))   # descarta registros sem metadados

# ---------------------------------------------------------------------
# 5. Filtros objetivos, duplicatas e sinal no título
# ---------------------------------------------------------------------
cand <- cand %>%
  mutate(tit_n = normaliza_titulo(titulo),
         criterio_objetivo = case_when(
           is.na(ano) | ano < ANO_MIN                     ~ "CI4 (ano)",
           !is.na(idioma) & !(idioma %in% IDIOMAS_OK)     ~ "CI5 (idioma)",
           tipo %in% c("editorial", "book-review", "paratext", "reference-entry", "letter", "erratum") ~ "CE5 (formato)",
           tipo == "book"                                 ~ "CI3 (livro)",
           !(tipo %in% TIPOS_OK)                          ~ "CE2 (cinzenta)",
           TRUE ~ "ok"),
         no_corpus = (!is.na(doi) & doi %in% corpus$doi_n) | tit_n %in% corpus$tit_n)

# Um candidato pode vir de vários estudos e das duas direções: consolidar
cand_unico <- cand %>%
  group_by(openalex_id) %>%
  summarise(doi = first(doi), titulo = first(titulo), ano = first(ano),
            tipo = first(tipo), idioma = first(idioma), veiculo = first(veiculo),
            criterio_objetivo = first(criterio_objetivo), no_corpus = any(no_corpus),
            direcao = paste(sort(unique(direcao)), collapse = "+"),
            n_seeds = n_distinct(seed_id),
            seeds = paste(sort(unique(seed_id)), collapse = "; "),
            .groups = "drop")

# Sinal no título (mesmos blocos da string de busca, simplificados)
t <- tolower(cand_unico$titulo)
PRIV <- "privac|data protection|gdpr|lgpd|anonymi|pseudonymi|de-?identif|personal data|dpia|linddun|membership inference"
ML   <- "machine learning|\\bml\\b|artificial intelligence|\\bai\\b|deep learning|\\bllms?\\b|language model|mlops|data science"
PROC <- "life ?cycle|crisp|mlops|process|methodolog|framework|by design|governance|assurance|audit|risk|requirement|guideline|checklist|compliance"
cand_unico <- cand_unico %>%
  mutate(sinal_priv = coalesce(str_detect(t, PRIV), FALSE),
         sinal_ml   = coalesce(str_detect(t, ML), FALSE),
         sinal_proc = coalesce(str_detect(t, PROC), FALSE),
         sinal = sinal_priv + sinal_ml + sinal_proc,
         prioridade = case_when(
           criterio_objetivo != "ok" | no_corpus ~ "0 - nao triar",
           sinal == 3 ~ "1 - alta",
           sinal_priv & (sinal_ml | sinal_proc) ~ "2 - média",
           TRUE ~ "3 - baixa")) %>%
  arrange(prioridade, desc(n_seeds), desc(ano))

# ---------------------------------------------------------------------
# 6. Saída
# ---------------------------------------------------------------------
cand_unico <- cand_unico %>%
  mutate(decisao_cesar = "", decisao_icaro = "", decisao_final = "", observacao = "")
write_excel_csv(cand_unico, ARQ_SAIDA)   # UTF-8 com BOM: acentos corretos no Excel

resumo <- tibble(
  indicador = c("Estudos no conjunto inicial", "Estudos sem correspondência no OpenAlex",
                "Registros brutos (backward + forward)", "Candidatos únicos",
                "Excluídos por critério objetivo", "Já presentes no corpus (duplicatas)",
                "Novos para triagem", "  prioridade 1", "  prioridade 2", "  prioridade 3"),
  valor = c(nrow(seed), length(sem_match), nrow(cand), nrow(cand_unico),
            sum(cand_unico$criterio_objetivo != "ok"),
            sum(cand_unico$criterio_objetivo == "ok" & cand_unico$no_corpus),
            sum(cand_unico$criterio_objetivo == "ok" & !cand_unico$no_corpus),
            sum(cand_unico$prioridade == "1 - alta"),
            sum(cand_unico$prioridade == "2 - média"),
            sum(cand_unico$prioridade == "3 - baixa")))
write_excel_csv(resumo, sub("\\.csv$", "_resumo_prisma.csv", ARQ_SAIDA))
print(resumo, n = Inf)
message("Arquivos salvos em: ", normalizePath(ARQ_SAIDA))
if (length(sem_match) > 0) message("Sem correspondência no OpenAlex: ", paste(sem_match, collapse = ", "))
