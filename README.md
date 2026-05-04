# League Games ML: Early-Game Win Prediction

This project builds a machine learning pipeline to predict whether a League of Legends match/player record results in a win using early-game objective and event features. The goal is to practice an end-to-end data workflow: collecting match data, preparing a modeling table, training a classification model, and evaluating model performance against a simple baseline.

## Project Motivation

League of Legends games often shift heavily based on early objectives such as first blood, first dragon, first Rift Herald, and first tower. This project asks:

> Can early-game events be used to predict the final win/loss outcome?

Instead of predicting before the game starts, this model is designed for an **early-game prediction setting**, where some in-game events are already known.

## Repository Structure

```text
league-games-ML/
├── match_data_process.ipynb          # Collects and processes match data from the Riot API
├── match_training_data.sql           # Creates the SQL view used for model training
├── match_data.csv                    # Raw / intermediate match-level data
├── model_training_early_events.csv   # Final modeling dataset
├── rf_classifier.ipynb               # Random Forest model training and evaluation notebook
└── README.md                         # Project documentation
```

## Data Collection and Processing

The data pipeline starts by collecting League of Legends ranked match data through the Riot API. The processing notebook includes helper functions to:

- Retrieve player PUUIDs
- Pull ranked ladder information
- Collect match IDs for selected players
- Request match-level JSON data
- Extract useful match and participant-level fields
- Convert processed records into a tabular dataset

The raw match data is then transformed into a cleaner modeling dataset focused on early-game events and match outcome.

## Modeling Dataset

The final modeling file is:

```text
model_training_early_events.csv
```

It contains **6,196 rows** and **23 columns**.

### Target Variable

The prediction target is:

```text
win_label
```

where:

```text
1 = win
0 = loss
```

### Example Features

The model uses contextual and early-game features such as:

- `champion_name`
- `team_position`
- `side`
- `patch`
- `team_first_blood`
- `enemy_first_blood`
- `first_blood_advantage`
- `team_first_dragon`
- `enemy_first_dragon`
- `first_dragon_advantage`
- `team_first_herald`
- `enemy_first_herald`
- `first_herald_advantage`
- `team_first_tower`
- `enemy_first_tower`
- `first_tower_advantage`

Tracking columns such as `uuid`, `match_id`, and `puuid` are kept for data management but are not used as model features.

## SQL Feature Engineering

The SQL file creates a modeling view called:

```sql
soloq.model_training_early_events
```

This view converts raw boolean event indicators into numeric model features. For example, first objective advantages are encoded as:

```text
 1 = player's team secured the objective first
-1 = enemy team secured the objective first
 0 = neither side secured it first / unavailable
```

This makes the features easier to use in a machine learning model.

## Machine Learning Approach

The model notebook uses a **Random Forest Classifier** to predict `win_label`.

### Why Random Forest?

A random forest combines many decision trees and averages their predictions. This is useful because it can capture non-linear relationships between early-game events and match outcomes. For example, first tower, first Herald, and first dragon may interact with each other in ways that are not fully linear.

### Train / Validation / Test Split

The notebook uses `GroupShuffleSplit` instead of a normal random row split.

This is important because multiple rows can come from the same match. If rows from the same match appeared in both training and testing, the model could indirectly learn information about a match it is later evaluated on. To reduce this leakage risk, the split is grouped by `match_id`.

The final data split is approximately:

| Dataset | Rows | Purpose |
|---|---:|---|
| Training set | 3,982 | Fit the model |
| Validation set | 967 | Check model performance during development |
| Test set | 1,247 | Final model evaluation |

The notebook also checks that there is no match overlap across the training, validation, and test sets.

## Preprocessing

The model pipeline separates features into two groups:

### Categorical Features

Text columns are one-hot encoded:

- `champion_name`
- `team_position`
- `side`
- `patch`

### Numeric Features

Early-game event indicators and advantage variables are passed directly into the model.

The preprocessing and model are combined using a scikit-learn `Pipeline`, which keeps the workflow cleaner and helps avoid preprocessing mistakes.

## Model Performance

### Validation Results

| Metric | Score |
|---|---:|
| Accuracy | 0.680 |
| ROC-AUC | 0.734 |

### Test Results

| Metric | Score |
|---|---:|
| Accuracy | 0.727 |
| ROC-AUC | 0.798 |

The test-set majority-class baseline is approximately **0.609**. The Random Forest model achieves approximately **0.727** test accuracy, an improvement of about **11.9 percentage points** over the baseline.

### Test Classification Report

| Class | Precision | Recall | F1-score | Support |
|---|---:|---:|---:|---:|
| Loss / 0 | 0.63 | 0.73 | 0.68 | 488 |
| Win / 1 | 0.81 | 0.73 | 0.76 | 759 |
| Overall Accuracy |  |  | 0.73 | 1,247 |

## Feature Importance

The Random Forest feature importance results suggest that early objective control is strongly related to match outcome. The most important features include:

- `first_tower_advantage`
- `team_first_tower`
- `enemy_first_tower`
- `first_herald_advantage`
- `team_first_herald`
- `enemy_first_herald`

This makes intuitive sense because early tower and Herald control can create map pressure, gold advantages, and stronger objective control later in the game.

## How to Run the Project

### 1. Clone the repository

```bash
git clone https://github.com/SeKee-debug/league-games-ML.git
cd league-games-ML
```

### 2. Create a virtual environment

```bash
python -m venv venv
```

Activate it:

```bash
# Windows
venv\Scripts\activate

# macOS / Linux
source venv/bin/activate
```

### 3. Install required packages

```bash
pip install pandas numpy matplotlib scikit-learn requests python-dotenv
```

### 4. Add Riot API key if collecting new data

If you want to run the data collection notebook from scratch, create a `.env` file:

```text
riot_api_key=YOUR_RIOT_API_KEY_HERE
```

Do not commit `.env` to GitHub.

### 5. Run the notebooks

Recommended order:

```text
1. match_data_process.ipynb
2. match_training_data.sql
3. rf_classifier.ipynb
```

If you only want to train the model using the prepared dataset, you can start directly from:

```text
rf_classifier.ipynb
```

## Limitations

This project should be interpreted carefully:

- The model predicts win/loss using early-game events, not pre-game information only.
- Features such as first tower, first dragon, and first Herald are only known after the match has already started.
- The dataset may be biased toward the players and matches collected from the Riot API sample.
- The model uses engineered event indicators but does not yet include richer time-series game state information such as gold difference over time, kill timeline, vision score, or item spikes.

## Future Improvements

Potential next steps:

- Add more match timeline features, such as gold difference at 10 or 15 minutes
- Compare Random Forest with Logistic Regression, XGBoost, or LightGBM
- Tune hyperparameters using cross-validation
- Add calibration plots to check whether predicted win probabilities are reliable
- Build separate models by role, champion type, or patch
- Create visualizations showing how objective advantages affect win probability
- Improve the data pipeline structure by separating notebooks, scripts, raw data, and processed data folders

## Skills Demonstrated

This project demonstrates:

- API data collection
- Data cleaning and feature engineering
- SQL view creation for modeling data
- Python data analysis with pandas
- Machine learning classification with scikit-learn
- Group-aware train/validation/test splitting
- Model evaluation using accuracy, ROC-AUC, classification reports, and confusion matrices
- Feature importance interpretation

## Author

Tsz Kit Lin
