install.packages("mlbench")
install.packages("tidyverse")
install.packages("summarytools")


# Carregamento das bibliotecas
library(mlbench)
library(tidyverse)
library(summarytools)


# Carregando o dataset
data(PimaIndiansDiabetes)

dados <- PimaIndiansDiabetes


# (a) Estrutura inicial da base de dados

# Número de observações e variáveis
dim(dados)

# Nomes das variáveis
colnames(dados)

# Estrutura da base
str(dados)

# Visualização rápida dos dados
head(dados)
tail(dados)

# Estrutura em formato tidyverse
glimpse(dados)



# (b) Tipos de dados das variáveis

# Tipo de cada variável
sapply(dados, class)

# Quantidade de valores únicos por variável
sapply(dados, function(x) length(unique(x)))



# (c) Verificação de valores ausentes e codificações especiais

# Verificar valores ausentes (NA)
colSums(is.na(dados))

# Verificar valores iguais a zero
colSums(dados == 0)


# (d) Inspeção estrutural e resumo geral da base

# Resumo estatístico básico
summary(dados)

# Relatório completo da base
dfSummary(dados)
