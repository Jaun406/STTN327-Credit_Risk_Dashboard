#-----------------------------------------#
# Split the data into test and train data #
#-----------------------------------------#

setwd("D:/Uni_work/STATS/STTN327/Project")
getwd()

datafile <- "cleaned_scorecard_dataset.csv"
split <- 0.8

df <- read.csv(datafile)
nrow <- nrow(df)

training.data <- sample(1:nrow, split[1]*nrow)

df_train <- df[training.data,]
df_test <- df[-training.data,]

write.csv(df_train, "train_scorecard_dataset.csv")
write.csv(df_test, "test_scorecard_dataset.csv")
