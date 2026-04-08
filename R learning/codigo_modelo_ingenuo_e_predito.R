## ------------------------- Importação das Bibliotecas ------------------------- ##
## ------------------------- Importação das Bibliotecas ------------------------- ##

if (!require(patchwork)) {
  install.packages("patchwork")
  library(patchwork)
} else {
  library(patchwork)
}

library(ggplot2)

## --------------------------- Configurações Iniciais --------------------------- ##

set.seed(123)             # Semente

n_train         <- 1000   # Tamanho do conjunto de treino
n_test          <- 1000   # Tamanho do conjunto de teste

alpha           <- -0.5   # Intercepto (modelo gerador)
beta            <-  1.2   # Efeito do biomarcador (modelo gerador)
sigma           <-  1.0   # Desvio-padrão do biomarcador

delta           <-  0.7   # Erro sistemático de calibração no Lab B

## ------------------------ Geração dos Dados Simulados ------------------------- ##

## Biomarcador (X^ast)

X_train_true    <- rnorm(n_train, mean = 0, sd = sigma)
X_test_true     <- rnorm(n_test,  mean = 0, sd = sigma)

## Desfecho binário (modelo logístico)

p_train         <- plogis(alpha + beta * X_train_true)
p_test          <- plogis(alpha + beta * X_test_true)

Y_train         <- rbinom(n_train, size = 1, prob = p_train)
Y_test          <- rbinom(n_test,  size = 1, prob = p_test)

## Definição do Laboratório (0 = Laboratório A, 1 = Laboratório B)

lab_train       <- rbinom(n_train, size = 1, prob = 0.5)

## Erro sistemático de calibração: deslocamento constante aplicado ao Lab B

X_train_obs     <- X_train_true + ifelse(lab_train == 1, delta, 0)

## Resumo descritivo do biomarcador por laboratório (conjunto de treino)

cat(" # --------------------------------------------------------- #\n",
    "# Resumo Descritivo do Biomarcador (X) (Conjunto de Treino) #\n",
    "# --------------------------------------------------------- #\n\n",
    
    "Laboratório A (lab_train = 0)\n\n",
    "n = ", sum(lab_train == 0), "\n\n",
    paste("",capture.output(summary(X_train_obs[lab_train == 0])), collapse = "\n"),
    "\n\n\n",
    
    "Laboratório B (lab_train = 1)\n\n",
    "n = ", sum(lab_train == 1), "\n\n",
    paste("",capture.output(summary(X_train_obs[lab_train == 1])), collapse = "\n"),
    "\n"
)

## ----------------------------- Ajuste dos Modelos ----------------------------- ##

## (I) Modelo ingênuo (MI)

m_MI            <- glm(Y_train ~ X_train_obs, family = binomial)

## (II) Modelo ajustado com indicador de laboratório (MAL)

m_MAL           <- glm(Y_train ~ X_train_obs + lab_train, family = binomial)

## Resultados

cat(" # ---------------------------- #\n",
    "# Resumo dos Modelos Ajustados #\n",
    "# ---------------------------- #\n\n",
    
    "(I) MI\n",
    paste("",capture.output(summary(m_MI)), collapse = "\n"),
    "\n\n",
    
    "(II) MAL\n",
    paste("",capture.output(summary(m_MAL)), collapse = "\n")
)

coef(m_MI)
coef(m_MAL)



## ----------------------------- Cenários de Teste ------------------------------ ##

## (I) Cenário limpo (sem erro sistemático)

lab_test_clean  <- rbinom(n_test, size = 1, prob = 0.5)
X_test_clean    <- X_test_true

## (II) Cenário misto (erro sistemático presente no Lab B)

lab_test_mixed  <- rbinom(n_test, size = 1, prob = 0.5)
X_test_mixed    <- X_test_true + ifelse(lab_test_mixed == 1, delta, 0)

## Resumo descritivo do biomarcador em cada cenário

cat(" # -------------------------------------------------------- #\n",
    "# Resumo Descritivo do Biomarcador (X) (Conjunto de Teste) #\n",
    "# -------------------------------------------------------- #\n\n",
    
    "(I) Cenário Limpo\n\n",
    
    "Laboratório A (lab_test_clean = 0)\n\n",
    "n = ", sum(lab_test_clean == 0), "\n\n",
    paste("",capture.output(summary(X_test_clean[lab_test_clean == 0])), collapse = "\n"),
    "\n\n",
    
    "Laboratório B (lab_test_clean = 1)\n\n",
    "n = ", sum(lab_test_clean == 1), "\n\n",
    paste("",capture.output(summary(X_test_clean[lab_test_clean == 1])), collapse = "\n"),
    "\n\n\n",
    
    "(II) Cenário Misto\n\n",
    
    "Laboratório A (lab_test_mixed = 0)\n\n",
    "n = ", sum(lab_test_mixed == 0), "\n\n",
    paste("",capture.output(summary(X_test_mixed[lab_test_mixed == 0])), collapse = "\n"),
    "\n\n",
    
    "Laboratório B (lab_test_mixed = 1)\n\n",
    "n = ", sum(lab_test_mixed == 1), "\n\n",
    paste("",capture.output(summary(X_test_mixed[lab_test_mixed == 1])), collapse = "\n"),
    "\n"
)


## ---------------------- Predições nos Cenários de Teste ----------------------- ##

## Funções de Predição

pred_MI         <- function(model, x_obs)
{
  plogis(predict(model, 
                 newdata = data.frame(X_train_obs = x_obs)))
}

pred_MAL        <- function(model, x_obs, lab)
{
  plogis(predict(model,
                 newdata = data.frame(X_train_obs = x_obs, lab_train  = lab)))
}

## (I) Cenário limpo

p_MI_clean      <- pred_MI(m_MI,  X_test_clean)
p_MAL_clean     <- pred_MAL(m_MAL, X_test_clean, lab_test_clean)

## (II) Cenário misto

p_MI_mixed      <- pred_MI(m_MI,  X_test_mixed)
p_MAL_mixed     <- pred_MAL(m_MAL, X_test_mixed, lab_test_mixed)

## Resumo das probabilidades preditas

cat(" # -------------------------------------- #\n",
    "# Resumo das Probabilidades Preditas (p) #\n",
    "# -------------------------------------- #\n\n",
    
    "(I) Cenário Limpo\n\n",
    
    "MI\n\n",
    "n = ", length(p_MI_clean),
    " | fora de [0,1] = ", sum(p_MI_clean < 0 | p_MI_clean > 1), "\n\n",
    paste("",capture.output(summary(p_MI_clean)), collapse = "\n"),
    "\n\n",
    
    "MAL\n\n",
    "n = ", length(p_MAL_clean),
    " | fora de [0,1] = ", sum(p_MAL_clean < 0 | p_MAL_clean > 1), "\n\n",
    paste("",capture.output(summary(p_MAL_clean)), collapse = "\n"),
    "\n\n\n",
    
    "(II) Cenário Misto\n\n",
    
    "MI\n\n",
    "n = ", length(p_MI_mixed),
    " | fora de [0,1] = ", sum(p_MI_mixed < 0 | p_MI_mixed > 1), "\n\n",
    paste("",capture.output(summary(p_MI_mixed)), collapse = "\n"),
    "\n\n",
    
    "MAL\n\n",
    "n = ", length(p_MAL_mixed),
    " | fora de [0,1] = ", sum(p_MAL_mixed < 0 | p_MAL_mixed > 1), "\n\n",
    paste("",capture.output(summary(p_MAL_mixed)), collapse = "\n"),
    "\n"
)


## --------------------- Funções de Avaliação de Desempenho --------------------- ##

## Área da Curva ROC

auc             <- function(y, score)
{
  r             <- rank(score, ties.method = "average")
  n1            <- sum(y == 1)
  n0            <- sum(y == 0)
  
  if (n1 == 0 || n0 == 0) return(NA_real_)
  
  (sum(r[y == 1]) - n1 * (n1 + 1) / 2) / (n1 * n0)
}

## Escore de Brier

brier           <- function(y, p)
{
  mean((y - p)^2)
}

## Expected Calibration Error

ece             <- function(y, p, bins = 10)
{
  cutp          <- cut(p,
                       breaks = seq(0, 1, length.out = bins + 1),
                       include.lowest = TRUE)
  tab           <- split(data.frame(y = y, p = p), cutp)
  
  out           <- 0
  for (g in tab)
  {
    if (nrow(g) == 0) next
    out         <- out + (nrow(g) / length(y)) * abs(mean(g$y) - mean(g$p))
  }
  out
}

## Organização das Medidas de Performance

metrics         <- function(y, p)
{
  c(AUC = auc(y, p), Brier = brier(y, p), ECE = ece(y, p))
}

## --------------------------------- Resultados --------------------------------- ##

cat("# ----------------------------------------- #\n",
    "# MI vs MAL (Cenário Limpo e Cenário Misto) #\n",
    "# ----------------------------------------- #\n\n",
    
    "(I) Cenário Limpo\n\n",
    paste("",capture.output(
      rbind("MI"  = metrics(Y_test, p_MI_clean),
            "MAL" = metrics(Y_test, p_MAL_clean))
    ), collapse = "\n"),
    "\n\n(II) Cenário Misto\n\n",
    paste("",capture.output(
      rbind("MI"  = metrics(Y_test, p_MI_mixed),
            "MAL" = metrics(Y_test, p_MAL_mixed))
    ), collapse = "\n"),
    "\n", sep = "")


## ---------------------------- Curvas de Calibração ---------------------------- ##

calib_plot      <- function(y, p, title = "", bins = 10)
{
  df            <- data.frame(y = y, p = p)
  df$bin        <- cut(df$p, 
                       breaks = seq(0, 1, length.out = bins + 1), 
                       include.lowest = TRUE)
  df_bin        <- aggregate(cbind(y, p) ~ bin, data = df, FUN = mean)
  
  ggplot(df_bin, aes(x = p, y = y)) +
    geom_point(size = 2.2, color = "#1f77b4") +
    geom_line(linewidth = 0.7, color = "#1f77b4") +
    geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "#ff7f0e") +
    scale_x_continuous(limits = c(0, 1)) +
    scale_y_continuous(limits = c(0, 1)) +
    labs(title = title,
         x = "Probabilidade Predita",
         y = "Probabilidade Empírica") +
    theme_minimal() +
    theme(plot.title  = element_text(size = 10, hjust = 0.5, margin = margin(b = 10)),
          axis.title.x = element_text(margin = margin(t = 10)),
          axis.title.y = element_text(margin = margin(r = 10)))
}

g1              <- calib_plot(Y_test, p_MI_clean,  title = "(I) Cenário Limpo — MI")
g2              <- calib_plot(Y_test, p_MAL_clean, title = "(I) Cenário Limpo — MAL")
g3              <- calib_plot(Y_test, p_MI_mixed,  title = "(II) Cenário Misto — MI")
g4              <- calib_plot(Y_test, p_MAL_mixed, title = "(II) Cenário Misto — MAL")

(g1 | g2) / (g3 | g4)
