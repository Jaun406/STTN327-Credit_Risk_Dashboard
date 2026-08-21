# ==============
# ScoreCard Data
# ==============

# =================================================================================================================================
# What has been done
# ------------------
# ID1-ID9 data was row-bound by ID and merged with Biographic data
# ID1 data has a gap that had to be addressed to avoid generating 'NA' values unnecessarily before merging two data parts
# I check the data types of each column and cast each column to the proffered data type suitable for Linear or Logistic regression.
# Next Steps: Start cleaning process, either on each sheet individually or on the merged dataset directly
# =================================================================================================================================

rm(list=ls())

setwd("C:\\STTN327")
getwd()

install.packages("readxl")
install.packages("writexl")
library(readxl)
library(writexl)

Biographic_data <- read_excel("scorecard_dataset.xlsx", sheet ="Biographical")

ID1_data_part1 <- read_excel("scorecard_dataset.xlsx", sheet ="ID1", range = cell_rows(1:1092))
ID1_data_part2 <- read_excel("scorecard_dataset.xlsx", sheet ="ID1", range = cell_rows(8885:10001), col_names = FALSE)
names(ID1_data_part2) <- names(ID1_data_part1)
ID1_data <- rbind(ID1_data_part1, ID1_data_part2)

ID2_data <- read_excel("scorecard_dataset.xlsx", sheet ="ID2", n_max = 1123)
ID3_data <- read_excel("scorecard_dataset.xlsx", sheet ="ID3", n_max = 1047)
ID4_data <- read_excel("scorecard_dataset.xlsx", sheet ="ID4", n_max = 1146)
ID5_data <- read_excel("scorecard_dataset.xlsx", sheet ="ID5", n_max = 1093)
ID6_data <- read_excel("scorecard_dataset.xlsx", sheet ="ID6", n_max = 1091)
ID7_data <- read_excel("scorecard_dataset.xlsx", sheet ="ID7", n_max = 1173)
ID8_data <- read_excel("scorecard_dataset.xlsx", sheet ="ID8", n_max = 1146)
ID9_data <- read_excel("scorecard_dataset.xlsx", sheet ="ID9", n_max = 1118)

combinded_ID <- rbind(ID1_data, ID2_data,
                      ID3_data, ID4_data,
                      ID5_data, ID6_data,
                      ID7_data, ID8_data,
                      ID9_data)

merged_data <- merge(Biographic_data, combinded_ID, by = "ID")

head(merged_data)
str(merged_data)

# Converting to factors:
merged_data$Gender <- as.factor(merged_data$Gender)
merged_data$Education <- as.factor(merged_data$Education)
merged_data$EmpStatus <- as.factor(merged_data$EmpStatus)
merged_data$HomeOwn <- as.factor(merged_data$HomeOwn)
merged_data$Purpose <- as.factor(merged_data$Purpose)

# Convert loan amount to numeric type:
merged_data$LoanAmt <- as.numeric(merged_data$LoanAmt)
str(merged_data)

# Convert ID to type char:
merged_data$ID <- as.character(merged_data$ID)
str(merged_data)

# For Logistic regression we can leave default as $num, we might however need to change it to a factor
# at a later stage when looking at implementing machine learning models
# merged_data$default <- as.factor(merged_data$default)

# Merged data set as .csv:
write.csv(merged_data, "C:\\STTN327\\ScoreCrad.csv", row.names = FALSE)

# Merged data set as .xlsx:
write_xlsx(merged_data, path = "C:\\STTN327\\ScoreCrad.xlsx")


