import numpy as np
import pandas as pd
from sklearn.linear_model import LogisticRegression
from scipy.special import expit
import matplotlib.pyplot as plt
import matplotlib.pyplot as plt

# ---------------- Configurações ---------------- #
np.random.seed(123)

n_train = 1500
n_test  = 1500

alpha = -0.5
beta  = 1.2
sigma = 1.0
delta = 0.7
a     = 1.5

# ---------------- Dados verdadeiros ---------------- #
X_train_true = np.random.normal(0, sigma, n_train)
X_test_true  = np.random.normal(0, sigma, n_test)

p_train = expit(alpha + beta * X_train_true)
p_test  = expit(alpha + beta * X_test_true)

Y_train = np.random.binomial(1, p_train)
Y_test  = np.random.binomial(1, p_test)

# ---------------- Ruído ---------------- #
U_train = np.random.uniform(-a, a, n_train)
U_test  = np.random.uniform(-a, a, n_test)

# ---------------- Processos ---------------- #
processo_train = np.random.choice([0,1,2], n_train)

X_train_obs = X_train_true.copy()

# erro aleatório
mask1 = processo_train == 1
X_train_obs[mask1] = X_train_true[mask1] + U_train[mask1]

# erro sistemático
mask2 = processo_train == 2
X_train_obs[mask2] = X_train_true[mask2] + delta + U_train[mask2]

# ---------------- MODELOS ---------------- #

# MI
model_MI = LogisticRegression()
model_MI.fit(X_train_obs.reshape(-1,1), Y_train)

# MAL (one-hot encoding do processo)
X_MAL = np.column_stack([
    X_train_obs,
    (processo_train == 1).astype(int),
    (processo_train == 2).astype(int)
])

model_MAL = LogisticRegression()
model_MAL.fit(X_MAL, Y_train)

# ---------------- CENÁRIOS ---------------- #

# Limpo
X_test_clean = X_test_true.copy()
proc_clean   = np.random.choice([0,1,2], n_test)

# Aleatório
X_test_rand = X_test_true.copy()
mask = proc_clean == 1
X_test_rand[mask] += U_test[mask]

# Sistemático
X_test_syst = X_test_true.copy()
mask1 = proc_clean == 1
mask2 = proc_clean == 2

X_test_syst[mask1] += U_test[mask1]
X_test_syst[mask2] += delta + U_test[mask2]

# ---------------- Predição ---------------- #

def pred_MI(model, X):
    return model.predict_proba(X.reshape(-1,1))[:,1]

def pred_MAL(model, X, proc):
    X_full = np.column_stack([
        X,
        (proc == 1).astype(int),
        (proc == 2).astype(int)
    ])
    return model.predict_proba(X_full)[:,1]

# previsões
p_MI_clean  = pred_MI(model_MI, X_test_clean)
p_MAL_clean = pred_MAL(model_MAL, X_test_clean, proc_clean)

p_MI_rand  = pred_MI(model_MI, X_test_rand)
p_MAL_rand = pred_MAL(model_MAL, X_test_rand, proc_clean)

p_MI_syst  = pred_MI(model_MI, X_test_syst)
p_MAL_syst = pred_MAL(model_MAL, X_test_syst, proc_clean)

# ---------------- MÉTRICAS ---------------- #

def brier(y, p):
    return np.mean((y - p)**2)

def auc_manual(y, score):
    r = score.argsort().argsort()
    n1 = np.sum(y==1)
    n0 = np.sum(y==0)
    return (np.sum(r[y==1]) - n1*(n1-1)/2) / (n1*n0)

def ece(y, p, bins=10):
    bins_edges = np.linspace(0,1,bins+1)
    ece_val = 0
    for i in range(bins):
        mask = (p >= bins_edges[i]) & (p < bins_edges[i+1])
        if np.sum(mask) == 0:
            continue
        ece_val += np.mean(mask) * abs(np.mean(y[mask]) - np.mean(p[mask]))
    return ece_val

def metrics(y, p):
    return {
        "AUC": auc_manual(y,p),
        "Brier": brier(y,p),
        "ECE": ece(y,p)
    }

# ---------------- RESULTADOS ---------------- #

print("\nCENÁRIO LIMPO")
print("MI:", metrics(Y_test, p_MI_clean))
print("MAL:", metrics(Y_test, p_MAL_clean))

print("\nCENÁRIO ALEATÓRIO")
print("MI:", metrics(Y_test, p_MI_rand))
print("MAL:", metrics(Y_test, p_MAL_rand))

print("\nCENÁRIO SISTEMÁTICO")
print("MI:", metrics(Y_test, p_MI_syst))
print("MAL:", metrics(Y_test, p_MAL_syst))

fig, axes = plt.subplots(3, 2, figsize=(10, 12))

def calib_plot_ax(ax, y, p, title="", bins=10):
    df = pd.DataFrame({"y": y, "p": p})
    df["bin"] = pd.cut(df["p"], bins=np.linspace(0,1,bins+1), include_lowest=True)
    df_bin = df.groupby("bin").mean(numeric_only=True)

    ax.plot(df_bin["p"], df_bin["y"], marker='o')
    ax.plot([0,1], [0,1], linestyle='--')
    ax.set_xlim(0,1)
    ax.set_ylim(0,1)
    ax.set_title(title)
    ax.set_xlabel("Predito")
    ax.set_ylabel("Real")

# linha 1
calib_plot_ax(axes[0,0], Y_test, p_MI_clean,  "(I) Limpo — MI")
calib_plot_ax(axes[0,1], Y_test, p_MAL_clean, "(I) Limpo — MAL")

# linha 2
calib_plot_ax(axes[1,0], Y_test, p_MI_rand,  "(II) Aleatório — MI")
calib_plot_ax(axes[1,1], Y_test, p_MAL_rand, "(II) Aleatório — MAL")

# linha 3
calib_plot_ax(axes[2,0], Y_test, p_MI_syst,  "(III) Sistemático — MI")
calib_plot_ax(axes[2,1], Y_test, p_MAL_syst, "(III) Sistemático — MAL")

plt.tight_layout()
plt.show()