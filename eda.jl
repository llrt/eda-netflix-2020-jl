## This is a loose port of original EDA of Netflix 2020 Dataset in R by ygterl (https://github.com/ygterl/EDA-Netflix-2020-in-R)

# load required libraries
using Queryverse # macropackage for DS 
using DataFrames, CategoricalArrays # packages for data frame manipulation
using CSVFiles # package for CSV loading


# reading file is easy, just use load function
netflix_df = load("./netflix_titles.csv", delim=',', header_exists=true) |> DataFrame

# next, it's useful to take a good look at the dataset
println("Number of obs: ", nrow(netflix_df)) # number of observations
println("Number of cols: ", ncol(netflix_df)) # number of variables (columns)
println("Cols' names: ", names(netflix_df)) # list variables
println("Cols' types: ", [eltype(col) for col = eachcol(netflix_df)]) # list variables types
first(netflix_df, 5) # listing first 5 obs
last(netflix_df, 5) # listing last 5 obs

# change columns to categorical variables (factors)
categorical!(netflix_df, :type, compress=true) # movie's type
categorical!(netflix_df, :country, compress=true) # movie's country
categorical!(netflix_df, :rating, compress=true) # movie's mature rating
categorical!(netflix_df, :release_year, compress=true) # movie's release year

println("Cols' types: ", [eltype(col) for col = eachcol(netflix_df)]) # list variables types again, after changing to categoricals