# carregar pacotes (instala se não tiver)
if (!require(pointblank)) install.packages("pointblank")
if (!require(dplyr)) install.packages("dplyr")

library(pointblank)
library(dplyr)

# carregar base de dados
data("airquality")


# criando o agente de validação (tipo um "controlador" das regras)
agent <- create_agent(
  tbl = airquality,              # tabela que vou validar
  tbl_name = "airquality"
) %>%
  
  # ===== regras básicas de calendário =====

col_vals_between(columns = Month, left = 5, right = 9) %>%   # mês só pode ser de maio (5) até setembro (9)
  col_vals_between(columns = Day, left = 1, right = 31) %>%    # dia entre 1 e 31 (padrão)
  col_vals_not_null(columns = c(Month, Day)) %>%               # não pode ter NA nessas colunas
  
  
  # ===== regras das variáveis meteorológicas =====

col_vals_gt(columns = Wind, value = 0) %>%                   # vento tem que ser positivo
  col_vals_between(columns = Temp, left = 40, right = 120) %>%# temperatura em faixa "aceitável"
  col_vals_gt(columns = Solar.R, value = 0) %>%                # radiação solar positiva
  col_vals_not_null(columns = c(Wind, Temp, Solar.R)) %>%      # não pode faltar esses dados
  
  
  # ===== regras entre variáveis (relacionais) =====

col_vals_expr(
  expr = ~ is.na(Ozone) | !is.na(Solar.R)   # se tem Ozone, deveria ter Solar.R também
) %>%
  
  col_vals_expr(
    expr = ~ is.na(Ozone) | (!is.na(Wind) & !is.na(Temp))  # se tem Ozone, precisa ter Wind e Temp
  )


# rodando a validação (aqui ele testa tudo)
agent <- interrogate(agent)


# relatório geral (resumo das regras)
report <- get_agent_report(agent)
print(report)


# separar dados bons e ruins
dados_validos   <- get_sundered_data(agent, type = "pass")   # passou em tudo
dados_invalidos <- get_sundered_data(agent, type = "fail")   # falhou em alguma regra


# só pra ver quantos deram problema
cat("\nResumo:\n")
cat("Válidos:", nrow(dados_validos), "\n")
cat("Inválidos:", nrow(dados_invalidos), "\n")


# ver exatamente quais linhas deram erro
print(dados_invalidos)


# contar quantos erros por regra (pra entender onde deu ruim)
cat("\nErros por regra:\n")

for (i in 1:12) {
  n_falhas <- agent$validation_set$f_failed[i] * nrow(airquality)
  cat("Regra", i, "->", round(n_falhas), "falhas\n")
}