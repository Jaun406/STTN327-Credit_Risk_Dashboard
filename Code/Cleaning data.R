##project
##reading the data
setwd("C:/STTN327")
credit_df<-read.csv("Credit_data_raw.csv",header= TRUE)
#########
#Cleaning data for ID4
#########
########
##no-numeric

suppressWarnings(numeric_intrate<-as.numeric(credit_df$IntRate))
text_in_intrate_idx<-which(is.na(numeric_intrate))


suppressWarnings(numeric_income<-as.numeric(credit_df$Income))
text_in_income_idx<-which(is.na(numeric_income))
credit_df<-credit_df[-text_in_income_idx,]

suppressWarnings(numeric_DTI<-as.numeric(credit_df$DTI))
text_in_DTI_idx<-which(is.na(numeric_DTI))

suppressWarnings(numeric_LoanAmt<-as.numeric(credit_df$LoanAmt))
text_in_LoanAmt_idx<-which(is.na(numeric_LoanAmt))
credit_df<-credit_df[-text_in_LoanAmt_idx,]

suppressWarnings(numeric_Hist<-as.numeric(credit_df$HistLen))
text_in_Hist_idx<-which(is.na(numeric_Hist))

suppressWarnings(numeric_Utilisation<-as.numeric(credit_df$Utilisation))
text_in_Utilisation_idx<-which(is.na(numeric_Utilisation))

suppressWarnings(numeric_Age<-as.numeric(credit_df$Age))
text_in_Age_idx<-which(is.na(numeric_Age))


suppressWarnings(numeric_default<-as.numeric(credit_df$default))
text_in_default_idx<-which(is.na(numeric_DTI))

na_Emp_idx<-which(is.na(credit_df$EmpStatus))
cat("rows with missing values",na_Emp_idx,"\n")

na_HomeOwn_idx<-which(is.na(credit_df$HomeOwn))
cat("rows with missing values",na_HomeOwn_idx,"\n")

na_Purpose_idx<-which(is.na(credit_df$Purpose))
cat("rows with missing values",na_Purpose_idx,"\n")

na_default_idx<-which(is.na(credit_df$default))
cat("rows with missing values",na_default_idx,"\n")

#####
##missplet categories
####
valid_EMP_categories<- c("Salaried","Self-employed","Contract","Unemployed")
typo_EmpStatus_idx<-which(!credit_df$EmpStatus %in% valid_EMP_categories)
cat("rows with missplet word",typo_EmpStatus_idx,"\n")

valid_HomeOwn_categories<- c("Rent","Mortgage","Own")
typo_HomeOwn_idx<-which(!credit_df$HomeOwn %in% valid_HomeOwn_categories)
cat("rows with missplet word",typo_HomeOwn_idx,"\n")
credit_df$HomeOwn[c(3352, 3371, 3546)]
credit_df$HomeOwn[c(3352, 3371, 3546)] <- "Mortgage"


valid_Purpose_categories<- c("Other","Home_improvement","Vehicle","Debt_consolidation")
typo_Purpose_idx<-which(!credit_df$Purpose %in% valid_Purpose_categories)
cat("rows with missplet word",typo_Purpose_idx,"\n")
#####
##Duplicate remove
####
dup_idx<-which(duplicated(credit_df))
cat("rows that are duplicates:",dup_idx,"\n")
credit_df <- credit_df[!duplicated(credit_df), ]
##
#DATA OUT OF RANGE
##

