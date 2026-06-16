# SME Survival Analytics

## Project Overview
This project analyzes the survival dynamics of **65,351 Small and Medium Enterprises (SMEs)** using survival analysis techniques. The goal is to identify when firms are most likely to exit and what factors drive that risk.

**Key Question:** Does profitability and industry type affect how long a firm survives?

## Methodology
- **Survival Estimation:** Kaplan-Meier estimator to plot survival probabilities over time.
- **Group Comparison:** Log-rank test to compare survival across industries (NACE categories).
- **Risk Modeling:** Cox Proportional Hazards model to quantify the impact of Return on Assets (ROA) and industry on the hazard of firm exit.
- **Software:** R (survival, survminer, tidyverse) for analysis; Power BI for interactive visualization.

## Key Findings
- **Overall Failure Rate:** 33.86% of firms exited during the observation period.
- **Early-Stage Risk:** Firms face the highest exit risk in their first 5 years ("Liability of Newness").
- **Profitability Matters:** A 1-unit increase in ROA reduces the hazard of exit by ~0.22% (HR = 0.9978, p < 0.001).
- **Industry Risk:** Firms in NACE 2612 have **29% higher exit risk** (HR = 1.29) compared to the reference category.

## Dashboard Preview
![SME Survival Dashboard](SME SURVIVAL ANALYTICS DASHBOARD.pdf)
*(SME SURVIVAL ANALYTICS DASHBOARD)*

**Interactive Dashboard:** *(PDF preview available in repo.)*

## Reproducibility
To run the analysis yourself:
1. Clone this repository.
2. Download the CSI DATASET
3. Open `SME_Survival_Analysis.R` in RStudio.
4. Install required packages: `survival`, `survminer`, `tidyverse`, `lubridate`, `broom`.
5. Run the script.

## Tools Used
- **R:** Data cleaning, survival modeling, visualization.
- **Power BI:** Dashboard creation.
- **Excel:** Initial data validation.

## About the Author
Misheck Tapambwa – Applied Statistics Graduate (UZ), aspiring actuary (SOA Exam P Nov 2026).

[linkedin.com/in/misheck-tapambwa-ab8b09315] | [tapambwamisheck222@gmail.com]
