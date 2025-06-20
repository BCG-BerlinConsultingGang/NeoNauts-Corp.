def model(dbt, session):
    import pandas as pd
    from sklearn.preprocessing import StandardScaler, MinMaxScaler
    from sklearn.linear_model import LogisticRegression
    from sklearn.model_selection import train_test_split
    from sklearn.cluster import KMeans

    # Reference your source table (adjust as needed)
    df = dbt.ref("int_transformed_neo_bank").to_pandas()

    # Parse dates
    date_columns = [
        "sign_up_date",
        "first_notification",
        "last_notification",
        "first_transaction_date",
        "last_transaction_date"
    ]
    for col in date_columns:
        df[col] = pd.to_datetime(df[col], errors='coerce')

    # Machine Learning Model
    ML_scaler = StandardScaler().set_output(transform="pandas")
    model = LogisticRegression()

    X = df[[
        "avg_transactions_per_day", "crypto_unlocked", "is_standard_user",
        "is_premium_user", "is_metal_user", "average_amount_per_transaction_usd",
        "active_timeframe", "apple_user", "android_user", "age",
        "nb_notifications", "direction_ratio"
    ]]
    y = df["active_user"]
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    X_train_scaled = ML_scaler.fit_transform(X_train)
    model.fit(X_train_scaled, y_train)

    # Engagement Score Calculation
    engagement_features = [
        "avg_transactions_per_day", "crypto_unlocked", "is_standard_user",
        "is_premium_user", "is_metal_user", "average_amount_per_transaction_usd",
        "active_timeframe", "direction_ratio"
    ]
    scaler = MinMaxScaler()
    df_scaled = pd.DataFrame(scaler.fit_transform(df[engagement_features]), columns=engagement_features)
    weights = {
        "active_timeframe": 45, "avg_transactions_per_day": 20, "direction_ratio": 15,
        "is_metal_user": 7, "is_premium_user": 8, "is_standard_user": 0,
        "average_amount_per_transaction_usd": 3, "crypto_unlocked": 2
    }
    df_scaled["LES"] = sum(df_scaled[feature] * weight for feature, weight in weights.items())
    df_scaled["user_id"] = df["user_id"]

    # Segment Clustering with KMeans
    X_cluster = df_scaled[["LES"]].copy()
    kmeans = KMeans(n_clusters=3, random_state=42)
    df_scaled['segment_kmeans'] = kmeans.fit_predict(X_cluster)
    cluster_order = df_scaled.groupby('segment_kmeans')['LES'].mean().sort_values().index
    segment_labels = {cluster_order[0]: 'Low Engagement',
                      cluster_order[1]: 'Medium Engagement',
                      cluster_order[2]: 'High Engagement'}
    df_scaled['segment_label'] = df_scaled['segment_kmeans'].map(segment_labels)

    # Merge with original data
    mart_user_LES_Neo_Bank = df_scaled[["user_id", "LES", "segment_label"]].merge(df, on="user_id", how="left")

    # Churn Probability Calculation
    X_full_data = df[[
        "avg_transactions_per_day", "crypto_unlocked", "is_standard_user",
        "is_premium_user", "is_metal_user", "average_amount_per_transaction_usd",
        "active_timeframe", "apple_user", "android_user", "age",
        "nb_notifications", "direction_ratio"
    ]]
    X_full_data_scaled = ML_scaler.transform(X_full_data)
    probabilities = model.predict_proba(X_full_data_scaled)
    churn_probability = probabilities[:, 0]

    df_churn_prediction = pd.DataFrame({
        'user_id': df['user_id'],
        'churn_probability': churn_probability
    })

    mart_user_LES_Neo_Bank = mart_user_LES_Neo_Bank.merge(
        df_churn_prediction,
        on="user_id",
        how="left"
    )

    return mart_user_LES_Neo_Bank
