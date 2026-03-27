# instalar se precisar
install.packages("NHANES")
install.packages("ggplot2")
install.packages("dplyr")

# carregar
library(NHANES)
library(ggplot2)
library(dplyr)

data(NHANES)


# a - histograma
hist(NHANES$BMI, main="Histograma BMI", xlab="BMI")

hist(NHANES$BMI, breaks="Sturges", main="BMI - Sturges", xlab="BMI")
hist(NHANES$BMI, breaks="FD", main="BMI - Freedman-Diaconis", xlab="BMI")


# b - boxply

boxplot(BMI ~ Gender, data = NHANES,
        main = "BMI por Gênero",
        xlab = "Gênero",
        ylab = "BMI")

# vilino

ggplot(NHANES, aes(x = Gender, y = BMI)) +
  geom_violin(fill = "lightblue") +
  labs(title = "Distribuição de BMI por Gênero",
       x = "Gênero",
       y = "BMI") +
  theme_minimal()


# barras
# frequência absoluta
freq <- table(NHANES$Education)
barplot(freq, main="Educação (freq absoluta)", las=2)

# frequência relativa
freq_rel <- prop.table(freq)
barplot(freq_rel, main="Educação (freq relativa)", las=2)



# e - Tabela contingência
tab <- table(NHANES$Diabetes, NHANES$Gender)

tab

prop.table(tab, margin = 1)

prop.table(tab, margin = 2)

barplot(tab, beside=TRUE, legend=TRUE,
        main="Diabetes por Gênero")

# f - dispersão

plot(NHANES$Height, NHANES$Weight,
     main="Altura vs Peso",
     xlab="Altura",
     ylab="Peso")

ggplot(NHANES, aes(x = Height, y = Weight)) +
  geom_point(alpha = 0.5) +
  labs(title="Altura vs Peso") +
  theme_minimal()



# g - mat dispersão
vars <- NHANES %>%
  select(Age, BMI, TotChol, BPSysAve)

pairs(vars)

# h - valores faltantes
colMeans(is.na(NHANES[, c("BMI", "Age", "TotChol", "BPSysAve")]))

                
barplot(colMeans(is.na(NHANES)) ,
        main="Proporção de NA por variável",
        las=2)
