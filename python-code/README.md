Customer Engagement & Churn Prediction

This repository contains a Python-based data analytics project that explores how customers engage with a Neo Banking app — and predicts which users are likely to stop using the service (so-called churn).
The goal of the project is to better understand user behavior, identify early risk patterns, and support decision-making with data-driven insights.

Project Overview
The notebook includes several key components:
1. Data Cleaning & Preparation
Import of three core datasets:
df_transactions: all user transactions (amount, date, direction,...)
df_notifications: communication history (channel, status, timestamp,...)
df_users: static user info (age, country, device)
Weekly aggregation and preprocessing of behavioral metrics
3. Customer Engagement Score (CES)
A weekly score is calculated for each user to capture engagement
Combines various signals:
Transaction frequency and volume
Interaction with notifications
Subscription type (standard, premium, metal)
All features are normalized and weighted to form a single score
4. Visualization
Trends over time (e.g., average CES by week)
User-level CES development (incl. drop detection)
Enables pattern recognition across different user segments
5. Churn Definition & Labeling
Users are marked as churned if no transaction occurs for 30+ days
A rolling-window approach is used to generate churn labels over time
Weekly user data is enriched with features and labeled accordingly
6. Machine Learning Integration
A classification model (e.g., logistic regression) is trained
Input: weekly user features
Output: probability that a user will churn in the near future
Predictions are saved in a churn forecast table for further use
Technologies Used
Python (Pandas, NumPy, scikit-learn, Matplotlib)
Google BigQuery (data sourcing)
Google Colab (development environment)
Why This Matters
For digital platforms like Neo Banks, customer retention is critical. This project shows how engagement can be tracked, quantified, and used to:
Detect churn risks before they happen
Visualize behavioral shifts over time
Build targeted user strategies based on data
File Structure
This repository contains two Python files:
Python_Code_for_Neo_Bank.ipynb – the full Jupyter notebook including explanations, visualizations, and step-by-step documentation
Python_Code_for_Neo_Bank.py – a cleaner version of the code for direct execution or integration into other workflows
