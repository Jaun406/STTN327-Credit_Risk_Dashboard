# -*- coding: utf-8 -*-
"""
Created on Mon Sep 21 10:30:36 2026

@author: Malan
"""
"""
Lets import the data
"""
import pandas as pd
import os
import matplotlib.pyplot as plt
import seaborn as sns


os.chdir("C:/STTN327/project")
df = pd.read_csv("Train.csv")

from scipy.stats import shapiro
Intersest_rate = df["IntRate"]

stat,p = shapiro(Intersest_rate)
print("Ho : Data is noramilly distr ")
print ("Ha: Data is not normally distr")
print ("Statistic =", stat)
if p > 0.05 :
    print(p ," > a : Meaning we don't reject Ho" )
    print("Meaning the data is normally distr")
else :
    print(p , "< a : Meaning we reject Ho")
    print("The Data is no normalliy distr")
    print("Becuase its not normal we must standardised the data by calculating:")
    print("mean and sd")
    mean = Intersest_rate.mean()
    print("mean = " ,mean)
    std = Intersest_rate.std()
    print ("Std = ",std)
if p > 0.05 :
    print("do not need to test normality with standardised group")
else :
    print("test the normality of the standandised group")
    print("Ho : Data is noramilly distr ")
    print ("Ha: Data is not normally distr")
#%%    
"""
building a model to calculate the interest rate
"""
#Response variable interest rate

import statsmodels.api as sm
import statsmodels.formula.api as smf
print(df.columns)
model_sign = smf.ols(formula = "IntRate ~ Income + DTI + LoanAmt + HistLen + "
                     "Utilisation+Age+Offences + C(EmpStatus)+C(HomeOwn)+"
                     "C(Purpose)+C(Gender)+C(Education)"
                    ,data = df).fit()
print(model_sign.summary())
#let see what significant
for variable in model_sign.pvalues.index:
    if variable == "Intercept":
        continue

    if model_sign.pvalues[variable] < 0.05:
        print(variable, "is significant")
    else:
        print(variable, "is not significant")
#%%
"""
lets make the right model with train data
"""
#right model 
model = smf.ols(formula = "IntRate ~ DTI + HistLen + Age + "
                     "C(EmpStatus)+C(HomeOwn)+C(Purpose)"
                    ,data = df).fit()
print(model.summary())
#lets see what the redisual are
res = model.resid
stat,p = shapiro(res)
print("Ho : Data is noramilly distr ")
print ("Ha: Data is not normally distr")
print ("Statistic =", stat)
if p > 0.05 :
    print(p ," > a : Meaning we don't reject Ho" )
    print("Meaning the data is normally distr")
else :
    print(p , "< a : Meaning we reject Ho")
    print("The Data  residuakl are not normal is no normalliy distr")
#lets make a graph to see
sns.histplot(res,kde = "density")
plt.show()
#%%
"""
lets test my model
"""
predicted = round(model.predict(df),2)
intrate = round(df["IntRate"],2)
error = abs(predicted - intrate)
max = error.max()
avg = error.mean()
error_below = error[error < 1]
accuracy_table = pd.concat([intrate,predicted,error],axis = 1)
print(predicted)
print("the max error is : ",max)
print("the avg error is : ",avg)
print("the number of data that is below 1 error is :",error_below.count(),
      "out of ",predicted.count())
"""
lets make plots to show what happen
"""

plt.plot(predicted,intrate)
plt.show() 
plt.scatter(intrate,predicted)
plt.xlabel("Actual")
plt.ylabel("predicted")
plt.title("Actusl vs predicted")
plt.show()
plt.plot(error)

sns.scatterplot(
    x=model.fittedvalues,
    y=model.resid,
    alpha=0.4
)
plt.axhline(0, color="red", linestyle="--")
plt.xlabel("Fitted values")
plt.ylabel("Residuals")
plt.show()

# Q-Q plot
sm.qqplot(model.resid, line="45", fit=True)
plt.show()

#%%
"""
Test data
"""
os.chdir("C:/STTN327/project")
test = pd.read_csv("credit_score_Test.csv")
"""
lets test the models
"""
model_test = smf.ols(formula = "IntRate ~ DTI + HistLen + Age + "
                     "C(EmpStatus)+C(HomeOwn)+C(Purpose)"
                    ,data = test).fit()
print(model_test.summary())
res_test = model_test.resid
stat,p = shapiro(res_test)
print("Ho : Data is noramilly distr ")
print ("Ha: Data is not normally distr")
print ("Statistic =", stat)
if p > 0.05 :
    print(p ," > a : Meaning we don't reject Ho" )
    print("Meaning the data is normally distr")
else :
    print(p , "< a : Meaning we reject Ho")
    print("The Data  residuakl are not normal is no normalliy distr")
#lets make a graph to see
plt.plot(res_test,res_test)
plt.show()
sns.histplot(res_test,kde = "density")
plt.show()
#%%
"""
lets test my model
"""
predicted = round(model_test.predict(test),2)
intrate = round(test["IntRate"],2)
error = abs(predicted - intrate)
max = error.max()
avg = error.mean()
error_below = error[error < 1]
accuracy_table = pd.concat([intrate,predicted,error],axis = 1)
print(predicted)
print("the max error is : ",max)
print("the avg error is : ",avg)
print("the number of data that is below 1 error is :",error_below.count(),
      "out of ",predicted.count())
"""
lets make plots to show what happen
"""
plt.plot(predicted,intrate)
plt.show() 
plt.scatter(intrate,predicted)
plt.xlabel("Actual")
plt.ylabel("predicted")
plt.title("Actusl vs predicted")
plt.show()
plt.plot(error)

# Q-Q plot
sm.qqplot(model_test.resid, line="45", fit=True)
plt.show()
#%%
"""
what the coef does
"""
# Extract coefficients from the fitted model
coef = model_test.params

# Remove the intercept
coef = coef.drop("Intercept", errors="ignore")

# Create bar plot
colors = ["green" if x >= 0 else "red" for x in coef.values]

coef.plot(kind="bar", color=colors, figsize=(12, 6))

plt.axhline(y=0, color="black", linewidth=0.8)
plt.title("OLS Regression Coefficients for IntRate")
plt.xlabel("Variables")
plt.ylabel("Coefficient")
plt.xticks(rotation=45, ha="right")
plt.tight_layout()
plt.show()

sns.scatterplot(
    x=model_test.fittedvalues,
    y=model_test.resid,
    alpha=0.4
)
plt.axhline(0, color="red", linestyle="--")
plt.xlabel("Fitted values")
plt.ylabel("Residuals")
plt.show()

# Q-Q plot
sm.qqplot(model_test.resid, line="45", fit=True)
plt.show()
