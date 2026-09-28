# -*- coding: utf-8 -*-
"""
Created on Mon Sep 21 10:30:36 2026

@author: Malan
"""
import pandas as pd
import os

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
stand_IntRate = (Intersest_rate - mean)/std
print(stand_IntRate.head(6))
stat1,p1 = shapiro(stand_IntRate)
print ("Statistic =", stat1)
if p1 > 0.05 :
    print(p1 ," > a : Meaning we don't reject Ho" )
    print("Meaning the data is normally distr")
else :
    print(p1 , "< a : Meaning we reject Ho")
    print("The Data is no normalliy distr")
#%%
"""
building a model to calculate the interest rate
"""
#Response variable interest rate

import statsmodels.api as sm
import statsmodels.formula.api as smf
print(df.columns)
y = df["IntRate"]
x1 = df[["Income", "DTI", "LoanAmt", "HistLen",
       "Utilisation","Age", "Offences"]]
x2 =  df[["EmpStatus", "HomeOwn", "Purpose",
       "Gender", "Education"]]

model_sign = smf.ols(formula = "IntRate ~ Income + DTI + LoanAmt + HistLen + "
                     "Utilisation+Age+Offences + C(EmpStatus)+C(HomeOwn)+"
                     "C(Purpose)+C(Gender)+C(Education)"
                    ,data = df).fit()
print(model_sign.summary())

for variable in model_sign.pvalues.index:
    if variable == "Intercept":
        continue

    if model_sign.pvalues[variable] < 0.05:
        print(variable, "is significant")
    else:
        print(variable, "is not significant")
#right model 
model = smf.ols(formula = "IntRate ~ DTI + HistLen + Age + "
                     "C(EmpStatus)+C(HomeOwn)+C(Purpose)"
                    ,data = df).fit()
print(model.summary())
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
    print("The Data is no normalliy distr")
#Test the model 
predicted = round(model_sign.predict(df),2)
intrate = round(df[ "IntRate"],2)
error = abs(predicted - intrate)
max = max(error)
avg = error.mean()
error_below = error[error < 1]
accuracy_table = pd.concat([intrate,predicted,error],axis = 1)
print(predicted)
print("the max error is : ",max)
print("the avg error is : ",avg)
print("the number of data that is below 1 error is :",error_below.count())
