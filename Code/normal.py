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
print(df.columns)
y = df["IntRate"]
x1 = df[["Income", "DTI", "LoanAmt", "HistLen",
       "Utilisation","Age", "Offences"]]
x2 =  df[["EmpStatus", "HomeOwn", "Purpose",
       "Gender", "Education"]]
dummy_Emp = df[["Emp"]
X = pd.get_dummies(x2, drop_first=True)
model_sign = sm.OLS(y,x1+X).fit()

