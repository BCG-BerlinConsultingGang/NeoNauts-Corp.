Churn and Clustering Method – NeoBank Analytics

This notebook provides a full pipeline to analyze user churn behavior and cluster user profiles based on behavioral patterns. 
It is built to run in Google Colab using data extracted from BigQuery.

-> Contents

- Data Import
Connects to BigQuery and loads pre-transformed user-level transaction data from:
neonauts.dbt_azoellner.int_transformed_neo_bank
- Churn Definition
Churn is defined as no user activity within a 30-day window. Users are labeled accordingly.
- Clustering Analysis
Behavioral features (e.g. transaction frequency, average amount, engagement scores) are extracted and normalized to feed into clustering algorithms (e.g. KMeans).
- Churn Labeling and Interpretation
Each cluster is analyzed in terms of its churn share and behavioral profile to identify high-risk user segments.

-> Data Stack
- pandas, numpy, sklearn for data wrangling and clustering
- google.cloud.bigquery for cloud-based data access
- matplotlib, seaborn for result visualization
- StandardScaler and KMeans from sklearn

-> Output
- Cleaned dataset with churn labels
- User clusters based on behavioral patterns
- Visual interpretation of churn risk across clusters
- Reusable pipeline for churn prediction and segmentation

-> Requirements
- Google Cloud project access (BigQuery)
- Python environment (Colab or Jupyter)
- Python packages:
  - google-cloud-bigquery
  - scikit-learn
  - matplotlib, seaborn
