Final Mart Table – Churn & Clustering (NeoBank)

This notebook contains the final transformation steps used to create a mart-level BigQuery table for churn segmentation and clustering in the NeoBank analytics pipeline.
It consolidates cleaned, feature-enriched user data and stores the result in a reusable table for downstream analytics and modeling.

-> Purpose
1. Prepare a production-ready mart table containing:
  - Churn labels (based on 30+ days inactivity)
  - Scaled behavioral features
  - Clustering results
  - User segmentation info
2. Store this result in BigQuery for BI tools (e.g. Looker Studio) or machine learning models.

-> Data Source 
- Input: neonauts.dbt_azoellner.int_transformed_neo_bank
- Output (mart table): neonauts.dbt_maxstuenzner.mart_user_churn_clusters

-> Main Steps
1. Import transformed user-level data
2. Feature engineering:
  - Lifetime engagement metrics
  - Transaction frequency and value
  - Notification history
3. Cluster assignment via KMeans
4. Churn labeling and thresholding
5. Export final DataFrame to BigQuery mart table

-> Technologies Used
- Python 3.11 (Colab)
- BigQuery (via google.cloud.bigquery)
- pandas, numpy, sklearn

-> Output Table Contains
- user_id
- Churn label
- Engagement features
- Cluster assignment
- Scaled/normalized feature columns
