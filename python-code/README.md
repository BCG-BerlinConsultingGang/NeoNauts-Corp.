NeoBank Analytics – Python Code

This folder contains the complete Python pipeline used in the NeoBank analytics project, developed in Google Colab. The objective of the project is to analyze user engagement and transactional behavior, and to predict potential user churn using machine learning.
Contents
NeoBank_Project_Python_Final.ipynb
The main notebook containing the full analysis pipeline, from data extraction to churn prediction.
Key Components
1. Data Extraction (BigQuery)
Authenticates Google Cloud credentials
Loads data from three main tables:
df_transactions: user transactions
df_notifications: sent notifications
df_users: static user information
2. Data Cleaning and Feature Engineering
Filters and aggregates transactions (e.g., OUTBOUND only)
Computes weekly user KPIs
Calculates metrics like transaction frequency, CES (Customer Engagement Score), and notification activity
3. Engagement Scoring (CES)
Weekly CES is computed using scaled and weighted features
Captures user activity trends over time
4. Churn Prediction
Defines churn as no activity for 30+ days
Prepares labeled dataset using a rolling transaction window (7–240 days)
Trains a logistic regression model to predict churn
Adds churn probabilities per user
5. Visualization
Time series plots for CES evolution
Weekly engagement tracking
Visual indicators for user segmentation and churn risk
Requirements
Python (via Google Colab)
Libraries:
pandas, numpy, sklearn, matplotlib, seaborn
google.cloud.bigquery
Notes
This code is optimized for execution within Google Colab.
It assumes access to a GCP project and datasets in BigQuery.
Replace the project.dataset.table paths with your own if adapting the code.

