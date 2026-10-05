"""
Module: config.py - Centralized configuration for Landkreis Dashboard.
"""

from typing import Dict, List, Final

MISSING_CODES: Final[List[int]] = [996, 997, 998, 999]

DEMOGRAPHIC_COLUMNS = {
    "id": "ID",
    "age": "_derived_age",
    "height": "Per_Groesse",
    "weight": "Per_Gewicht"
}

SF12_COLUMNS = {
    "health_status": "GK_SF12_1_healthstatus",
    "stairs": "GK_SF12_2_Treppen",
    "daily_life": "GK_SF12_3_Alltag",
    "depressed": "GK_SF12_4_niedergeschlagen",
    "calm": "GK_SF12_5_ruhig",
    "energy": "GK_SF12_6_Energie",
    "pain": "GK_SF12_7_Schmerz",
    "social": "GK_SF12_12_sozial"
}

SF12_LABELS = {
    "health_status": "General Health",
    "stairs": "Climbing Stairs",
    "daily_life": "Daily Activities",
    "depressed": "Felt Depressed",
    "calm": "Felt Calm",
    "energy": "Had Energy",
    "pain": "Pain",
    "social": "Social Functioning"
}

PHQ9_COLUMNS = [
    "MG_PHQ9_1_Int", "MG_PHQ9_2_Depr", "MG_PHQ9_3_Schlaf",
    "MG_PHQ9_4_Muede", "MG_PHQ9_5_Appetit", "MG_PHQ9_6_Versagen",
    "MG_PHQ9_7_Konz", "MG_PHQ9_8_Unruhe", "MG_PHQ9_9_Tod"
]

GAD2_COLUMNS = ["MG_GAD2_1_Nervoes", "MG_GAD2_2_Sorgen"]

UTILIZATION_FREQ_COLUMNS = {
    "HA": ("MV_freq_HA", "General Practitioner"),
    "Int": ("MV_freq_Int", "Internal Medicine"),
    "Kard": ("MV_freq_Kard", "Cardiology"),
    "Zahn": ("MV_freq_Zahn", "Dentist"),
    "Derm": ("MV_freq_Derm", "Dermatology"),
    "Auge": ("MV_freq_Auge", "Ophthalmology"),
    "Ortho": ("MV_freq_Ortho", "Orthopedics"),
    "PPT": ("MV_freq_PPT", "Psychotherapy")
}

SATISFACTION_COLUMNS = {
    "find_HA": ("MV_Zufr_HA finden", "Finding GP"),
    "find_FA": ("MV_Zufr_FA finden", "Finding Specialist"),
    "overall_HA": ("MV_Zufr_insg_HA", "Overall GP"),
    "overall_FA": ("MV_Zufr_insg_FA", "Overall Specialist")
}

THERAPY_COLUMNS = {
    "Physio": ("MV_freqTher_Physio", "Physiotherapy"),
    "Ergo": ("MV_freqTher_Ergo", "Occupational Therapy"),
    "Logo": ("MV_freqTher_Logo", "Speech Therapy"),
    "Heil": ("MV_freqTher_Heil", "Naturopathy")
}

PREVENTIVE_COLUMNS = {
    "checkup": ("GV_freq_GesCheckup", "Regular Checkups"),
    "cancer_haut": ("GV_Krebs_Haut", "Skin Cancer Screening"),
    "cancer_blood": ("GV_Krebs_DBlut", "Blood Test")
}

ML_SETTINGS = {
    "n_clusters": 3,
    "random_state": 42,
    "n_init": 10,
    "n_estimators": 100,
    "min_samples": 10
}

PLOT_SETTINGS = {
    "template": "plotly_white",
    "colorscale_sequential": "Blues",
    "colorscale_categorical": "Set2"
}

COLORBLIND_PALETTE = [
    "#0173B2", "#DE8F05", "#029E73", "#D55E00",
    "#CC78BC", "#FE0400", "#949494"
]

AGE_BINS = [0, 18, 30, 45, 60, 75, 100]
AGE_LABELS = ["0-17", "18-29", "30-44", "45-59", "60-74", "75+"]

PHQ9_SEVERITY = {
    "Minimal": {"min": 0, "max": 4},
    "Mild": {"min": 5, "max": 9},
    "Moderate": {"min": 10, "max": 14},
    "Moderately Severe": {"min": 15, "max": 19},
    "Severe": {"min": 20, "max": 27}
}
