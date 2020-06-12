# EDA of Netflix 2020 Dataset in Julia

This is a loosely inspired port of [great EDA of Netflix 2020 Dataset in R by ygterl](https://github.com/ygterl/EDA-Netflix-2020-in-R)  to Julia. His original Medium post is avalaible [here](https://medium.com/deep-learning-turkiye/exploration-of-netflix-2020-dataset-in-r-markdown-eda-b202bbaec4a)

The main goal of this repo is to explore Julia's data manipulation core utilities.

## Libraries used

- **DataFrames**: for data frame creation and manipulation
- **CategoricalArrays**: for creating categorical (factors) columns in data frames
- **CSV**: for CSV file importing
- **StatsBase**: for doing basic statistics analysis
- **Queryverse**: for dplyr-style data frame manipulation
- **Gadfly**: for ggplot-style plotting
- **Cairo**: for saving generated plots in PNG format