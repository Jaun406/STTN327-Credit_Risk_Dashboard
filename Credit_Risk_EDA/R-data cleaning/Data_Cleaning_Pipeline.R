# ============================================================================
# CREDIT RISK SCORECARD DATA
# COMPLETE DATA PREPARATION, AUDIT, CLEANING AND VALIDATION SCRIPT
# ============================================================================
#
# PURPOSE
# -------
# This script:
#
# 1. Imports the original Excel workbook.
# 2. Reconstructs the split ID1 dataset.
# 3. Row-binds ID1-ID9.
# 4. Audits the source data and merge integrity.
# 5. Merges the biographical and ID data.
# 6. Audits the complete merged dataset.
# 7. Checks:
#       - Data types
#       - Missing values
#       - Duplicate rows
#       - Duplicate IDs
#       - Categorical values
#       - Impossible numerical values
#       - Statistical outliers using IQR
#       - Logical inconsistencies between variables
#       - Loan-to-income ratios
# 8. Cleans confirmed data-quality problems.
# 9. Resolves duplicate IDs using a documented rule.
# 10. Imputes remaining missing numeric values using the median.
# 11. Converts variables to appropriate modelling data types.
# 12. Performs a final validation.
# 13. Exports:
#       - Clean CSV
#       - Clean Excel
#       - Duplicate-ID review
#       - Outlier analysis
#       - Cleaning log
#       - Final validation report
#
# IMPORTANT
# ---------
# This script performs DATA QUALITY CLEANING.
#
# It does NOT yet perform:
#       - WoE
#       - Information Value (IV)
#       - Scorecard binning
#       - Variable selection
#       - Train/test splitting
#       - Model fitting
#       - Model validation
#
# Those belong to the modelling stage after this dataset has been quality
# controlled.
# ============================================================================


# ============================================================================
# 0. RESET R ENVIRONMENT
# ============================================================================

rm(list = ls())

# Working directory
setwd("/Users/zanewaylon/Desktop/CreditRisk")

getwd()


# ============================================================================
# 1. PACKAGES
# ============================================================================

install.packages("readxl")
install.packages("writexl")

library(readxl)
library(writexl)

# ============================================================================
# 2. OUTPUT FILE LOCATIONS
# ============================================================================

output_dir <- "/Users/zanewaylon/Desktop/CreditRisk"

clean_csv_path <- file.path(
  output_dir,
  "cleaned_scorecard_dataset.csv"
)

clean_xlsx_path <- file.path(
  output_dir,
  "cleaned_scorecard_dataset.xlsx"
)

duplicate_review_path <- file.path(
  output_dir,
  "duplicate_ID_review.csv"
)

duplicate_conflict_path <- file.path(
  output_dir,
  "duplicate_ID_conflicts.csv"
)

outlier_path <- file.path(
  output_dir,
  "outlier_analysis_before_cleaning.csv"
)

validation_path <- file.path(
  output_dir,
  "final_validation_report.csv"
)

cleaning_log_path <- file.path(
  output_dir,
  "cleaning_log.csv"
)


# ============================================================================
# 3. IMPORT BIOGRAPHICAL DATA
# ============================================================================

Biographic_data <- read_excel(
  "scorecard_dataset.xlsx",
  sheet = "Biographical"
)


# ============================================================================
# 4. IMPORT ID1
# ============================================================================
#
# ID1 contains a gap in the worksheet. The populated data occurs in:
#
#       Rows 1:1092
#       Rows 8885:10001
#
# The second range is imported without column names and then given the same
# names as the first section.
# ============================================================================


ID1_data_part1 <- read_excel(
  "scorecard_dataset.xlsx",
  sheet = "ID1",
  range = cell_rows(1:1092)
)

ID1_data_part2 <- read_excel(
  "scorecard_dataset.xlsx",
  sheet = "ID1",
  range = cell_rows(8885:10001),
  col_names = FALSE
)

# Assign the correct column names
names(ID1_data_part2) <- names(ID1_data_part1)

# Combine both ID1 sections
ID1_data <- rbind(
  ID1_data_part1,
  ID1_data_part2
)


# ============================================================================
# 5. IMPORT ID2-ID9
# ============================================================================

ID2_data <- read_excel(
  "scorecard_dataset.xlsx",
  sheet = "ID2",
  n_max = 1123
)

ID3_data <- read_excel(
  "scorecard_dataset.xlsx",
  sheet = "ID3",
  n_max = 1047
)

ID4_data <- read_excel(
  "scorecard_dataset.xlsx",
  sheet = "ID4",
  n_max = 1146
)

ID5_data <- read_excel(
  "scorecard_dataset.xlsx",
  sheet = "ID5",
  n_max = 1093
)

ID6_data <- read_excel(
  "scorecard_dataset.xlsx",
  sheet = "ID6",
  n_max = 1091
)

ID7_data <- read_excel(
  "scorecard_dataset.xlsx",
  sheet = "ID7",
  n_max = 1173
)

ID8_data <- read_excel(
  "scorecard_dataset.xlsx",
  sheet = "ID8",
  n_max = 1146
)

ID9_data <- read_excel(
  "scorecard_dataset.xlsx",
  sheet = "ID9",
  n_max = 1118
)


# ============================================================================
# 6. COMBINE ID1-ID9
# ============================================================================

combined_ID <- rbind(
  ID1_data,
  ID2_data,
  ID3_data,
  ID4_data,
  ID5_data,
  ID6_data,
  ID7_data,
  ID8_data,
  ID9_data
)


# ============================================================================
# 7. SOURCE DATA AUDIT BEFORE MERGING
# ============================================================================

cat("\n")
cat("============================================================\n")
cat("SOURCE DATA AUDIT\n")
cat("============================================================\n")


# Dimensions

cat("\nBiographical data dimensions:\n")
print(dim(Biographic_data))

cat("\nCombined ID data dimensions:\n")
print(dim(combined_ID))


# Column names

cat("\nBiographical columns:\n")
print(names(Biographic_data))

cat("\nCombined ID columns:\n")
print(names(combined_ID))


# Data types

cat("\nBiographical data structure:\n")
str(Biographic_data)

cat("\nCombined ID data structure:\n")
str(combined_ID)


# ============================================================================
# 8. CHECK SOURCE IDs
# ============================================================================

Biographic_data$ID <- as.character(
  Biographic_data$ID
)

combined_ID$ID <- as.character(
  combined_ID$ID
)


cat("\nUnique IDs in Biographical data:\n")
print(length(unique(Biographic_data$ID)))

cat("\nUnique IDs in combined ID data:\n")
print(length(unique(combined_ID$ID)))


# Duplicate IDs within the two source datasets

cat("\nDuplicate IDs in Biographical data:\n")
print(sum(duplicated(Biographic_data$ID)))

cat("\nDuplicate IDs in combined ID data:\n")
print(sum(duplicated(combined_ID$ID)))


# IDs appearing in only one dataset

bio_only_IDs <- setdiff(
  Biographic_data$ID,
  combined_ID$ID
)

id_only_IDs <- setdiff(
  combined_ID$ID,
  Biographic_data$ID
)

cat("\nIDs present in Biographical data but not ID data:\n")
print(length(bio_only_IDs))

cat("\nIDs present in ID data but not Biographical data:\n")
print(length(id_only_IDs))


# ============================================================================
# 9. MERGE DATASETS
# ============================================================================

merged_data <- merge(
  Biographic_data,
  combined_ID,
  by = "ID"
)


# Preserve untouched merged data

raw_merged_data <- merged_data


# ============================================================================
# 10. INITIAL MERGED DATASET AUDIT
# ============================================================================

cat("\n")
cat("============================================================\n")
cat("INITIAL MERGED DATASET\n")
cat("============================================================\n")


# First six observations

cat("\nFirst six observations:\n")
print(head(merged_data))


# Dimensions

cat("\nNumber of rows:\n")
print(nrow(merged_data))

cat("\nNumber of columns:\n")
print(ncol(merged_data))


# Structure

cat("\nDataset structure:\n")
str(merged_data)


# ============================================================================
# 11. STANDARDISE BASIC DATA TYPES
# ============================================================================

# ID should be treated as an identifier, not as a continuous variable

merged_data$ID <- as.character(
  merged_data$ID
)


# Character variables

character_columns <- c(
  "Gender",
  "Education",
  "EmpStatus",
  "HomeOwn",
  "Purpose"
)

merged_data[character_columns] <- lapply(
  merged_data[character_columns],
  function(x) {
    
    x <- trimws(
      as.character(x)
    )
    
    # Convert empty strings to NA
    x[x == ""] <- NA
    
    return(x)
  }
)


# ============================================================================
# 12. LOAN AMOUNT CONVERSION
# ============================================================================
#
# LoanAmt originally entered R as character data.
# Convert it to numeric.
#
# Commas are removed first in case values are formatted as:
#
#       1,500,000
#
# ============================================================================

merged_data$LoanAmt_raw <- as.character(
  merged_data$LoanAmt
)

loanamt_clean <- gsub(
  ",",
  "",
  trimws(merged_data$LoanAmt_raw)
)

merged_data$LoanAmt <- suppressWarnings(
  as.numeric(loanamt_clean)
)


# Capture any text values that failed conversion

invalid_loan_text <- unique(
  merged_data$LoanAmt_raw[
    is.na(merged_data$LoanAmt) &
      !is.na(merged_data$LoanAmt_raw) &
      trimws(merged_data$LoanAmt_raw) != ""
  ]
)

cat("\nNon-numeric LoanAmt values found:\n")
print(invalid_loan_text)


# ============================================================================
# 13. MISSING VALUE AUDIT
# ============================================================================

missing_count_before <- colSums(
  is.na(merged_data)
)

missing_percentage_before <- round(
  colMeans(is.na(merged_data)) * 100,
  2
)

missing_audit <- data.frame(
  Variable = names(missing_count_before),
  Missing_Count = as.numeric(missing_count_before),
  Missing_Percentage = as.numeric(missing_percentage_before)
)

cat("\n")
cat("Missing values by variable:\n")
print(missing_audit)


cat("\nTotal missing values:\n")
print(sum(is.na(merged_data)))


# ============================================================================
# 14. DUPLICATE ROW AUDIT
# ============================================================================

duplicate_complete_rows <- sum(
  duplicated(merged_data)
)

cat("\nCompletely duplicated rows:\n")
print(duplicate_complete_rows)


# Save exact duplicate rows for audit

exact_duplicate_review <- merged_data[
  duplicated(merged_data) |
    duplicated(merged_data, fromLast = TRUE),
]

if (nrow(exact_duplicate_review) > 0) {
  
  write.csv(
    exact_duplicate_review,
    file.path(
      output_dir,
      "exact_duplicate_rows.csv"
    ),
    row.names = FALSE
  )
  
}


# ============================================================================
# 15. DUPLICATE ID AUDIT
# ============================================================================

duplicate_ID_count <- sum(
  duplicated(merged_data$ID)
)

cat("\nDuplicate ID observations:\n")
print(duplicate_ID_count)

cat("\nUnique IDs:\n")
print(length(unique(merged_data$ID)))


duplicate_IDs <- unique(
  merged_data$ID[
    duplicated(merged_data$ID)
  ]
)


duplicate_ID_review <- merged_data[
  merged_data$ID %in% duplicate_IDs,
]

# Save for audit

write.csv(
  duplicate_ID_review,
  duplicate_review_path,
  row.names = FALSE
)


# ============================================================================
# 16. IDENTIFY DUPLICATE IDS WITH CONFLICTING DATA
# ============================================================================
#
# Some duplicate IDs may be exact copies.
# Others may contain different information under the same ID.
#
# We therefore identify IDs where more than one unique record exists.
# ============================================================================

duplicate_ID_conflicts <- merged_data[
  merged_data$ID %in% duplicate_IDs,
]

# Columns used to determine whether observations differ

comparison_columns <- setdiff(
  names(merged_data),
  c(
    "ID",
    "LoanAmt_raw"
  )
)


# Count unique complete records per ID

unique_records_per_ID <- aggregate(
  as.formula(
    paste(
      "rep(1, nrow(merged_data)) ~ ID"
    )
  ),
  data = merged_data,
  FUN = length
)

names(unique_records_per_ID)[2] <- "Rows"


# Determine conflicting duplicate IDs

conflicting_ID_list <- c()

for (current_ID in duplicate_IDs) {
  
  temp <- merged_data[
    merged_data$ID == current_ID,
    comparison_columns,
    drop = FALSE
  ]
  
  temp <- unique(temp)
  
  if (nrow(temp) > 1) {
    
    conflicting_ID_list <- c(
      conflicting_ID_list,
      current_ID
    )
    
  }
  
}


duplicate_conflicts <- merged_data[
  merged_data$ID %in% conflicting_ID_list,
]

cat("\nDuplicate IDs with conflicting records:\n")
print(length(conflicting_ID_list))

if (length(conflicting_ID_list) > 0) {
  
  write.csv(
    duplicate_conflicts,
    duplicate_conflict_path,
    row.names = FALSE
  )
  
}


# ============================================================================
# 17. CATEGORICAL VARIABLE AUDIT
# ============================================================================

cat("\n")
cat("============================================================\n")
cat("CATEGORICAL VARIABLE AUDIT\n")
cat("============================================================\n")


cat("\nGender:\n")
print(
  table(
    merged_data$Gender,
    useNA = "ifany"
  )
)

cat("\nEducation:\n")
print(
  table(
    merged_data$Education,
    useNA = "ifany"
  )
)

cat("\nEmployment status:\n")
print(
  table(
    merged_data$EmpStatus,
    useNA = "ifany"
  )
)

cat("\nHome ownership:\n")
print(
  table(
    merged_data$HomeOwn,
    useNA = "ifany"
  )
)

cat("\nPurpose:\n")
print(
  table(
    merged_data$Purpose,
    useNA = "ifany"
  )
)


# Unique values

cat("\nUnique Gender values:\n")
print(sort(unique(merged_data$Gender)))

cat("\nUnique Education values:\n")
print(sort(unique(merged_data$Education)))

cat("\nUnique Employment values:\n")
print(sort(unique(merged_data$EmpStatus)))

cat("\nUnique Home Ownership values:\n")
print(sort(unique(merged_data$HomeOwn)))

cat("\nUnique Purpose values:\n")
print(sort(unique(merged_data$Purpose)))


# ============================================================================
# 18. NUMERICAL VARIABLE AUDIT
# ============================================================================

cat("\n")
cat("============================================================\n")
cat("NUMERICAL VARIABLE AUDIT\n")
cat("============================================================\n")


numeric_columns_before <- c(
  "Offences",
  "IntRate",
  "Income",
  "DTI",
  "LoanAmt",
  "HistLen",
  "Utilisation",
  "Age",
  "default"
)

for (col in numeric_columns_before) {
  
  cat("\n--------------------------------------------\n")
  cat("Variable:", col, "\n")
  cat("--------------------------------------------\n")
  
  print(
    summary(
      merged_data[[col]]
    )
  )
  
  cat(
    "Missing:",
    sum(is.na(merged_data[[col]])),
    "\n"
  )
  
}


# ============================================================================
# 19. LOGICAL / DOMAIN CHECKS
# ============================================================================

cat("\n")
cat("============================================================\n")
cat("DOMAIN AND LOGICAL CHECKS\n")
cat("============================================================\n")


# --------------------------------------------------------------------------
# Offences
# --------------------------------------------------------------------------

negative_offences <- sum(
  merged_data$Offences < 0,
  na.rm = TRUE
)

non_integer_offences <- sum(
  merged_data$Offences %% 1 != 0,
  na.rm = TRUE
)

cat("\nNegative offences:", negative_offences, "\n")
cat("Non-integer offences:", non_integer_offences, "\n")

cat("\nUnique offence values:\n")
print(sort(unique(merged_data$Offences)))


# --------------------------------------------------------------------------
# Interest Rate
# --------------------------------------------------------------------------

invalid_interest_rate <- sum(
  merged_data$IntRate < 0 |
    merged_data$IntRate > 100,
  na.rm = TRUE
)

cat(
  "\nInterest rates outside 0-100:",
  invalid_interest_rate,
  "\n"
)


# --------------------------------------------------------------------------
# Income
# --------------------------------------------------------------------------

negative_income <- sum(
  merged_data$Income < 0,
  na.rm = TRUE
)

cat(
  "\nNegative income observations:",
  negative_income,
  "\n"
)


# --------------------------------------------------------------------------
# DTI
# --------------------------------------------------------------------------

negative_DTI <- sum(
  merged_data$DTI < 0,
  na.rm = TRUE
)

cat(
  "\nNegative DTI observations:",
  negative_DTI,
  "\n"
)


# --------------------------------------------------------------------------
# Loan amount
# --------------------------------------------------------------------------

invalid_loan_amount <- sum(
  merged_data$LoanAmt <= 0,
  na.rm = TRUE
)

cat(
  "\nLoanAmt <= 0 observations:",
  invalid_loan_amount,
  "\n"
)


# --------------------------------------------------------------------------
# Utilisation
# --------------------------------------------------------------------------

utilisation_above_100 <- sum(
  merged_data$Utilisation > 100,
  na.rm = TRUE
)

utilisation_below_0 <- sum(
  merged_data$Utilisation < 0,
  na.rm = TRUE
)

cat(
  "\nUtilisation > 100:",
  utilisation_above_100,
  "\n"
)

cat(
  "Utilisation < 0:",
  utilisation_below_0,
  "\n"
)


# --------------------------------------------------------------------------
# Age
# --------------------------------------------------------------------------

invalid_age <- sum(
  merged_data$Age < 18 |
    merged_data$Age > 100,
  na.rm = TRUE
)

cat(
  "\nAge outside 18-100:",
  invalid_age,
  "\n"
)


# --------------------------------------------------------------------------
# Default
# --------------------------------------------------------------------------

invalid_default <- sum(
  !merged_data$default %in% c(0, 1),
  na.rm = TRUE
)

cat(
  "\nInvalid default values:",
  invalid_default,
  "\n"
)


# ============================================================================
# 20. LOGICAL RELATIONSHIP: HISTORY LENGTH VS AGE
# ============================================================================

history_greater_than_age <- which(
  !is.na(merged_data$HistLen) &
    !is.na(merged_data$Age) &
    merged_data$HistLen > merged_data$Age
)

cat(
  "\nObservations where HistLen > Age:",
  length(history_greater_than_age),
  "\n"
)

if (length(history_greater_than_age) > 0) {
  
  print(
    merged_data[
      history_greater_than_age,
      c("ID", "Age", "HistLen")
    ]
  )
  
}


# ============================================================================
# 21. ZERO INCOME CHECK
# ============================================================================

zero_income <- which(
  !is.na(merged_data$Income) &
    merged_data$Income == 0
)

cat(
  "\nZero-income observations:",
  length(zero_income),
  "\n"
)

if (length(zero_income) > 0) {
  
  print(
    merged_data[
      zero_income,
      c(
        "ID",
        "Income",
        "LoanAmt",
        "DTI",
        "EmpStatus"
      )
    ]
  )
  
}


# ============================================================================
# 22. IQR OUTLIER ANALYSIS
# ============================================================================
#
# IMPORTANT:
#
# An IQR outlier is NOT automatically considered bad data.
#
# This section is diagnostic only.
# ============================================================================


outlier_results <- data.frame(
  Variable = character(),
  Q1 = numeric(),
  Q3 = numeric(),
  IQR = numeric(),
  Lower_Limit = numeric(),
  Upper_Limit = numeric(),
  Number_Outliers = integer(),
  stringsAsFactors = FALSE
)


numeric_columns_for_outliers <- c(
  "Offences",
  "IntRate",
  "Income",
  "DTI",
  "LoanAmt",
  "HistLen",
  "Utilisation",
  "Age"
)


for (col in numeric_columns_for_outliers) {
  
  x <- merged_data[[col]]
  
  Q1 <- quantile(
    x,
    0.25,
    na.rm = TRUE
  )
  
  Q3 <- quantile(
    x,
    0.75,
    na.rm = TRUE
  )
  
  IQR_value <- IQR(
    x,
    na.rm = TRUE
  )
  
  lower_limit <- Q1 - 1.5 * IQR_value
  
  upper_limit <- Q3 + 1.5 * IQR_value
  
  number_outliers <- sum(
    x < lower_limit |
      x > upper_limit,
    na.rm = TRUE
  )
  
  outlier_results <- rbind(
    outlier_results,
    data.frame(
      Variable = col,
      Q1 = Q1,
      Q3 = Q3,
      IQR = IQR_value,
      Lower_Limit = lower_limit,
      Upper_Limit = upper_limit,
      Number_Outliers = number_outliers
    )
  )
  
}


cat("\nIQR outlier analysis:\n")
print(outlier_results)


write.csv(
  outlier_results,
  outlier_path,
  row.names = FALSE
)


# ============================================================================
# 23. VISUAL EXPLORATION OF NUMERICAL VARIABLES
# ============================================================================
#
# This does not change the data.
#
# It provides visual confirmation of skewness, extreme values and
# distributions.
# ============================================================================


pdf(
  file.path(
    output_dir,
    "numeric_variable_diagnostics.pdf"
  ),
  width = 10,
  height = 7
)


for (col in numeric_columns_for_outliers) {
  
  par(mfrow = c(1, 2))
  
  hist(
    merged_data[[col]],
    main = paste(
      "Histogram:",
      col
    ),
    xlab = col,
    breaks = 30
  )
  
  boxplot(
    merged_data[[col]],
    main = paste(
      "Boxplot:",
      col
    ),
    ylab = col
  )
  
}


dev.off()


# ============================================================================
# 24. LOAN-TO-INCOME ANALYSIS
# ============================================================================
#
# This is used as an analytical diagnostic only.
#
# We do NOT automatically add this as a final modelling variable.
# ============================================================================


merged_data$Loan_to_Income <- with(
  merged_data,
  ifelse(
    is.na(Income) |
      Income == 0 |
      is.na(LoanAmt),
    NA,
    LoanAmt / Income
  )
)


cat("\nLoan-to-income ratio summary:\n")
print(
  summary(
    merged_data$Loan_to_Income
  )
)


# Largest Loan-to-Income observations

loan_to_income_order <- order(
  merged_data$Loan_to_Income,
  decreasing = TRUE,
  na.last = NA
)

cat("\nLargest Loan-to-Income observations:\n")

print(
  merged_data[
    loan_to_income_order[
      1:min(
        20,
        length(loan_to_income_order)
      )
    ],
    c(
      "ID",
      "Income",
      "LoanAmt",
      "Loan_to_Income"
    )
  ]
)


# ============================================================================
# 25. BEGIN CLEANING
# ============================================================================

cat("\n")
cat("============================================================\n")
cat("STARTING DATA CLEANING\n")
cat("============================================================\n")


# ============================================================================
# 26. CLEAN CATEGORICAL SPELLING ERRORS
# ============================================================================
#
# Observed HomeOwn errors:
#
#       Mortgag
#       Mortge
#       Mortgge
#
# These are treated as spelling errors for Mortgage.
# ============================================================================


homeown_typos <- merged_data$HomeOwn %in% c(
  "Mortgag",
  "Mortge",
  "Mortgge"
)

cat(
  "\nHome ownership spelling errors corrected:",
  sum(homeown_typos, na.rm = TRUE),
  "\n"
)

merged_data$HomeOwn[
  homeown_typos
] <- "Mortgage"


# ============================================================================
# 27. CLEAN INVALID INTEREST RATES
# ============================================================================
#
# Valid interest rate domain:
#
#       0 <= IntRate <= 100
#
# The invalid values are marked as NA.
# They are imputed later using the median of the cleaned dataset.
# ============================================================================


invalid_IntRate_rows <- which(
  merged_data$IntRate < 0 |
    merged_data$IntRate > 100
)

cat(
  "\nInvalid interest rates corrected:",
  length(invalid_IntRate_rows),
  "\n"
)

if (length(invalid_IntRate_rows) > 0) {
  
  merged_data$IntRate[
    invalid_IntRate_rows
  ] <- NA
  
}


# ============================================================================
# 28. CLEAN INVALID DTI
# ============================================================================
#
# DTI cannot be negative.
# ============================================================================


invalid_DTI_rows <- which(
  merged_data$DTI < 0
)

cat(
  "\nNegative DTI values corrected:",
  length(invalid_DTI_rows),
  "\n"
)

if (length(invalid_DTI_rows) > 0) {
  
  merged_data$DTI[
    invalid_DTI_rows
  ] <- NA
  
}


# ============================================================================
# 29. CLEAN INVALID AGE VALUES
# ============================================================================
#
# Adult credit-risk dataset:
#
#       Age < 18     => invalid
#       Age > 100    => invalid
#
# Values are set to NA rather than deleting the entire observation.
# ============================================================================


invalid_age_rows <- which(
  merged_data$Age < 18 |
    merged_data$Age > 100
)

cat(
  "\nInvalid age observations corrected:",
  length(invalid_age_rows),
  "\n"
)

if (length(invalid_age_rows) > 0) {
  
  merged_data$Age[
    invalid_age_rows
  ] <- NA
  
}


# ============================================================================
# 30. CLEAN LOAN AMOUNT
# ============================================================================
#
# LoanAmt <= 0 is invalid.
#
# A grossly corrupted LoanAmt can also be identified using a deliberately
# conservative threshold:
#
#       Q3 + 10 * IQR
#
# This is much more conservative than the normal 1.5*IQR rule and is intended
# to identify data corruption rather than ordinary large loans.
# ============================================================================


invalid_loan_rows <- which(
  merged_data$LoanAmt <= 0
)

cat(
  "\nNon-positive loan amounts:",
  length(invalid_loan_rows),
  "\n"
)

if (length(invalid_loan_rows) > 0) {
  
  merged_data$LoanAmt[
    invalid_loan_rows
  ] <- NA
  
}


# Conservative gross-error threshold

loan_q1_clean <- quantile(
  merged_data$LoanAmt,
  0.25,
  na.rm = TRUE
)

loan_q3_clean <- quantile(
  merged_data$LoanAmt,
  0.75,
  na.rm = TRUE
)

loan_iqr_clean <- IQR(
  merged_data$LoanAmt,
  na.rm = TRUE
)

loan_gross_upper_limit <- loan_q3_clean +
  (10 * loan_iqr_clean)


gross_loan_rows <- which(
  merged_data$LoanAmt >
    loan_gross_upper_limit
)

cat(
  "\nGrossly corrupted loan amounts:",
  length(gross_loan_rows),
  "\n"
)

cat(
  "Gross LoanAmt threshold:",
  loan_gross_upper_limit,
  "\n"
)

if (length(gross_loan_rows) > 0) {
  
  merged_data$LoanAmt[
    gross_loan_rows
  ] <- NA
  
}


# ============================================================================
# 31. CLEAN LOGICAL AGE/HISTORY INCONSISTENCY
# ============================================================================
#
# Credit history length greater than age is logically inconsistent.
#
# We do not delete the observation.
# We mark Age as missing so that the problematic field can be imputed.
# ============================================================================


invalid_history_age_rows <- which(
  !is.na(merged_data$HistLen) &
    !is.na(merged_data$Age) &
    merged_data$HistLen > merged_data$Age
)

cat(
  "\nHistLen > Age inconsistencies:",
  length(invalid_history_age_rows),
  "\n"
)

if (length(invalid_history_age_rows) > 0) {
  
  merged_data$Age[
    invalid_history_age_rows
  ] <- NA
  
}


# ============================================================================
# 32. PREPARE FOR DUPLICATE RESOLUTION
# ============================================================================

# Variables used to assess completeness

completeness_columns <- c(
  "Gender",
  "Education",
  "Offences",
  "IntRate",
  "Income",
  "DTI",
  "LoanAmt",
  "HistLen",
  "Utilisation",
  "Age",
  "EmpStatus",
  "HomeOwn",
  "Purpose",
  "default"
)


# Number of missing fields in each observation

merged_data$row_missing_count <- rowSums(
  is.na(
    merged_data[
      completeness_columns
    ]
  )
)


# Preserve current row order

merged_data$row_original_order <- seq_len(
  nrow(merged_data)
)


# ============================================================================
# 33. RESOLVE DUPLICATE IDs
# ============================================================================
#
# Rule:
#
# 1. For each ID, retain the observation with the fewest missing fields.
# 2. If tied, retain the first occurrence.
#
# This gives a deterministic reproducible rule.
#
# All duplicate observations were saved earlier for audit/review.
# ============================================================================


merged_data <- merged_data[
  order(
    merged_data$ID,
    merged_data$row_missing_count,
    merged_data$row_original_order
  ),
]


merged_data <- merged_data[
  !duplicated(
    merged_data$ID
  ),
]


# Restore original-style ordering by ID

merged_data <- merged_data[
  order(
    merged_data$ID
  ),
]


cat(
  "\nRows after duplicate-ID resolution:",
  nrow(merged_data),
  "\n"
)

cat(
  "Unique IDs after duplicate-ID resolution:",
  length(unique(merged_data$ID)),
  "\n"
)


# Remove temporary duplicate-analysis variables

merged_data$row_missing_count <- NULL
merged_data$row_original_order <- NULL


# ============================================================================
# 34. MEDIAN IMPUTATION
# ============================================================================
#
# Remaining missing numeric fields are imputed using the median.
#
# Median is preferred here because variables such as Income and LoanAmt are
# strongly right-skewed and contain large legitimate values.
#
# IMPORTANT:
# For final predictive modelling, the imputation statistics should ideally
# be calculated from the TRAINING DATA ONLY and then applied to validation/
# test data. This avoids data leakage.
# ============================================================================


median_impute <- function(x) {
  
  median_value <- median(
    x,
    na.rm = TRUE
  )
  
  x[is.na(x)] <- median_value
  
  return(x)
  
}


# Variables with missing values requiring imputation

imputation_columns <- c(
  "Income",
  "IntRate",
  "DTI",
  "LoanAmt",
  "Age"
)


# Record medians used

imputation_values <- data.frame(
  Variable = character(),
  Median_Used = numeric(),
  stringsAsFactors = FALSE
)


for (col in imputation_columns) {
  
  median_value <- median(
    merged_data[[col]],
    na.rm = TRUE
  )
  
  imputation_values <- rbind(
    imputation_values,
    data.frame(
      Variable = col,
      Median_Used = median_value
    )
  )
  
  merged_data[[col]] <- median_impute(
    merged_data[[col]]
  )
  
}


# Save imputation information

write.csv(
  imputation_values,
  file.path(
    output_dir,
    "imputation_values.csv"
  ),
  row.names = FALSE
)


# ============================================================================
# 35. CONVERT CATEGORICAL VARIABLES TO FACTORS
# ============================================================================


merged_data$Gender <- factor(
  merged_data$Gender,
  levels = c(
    "Female",
    "Male"
  )
)


merged_data$Education <- factor(
  merged_data$Education,
  levels = c(
    "Degree",
    "Diploma",
    "Grade 12",
    "No records",
    "Postgrad"
  )
)


merged_data$EmpStatus <- factor(
  merged_data$EmpStatus,
  levels = c(
    "Contract",
    "Salaried",
    "Self-employed",
    "Unemployed"
  )
)


merged_data$HomeOwn <- factor(
  merged_data$HomeOwn,
  levels = c(
    "Mortgage",
    "Own",
    "Rent"
  )
)


merged_data$Purpose <- factor(
  merged_data$Purpose,
  levels = c(
    "Debt_consolidation",
    "Home_improvement",
    "Other",
    "Vehicle"
  )
)


# ============================================================================
# 36. DEFAULT AS NUMERIC BINARY TARGET
# ============================================================================


merged_data$default <- as.numeric(
  merged_data$default
)


# ============================================================================
# 37. REMOVE ANALYTICAL / TEMPORARY VARIABLES
# ============================================================================
#
# Loan_to_Income was created as a diagnostic variable.
# It is NOT automatically included in the final cleaned scorecard dataset.
#
# LoanAmt_raw was only retained for cleaning diagnostics.
# ============================================================================


merged_data$Loan_to_Income <- NULL
merged_data$LoanAmt_raw <- NULL


# ============================================================================
# 38. FINAL DATA TYPE CHECK
# ============================================================================

cat("\n")
cat("============================================================\n")
cat("FINAL DATA TYPES\n")
cat("============================================================\n")

print(
  sapply(
    merged_data,
    class
  )
)


# ============================================================================
# 39. FINAL MISSING VALUE CHECK
# ============================================================================

final_missing_counts <- colSums(
  is.na(merged_data)
)

final_missing_percentages <- round(
  colMeans(is.na(merged_data)) * 100,
  4
)

cat("\nFinal missing values:\n")
print(final_missing_counts)

cat("\nFinal missing percentages:\n")
print(final_missing_percentages)


# ============================================================================
# 40. FINAL DUPLICATE CHECK
# ============================================================================

final_duplicate_rows <- sum(
  duplicated(merged_data)
)

final_duplicate_IDs <- sum(
  duplicated(merged_data$ID)
)


cat(
  "\nFinal duplicate complete rows:",
  final_duplicate_rows,
  "\n"
)

cat(
  "Final duplicate IDs:",
  final_duplicate_IDs,
  "\n"
)


# ============================================================================
# 41. FINAL DOMAIN VALIDATION
# ============================================================================


final_invalid_Offences <- sum(
  merged_data$Offences < 0 |
    merged_data$Offences %% 1 != 0,
  na.rm = TRUE
)


final_invalid_IntRate <- sum(
  merged_data$IntRate < 0 |
    merged_data$IntRate > 100,
  na.rm = TRUE
)


final_invalid_Income <- sum(
  merged_data$Income < 0,
  na.rm = TRUE
)


final_invalid_DTI <- sum(
  merged_data$DTI < 0,
  na.rm = TRUE
)


final_invalid_LoanAmt <- sum(
  merged_data$LoanAmt <= 0,
  na.rm = TRUE
)


final_invalid_Utilisation <- sum(
  merged_data$Utilisation < 0,
  na.rm = TRUE
)


final_invalid_Age <- sum(
  merged_data$Age < 18 |
    merged_data$Age > 100,
  na.rm = TRUE
)


final_invalid_default <- sum(
  !merged_data$default %in% c(0, 1),
  na.rm = TRUE
)


final_history_age_errors <- sum(
  merged_data$HistLen > merged_data$Age,
  na.rm = TRUE
)


# ============================================================================
# 42. FINAL CATEGORICAL VALIDATION
# ============================================================================


valid_gender <- c(
  "Female",
  "Male"
)

valid_education <- c(
  "Degree",
  "Diploma",
  "Grade 12",
  "No records",
  "Postgrad"
)

valid_employment <- c(
  "Contract",
  "Salaried",
  "Self-employed",
  "Unemployed"
)

valid_homeown <- c(
  "Mortgage",
  "Own",
  "Rent"
)

valid_purpose <- c(
  "Debt_consolidation",
  "Home_improvement",
  "Other",
  "Vehicle"
)


invalid_gender <- sum(
  !as.character(merged_data$Gender) %in%
    valid_gender,
  na.rm = TRUE
)


invalid_education <- sum(
  !as.character(merged_data$Education) %in%
    valid_education,
  na.rm = TRUE
)


invalid_employment <- sum(
  !as.character(merged_data$EmpStatus) %in%
    valid_employment,
  na.rm = TRUE
)


invalid_homeown <- sum(
  !as.character(merged_data$HomeOwn) %in%
    valid_homeown,
  na.rm = TRUE
)


invalid_purpose <- sum(
  !as.character(merged_data$Purpose) %in%
    valid_purpose,
  na.rm = TRUE
)


# ============================================================================
# 43. FINAL DEFAULT DISTRIBUTION
# ============================================================================

default_counts <- table(
  merged_data$default,
  useNA = "ifany"
)

default_proportions <- prop.table(
  default_counts
)


cat("\n")
cat("============================================================\n")
cat("FINAL DEFAULT DISTRIBUTION\n")
cat("============================================================\n")

print(default_counts)

print(default_proportions)


# ============================================================================
# 44. FINAL CATEGORICAL DISTRIBUTIONS
# ============================================================================

cat("\n")
cat("============================================================\n")
cat("FINAL CATEGORICAL DISTRIBUTIONS\n")
cat("============================================================\n")


cat("\nGender:\n")
print(
  table(
    merged_data$Gender,
    useNA = "ifany"
  )
)


cat("\nEducation:\n")
print(
  table(
    merged_data$Education,
    useNA = "ifany"
  )
)


cat("\nEmployment Status:\n")
print(
  table(
    merged_data$EmpStatus,
    useNA = "ifany"
  )
)


cat("\nHome Ownership:\n")
print(
  table(
    merged_data$HomeOwn,
    useNA = "ifany"
  )
)


cat("\nPurpose:\n")
print(
  table(
    merged_data$Purpose,
    useNA = "ifany"
  )
)


# ============================================================================
# 45. FINAL NUMERICAL SUMMARIES
# ============================================================================

cat("\n")
cat("============================================================\n")
cat("FINAL NUMERICAL SUMMARIES\n")
cat("============================================================\n")


final_numeric_columns <- c(
  "Offences",
  "IntRate",
  "Income",
  "DTI",
  "LoanAmt",
  "HistLen",
  "Utilisation",
  "Age"
)


for (col in final_numeric_columns) {
  
  cat("\n--------------------------------------------\n")
  cat(col, "\n")
  cat("--------------------------------------------\n")
  
  print(
    summary(
      merged_data[[col]]
    )
  )
  
}


# ============================================================================
# 46. FINAL IQR OUTLIER ANALYSIS
# ============================================================================
#
# Again, this is DIAGNOSTIC.
# Legitimate extreme borrowers are retained.
# ============================================================================


final_outlier_results <- data.frame(
  Variable = character(),
  Q1 = numeric(),
  Q3 = numeric(),
  IQR = numeric(),
  Lower_Limit = numeric(),
  Upper_Limit = numeric(),
  Number_Outliers = integer(),
  stringsAsFactors = FALSE
)


for (col in final_numeric_columns) {
  
  x <- merged_data[[col]]
  
  Q1 <- quantile(
    x,
    0.25,
    na.rm = TRUE
  )
  
  Q3 <- quantile(
    x,
    0.75,
    na.rm = TRUE
  )
  
  IQR_value <- IQR(
    x,
    na.rm = TRUE
  )
  
  lower_limit <- Q1 -
    1.5 * IQR_value
  
  upper_limit <- Q3 +
    1.5 * IQR_value
  
  number_outliers <- sum(
    x < lower_limit |
      x > upper_limit,
    na.rm = TRUE
  )
  
  final_outlier_results <- rbind(
    final_outlier_results,
    data.frame(
      Variable = col,
      Q1 = Q1,
      Q3 = Q3,
      IQR = IQR_value,
      Lower_Limit = lower_limit,
      Upper_Limit = upper_limit,
      Number_Outliers = number_outliers
    )
  )
  
}


cat("\nFinal IQR outlier results:\n")
print(final_outlier_results)


write.csv(
  final_outlier_results,
  file.path(
    output_dir,
    "outlier_analysis_after_cleaning.csv"
  ),
  row.names = FALSE
)


# ============================================================================
# 47. CLEANING LOG
# ============================================================================


cleaning_log <- data.frame(
  Step = c(
    "Original merged rows",
    "Original unique IDs",
    "Missing Income values",
    "Missing LoanAmt values",
    "Complete duplicate rows",
    "Duplicate ID observations",
    "Invalid Interest Rates",
    "Negative DTI values",
    "Non-positive LoanAmt",
    "Gross LoanAmt errors",
    "Invalid Ages",
    "HistLen > Age inconsistencies",
    "HomeOwn spelling errors corrected",
    "Final rows",
    "Final unique IDs",
    "Final missing values",
    "Final duplicate IDs"
  ),
  
  Before = c(
    nrow(raw_merged_data),
    length(unique(raw_merged_data$ID)),
    sum(is.na(raw_merged_data$Income)),
    sum(is.na(raw_merged_data$LoanAmt)),
    duplicate_complete_rows,
    duplicate_ID_count,
    invalid_interest_rate,
    negative_DTI,
    invalid_loan_amount,
    length(gross_loan_rows),
    length(invalid_age_rows),
    length(history_greater_than_age),
    sum(homeown_typos, na.rm = TRUE),
    NA,
    NA,
    NA,
    NA
  ),
  
  After = c(
    nrow(merged_data),
    length(unique(merged_data$ID)),
    sum(is.na(merged_data$Income)),
    sum(is.na(merged_data$LoanAmt)),
    sum(duplicated(merged_data)),
    sum(duplicated(merged_data$ID)),
    final_invalid_IntRate,
    final_invalid_DTI,
    final_invalid_LoanAmt,
    NA,
    final_invalid_Age,
    final_history_age_errors,
    0,
    nrow(merged_data),
    length(unique(merged_data$ID)),
    sum(is.na(merged_data)),
    sum(duplicated(merged_data$ID))
  )
)


write.csv(
  cleaning_log,
  cleaning_log_path,
  row.names = FALSE
)


# ============================================================================
# 48. FINAL VALIDATION REPORT
# ============================================================================


validation_report <- data.frame(
  
  Check = c(
    "Rows",
    "Columns",
    "Unique IDs",
    "Duplicate complete rows",
    "Duplicate IDs",
    "Total missing values",
    "Invalid Offences",
    "Invalid Interest Rates",
    "Negative Income",
    "Negative DTI",
    "Invalid Loan Amount",
    "Invalid Utilisation below 0",
    "Invalid Age",
    "HistLen > Age",
    "Invalid Default",
    "Invalid Gender",
    "Invalid Education",
    "Invalid Employment Status",
    "Invalid Home Ownership",
    "Invalid Purpose"
  ),
  
  Result = c(
    nrow(merged_data),
    ncol(merged_data),
    length(unique(merged_data$ID)),
    final_duplicate_rows,
    final_duplicate_IDs,
    sum(is.na(merged_data)),
    final_invalid_Offences,
    final_invalid_IntRate,
    final_invalid_Income,
    final_invalid_DTI,
    final_invalid_LoanAmt,
    final_invalid_Utilisation,
    final_invalid_Age,
    final_history_age_errors,
    final_invalid_default,
    invalid_gender,
    invalid_education,
    invalid_employment,
    invalid_homeown,
    invalid_purpose
  ),
  
  Status = c(
    "CHECK",
    "CHECK",
    ifelse(
      length(unique(merged_data$ID)) == nrow(merged_data),
      "PASS",
      "FAIL"
    ),
    
    ifelse(
      final_duplicate_rows == 0,
      "PASS",
      "FAIL"
    ),
    
    ifelse(
      final_duplicate_IDs == 0,
      "PASS",
      "FAIL"
    ),
    
    ifelse(
      sum(is.na(merged_data)) == 0,
      "PASS",
      "FAIL"
    ),
    
    ifelse(
      final_invalid_Offences == 0,
      "PASS",
      "FAIL"
    ),
    
    ifelse(
      final_invalid_IntRate == 0,
      "PASS",
      "FAIL"
    ),
    
    ifelse(
      final_invalid_Income == 0,
      "PASS",
      "FAIL"
    ),
    
    ifelse(
      final_invalid_DTI == 0,
      "PASS",
      "FAIL"
    ),
    
    ifelse(
      final_invalid_LoanAmt == 0,
      "PASS",
      "FAIL"
    ),
    
    ifelse(
      final_invalid_Utilisation == 0,
      "PASS",
      "REVIEW / ALLOWED >100"
    ),
    
    ifelse(
      final_invalid_Age == 0,
      "PASS",
      "FAIL"
    ),
    
    ifelse(
      final_history_age_errors == 0,
      "PASS",
      "FAIL"
    ),
    
    ifelse(
      final_invalid_default == 0,
      "PASS",
      "FAIL"
    ),
    
    ifelse(
      invalid_gender == 0,
      "PASS",
      "FAIL"
    ),
    
    ifelse(
      invalid_education == 0,
      "PASS",
      "FAIL"
    ),
    
    ifelse(
      invalid_employment == 0,
      "PASS",
      "FAIL"
    ),
    
    ifelse(
      invalid_homeown == 0,
      "PASS",
      "FAIL"
    ),
    
    ifelse(
      invalid_purpose == 0,
      "PASS",
      "FAIL"
    )
  ),
  
  stringsAsFactors = FALSE
)


write.csv(
  validation_report,
  validation_path,
  row.names = FALSE
)


# ============================================================================
# 49. FINAL STRUCTURE
# ============================================================================

cat("\n")
cat("============================================================\n")
cat("FINAL DATASET STRUCTURE\n")
cat("============================================================\n")

str(merged_data)


# ============================================================================
# 50. FINAL HEAD
# ============================================================================

cat("\n")
cat("============================================================\n")
cat("FIRST SIX CLEAN OBSERVATIONS\n")
cat("============================================================\n")

print(
  head(merged_data)
)


# ============================================================================
# 51. EXPORT CLEAN DATASET
# ============================================================================

write.csv(
  merged_data,
  clean_csv_path,
  row.names = FALSE
)


write_xlsx(
  merged_data,
  path = clean_xlsx_path
)


# ============================================================================
# 52. FINAL SUMMARY
# ============================================================================

cat("\n")
cat("============================================================\n")
cat("CREDIT RISK DATA CLEANING COMPLETE\n")
cat("============================================================\n")


cat(
  "\nOriginal merged rows:",
  nrow(raw_merged_data),
  "\n"
)


cat(
  "Original unique IDs:",
  length(unique(raw_merged_data$ID)),
  "\n"
)


cat(
  "Final rows:",
  nrow(merged_data),
  "\n"
)


cat(
  "Final unique IDs:",
  length(unique(merged_data$ID)),
  "\n"
)


cat(
  "Final columns:",
  ncol(merged_data),
  "\n"
)


cat(
  "Final missing values:",
  sum(is.na(merged_data)),
  "\n"
)


cat(
  "Final duplicate IDs:",
  sum(duplicated(merged_data$ID)),
  "\n"
)


cat(
  "Final invalid interest rates:",
  final_invalid_IntRate,
  "\n"
)


cat(
  "Final negative DTI:",
  final_invalid_DTI,
  "\n"
)


cat(
  "Final invalid LoanAmt:",
  final_invalid_LoanAmt,
  "\n"
)


cat(
  "Final invalid Age:",
  final_invalid_Age,
  "\n"
)


cat(
  "Final HistLen > Age:",
  final_history_age_errors,
  "\n"
)


cat(
  "Final invalid default values:",
  final_invalid_default,
  "\n"
)


cat("\nFiles created:\n")

cat(
  "\nClean CSV:\n",
  clean_csv_path,
  "\n"
)

cat(
  "\nClean Excel:\n",
  clean_xlsx_path,
  "\n"
)

cat(
  "\nDuplicate review:\n",
  duplicate_review_path,
  "\n"
)

cat(
  "\nDuplicate conflict review:\n",
  duplicate_conflict_path,
  "\n"
)

cat(
  "\nBefore-cleaning outlier analysis:\n",
  outlier_path,
  "\n"
)

cat(
  "\nCleaning log:\n",
  cleaning_log_path,
  "\n"
)

cat(
  "\nValidation report:\n",
  validation_path,
  "\n"
)