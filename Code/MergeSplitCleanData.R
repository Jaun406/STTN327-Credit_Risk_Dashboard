# ==============
# Merged data
# ==============

# =================================================================================================================================
# What has been done
# ------------------
# This script have merged the biographical data and the credit data to build a more complete model on all the data.
# By doing this we have a fuller picture of all the variables and can make an informed decision.
# After the data was merged the data is split into training and testing data using a 80-20 split
# =================================================================================================================================

rm(list=ls())

setwd('C:\\STTN327')
getwd()

# Read in data
credit_df <- read.csv("Credit_data_clean.csv")
biographical_df <- read.csv("Biographical_clean.csv")

# Merge these 2 data frames on ID
Credit_Score_df <- merge(credit_df, biographical_df, by="ID")
write.csv(Credit_Score_df,"Credit_Score.csv")

# Create test and training data sets

n <- nrow(Credit_Score_df)
training.rows <- sample(1:n, 0.8*n) # 80% of the data should be used for training

Credit_Score_Train <- Credit_Score_df[training.rows,]
Credit_Score_Test <- Credit_Score_df[-training.rows,]

write.csv(Credit_Score_Train, "Credit_Score_Train.csv")
write.csv(Credit_Score_Test, "Credit_Score_Test.csv")
