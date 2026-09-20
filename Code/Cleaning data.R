## Credit risk project
################################################################################

## Reading the data
################################################################################

setwd("C:/STTN327")
credit_df<-read.csv("Credit_data_raw.csv",header= TRUE)


## Cleaning data
################################################################################

# 1.) NON-NUMERIC

# 1.1) Get all the text values in the IntRate column
suppressWarnings(numeric_intrate <- as.numeric(credit_df$IntRate))
text_in_intrate_idx <- which(is.na(numeric_intrate))

credit_df[text_in_intrate_idx,2] # No non-numerics
###

# 1.2) Get all the text values in the Income column
suppressWarnings(numeric_income <- as.numeric(credit_df$Income))
text_in_income_idx <- which(is.na(numeric_income))

credit_df[text_in_income_idx,3] # Some text values

# Get the median and replace the missing values with it
credit_df1 <- credit_df[-text_in_income_idx,]
med_income <- median(credit_df1$Income)
credit_df$Income[text_in_income_idx] <-med_income
###

# 1.3) Get all the text values in the DTI column
suppressWarnings(numeric_DTI<-as.numeric(credit_df$DTI))
text_in_DTI_idx<-which(is.na(numeric_DTI))

credit_df[text_in_DTI_idx,4] # No non-numerics
###

# 1.4) Get all the text values in the LoanAmt column
suppressWarnings(numeric_LoanAmt<-as.numeric(credit_df$LoanAmt))
text_in_LoanAmt_idx<-which(is.na(numeric_LoanAmt))

credit_df[text_in_LoanAmt_idx,5] # Some text values

# Get the median and replace the missing values with it
credit_df[6315,5]<-as.numeric(2952407)
credit_df2<-credit_df[-text_in_LoanAmt_idx,]
med_loan<-median(credit_df2$LoanAmt)
credit_df$LoanAmt[text_in_LoanAmt_idx[-1]] <-med_loan
###

# 1.5) Get all the text values in the HistLen column
suppressWarnings(numeric_Hist<-as.numeric(credit_df$HistLen))
text_in_Hist_idx<-which(is.na(numeric_Hist))

credit_df[text_in_Hist_idx, 6] # No non-numerics
###

# 1.6) Get all the text values in the Utilisation column
suppressWarnings(numeric_Utilisation<-as.numeric(credit_df$Utilisation))
text_in_Utilisation_idx<-which(is.na(numeric_Utilisation))

credit_df[text_in_Utilisation_idx, 7] # No non-numerics
###

# 1.7) Get all the text values in the Age column
suppressWarnings(numeric_Age<-as.numeric(credit_df$Age))
text_in_Age_idx<-which(is.na(numeric_Age))

credit_df[text_in_Age_idx, 8] # No non-numerics
###

# 1.8) Get all the text values in the default column
suppressWarnings(numeric_default<-as.numeric(credit_df$default))
text_in_default_idx<-which(is.na(numeric_DTI))

credit_df[text_in_Age_idx, 12] # No non-numerics
###
################################################################################


## 2.) REMOVE ALL THE NA-VALUES

na_Emp_idx<-which(is.na(credit_df$EmpStatus))
cat("rows with missing values",na_Emp_idx,"\n")

na_HomeOwn_idx<-which(is.na(credit_df$HomeOwn))
cat("rows with missing values",na_HomeOwn_idx,"\n")

na_Purpose_idx<-which(is.na(credit_df$Purpose))
cat("rows with missing values",na_Purpose_idx,"\n")

na_default_idx<-which(is.na(credit_df$default))
cat("rows with missing values",na_default_idx,"\n")

################################################################################


## 3.) FIX SPELLING ERRORS

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
################################################################################


## 4.) REMOVE DUPLICATES

dup_idx<-which(duplicated(credit_df$ID))
cat("Rows that are duplicates:",dup_idx,"\n")
credit_df <- credit_df[!duplicated(credit_df), ]
credit_df3<-credit_df[dup_idx,]
################################################################################


## 5.) DATA OUT OF RANGE

wrong_intrate_idx<-which(credit_df$IntRate < 0|credit_df$IntRate>35)
cat("Rows with impossible intrate :",wrong_intrate_idx ,"\n")
credit_df4<-credit_df[wrong_intrate_idx,2]
credit_df[10003,2]<-17.75
credit_df[10004,2]<-30.75
credit_df[10005,2]<-20.75

wrong_income_idx<-which(credit_df$Income < 0|credit_df$Income > 4448752)
cat("rows with impossible intrate :",wrong_income_idx ,"\n")


wrong_DTI_idx<-which(credit_df$DTI< 0| credit_df$DTI > 4)
cat("rows with impossible intrate :",wrong_DTI_idx ,"\n")
credit_df4<-credit_df[wrong_DTI_idx,4]
credit_df[9992,4]<-0.47

wrong_DTI_idx<-which(credit_df$DTI< 0| credit_df$DTI > 4)
cat("rows with impossible intrate :",wrong_DTI_idx ,"\n")

wrong_loanamt_idx<-which(credit_df$LoanAmt< 0)
cat("rows with impossible intrate :",wrong_loanamt_idx ,"\n")
credit_df4<-credit_df[wrong_loanamt_idx,5]
credit_df[wrong_loanamt_idx,5]<-1468937

wrong_age_idx<-which(credit_df$Age < 21|credit_df$Age > 100)
cat("rows with impossible intrate :",wrong_age_idx ,"\n")
credit_df4<-credit_df[wrong_age_idx,8]
credit_df[ 10001,8]<-25.8
credit_df[ 10002,8]<-53
clean_data<-credit_df
################################################################################


write.csv(clean_data, "C:/STTN327/Credit_data_clean.csv", row.names = FALSE)
