# Python Visualizations Improvements - Landkreis Dashboard

## Overview

This document describes the improvements made to the Python visualization module (`python/plots.py`) and explains each visualization's purpose and interpretation.

---

## Improvements Implemented

### 1. Code Quality & Structure
- **Type Hints**: All functions now have proper Python type annotations
- **Centralized Configuration**: Column mappings and constants moved to `config.py`
- **Logging**: Added logging support for debugging and monitoring
- **Error Handling**: Comprehensive error handling with user-friendly messages
- **Fixed Bugs**: Fixed indentation bug in `get_mental_health_plot()`

### 2. Performance
- **Caching Ready**: Structure supports `@lru_cache` for expensive operations
- **Efficient Data Cleaning**: Centralized missing value code handling

### 3. Dependencies
- **requirements.txt**: Added for reproducible Python environment

---

## New Visualizations Explained

### Section 1: Demographics & Health Overview

#### 1.1 Age Distribution (`get_age_distribution_plot`)
**What it shows**: Distribution of patients across age groups with gender breakdown.

**Interpretation**: 
- Shows the demographic composition of your patient cohort
- Helps identify which age groups are most represented
- Gender breakdown reveals potential sex-based differences in healthcare utilization

**Key Insights**: 
- Are there more young or old patients?
- Is there a gender imbalance in certain age groups?

---

#### 1.2 Age vs Health Status Scatter (`get_age_health_scatter`)
**What it shows**: Relationship between patient age and self-reported health status (SF-12).

**Interpretation**:
- Each dot represents a patient
- X-axis: Age, Y-axis: Self-reported health (1=Poor to 5=Excellent)
- Red dashed line shows the trend

**Key Insights**:
- Does health status decline with age? (downward trend)
- Are there outliers (older patients with excellent health)?
- How strong is the age-health correlation?

---

#### 1.3 SF-12 Health Profile (`get_sf12_health_profile`)
**What it shows**: Radar chart of health-related quality of life across multiple domains.

**Interpretation**:
- Each axis represents a different health domain (physical, mental, social)
- Scores range from 1-5 (higher = better health)
- Shape reveals health profile patterns

**Key Insights**:
- Which health domains are strongest/weakest?
- Is physical or mental health more affected?
- Balanced vs. imbalanced health profiles

---

### Section 2: Mental Health

#### 2.1 PHQ-9 Depression Severity (`get_phq9_severity_plot`)
**What it shows**: Distribution of depression screening results by severity level.

**Interpretation**:
- PHQ-9 scores categorized: Minimal (0-4), Mild (5-9), Moderate (10-14), Moderately Severe (15-19), Severe (20-27)
- Bar heights show number of patients in each category
- Color intensity indicates severity

**Key Insights**:
- What percentage of patients show clinically significant depression?
- Is mental health support needed for this population?
- Target groups for intervention

---

#### 2.2 Therapy Usage (`get_therapy_usage_plot`)
**What it shows**: Donut chart showing which therapy types patients are using.

**Interpretation**:
- Each segment represents a therapy type (physiotherapy, occupational therapy, etc.)
- Size shows number of patients using that therapy
- Helps understand treatment patterns

**Key Insights**:
- Which therapies are most utilized?
- Are mental health therapies (psychotherapy) underutilized?
- Gaps in therapy provision

---

### Section 3: Healthcare Utilization & Satisfaction

#### 3.1 Utilization Heatmap (`get_utilization_heatmap`)
**What it shows**: Healthcare visit patterns across medical specialties by age group.

**Interpretation**:
- Rows: Medical departments (GP, Cardiology, etc.)
- Columns: Age groups
- Color intensity: Mean visit frequency (darker = more visits)

**Key Insights**:
- Which departments are most used by each age group?
- Do seniors use more specialist care?
- Resource allocation planning

---

#### 3.2 Healthcare Satisfaction Radar (`get_satisfaction_radar`)
**What it shows**: Patient satisfaction across different healthcare access dimensions.

**Interpretation**:
- Each axis: Different satisfaction aspect (finding appointments, overall satisfaction, etc.)
- Scores 1-5 (higher = more satisfied)
- Larger area = higher overall satisfaction

**Key Insights**:
- Which aspects need improvement?
- Is appointment access a problem?
- Overall healthcare experience quality

---

### Section 4: Preventive Care

#### 4.1 Preventive Services Uptake (`get_preventive_care_plot`)
**What it shows**: Percentage of patients receiving various preventive care services.

**Interpretation**:
- Horizontal bars show uptake rates for different services
- Includes checkups, cancer screenings, blood tests
- Higher percentage = better preventive care coverage

**Key Insights**:
- Are patients getting regular checkups?
- Cancer screening participation rates
- Gaps in preventive care

---

### Section 5: Machine Learning

#### 5.1 Patient Phenotypes - PCA + K-Means (`get_ml_clustering_plot`)
**What it shows**: Patient subgroups identified through unsupervised machine learning.

**Interpretation**:
- PCA reduces dimensions to 2 principal components
- K-Means clusters patients with similar characteristics
- Each color = a patient cluster/phenotype
- Hover over points to see patient details

**Key Insights**:
- How many distinct patient types exist?
- What characterizes each cluster?
- Personalized medicine opportunities

---

#### 5.2 Health Status Predictors (`get_ml_feature_importance_plot`)
**What it shows**: Random Forest analysis of which factors best predict self-reported health.

**Interpretation**:
- Horizontal bars show feature importance scores
- Longer bars = stronger predictors of health status
- Based on machine learning model

**Key Insights**:
- Is age or lifestyle more important for health?
- Does healthcare utilization predict health status?
- Target factors for health interventions

---

## File Structure

```
python/
├── plots.py              # Main visualization functions (IMPROVED)
├── config.py             # Column mappings and constants (NEW)
└── requirements.txt      # Python dependencies (NEW)

modules/
├── mod_python_ui.R       # Updated UI with new plots
└── mod_python_server.R   # Updated server with new functions
```

---

## Usage Notes

### Data Requirements
- The visualizations expect the LaeKoSA dataset with standard column names
- Missing columns are handled gracefully with warning messages
- Minimum sample sizes apply for ML visualizations (10+ complete cases)

### Missing Value Codes
The following German survey codes are automatically converted to NaN:
- 996: not applicable
- 997: unknown
- 998: refused
- 999: not specified

### Performance Tips
- Data is converted once from R to Python (cached reactive)
- ML models train on-demand (consider caching for large datasets)
- Plotly JS is loaded from CDN for faster initial load

---

## Troubleshooting

### "No data available" messages
- Check that `laekosa_data` exists in global environment
- Verify data has the expected columns
- Ensure sufficient rows (>10 for most plots)

### "Column not found" errors
- Column names are case-sensitive
- German umlauts may need special handling (ü -> ue)
- Check `config.py` for expected column mappings

### ML plots not rendering
- Need minimum 10 complete cases
- Require at least 2 numeric features for clustering
- Target variable must have variation (2+ unique values)

---

## Future Enhancements

Potential additions for future versions:
1. **Correlation Heatmap**: Show relationships between all health indicators
2. **Time-Series Trends**: If longitudinal data becomes available
3. **Geographic Mapping**: District-level visualizations
4. **Export Functions**: Download plots as PNG/SVG
5. **Interactive Filters**: Age/gender filters for all plots
