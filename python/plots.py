"""
Module: plots.py

A collection of Plotly-based visualization helpers for the Landkreis Dashboard.
These functions are called from R via reticulate to render interactive plots
inside a Shiny dashboard.
"""

import pandas as pd
import numpy as np
import plotly.express as px
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
from sklearn.ensemble import RandomForestClassifier

# --------------------------------------------------------------------------
# HELPER: Robust Data Loading
# --------------------------------------------------------------------------
def load_clean_data(df):
    """
    Convert the object passed by R/reticulate into a clean pandas DataFrame
    and normalize escaped column names.
    """
    if df is None:
        return pd.DataFrame()

    if not isinstance(df, pd.DataFrame):
        try:
            df = pd.DataFrame(df)
        except Exception:
            return pd.DataFrame()

    cleaned = df.copy()

    # Fix accidental Markdown-style escaping in CSV headers:
    # \_derived\_age becomes X_derived_age
    cleaned.columns = [
        str(col).strip().replace("\\_", "_")
        for col in cleaned.columns
    ]

    return cleaned

# --------------------------------------------------------------------------
# 1. Descriptive: Age & Gender Distribution
# --------------------------------------------------------------------------
def get_age_distribution_plot(df):
    """Generate an interactive histogram of age by gender.
    
    Parameters
    ----------
    df : pd.DataFrame
        Raw data frame from R/reticulate. Must contain columns
        'X_derived_age' and 'Per_Geschlecht'.
    
    Returns
    -------
    str
        HTML string of the Plotly figure for embedding in Shiny.
    """
    df = load_clean_data(df)
    if df.empty:
        return "<div style='color:red;'>Error: No data loaded.</div>"

    # Map LaeKoSA columns
    age_col = "X_derived_age"
    gender_col = 'Per_Geschlecht' 
    
    if age_col not in df.columns or gender_col not in df.columns:
        return f"<div style='color:red;'>Missing columns: {age_col} or {gender_col}</div>"

    # Clean data
    df = df.dropna(subset=[age_col, gender_col])
    df[age_col] = pd.to_numeric(df[age_col], errors='coerce')
    
    # Map gender codes to labels if needed (assuming 1/2 or M/F)
    if df[gender_col].dtype in ['int64', 'float64']:
        df['Gender_Label'] = df[gender_col].map({1: 'Male', 2: 'Female'}).fillna('Other')
    else:
        df['Gender_Label'] = df[gender_col]

    fig = px.histogram(df, x=age_col, color='Gender_Label', 
                       title="Age & Gender Distribution",
                       labels={age_col: "Age", 'Gender_Label': 'Gender'})
    fig.update_layout(template="plotly_white")
    return fig.to_html(full_html=False)

# --------------------------------------------------------------------------
# 2. Descriptive: Healthcare Utilization Comparison
# --------------------------------------------------------------------------
def get_healthcare_utilization_plot(df):
    """Bar chart of mean visit frequencies across medical departments.
    
    Parameters
    ----------
    df : pd.DataFrame
        Raw data frame from R/reticulate. Must contain at least one of
        the columns: MV_freq_HA, MV_freq_Int, MV_freq_Kard, MV_freq_Zahn,
        MV_freq_Derm, MV_freq_Auge, MV_freq_Gyn, MV_freq_Uro.
    
    Returns
    -------
    str
        HTML string of the Plotly figure for embedding in Shiny.
    """
    df = load_clean_data(df)
    if df.empty: return "<p>No data</p>"

    # Columns for visit frequencies in LaeKoSA
    vis_cols = [
        'MV_freq_HA', 'MV_freq_Int', 'MV_freq_Kard', 'MV_freq_Zahn', 
        'MV_freq_Derm', 'MV_freq_Auge', 'MV_freq_Gyn', 'MV_freq_Uro'
    ]
    
    # Filter only existing columns
    existing_cols = [c for c in vis_cols if c in df.columns]
    
    if not existing_cols:
        return "<div style='color:orange;'>No utilization columns found.</div>"

    # Calculate means
    mean_freq = df[existing_cols].mean().reset_index()
    mean_freq.columns = ['Department', 'Mean Visit Frequency']
    
    # Clean up department names for display
    mean_freq['Department'] = mean_freq['Department'].str.replace('MV_freq_', '').str.upper()
    
    fig = px.bar(
        mean_freq, x='Department', y='Mean Visit Frequency',
        title="<b>Average Patient Visit Frequency Across Departments</b>",
        color='Mean Visit Frequency', color_continuous_scale='Blues'
    )
    fig.update_layout(margin=dict(t=50, b=40, l=40, r=40), template="plotly_white")
    return fig.to_html(include_plotlyjs=False, full_html=False)

# --------------------------------------------------------------------------
# 3. Descriptive: Mental Health Screening (PHQ-9)
# --------------------------------------------------------------------------
def get_mental_health_plot(df):
    """Distribution of PHQ-9 depression screening scores.
    
    Parameters
    ----------
    df : pd.DataFrame
        Raw data frame from R/reticulate. Must contain at least one of
        the PHQ-9 item columns: MG_PHQ9_1_Int, MG_PHQ9_2_Depr, ..., MG_PHQ9_9_Tod.
    
    Returns
    -------
    str
        HTML string of the Plotly figure for embedding in Shiny.
    """
    df = load_clean_data(df)
    if df.empty: 
        return "<p>No data</p>"

    # PHQ-9 items in LaeKoSA
    phq_cols = [
        'MG_PHQ9_1_Int', 'MG_PHQ9_2_Depr', 'MG_PHQ9_3_Schlaf',
        'MG_PHQ9_4_Müde', 'MG_PHQ9_5_Appetit', 'MG_PHQ9_6_Versagen',
        'MG_PHQ9_7_Konz', 'MG_PHQ9_8_Unruhe', 'MG_PHQ9_9_Tod'
    ]

    existing_phq = [col for col in phq_cols if col in df.columns]
    
    if len(existing_phq) > 0:
        # Calculate sum score
        phq_data = df[existing_phq].apply(pd.to_numeric, errors='coerce')

        # Treat survey-specific missing codes as missing values
        phq_data = phq_data.replace([996, 997, 998, 999], np.nan)

        # Require all nine answers for a valid PHQ-9 total
        df['PHQ9_Sum'] = phq_data.sum(axis=1, min_count=9)
        df_valid = df.dropna(subset=['PHQ9_Sum'])

        if not df_valid.empty:
            fig = px.box(
                df_valid, y="PHQ9_Sum",
                title="<b>Distribution of Depression Screening Index (PHQ-9 Sum)</b>",
                labels={"PHQ9_Sum": "PHQ-9 Total Score"},
                color_discrete_sequence=["#0ea5e9"]
            )
            fig.update_layout(margin=dict(t=50, b=40, l=40, r=40), template="plotly_white")
            return fig.to_html(include_plotlyjs="False", full_html=False)
        
    # This return was previously outside the function due to indentation error
    return "<p>No PHQ-9 columns found or no complete responses.</p>"

# --------------------------------------------------------------------------
# 4. Machine Learning: Unsupervised Patient Phenotyping (K-Means & PCA)
# --------------------------------------------------------------------------
def get_ml_clustering_plot(df):
    """2D PCA scatter plot with K-Means clustering of patient phenotypes.
    
    Parameters
    ----------
    df : pd.DataFrame
        Raw data frame from R/reticulate. Must contain at least two numeric
        columns to perform PCA.
    
    Returns
    -------
    str
        HTML string of the Plotly figure for embedding in Shiny.
    """
    df = load_clean_data(df)

    if df.empty:
        return "<p>No data</p>"

    features = [
        'X_derived_age',
        'Per_Größe',
        'Per_Gewicht',
        'GK_SF12_1_healthstatus'
    ]

    valid_features = [f for f in features if f in df.columns]

    if len(valid_features) < 2:
        return (
            "<div style='color:orange;'>"
            f"Need at least 2 of: {features}. "
            f"Found: {valid_features}"
            "</div>"
        )

    sub = df[valid_features].copy()

    for col in valid_features:
        sub[col] = pd.to_numeric(sub[col], errors='coerce')

    # Remove special missing-value codes common in German surveys
    sub = sub.replace([996, 997, 998, 999], np.nan)
    sub = sub.dropna()

    if len(sub) < 10:
        return "<p>Insufficient complete data for clustering.</p>"

    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(sub[valid_features])

    kmeans = KMeans(
        n_clusters=3,
        random_state=42,
        n_init=10
    )
    clusters = kmeans.fit_predict(X_scaled)

    pca = PCA(n_components=2)
    pcs = pca.fit_transform(X_scaled)

    pca_df = pd.DataFrame(
        pcs,
        columns=['PC1', 'PC2'],
        index=sub.index
    )

    pca_df['Cluster'] = [
        f"Cluster Group {cluster + 1}"
        for cluster in clusters
    ]

    hover_columns = []

    if 'X_derived_age' in sub.columns:
        pca_df['Age'] = sub['X_derived_age']
        hover_columns.append('Age')

    if 'Per_Größe' in sub.columns:
        pca_df['Height'] = sub['Per_Größe']
        hover_columns.append('Height')

    if 'Per_Gewicht' in sub.columns:
        pca_df['Weight'] = sub['Per_Gewicht']
        hover_columns.append('Weight')

    fig = px.scatter(
        pca_df,
        x='PC1',
        y='PC2',
        color='Cluster',
        hover_data=hover_columns,
        title="<b>Machine Learning Patient Phenotypes "
              "(PCA & K-Means)</b>",
        labels={
            "PC1": "Principal Component 1",
            "PC2": "Principal Component 2"
        },
        color_discrete_map={
            "Cluster Group 1": "#2563eb",
            "Cluster Group 2": "#10b981",
            "Cluster Group 3": "#f59e0b"
        }
    )

    explained = pca.explained_variance_ratio_ * 100

    fig.update_xaxes(
        title=f"Principal Component 1 ({explained[0]:.1f}%)"
    )
    fig.update_yaxes(
        title=f"Principal Component 2 ({explained[1]:.1f}%)"
    )

    fig.update_layout(
        margin=dict(t=50, b=40, l=40, r=40),
        template="plotly_white"
    )

    return fig.to_html(
        include_plotlyjs=False,
        full_html=False
    )

# --------------------------------------------------------------------------
# 5. Machine Learning: Feature Importance (Predicting Health Status)
# --------------------------------------------------------------------------
def get_ml_feature_importance_plot(df):
    """Random Forest feature importance for predicting health status.
    
    Parameters
    ----------
    df : pd.DataFrame
        Raw data frame from R/reticulate. Must contain the target column
        'GK_SF12_1_healthstatus' and at least two predictors from
        ['X_derived_age', 'Per_Größe', 'Per_Gewicht', 'MV_freq_HA', 'SU_num_Helfer'].
    
    Returns
    -------
    str
        HTML string of the Plotly figure for embedding in Shiny.
    """
    df = load_clean_data(df)
    if df.empty: return "<p>No data</p>"

    # Target: General health status (SF-12)
    target_col = 'GK_SF12_1_healthstatus'
    
    # Predictors: Demographics & Utilization
    pred_candidates = ['X_derived_age', 'Per_Größe', 'Per_Gewicht', 'MV_freq_HA', 'SU_num_Helfer']
    feature_cols = [c for c in pred_candidates if c in df.columns]
    
    if target_col not in df.columns or len(feature_cols) < 2:
        return f"<div style='color:orange;'>Missing target '{target_col}' or predictors. Found: {feature_cols}</div>"

    sub = df[feature_cols + [target_col]].copy()
    
    # Convert to numeric and handle missing codes
    for col in feature_cols + [target_col]:
        sub[col] = pd.to_numeric(sub[col], errors='coerce')
        
    # Replace survey missing codes with NaN
    sub = sub.replace([996, 997, 998, 999], np.nan)
    sub = sub.dropna()
    
    if sub.empty:
        return "<p>Insufficient clean data for model training.</p>"

    X = sub[feature_cols]
    y = sub[target_col].astype('category').cat.codes 
    
    if y.nunique() < 2:
         return "<p>Target variable has only one unique value.</p>"

    model = RandomForestClassifier(n_estimators=50, random_state=42)
    model.fit(X, y)
    
    importance_df = pd.DataFrame({
        'Feature': feature_cols,
        'Importance': model.feature_importances_
    }).sort_values(by='Importance', ascending=True)
    
    fig = px.bar(
        importance_df, x='Importance', y='Feature', orientation='h',
        title="<b>Random Forest Feature Importance: Drivers of Self-Reported Health</b>",
        color='Importance', color_continuous_scale='Viridis'
    )
    fig.update_layout(margin=dict(t=50, b=40, l=80, r=40), template="plotly_white")
    return fig.to_html(include_plotlyjs="False", full_html=False)
