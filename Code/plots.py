# -*- coding: utf-8 -*-
"""
Created on Mon Sep 21 10:30:36 2026

@author: Malan
"""
import pandas as pd
import os

os.chdir("C:/STTN327/project")
df = pd.read_csv("Train.csv")
#%%
"""
Default rate by category
"""
default = df["default"]
intrate = df[ "IntRate"]
income = df["Income"]
DTi = df["DTI"]
LoanAmt = df["LoanAmt"]
HistLen = df["HistLen"]
Utilisation = df["Utilisation"]
Age = df["Age"]
EmpStatus = df["EmpStatus"]
HomeOwn = df["HomeOwn"]
Purpose = df["Purpose"]
Gender = df["Gender"]
import matplotlib.pyplot as plt
"""default by cat"""

counts = df.groupby(["default","Gender"]).size().unstack(fill_value=0)

counts.plot(kind="bar",color = ["pink","blue"])

plt.xlabel("Default")
plt.ylabel("Number of people")
plt.title("Default by Gender")
plt.xticks(rotation=0)
plt.legend(["femal", " male"])
plt.show()
"""
comment on graph:
We can see that gender and default arnot significant
"""

counts = df.groupby(["default","Purpose"]).size().unstack(fill_value=0)
print(counts)
counts.plot(kind="bar",color = ["pink","blue","red","orange"])

plt.xlabel("Default")
plt.ylabel("Number of people")
plt.title("Default by Purpose")
plt.xticks(rotation=0)
plt.legend(["Debt_consolidation","Home_improvement","Other","Vehicle"])
plt.show()
"""
we can see vechiles are the most varibles and are more likly not to pay then to
pay aswel as Home_improvement.but rest is more likly to pay
"""
counts = df.groupby(["default","EmpStatus"]).size().unstack(fill_value=0)
print(counts)
counts.plot(kind="bar",color = ["pink","blue","red","orange"])

plt.xlabel("Default")
plt.ylabel("Number of people")
plt.title("Default by EmpStatus")
plt.xticks(rotation=0)
plt.legend(["Contract "," Salaried "," Self-employed","  Unemployed"])
plt.show()
"""
Althou salary is the most at both we can see that they are the only ones that 
are more liky not to pay then to pay
"""
counts = df.groupby(["default","HomeOwn"]).size().unstack(fill_value=0)
print(counts)
counts.plot(kind="bar",color = ["pink","blue","red"])

plt.xlabel("Default")
plt.ylabel("Number of people")
plt.title("Default by HomeOwn")
plt.xticks(rotation=0)
plt.legend(["Mortgage "," Own ","Rent"])
plt.show()
"""
that if you own a home you can say thateven distr if the will pay or not.Where 
as Mortagage more likly not pay as rent is more likly to pay
"""
#%%
"""
Volint plots
"""
import seaborn as sns
sns.violinplot(data=df, x ="Gender", y="default",palette=["pink","blue"])
plt.show()
"""
This plot shows for both defaults that most income is between 0 and one million
and how higher the income how higher the chase for them to pay

"""

# Annual income vs Default 
sns.violinplot(data = df,x = "default", y = "Income")
plt.xlabel("Default")
plt.ylabel("Annual Income")
plt.title("Annual Income Distribution by Default")
plt.show()

#Age vs default
sns.violinplot(data = df,x = "default", y = "Age")
plt.xlabel("Default")
plt.ylabel("Age")
plt.title("Age Distribution by Default")
plt.show()
#DTI vs default
sns.violinplot(data = df,x = "default", y = "DTI")
plt.xlabel("Default")
plt.ylabel("DTI")
plt.title("DTI Distribution by Default")
plt.show()
#intrate vs defualt
sns.violinplot(data = df,x = "default", y = "IntRate")
plt.xlabel("Default")
plt.ylabel("interest rate")
plt.title("Interest rate Distribution by Default")
plt.show()
#Purposre vs default
sns.violinplot(data = df,x = "Purpose", y =  "default")
plt.ylabel("Default")
plt.xlabel("Purpose")
plt.title("purpose Distribution by Default")
plt.show()
#loanamt vs default
sns.violinplot(data = df,x = "default", y = "LoanAmt")
plt.xlabel("Default")
plt.ylabel("loanamount")
plt.title("loanamount Distribution by Default")
plt.show()
# Histlen vs default
sns.violinplot(data = df,x = "default", y = "HistLen")
plt.xlabel("Default")
plt.ylabel("Hist Length")
plt.title("hist lebgth Distribution by Default")
plt.show()
#utilisation vs default
sns.violinplot(data = df,x = "default", y = "Utilisation")
plt.xlabel("Default")
plt.ylabel("Utilisation")
plt.title("Utilisation Distribution by Default")
plt.show()
#%%
"""Scatter plots"""
#annual income 
sns.scatterplot( data= df ,x = "Income",y = "default")
plt.xlabel("Income")
plt.ylabel("Default")
plt.title("income vs Default")

plt.show()

#Age vs income
sns.scatterplot(data = df , x = "Income" ,  y = "Age")
plt.xlabel("Income")
plt.ylabel("Age")
plt.title("Age and income")

plt.show()
#interest rate vs inome
sns.scatterplot(data = df , x = "Income" ,  y = "IntRate")
plt.xlabel("Income")
plt.ylabel("interest rate")
plt.title("interest rate and income")
plt.show()
# interest rate vs default
sns.scatterplot(data = df ,  y = "default" ,  x = "IntRate")
plt.ylabel("default")
plt.xlabel("interest rate")
plt.title("interest rate and default")
plt.show()

