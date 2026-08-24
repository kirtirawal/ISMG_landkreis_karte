import pandas as pd
import plotly.express as px

def get_age_distribution_plot(csv_path):
    df = pd.read_csv(csv_path)
    fig = px.histogram(df, x="_derived_age", nbins=20, title="Cohort Age Distribution", labels={"_derived_age": "Age"})
    fig.update_layout(margin=dict(t=40, b=40, l=40, r=40))
    return fig.to_html(include_plotlyjs="cdn", full_html=False)

def get_healthcare_utilization_plot(csv_path):
    df = pd.read_csv(csv_path)
    vis_cols = ['MV_freq_HA', 'MV_freq_Kard', 'MV_freq_Ortho', 'MV_freq_Zahn', 'MV_freq_Derm']
    existing_cols = [c for c in vis_cols if c in df.columns]
    mean_freq = df[existing_cols].mean().reset_index()
    mean_freq.columns = ['Specialty', 'Average Frequency Score']
    mean_freq['Specialty'] = mean_freq['Specialty'].str.replace('MV_freq_', '')
    
    fig = px.bar(mean_freq, x='Specialty', y='Average Frequency Score', title="Average Consultation Frequencies by Department")
    fig.update_layout(margin=dict(t=40, b=40, l=40, r=40), showlegend=False)
    return fig.to_html(include_plotlyjs="cdn", full_html=False)

def get_mental_health_plot(csv_path):
    df = pd.read_csv(csv_path)
    phq_cols = [c for c in df.columns if c.startswith('MG_PHQ9_')]
    target_col = phq_cols[1] if len(phq_cols) > 1 else phq_cols[0]
    
    fig = px.box(df, y=target_col, title="Distribution of Depression Screening Score (PHQ-9 Item)")
    fig.update_layout(margin=dict(t=40, b=40, l=40, r=40))
    return fig.to_html(include_plotlyjs="cdn", full_html=False)