## Perguntas

- A priori - multiplicadores de lagrange - restrição... O que é? Qual é a ponte entre os campos / definições / uso?
- Não usar bibliotecas? Pandas, np, sns, plt -> nativos em r

# Anotações de aula
## 26/02

Em toda e qualquer análise: Notar explicitamente o desfecho e os preditores (nomes e fatores chave da distribuição) (dicionário de dados)


### Tarefa 1.1
T: A tarefa é a previsão da demanda total de energia no futuro próximo.

P: Alguma métrica associada à regressão para medir o erro da previsão (MSE, MAE, MAPE,...)

E: Banco de dados histórico contendo medições horárias de consumo agregado [...] e indicadores de eventos excepcionais.

Abaixo está a representação da tabela em formato Markdown, preservando a semântica e a formatação original dos dados:


### Machine Learning Construction Workflow
| **Etapa** | **Descrição** | **Macrofase Conceitual** |
| ----------|---------------|--------------------------|
| *(a) Definição do Problema* | *Identificação clara do problema que o sistema deve resolver, incluindo a definição da tarefa supervisionada, dos objetivos analíticos e das medidas de desempenho apropriadas para avaliação.* | **(1) Study Design** |
| *(b) Coleta de Dados* | *Aquisição e organização dos dados relevantes para o problema, garantindo representatividade, qualidade e volume suficientes para o desenvolvimento e a avaliação do modelo.* | **(2) Data Collection** |
| *(c) Pré-processamento de Dados* | *Preparação do conjunto de dados para análise, incluindo limpeza, tratamento de valores ausentes, normalização, transformação de variáveis e eventual seleção ou extração de características.* | **(3) Data Preparation** |
| *(d) Seleção e Desenvolvimento de Modelos* | *Escolha da classe de modelos ou algoritmos mais adequados à tarefa (classificação, regressão, etc.), considerando complexidade dos dados, interpretabilidade e restrições computacionais.* | **(4) Model Training** |
| *(e) Treinamento do Modelo* | *Ajuste dos parâmetros do modelo utilizando exclusivamente os dados de treinamento, permitindo que o sistema aprenda a relação entre as variáveis preditoras e a resposta.* | **(4) Model Training** |
| *(f) Validação do Modelo* | *Avaliação preliminar do desempenho do modelo com dados distintos do treinamento, com o objetivo de detectar sobreajuste, subajuste e orientar decisões de complexidade e regularização.* | **(5) Model Evaluation** |
| *(g) Teste do Modelo* | *Avaliação final do modelo em um conjunto de dados independente, não utilizado nas etapas anteriores, para estimar sua capacidade de generalização.* | **(5) Model Evaluation** |
| *(h) Ajuste e Otimização* | *Refinamento iterativo do modelo por meio da otimização de hiperparâmetros, estratégias de regularização ou simplificação estrutural, com base nos resultados de validação e teste.* | **(6) Improve Performance** |
| *(i) Implementação e Monitoramento* | *Emprego do modelo validado em contexto aplicado e monitoramento contínuo do seu desempenho, visando assegurar estabilidade e adequação frente a mudanças nos dados ou no contexto operacional.* | **(6) Improve Performance** |

### Tarefa 1.2


## 05/03