def model(dbt, session):
    import pandas as pd
    from sklearn.preprocessing import StandardScaler, MinMaxScaler
    from sklearn.linear_model import LogisticRegression
    from sklearn.model_selection import train_test_split
    from sklearn.cluster import KMeans

    # Load data from the upstream dbt model
    df = dbt.ref("int_transformed_neo_bank").to_pandas()

    # Parse date columns
    date_columns = [
        "sign_up_date",
        "first_notification",
        "last_notification",
        "first_transaction_date",
        "last_transaction_date"
    ]
    for col in date_columns:
        df[col] = pd.to_datetime(df[col], errors='coerce')

    # ML feature set
    X = df[[
        "avg_transactions_per_day",
        "crypto_unlocked",
        "is_standard_user",
        "is_premium_user",
        "is_metal_user",
        "average_amount_per_transaction_usd",
        "active_timeframe",
        "apple_user",
        "android_user",
        "age",
        "nb_notifications",
        "direction_ratio"
    ]]
    y = df["active_user"]

    # Train logistic regression model
    ML_scaler = StandardScaler().set_output(transform="pandas")
    model = LogisticRegression()
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    X_train_scaled = ML_scaler.fit_transform(X_train)
    X_test_scaled = ML_scaler.transform(X_test)
    model.fit(X_train_scaled, y_train)

    # Extract coefficients (optional)
    coefficients = model.coef_[0]
    columns = X.columns
    df_coefficients = pd.DataFrame({'Feature': columns, 'Coefficient': coefficients}).sort_values(by='Coefficient', ascending=False)

    # Engagement feature weighting
    engagement_features = [
        "avg_transactions_per_day",
        "crypto_unlocked",
        "is_standard_user",
        "is_premium_user",
        "is_metal_user",
        "average_amount_per_transaction_usd",
        "active_timeframe",
        "direction_ratio"
    ]
    weights = {
        "active_timeframe": 45,
        "avg_transactions_per_day": 20,
        "direction_ratio": 15,
        "is_metal_user": 7,
        "is_premium_user": 8,
        "is_standard_user": 0,
        "average_amount_per_transaction_usd": 3,
        "crypto_unlocked": 2
    }

    # Scale and compute LES
    scaler = MinMaxScaler()
    df_scaled = pd.DataFrame(scaler.fit_transform(df[engagement_features]), columns=engagement_features)
    df_scaled["LES"] = sum(df_scaled[feature] * weight for feature, weight in weights.items())
    df_scaled["user_id"] = df["user_id"]

    # KMeans segmentation
    kmeans = KMeans(n_clusters=3, random_state=42)
    df_scaled["segment_kmeans"] = kmeans.fit_predict(df_scaled[["LES"]])
    cluster_order = df_scaled.groupby("segment_kmeans")["LES"].mean().sort_values().index
    segment_labels = {
        cluster_order[0]: "Low Engagement",
        cluster_order[1]: "Medium Engagement",
        cluster_order[2]: "High Engagement"
    }
    df_scaled["segment_label"] = df_scaled["segment_kmeans"].map(segment_labels)

    # Merge with original
    df_LES_segment = df_scaled[["user_id", "LES", "segment_label"]]
    df["user_id"] = df["user_id"].astype(int)
    df_LES_segment["user_id"] = df_LES_segment["user_id"].astype(int)
    mart_user_LES_Neo_Bank = df_LES_segment.merge(df, on="user_id", how="left")

    # Predict churn probability on full data
    X_full_data = X.copy()
    X_full_data_scaled = ML_scaler.transform(X_full_data)
    churn_probability = model.predict_proba(X_full_data_scaled)[:, 0]
    df_churn_prediction = pd.DataFrame({
        "user_id": df["user_id"],
        "churn_probability": churn_probability
    })
    mart_user_LES_Neo_Bank = mart_user_LES_Neo_Bank.merge(df_churn_prediction, on="user_id", how="left")

    return mart_user_LES_Neo_Bank


