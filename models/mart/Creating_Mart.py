from dbt.adapters.python import model

@model()
def model(dbt, session):
    import pandas as pd
    from sklearn.preprocessing import StandardScaler, MinMaxScaler
    from sklearn.linear_model import LogisticRegression
    from sklearn.model_selection import train_test_split
    from sklearn.cluster import KMeans

    # Load input data
    df = dbt.ref("int_transformed_neo_bank").to_pandas()

    # Convert date columns
    date_columns = [
        "sign_up_date", "first_notification", "last_notification",
        "first_transaction_date", "last_transaction_date"
    ]
    for col in date_columns:
        df[col] = pd.to_datetime(df[col], errors="coerce")

    # Define features and target
    X = df[[
        "avg_transactions_per_day", "crypto_unlocked", "is_standard_user",
        "is_premium_user", "is_metal_user", "average_amount_per_transaction_usd",
        "active_timeframe", "apple_user", "android_user", "age",
        "nb_notifications", "direction_ratio"
    ]]
    y = df["active_user"]

    # Train-test split & scale
    scaler = StandardScaler().set_output(transform="pandas")
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    X_train_scaled = scaler.fit_transform(X_train)

    # Logistic regression
    clf = LogisticRegression()
    clf.fit(X_train_scaled, y_train)

    # Engagement score
    engagement_features = [
        "avg_transactions_per_day", "crypto_unlocked", "is_standard_user",
        "is_premium_user", "is_metal_user", "average_amount_per_transaction_usd",
        "active_timeframe", "direction_ratio"
    ]
    weights = {
        "active_timeframe": 45, "avg_transactions_per_day": 20, "direction_ratio": 15,
        "is_metal_user": 7, "is_premium_user": 8, "is_standard_user": 0,
        "average_amount_per_transaction_usd": 3, "crypto_unlocked": 2
    }

    minmax_scaler = MinMaxScaler()
    df_eng_scaled = pd.DataFrame(minmax_scaler.fit_transform(df[engagement_features]), columns=engagement_features)
    for feature in weights:
        df_eng_scaled[feature] *= weights[feature]
    df_eng_scaled["LES"] = df_eng_scaled[list(weights)].sum(axis=1)
    df_eng_scaled["user_id"] = df["user_id"]

    # KMeans segmentation
    kmeans = KMeans(n_clusters=3, random_state=42)
    df_eng_scaled["segment_kmeans"] = kmeans.fit_predict(df_eng_scaled[["LES"]])
    cluster_order = df_eng_scaled.groupby("segment_kmeans")["LES"].mean().sort_values().index
    segment_map = {
        cluster_order[0]: "Low Engagement",
        cluster_order[1]: "Medium Engagement",
        cluster_order[2]: "High Engagement"
    }
    df_eng_scaled["segment_label"] = df_eng_scaled["segment_kmeans"].map(segment_map)

    # Merge segment info
    mart_user_LES_Neo_Bank = df_eng_scaled[["user_id", "LES", "segment_label"]].merge(df, on="user_id", how="left")

    # Predict churn
    X_scaled = scaler.transform(X)
    mart_user_LES_Neo_Bank["churn_probability"] = clf.predict_proba(X_scaled)[:, 0]

    return mart_user_LES_Neo_Bank
