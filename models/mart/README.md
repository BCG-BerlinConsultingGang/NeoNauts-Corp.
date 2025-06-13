# Final Mart Table – Churn & Clustering (NeoBank)

This notebook contains the final transformation steps used to create a mart-level BigQuery table for churn segmentation and clustering in the NeoBank analytics pipeline. It consolidates cleaned, feature-enriched user data and stores the result in a reusable table for downstream analytics and modeling.

**Disclaimer:** Large parts of the code overlap with the code found in the script directory. Since the Python script could not be executed or deployed directly from dbt to the data warehouse (as this requires a paid GCP feature), the code was run via Google Colab and is included here again for better readability.

## Purpose
Creation of a roduction-ready mart table containing:
  - Churn labels (based on 30+ days inactivity)
  - Scaled behavioral features
  - Clustering results
  - User segmentation info
    
## Data
- Input: neonauts.dbt_azoellner.int_transformed_neo_bank
- Output: neonauts.dbt_maxstuenzner.mart_user_churn_clusters

## Steps
1. Import transformed user-level data
2. Feature engineering
   - Lifetime engagement metrics
   - Transaction frequency and value
   - Notification history
3. Cluster assignment with K-means
4. Churn labeling and thresholding
5. Export final DataFrame to BigQuery mart table

## Tech Stack, Libraries and Methods
- Python 3.11 (Colab)
- BigQuery (via google.cloud.bigquery)
- pandas, numpy, sklearn
