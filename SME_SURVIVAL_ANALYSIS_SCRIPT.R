install.packages("survival")
install.packages("survminer")
install.packages("tidyverse")
install.packages("lubridate")

library(survival)
library(survminer)
library(tidyverse)
library(lubridate)
library(broom)

install.packages("readxl")
library(readxl)

df_raw      # original dataset (never touch this)
df_clean    # cleaned dataset
df_model    # dataset used for modeling

df_raw <- read_excel("~/misheck/misheck dissertation/Repository-CSI_survival analysis.xlsx")

df <- df_raw

#Data Cleaning

head(df)
str(df)
summary(df)


names(df)

summary(df$Death)

str(df$Death)

names(df)

summary(df$Birth)
summary(df$Death)


str(df$Birth)
str(df$Death)

df$birth <- as.numeric(df$Birth)
df$death <- as.numeric(df$Death)

unique(df$Birth)

df$Birth <- suppressWarnings(as.numeric(df$Birth))

sum(is.na(df$Birth))

df <- df %>% filter(!is.na(Birth))

df$Birth <- suppressWarnings(as.numeric(df$Birth))

df$Death <- suppressWarnings(as.numeric(df$Death))

sum(is.na(df$Birth))
sum(is.na(df$Death))

(study_end_year <- max(df$death, na.rm = TRUE))

df$survival_time <- ifelse(
  is.na(df$Death),
  study_end_year - df$Birth,
  df$Death - df$Birth
)

df$event <- ifelse(is.na(df$death), 0, 1)

df <- df %>% filter(survival_time >= 0)

nrow(df)

summary(df$survival_time)
table(df$event)

surv_object <- Surv(time = df$survival_time, event = df$event)

#Kaplan Mier Estimator

km_fit <- survfit(surv_object ~ 1, data = df)

# Export survival curve for Power BI
km_export <- data.frame(
  time = km_fit$time,
  survival = km_fit$surv,
  lower = km_fit$lower,
  upper = km_fit$upper
)
write.csv(km_export, "km_survival_curve.csv", row.names = FALSE)

summary(km_fit)

ggsurvplot(km_fit,
           data = df,
           xlab = "Time (Years)",
           ylab = "Survival Probability",
           title = "Kaplan-Meier Survival Curve for Firms")

table(df$event)
prop.table(table(df$event))


#Descriptive Statistics

summary(df$survival_time)
table(df$event)

df$Tot_Assets <- as.numeric(df$Tot_Assets)
df$ROA <- as.numeric(df$ROA)

df$Tot_Assets[!grepl("^-?[0-9.]+$", df$Tot_Assets)]

df$Tot_Assets <- gsub("[^0-9.-]", "", df$Tot_Assets)
df$Tot_Assets <- as.numeric(df$Tot_Assets)

sum(is.na(df$Tot_Assets))

df <- df %>% select(-Tot_Assets)
# Tot assets was excluded due to a magnitude of missing data 

coxph(Surv(survival_time, event) ~ ROA, data = df)

df$NACE <- as.factor(df$NACE)


#remember to group nance 

coxph(Surv(survival_time, event) ~ ROA + NACE, data = df)


df$NACE_factor <- as.factor(df$NACE)

# Export firm-level data for Power BI (after NACE_factor exists)
firm_export <- df[, c("survival_time", "event", "ROA", "NACE_factor")]
write.csv(firm_export, "firm_level_data.csv", row.names = FALSE)

barplot(table(df$NACE_factor),
        main = "Distribution of Firms by NACE Category",
        xlab = "NACE Category",
        ylab = "Number of Firms",
        col = "lightgreen")

table(df$NACE_factor)

cox_model_full <- coxph(Surv(survival_time, event) ~ ROA + NACE_factor, data = df)

# Export Cox model results for Power BI
cox_summary <- data.frame(
  variable = names(coef(cox_model_full)),
  coef = coef(cox_model_full),
  hr = exp(coef(cox_model_full)),
  lower_ci = exp(confint(cox_model_full)[,1]),
  upper_ci = exp(confint(cox_model_full)[,2]),
  p_value = summary(cox_model_full)$coefficients[,5]
)
write.csv(cox_summary, "cox_results.csv", row.names = FALSE)

summary(cox_model_full)


# model diagnostics 

cox.zph(cox_model_full)

plot(cox.zph(cox_model_full))

cox_model_strat <- coxph(
  Surv(survival_time, event) ~ ROA + strata(NACE_factor),
  data = df
)

summary(cox_model_strat)

#COVARIANCE

cor(df[, c("ROA", "Trad_count", "Prod_count", "City_firms")], use = "complete.obs")

#bOX PLOT

df$event_label <- ifelse(df$event == 1, "Failed", "Survived")

boxplot(ROA ~ event_label, data = df,
        main = "ROA by Firm Status",
        xlab = "Firm Status",
        ylab = "ROA",
        col = "lightblue")

#LOG RANK TESTS


survdiff(Surv(survival_time, event) ~ NACE_factor, data = df)

#
sapply(df[, c("ROA", "Trad_count", "Prod_count", "City_firms")], function(x) {
  c(
    Mean = mean(x, na.rm = TRUE),
    Median = median(x, na.rm = TRUE),
    SD = sd(x, na.rm = TRUE),
    Min = min(x, na.rm = TRUE),
    Max = max(x, na.rm = TRUE)
  )
})

#SURVIVAL TIME BY NACE

surv_by_nace <- survfit(Surv(survival_time, event) ~ NACE_factor, data = df)


km_by_nace <- tidy(surv_by_nace)
write.csv(km_by_nace, "km_by_nace.csv", row.names = FALSE)

ggsurvplot(
  survfit(Surv(survival_time, event) ~ NACE_factor, data = df),
  data = df,
  pval = TRUE,
  legend.title = "Industry (NACE)",
  title = "Kaplan-Meier Survival Curves by Industry"
)


#HISTOGRAM OF SURVIVAL TIME

hist(df$survival_time, breaks = 50,
     main = "Distribution of Survival Time",
     xlab = "Years",
     col = "lightblue")

#cumulative hazard plot

ggsurvplot(
  survfit(Surv(survival_time, event) ~ 1, data = df),
  fun = "cumhaz",
  title = "Cumulative Hazard Function"
)

#schonfield residuals plot

ph_test <- cox.zph(cox_model_full)
plot(ph_test)

getwd()
