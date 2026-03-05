# Importando e atribuindo dados
read.csv("../data/diabetes.csv")
df <- PimaIndiansDiabetes

# Estrutura
dim(df)
nrow(df)
ncol(df)
names(df)
str(df)
head(df)

# Tipos de variáveis
sapply(df, class)

# Valores ausentes
sum(is.na(df))
colSums(is.na(df))

vars_fisiologicas <- c("glucose", "pressure", "triceps", "insulin", "mass")
colSums(df[vars_fisiologicas] == 0)

# Resumo geral
summary(df)

# Transformação de tipo
df$diabetes <- as.factor(df$diabetes)
class(df$diabetes)
levels(df$diabetes)

str(df)

A SER TESTADO: glimpse, struct

# ============================================================
# INSPEÇÃO APROFUNDADA (gerado por IA para aprendizado)
# ============================================================

# --- Dimensões e tipos ---
cat("Dimensões:", nrow(df), "linhas x", ncol(df), "colunas\n")
sapply(df, class)
sapply(df, typeof)

# --- Primeiras e últimas linhas ---
head(df, 10)
tail(df, 10)

# --- Resumo estatístico completo ---
summary(df)

# --- Estatísticas descritivas detalhadas (variáveis numéricas) ---
vars_num <- names(df)[sapply(df, is.numeric)]

for (v in vars_num) {
  cat("\n====", v, "====\n")
  x <- df[[v]]
  cat("  Média:        ", mean(x, na.rm = TRUE), "\n")
  cat("  Mediana:      ", median(x, na.rm = TRUE), "\n")
  cat("  Desvio padrão:", sd(x, na.rm = TRUE), "\n")
  cat("  Variância:    ", var(x, na.rm = TRUE), "\n")
  cat("  Mín:          ", min(x, na.rm = TRUE), "\n")
  cat("  Máx:          ", max(x, na.rm = TRUE), "\n")
  cat("  Amplitude:    ", diff(range(x, na.rm = TRUE)), "\n")
  cat("  Assimetria:   ", (mean(x, na.rm = TRUE) - median(x, na.rm = TRUE)) / sd(x, na.rm = TRUE), "\n")
  cat("  Quantis:\n")
  print(quantile(x, probs = c(0.01, 0.05, 0.25, 0.50, 0.75, 0.95, 0.99), na.rm = TRUE))
}

# --- Contagem e % de valores ausentes por coluna ---
cat("\n--- Valores NA por coluna ---\n")
na_count <- colSums(is.na(df))
na_pct   <- round(100 * na_count / nrow(df), 2)
print(data.frame(NA_count = na_count, NA_pct = na_pct))
cat("Total de NAs:", sum(is.na(df)), "\n")
cat("Linhas com ao menos 1 NA:", sum(!complete.cases(df)), "\n")

# --- Zeros suspeitos em variáveis fisiológicas ---
cat("\n--- Zeros suspeitos (variáveis fisiológicas) ---\n")
zero_count <- colSums(df[vars_fisiologicas] == 0, na.rm = TRUE)
zero_pct   <- round(100 * zero_count / nrow(df), 2)
print(data.frame(zeros = zero_count, pct = zero_pct))

# --- Valores únicos por variável ---
cat("\n--- Número de valores únicos por variável ---\n")
print(sapply(df, function(x) length(unique(x))))

# --- Distribuição da variável resposta ---
cat("\n--- Distribuição de 'diabetes' ---\n")
print(table(df$diabetes))
print(round(100 * prop.table(table(df$diabetes)), 2))

# --- Valores únicos de variáveis categóricas/discretas ---
cat("\n--- Valores únicos: pregnant ---\n")
print(sort(unique(df$pregnant)))

cat("\n--- Valores únicos: age ---\n")
print(sort(unique(df$age)))

# --- Linhas duplicadas ---
cat("\n--- Linhas duplicadas:", sum(duplicated(df)), "\n")

# --- Correlação entre variáveis numéricas ---
cat("\n--- Matriz de correlação (Pearson) ---\n")
print(round(cor(df[vars_num], use = "complete.obs"), 3))