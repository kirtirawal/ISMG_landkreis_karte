"""
Module: plots.py - User-Friendly Visualizations with Insights

Designed for NON-TECHNICAL users with:
- Clear insight summaries
- Interactive annotations
- Simple, intuitive charts
- Actionable takeaways
"""

import pandas as pd
import numpy as np
import plotly.express as px
import plotly.graph_objects as go
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
from sklearn.ensemble import RandomForestClassifier
from typing import Optional, Dict, List, Any, Tuple
import json

from config import (
    MISSING_CODES, DEMOGRAPHIC_COLUMNS, SF12_COLUMNS, SF12_LABELS,
    PHQ9_COLUMNS, UTILIZATION_FREQ_COLUMNS, SATISFACTION_COLUMNS,
    THERAPY_COLUMNS, PREVENTIVE_COLUMNS, ML_SETTINGS, PLOT_SETTINGS,
    COLORBLIND_PALETTE, AGE_BINS, AGE_LABELS, PHQ9_SEVERITY
)

# ==============================================================================
# HELPER: Generate Insight Text
# ==============================================================================
def generate_insight_text(insights: Dict[str, Any]) -> str:
    """
    Generate HTML-formatted insight summary for non-technical users.
    
    Parameters
    ----------
    insights : Dict[str, Any]
        Dictionary with 'title', 'key_findings' (list), and 'recommendation'
    
    Returns
    -------
    str
        HTML string with formatted insights
    """
    html = """
    <div style="background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 100%); 
                border-left: 4px solid #0284c7; 
                padding: 15px; 
                margin: 10px 0 20px 0;
                border-radius: 8px;
                font-family: Arial, sans-serif;">
        <div style="display: flex; align-items: center; margin-bottom: 10px;">
            <span style="font-size: 20px; margin-right: 8px;">💡</span>
            <h4 style="margin: 0; color: #0c4a6e; font-size: 16px; font-weight: 600;">
                {title}
            </h4>
        </div>
        <div style="margin-left: 28px;">
            <ul style="margin: 8px 0; padding-left: 20px; color: #334155; line-height: 1.6;">
                {findings}
            </ul>
            {recommendation}
        </div>
    </div>
    """
    
    findings_html = ''.join([f"<li>{f}</li>" for f in insights.get('key_findings', [])])
    
    recommendation_html = ''
    if insights.get('recommendation'):
        recommendation_html = f"""
        <div style="background: #fef3c7; 
                    padding: 10px; 
                    border-radius: 6px;
                    margin-top: 10px;
                    color: #92400e;
                    font-weight: 500;">
            <strong>📌 Recommendation:</strong> {insights['recommendation']}
        </div>
        """
    
    return html.format(
        title=insights.get('title', 'Key Insights'),
        findings=findings_html,
        recommendation=recommendation_html
    )


def load_clean_data(df: Any) -> pd.DataFrame:
    """Convert R/reticulate object to clean pandas DataFrame."""
    if df is None:
        return pd.DataFrame()

    if not isinstance(df, pd.DataFrame):
        try:
            df = pd.DataFrame(df)
        except Exception:
            return pd.DataFrame()

    cleaned = df.copy()
    cleaned.columns = [str(col).strip().replace("\\_", "_") for col in cleaned.columns]
    return cleaned


def clean_survey_data(df: pd.DataFrame, columns: List[str]) -> pd.Series:
    """Clean survey data by replacing missing value codes with NaN."""
    if not columns:
        return pd.Series(dtype=float)
    clean_data = df[columns].apply(pd.to_numeric, errors='coerce')
    clean_data = clean_data.replace(MISSING_CODES, np.nan)
    return clean_data


def get_age_group(age: float) -> str:
    """Categorize age into groups."""
    if pd.isna(age):
        return "Unknown"
    for i in range(len(AGE_BINS) - 1):
        if AGE_BINS[i] <= age < AGE_BINS[i + 1]:
            return AGE_LABELS[i]
    return AGE_LABELS[-1]


# ==============================================================================
# VISUALIZATION 1: Age Distribution with Insights
# ==============================================================================
def get_age_distribution_plot(df: Any, age_filter: str = "all", gender_filter: str = "all") -> str:
    """
    Age distribution with clear insights for non-technical users.
    
    WHAT USERS SEE:
    - Simple bar chart showing patient age groups
    - Clear percentages and counts
    - Insight box explaining what this means
    """
    df = load_clean_data(df)
    if df.empty:
        return "<div class='alert alert-warning'>No data available</div>"

    age_col = DEMOGRAPHIC_COLUMNS.get("age", "_derived_age")
    gender_col = "Per_Geschlecht"
    
    if age_col not in df.columns:
        return "<div class='alert alert-warning'>Age column not found</div>"

    df_clean = df.dropna(subset=[age_col]).copy()
    df_clean[age_col] = pd.to_numeric(df_clean[age_col], errors='coerce')
    df_clean = df_clean.dropna(subset=[age_col])
    df_clean['Age_Group'] = df_clean[age_col].apply(get_age_group)
    
    # Apply filters
    if age_filter != "all":
        df_clean = df_clean[df_clean['Age_Group'] == age_filter]
    
    if gender_col in df_clean.columns and gender_filter != "all":
        gender_map = {'male': 1, 'female': 2, 'other': 999}
        gender_val = gender_map.get(gender_filter.lower(), 999)
        df_clean = df_clean[df_clean[gender_col] == gender_val]
    
    # Calculate statistics
    total_patients = len(df_clean)
    age_dist = df_clean['Age_Group'].value_counts().sort_index()
    mean_age = df_clean[age_col].mean()
    median_age = df_clean[age_col].median()
    
    # Find largest group
    largest_group = age_dist.idxmax() if len(age_dist) > 0 else "Unknown"
    largest_pct = (age_dist.max() / total_patients * 100) if total_patients > 0 else 0
    
    # Create visualization
    if gender_col in df_clean.columns and gender_filter == "all":
        df_clean['Gender'] = df_clean[gender_col].map({1: 'Male', 2: 'Female'}).fillna('Other')
        fig = px.histogram(
            df_clean, x='Age_Group', color='Gender',
            title="Patient Age & Gender Distribution",
            labels={'Age_Group': 'Age Group', 'Gender': 'Gender'},
            color_discrete_sequence=['#3b82f6', '#ec4899'],
            barmode='group',
            text_auto='.0f'
        )
    else:
        fig = px.bar(
            x=age_dist.index,
            y=age_dist.values,
            title="Patient Age Distribution",
            labels={'x': 'Age Group', 'y': 'Number of Patients'},
            color=age_dist.values,
            color_continuous_scale='Blues',
            text=age_dist.values
        )
    
    fig.update_layout(
        template="plotly_white",
        height=450,
        showlegend=True,
        xaxis_title="Age Group",
        yaxis_title="Number of Patients",
        title=dict(font=dict(size=18, family="Arial"), x=0.5)
    )
    
    # Generate insights
    insights = {
        "title": "What This Tells Us",
        "key_findings": [
            f"Total of <strong>{total_patients:,}</strong> patients in the dataset",
            f"Average age is <strong>{mean_age:.1f} years</strong> (median: {median_age:.1f})",
            f"Largest group: <strong>{largest_group}</strong> ({largest_pct:.1f}% of patients)",
        ],
        "recommendation": f"Focus healthcare resources on the {largest_group} age group, which represents the largest patient segment."
    }
    
    return generate_insight_text(insights) + fig.to_html(include_plotlyjs=False, full_html=False, config={'displayModeBar': True, 'responsive': True})


# ==============================================================================
# VISUALIZATION 2: Simple Health Score Gauge
# ==============================================================================
def get_simple_health_score(df: Any) -> str:
    """
    Simple gauge showing overall health score - like a speedometer.
    
    WHAT USERS SEE:
    - Gauge/speedometer showing average health score
    - Color-coded (red=poor, green=excellent)
    - Simple interpretation
    """
    df = load_clean_data(df)
    if df.empty:
        return "<div class='alert alert-warning'>No data available</div>"

    health_col = SF12_COLUMNS.get("health_status", "GK_SF12_1_healthstatus")
    
    if health_col not in df.columns:
        return "<div class='alert alert-warning'>Health status data not found</div>"
    
    clean_series = clean_survey_data(df, [health_col])
    avg_score = clean_series.mean()
    total_respondents = clean_series.notna().sum()
    
    # Determine health level
    if avg_score >= 4:
        health_level = "Good to Excellent"
        health_color = "#22c55e"
        emoji = "😊"
    elif avg_score >= 3:
        health_level = "Fair to Good"
        health_color = "#eab308"
        emoji = "😐"
    else:
        health_level = "Poor to Fair"
        health_color = "#ef4444"
        emoji = "😟"
    
    # Create gauge chart
    fig = go.Figure(go.Indicator(
        mode="gauge+number+delta",
        value=avg_score,
        domain={'x': [0, 1], 'y': [0, 1]},
        title={
            'text': f"Average Health Score {emoji}<br><span style='font-size:13px'>Based on {total_respondents:,} patients</span>",
            'font': {'size': 16, 'family': 'Arial'}
        },
        delta={'reference': 3, 'increasing': {'color': "#22c55e"}},
        gauge={
            'axis': {'range': [1, 5], 'tickwidth': 2, 'tickcolor': "white"},
            'bar': {'color': health_color},
            'bgcolor': "white",
            'borderwidth': 2,
            'bordercolor': "gray",
            'steps': [
                {'range': [1, 2], 'color': '#fee2e2'},
                {'range': [2, 3], 'color': '#fef3c7'},
                {'range': [3, 4], 'color': '#d1fae5'},
                {'range': [4, 5], 'color': '#86efac'}
            ],
        }
    ))
    
    fig.update_layout(
        height=400,
        margin=dict(t=80, b=40, l=40, r=40),
        paper_bgcolor="white",
        font={'family': "Arial", 'size': 14}
    )
    
    # Generate insights
    insights = {
        "title": "What This Health Score Means",
        "key_findings": [
            f"Average health score is <strong>{avg_score:.2f} out of 5</strong>",
            f"Overall health status: <strong>{health_level}</strong>",
            f"Based on {total_respondents:,} patient responses",
        ],
        "recommendation": "Monitor health trends over time. Scores below 3 may indicate need for targeted health interventions."
    }
    
    return generate_insight_text(insights) + fig.to_html(include_plotlyjs=False, full_html=False, config={'displayModeBar': False, 'responsive': True})


# ==============================================================================
# VISUALIZATION 3: PHQ-9 Depression with Clear Categories
# ==============================================================================
def get_phq9_simple_plot(df: Any) -> str:
    """
    Simplified PHQ-9 visualization with clear severity categories.
    
    WHAT USERS SEE:
    - Traffic light colors (green=minimal, red=severe)
    - Percentage breakdown
    - Clear interpretation of what scores mean
    """
    df = load_clean_data(df)
    if df.empty:
        return "<div class='alert alert-warning'>No data available</div>"

    phq_cols = [c for c in PHQ9_COLUMNS if c in df.columns]
    
    if len(phq_cols) < 5:
        return "<div class='alert alert-warning'>Insufficient PHQ-9 data</div>"

    phq_data = clean_survey_data(df, phq_cols)
    df_clean = df.copy()
    df_clean['PHQ9_Sum'] = phq_data.sum(axis=1, min_count=5)
    df_clean = df_clean.dropna(subset=['PHQ9_Sum'])
    
    if df_clean.empty:
        return "<div class='alert alert-warning'>No complete PHQ-9 responses</div>"
    
    def categorize_phq9(score: float) -> str:
        for level, bounds in PHQ9_SEVERITY.items():
            if bounds["min"] <= score <= bounds["max"]:
                return level
        return "Unknown"
    
    df_clean['PHQ9_Severity'] = df_clean['PHQ9_Sum'].apply(categorize_phq9)
    df_clean['PHQ9_Category'] = df_clean['PHQ9_Severity'].apply(
        lambda x: 'No/Minimal' if x in ['Minimal'] else 
                  'Mild' if x == 'Mild' else 
                  'Moderate+' if x in ['Moderate', 'Moderately Severe', 'Severe'] else 'Unknown'
    )
    
    # Calculate statistics
    total = len(df_clean)
    clinically_significant = len(df_clean[df_clean['PHQ9_Sum'] >= 10])
    clinically_pct = (clinically_significant / total * 100) if total > 0 else 0
    
    severity_order = ["Minimal", "Mild", "Moderate", "Moderately Severe", "Severe"]
    severity_counts = df_clean['PHQ9_Severity'].value_counts().reindex(severity_order, fill_value=0)
    
    severity_colors = {
        "Minimal": "#22c55e",
        "Mild": "#84cc16",
        "Moderate": "#eab308",
        "Moderately Severe": "#f97316",
        "Severe": "#ef4444"
    }
    
    fig = px.bar(
        x=severity_counts.index,
        y=severity_counts.values,
        title="Depression Screening Results (PHQ-9)",
        labels={'x': 'Severity Level', 'y': 'Number of Patients'},
        color=severity_counts.index,
        color_discrete_map=severity_colors,
        text=severity_counts.values
    )
    
    fig.update_layout(
        template="plotly_white",
        height=450,
        showlegend=False,
        xaxis_title="Severity Level",
        yaxis_title="Number of Patients",
        title=dict(font=dict(size=18, family="Arial"), x=0.5)
    )
    
    fig.update_traces(texttemplate='%{text} (%{y:.1f}%)', textposition='outside')
    
    # Generate insights
    insights = {
        "title": "What Depression Screening Shows",
        "key_findings": [
            f"<strong>{clinically_pct:.1f}%</strong> of patients show clinically significant depression symptoms (score ≥10)",
            f"<strong>{severity_counts.get('Minimal', 0)}</strong> patients have minimal/no depression symptoms",
            f"<strong>{severity_counts.get('Moderate', 0) + severity_counts.get('Moderately Severe', 0) + severity_counts.get('Severe', 0)}</strong> patients have moderate or worse symptoms",
        ],
        "recommendation": f"Consider mental health screening and support services, especially for the {clinically_pct:.1f}% showing significant symptoms."
    }
    
    return generate_insight_text(insights) + fig.to_html(include_plotlyjs=False, full_html=False, config={'displayModeBar': True, 'responsive': True})


# ==============================================================================
# VISUALIZATION 4: Healthcare Satisfaction - Simple Smiley Chart
# ==============================================================================
def get_satisfaction_simple(df: Any) -> str:
    """
    Simple satisfaction visualization with emoji ratings.
    
    WHAT USERS SEE:
    - Smiley faces for satisfaction levels
    - Easy to understand ratings
    - Clear areas needing improvement
    """
    df = load_clean_data(df)
    if df.empty:
        return "<div class='alert alert-warning'>No data available</div>"

    satisfaction_data = {}
    for key, (col, label) in SATISFACTION_COLUMNS.items():
        if col in df.columns:
            clean_series = clean_survey_data(df, [col])
            satisfaction_data[label] = clean_series.mean()
    
    if not satisfaction_data:
        return "<div class='alert alert-warning'>No satisfaction data found</div>"
    
    # Add emoji based on score
    def get_emoji(score):
        if score >= 4: return "😊"
        elif score >= 3: return "😐"
        else: return "😟"
    
    categories = [f"{get_emoji(v)} {k}" for k, v in satisfaction_data.items()]
    values = list(satisfaction_data.values())
    
    # Find lowest and highest
    min_key = min(satisfaction_data, key=satisfaction_data.get)
    max_key = max(satisfaction_data, key=satisfaction_data.get)
    avg_satisfaction = np.mean(values)
    
    fig = px.bar(
        y=categories,
        x=values,
        orientation='h',
        title="Patient Satisfaction with Healthcare",
        labels={'x': 'Average Rating (1-5)', 'y': ''},
        color=values,
        color_continuous_scale=['#ef4444', '#eab308', '#22c55e'],
        range_color=[1, 5],
        text=values
    )
    
    fig.update_layout(
        template="plotly_white",
        height=400,
        showlegend=False,
        xaxis_title="Satisfaction Rating (1=Poor, 5=Excellent)",
        xaxis=dict(range=[0, 5]),
        title=dict(font=dict(size=18, family="Arial"), x=0.5),
        margin=dict(t=60, b=60, l=150, r=40)
    )
    
    fig.update_traces(texttemplate='%{text:.2f}', textposition='outside')
    
    # Generate insights
    insights = {
        "title": "Satisfaction Insights",
        "key_findings": [
            f"Overall satisfaction average: <strong>{avg_satisfaction:.2f}/5</strong>",
            f"Highest satisfaction: <strong>{max_key}</strong> ({satisfaction_data[max_key]:.2f}/5)",
            f"Needs improvement: <strong>{min_key}</strong> ({satisfaction_data[min_key]:.2f}/5)",
        ],
        "recommendation": f"Focus improvement efforts on '{min_key}' - this area has the lowest patient satisfaction."
    }
    
    return generate_insight_text(insights) + fig.to_html(include_plotlyjs=False, full_html=False, config={'displayModeBar': False, 'responsive': True})


# ==============================================================================
# VISUALIZATION 5: Simple Bar Chart for Utilization
# ==============================================================================
def get_utilization_simple(df: Any) -> str:
    """
    Simplified healthcare utilization chart.
    
    WHAT USERS SEE:
    - Clear bar chart of visit frequencies
    - Top departments highlighted
    - Easy comparison
    """
    df = load_clean_data(df)
    if df.empty:
        return "<div class='alert alert-warning'>No data available</div>"

    existing_cols = []
    labels = []
    
    for key, (col, label) in UTILIZATION_FREQ_COLUMNS.items():
        if col in df.columns:
            existing_cols.append(col)
            labels.append(label)
    
    if not existing_cols:
        return "<div class='alert alert-warning'>No utilization data found</div>"

    mean_freq = df[existing_cols].apply(
        lambda x: clean_survey_data(df, [x.name]).mean()
    )
    
    result_df = pd.DataFrame({
        'Department': labels[:len(mean_freq)],
        'Mean Visits': mean_freq.values
    }).sort_values('Mean Visits', ascending=True)
    
    # Find top department
    top_dept = result_df.iloc[-1]['Department']
    top_visits = result_df.iloc[-1]['Mean Visits']
    
    fig = px.bar(
        result_df,
        x='Mean Visits',
        y='Department',
        orientation='h',
        title="Average Healthcare Visits by Department",
        labels={'x': 'Average Visits per Patient', 'y': ''},
        color='Mean Visits',
        color_continuous_scale='Blues',
        text='Mean Visits'
    )
    
    fig.update_layout(
        template="plotly_white",
        height=500,
        showlegend=False,
        xaxis_title="Average Number of Visits",
        title=dict(font=dict(size=18, family="Arial"), x=0.5),
        margin=dict(t=60, b=60, l=150, r=40)
    )
    
    fig.update_traces(texttemplate='%{text:.2f}', textposition='outside')
    
    # Generate insights
    insights = {
        "title": "Healthcare Utilization Insights",
        "key_findings": [
            f"Most visited department: <strong>{top_dept}</strong> ({top_visits:.2f} avg visits)",
            f"Total of <strong>{len(result_df)}</strong> department types tracked",
            f"Average visits range from {result_df['Mean Visits'].min():.2f} to {result_df['Mean Visits'].max():.2f}",
        ],
        "recommendation": f"Ensure adequate staffing and resources for {top_dept}, the most frequently used service."
    }
    
    return generate_insight_text(insights) + fig.to_html(include_plotlyjs=False, full_html=False, config={'displayModeBar': True, 'responsive': True})


# ==============================================================================
# VISUALIZATION 6: Preventive Care - Progress Style
# ==============================================================================
def get_preventive_simple(df: Any) -> str:
    """
    Preventive care shown as progress bars.
    
    WHAT USERS SEE:
    - Progress bar style (like completion percentage)
    - Green/yellow/red based on uptake rate
    - Clear targets
    """
    df = load_clean_data(df)
    if df.empty:
        return "<div class='alert alert-warning'>No data available</div>"

    preventive_data = {}
    total = len(df)
    
    for key, (col, label) in PREVENTIVE_COLUMNS.items():
        if col in df.columns:
            clean_series = clean_survey_data(df, [col])
            positive = (clean_series <= 2).sum()
            preventive_data[label] = (positive / total * 100) if total > 0 else 0
    
    if not preventive_data:
        return "<div class='alert alert-warning'>No preventive care data found</div>"
    
    # Calculate average uptake
    avg_uptake = np.mean(list(preventive_data.values()))
    
    # Find best and worst
    best_service = max(preventive_data, key=preventive_data.get)
    worst_service = min(preventive_data, key=preventive_data.get)
    
    fig = px.bar(
        y=list(preventive_data.keys()),
        x=list(preventive_data.values()),
        orientation='h',
        title="Preventive Care Uptake Rate",
        labels={'x': 'Percentage of Patients (%)', 'y': ''},
        color=list(preventive_data.values()),
        color_continuous_scale=['#ef4444', '#eab308', '#22c55e'],
        range_color=[0, 100],
        text=list(preventive_data.values())
    )
    
    # Add target line at 70%
    fig.add_vline(x=70, line_dash="dash", line_color="gray", 
                  annotation_text="Target: 70%", annotation_position="top")
    
    fig.update_layout(
        template="plotly_white",
        height=400,
        showlegend=False,
        xaxis_title="Percentage of Patients Receiving Service (%)",
        xaxis=dict(range=[0, 100]),
        title=dict(font=dict(size=18, family="Arial"), x=0.5),
        margin=dict(t=60, b=60, l=180, r=40)
    )
    
    fig.update_traces(texttemplate='%{text:.1f}%', textposition='outside')
    
    # Generate insights
    insights = {
        "title": "Preventive Care Insights",
        "key_findings": [
            f"Average uptake rate: <strong>{avg_uptake:.1f}%</strong>",
            f"Best performing: <strong>{best_service}</strong> ({preventive_data[best_service]:.1f}%)",
            f"Needs improvement: <strong>{worst_service}</strong> ({preventive_data[worst_service]:.1f}%)",
        ],
        "recommendation": f"Focus outreach efforts on '{worst_service}' to improve preventive care coverage."
    }
    
    return generate_insight_text(insights) + fig.to_html(include_plotlyjs=False, full_html=False, config={'displayModeBar': False, 'responsive': True})


# ==============================================================================
# LEGACY FUNCTIONS (redirect to new implementations)
# ==============================================================================
def get_sf12_health_profile(df: Any) -> str:
    """Redirect to simple health score."""
    return get_simple_health_score(df)

def get_phq9_severity_plot(df: Any) -> str:
    """Redirect to simple PHQ-9 plot."""
    return get_phq9_simple_plot(df)

def get_satisfaction_radar(df: Any) -> str:
    """Redirect to simple satisfaction chart."""
    return get_satisfaction_simple(df)

def get_healthcare_utilization_plot(df: Any) -> str:
    """Redirect to simple utilization chart."""
    return get_utilization_simple(df)

def get_preventive_care_plot(df: Any) -> str:
    """Redirect to simple preventive care chart."""
    return get_preventive_simple(df)

def get_therapy_usage_plot(df: Any) -> str:
    """Simple therapy usage - keep as pie chart."""
    df = load_clean_data(df)
    if df.empty:
        return "<div class='alert alert-warning'>No data available</div>"

    therapy_counts = {}
    for key, (col, label) in THERAPY_COLUMNS.items():
        if col in df.columns:
            clean_series = clean_survey_data(df, [col])
            users = (clean_series > 0).sum()
            therapy_counts[label] = users
    
    if not therapy_counts:
        return "<div class='alert alert-warning'>No therapy data found</div>"
    
    total_users = sum(therapy_counts.values())
    
    fig = px.pie(
        values=list(therapy_counts.values()),
        names=list(therapy_counts.keys()),
        title=f"Therapy Usage (Total: {total_users} patients)",
        color_discrete_sequence=COLORBLIND_PALETTE,
        hole=0.4
    )
    
    fig.update_traces(hoverinfo='label+value+percent', textinfo='percent')
    fig.update_layout(
        template="plotly_white",
        height=450,
        showlegend=True,
        title=dict(font=dict(size=18, family="Arial"), x=0.5),
        margin=dict(t=60, b=40, l=40, r=40)
    )
    
    insights = {
        "title": "Therapy Usage Insights",
        "key_findings": [
            f"Total of <strong>{total_users}</strong> patients using therapy services",
            f"Most common therapy: <strong>{max(therapy_counts, key=therapy_counts.get)}</strong>",
        ],
        "recommendation": "Ensure adequate availability of the most utilized therapy types."
    }
    
    return generate_insight_text(insights) + fig.to_html(include_plotlyjs=False, full_html=False, config={'displayModeBar': True, 'responsive': True})


def get_age_health_scatter(df: Any) -> str:
    """Age vs health scatter - simplified."""
    df = load_clean_data(df)
    if df.empty:
        return "<div class='alert alert-warning'>No data available</div>"

    age_col = DEMOGRAPHIC_COLUMNS.get("age", "_derived_age")
    health_col = SF12_COLUMNS.get("health_status", "GK_SF12_1_healthstatus")
    
    if age_col not in df.columns or health_col not in df.columns:
        return "<div class='alert alert-warning'>Required columns not found</div>"
    
    df_clean = df[[age_col, health_col]].copy()
    df_clean[age_col] = pd.to_numeric(df_clean[age_col], errors='coerce')
    df_clean[health_col] = pd.to_numeric(df_clean[health_col], errors='coerce')
    df_clean = df_clean.dropna()
    
    if len(df_clean) < 10:
        return "<div class='alert alert-warning'>Insufficient data</div>"
    
    # Calculate correlation
    correlation = df_clean[age_col].corr(df_clean[health_col])
    
    fig = px.scatter(
        df_clean,
        x=age_col,
        y=health_col,
        title="Age vs Self-Reported Health",
        labels={age_col: 'Age (years)', health_col: 'Health Rating (1-5)'},
        opacity=0.5,
        color=health_col,
        color_continuous_scale='RdYlGn',
        trendline="ols"
    )
    
    fig.update_layout(
        template="plotly_white",
        height=450,
        xaxis_title="Age",
        yaxis_title="Health Rating (1=Poor, 5=Excellent)",
        title=dict(font=dict(size=18, family="Arial"), x=0.5)
    )
    
    corr_interpretation = "weak" if abs(correlation) < 0.3 else "moderate" if abs(correlation) < 0.7 else "strong"
    corr_direction = "negative (health decreases with age)" if correlation < 0 else "positive"
    
    insights = {
        "title": "Age-Health Relationship",
        "key_findings": [
            f"Correlation: <strong>{correlation:.3f}</strong> ({corr_interpretation} {corr_direction})",
            f"Based on <strong>{len(df_clean):,}</strong> patients",
        ],
        "recommendation": "Monitor health trends across age groups for targeted interventions."
    }
    
    return generate_insight_text(insights) + fig.to_html(include_plotlyjs=False, full_html=False, config={'displayModeBar': True, 'responsive': True})


def get_utilization_heatmap(df: Any) -> str:
    """Simplified heatmap."""
    df = load_clean_data(df)
    if df.empty:
        return "<div class='alert alert-warning'>No data available</div>"

    age_col = DEMOGRAPHIC_COLUMNS.get("age", "_derived_age")
    
    if age_col not in df.columns:
        return "<div class='alert alert-warning'>Age column not found</div>"
    
    df_clean = df.copy()
    df_clean[age_col] = pd.to_numeric(df_clean[age_col], errors='coerce')
    df_clean = df_clean.dropna(subset=[age_col])
    df_clean['Age_Group'] = df_clean[age_col].apply(get_age_group)
    
    utilization_data = {}
    for key, (col, label) in UTILIZATION_FREQ_COLUMNS.items():
        if col in df_clean.columns:
            clean_series = clean_survey_data(df_clean, [col])
            df_clean[col] = clean_series
            grouped = df_clean.groupby('Age_Group')[col].mean()
            utilization_data[label] = grouped
    
    if not utilization_data:
        return "<div class='alert alert-warning'>No utilization data found</div>"
    
    heatmap_df = pd.DataFrame(utilization_data).fillna(0)
    
    fig = px.imshow(
        heatmap_df.T,
        labels=dict(x="Age Group", y="Department", color="Avg Visits"),
        x=heatmap_df.columns,
        y=heatmap_df.index,
        color_continuous_scale='Blues',
        title="Healthcare Visits by Age Group",
        text_auto='.2f'
    )
    
    fig.update_layout(
        template="plotly_white",
        height=500,
        xaxis_title="Age Group",
        title=dict(font=dict(size=18, family="Arial"), x=0.5),
        margin=dict(t=60, b=80, l=120, r=40)
    )
    
    insights = {
        "title": "Utilization Patterns by Age",
        "key_findings": [
            f"Darker colors indicate higher utilization",
            f"Shows which departments are most used by each age group",
        ],
        "recommendation": "Use this to plan age-specific healthcare services."
    }
    
    return generate_insight_text(insights) + fig.to_html(include_plotlyjs=False, full_html=False, config={'displayModeBar': True, 'responsive': True})


def get_ml_clustering_plot(df: Any) -> str:
    """Simplified ML clustering with clear explanation."""
    df = load_clean_data(df)
    if df.empty:
        return "<div class='alert alert-warning'>No data available</div>"

    features = [
        DEMOGRAPHIC_COLUMNS.get("age", "_derived_age"),
        SF12_COLUMNS.get("health_status", "GK_SF12_1_healthstatus")
    ]

    valid_features = [f for f in features if f in df.columns]

    if len(valid_features) < 2:
        return "<div class='alert alert-warning'>Need age and health data for clustering</div>"

    sub = df[valid_features].copy()
    for col in valid_features:
        sub[col] = pd.to_numeric(sub[col], errors='coerce')

    sub = sub.replace(MISSING_CODES, np.nan).dropna()

    if len(sub) < 10:
        return "<div class='alert alert-warning'>Insufficient data for clustering</div>"

    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(sub[valid_features])

    kmeans = KMeans(n_clusters=3, random_state=42, n_init=10)
    clusters = kmeans.fit_predict(X_scaled)

    pca = PCA(n_components=2)
    pcs = pca.fit_transform(X_scaled)

    pca_df = pd.DataFrame(pcs, columns=['PC1', 'PC2'])
    pca_df['Cluster'] = [f"Group {i+1}" for i in clusters]
    pca_df['Age'] = sub[valid_features[0]].values
    pca_df['Health'] = sub[valid_features[1]].values if len(valid_features) > 1 else 0

    # Calculate cluster insights
    cluster_summary = pca_df.groupby('Cluster')[['Age', 'Health']].mean()
    
    fig = px.scatter(
        pca_df,
        x='PC1',
        y='PC2',
        color='Cluster',
        hover_data=['Age', 'Health'],
        title="Patient Groups (Auto-Discovered)",
        labels={"PC1": "Component 1", "PC2": "Component 2"},
        color_discrete_sequence=COLORBLIND_PALETTE[:3],
        size_max=10
    )

    fig.update_layout(
        template="plotly_white",
        height=450,
        title=dict(font=dict(size=18, family="Arial"), x=0.5),
        margin=dict(t=60, b=60, l=60, r=40)
    )
    
    insights = {
        "title": "Patient Group Insights",
        "key_findings": [
            f"Algorithm found <strong>3 distinct patient groups</strong>",
            f"Groups are based on similarities in age and health status",
            f"Hover over points to see individual patient details",
        ],
        "recommendation": "Consider tailored approaches for each patient group."
    }
    
    return generate_insight_text(insights) + fig.to_html(include_plotlyjs=False, full_html=False, config={'displayModeBar': True, 'responsive': True})


def get_ml_feature_importance_plot(df: Any) -> str:
    """Simplified feature importance."""
    df = load_clean_data(df)
    if df.empty:
        return "<div class='alert alert-warning'>No data available</div>"

    target_col = SF12_COLUMNS.get("health_status", "GK_SF12_1_healthstatus")
    pred_candidates = [
        DEMOGRAPHIC_COLUMNS.get("age", "_derived_age"),
        DEMOGRAPHIC_COLUMNS.get("weight", "Per_Gewicht"),
        "MV_freq_HA"
    ]
    
    feature_cols = [c for c in pred_candidates if c in df.columns]

    if target_col not in df.columns or len(feature_cols) < 2:
        return "<div class='alert alert-warning'>Insufficient data for analysis</div>"

    sub = df[feature_cols + [target_col]].copy()

    for col in feature_cols + [target_col]:
        sub[col] = pd.to_numeric(sub[col], errors='coerce')

    sub = sub.replace(MISSING_CODES, np.nan).dropna()

    if sub.empty:
        return "<div class='alert alert-warning'>No clean data available</div>"

    X = sub[feature_cols]
    y = pd.cut(sub[target_col], bins=3, labels=['Low', 'Medium', 'High']).cat.codes

    if y.nunique() < 2:
        return "<div class='alert alert-warning'>Target needs more variation</div>"

    model = RandomForestClassifier(n_estimators=100, random_state=42)
    model.fit(X, y)

    importance_df = pd.DataFrame({
        'Factor': feature_cols,
        'Importance': model.feature_importances_
    }).sort_values(by='Importance', ascending=True)
    
    # Map to friendly names
    friendly_names = {
        '_derived_age': 'Age',
        'Per_Gewicht': 'Weight',
        'MV_freq_HA': 'GP Visits'
    }
    importance_df['Factor'] = importance_df['Factor'].map(
        lambda x: friendly_names.get(x, x)
    )

    fig = px.bar(
        importance_df,
        x='Importance',
        y='Factor',
        orientation='h',
        title="What Factors Affect Health Status?",
        color='Importance',
        color_continuous_scale='Viridis',
        text='Importance'
    )

    fig.update_layout(
        template="plotly_white",
        height=350,
        xaxis_title="Relative Importance",
        title=dict(font=dict(size=18, family="Arial"), x=0.5),
        margin=dict(t=60, b=60, l=100, r=40)
    )
    
    fig.update_traces(texttemplate='%{text:.2f}', textposition='outside')
    
    top_factor = importance_df.iloc[-1]['Factor']
    
    insights = {
        "title": "Health Status Drivers",
        "key_findings": [
            f"Most important factor: <strong>{top_factor}</strong>",
            f"Analysis based on machine learning model",
        ],
        "recommendation": f"Focus health interventions on {top_factor.lower()} as it has the strongest impact on health outcomes."
    }
    
    return generate_insight_text(insights) + fig.to_html(include_plotlyjs=False, full_html=False, config={'displayModeBar': False, 'responsive': True})
