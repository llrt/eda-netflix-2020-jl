## This is a loose port of original EDA of Netflix 2020 Dataset in R by ygterl (https://github.com/ygterl/EDA-Netflix-2020-in-R)

# load required libraries
using Queryverse # metapackage for DS 
using DataFrames, CategoricalArrays # packages for data frame manipulation
using CSV # package for CSV loading
using StatsKit # metapackage for statistics


# reading data file
netflix_df = CSV.read("./netflix_titles.csv", delim=',', header=1) |> DataFrame

# next, it's useful to take a good look at the dataset
println("Number of obs: ", nrow(netflix_df)) # number of observations
println("Number of cols: ", ncol(netflix_df)) # number of variables (columns)
println("Cols' names: ", names(netflix_df)) # list variables
println("Cols' types: ", [eltype(col) for col = eachcol(netflix_df)]) # list variables types
first(netflix_df, 5) # listing first 5 obs
last(netflix_df, 5) # listing last 5 obs


# discard show id, it's not really relevant
netflix_df = netflix_df |> @select(-:show_id) |> DataFrame

# change columns to categorical variables (factors)
# categorical!(netflix_df, :type, compress=true) # movie's type
# categorical!(netflix_df, :country, compress=true) # movie's country
# categorical!(netflix_df, :rating, compress=true) # movie's mature rating
# categorical!(netflix_df, :release_year, compress=true) # movie's release year
# categorical!(netflix_df, :listed_in, compress=true) # movie's genre
# categorical!(netflix_df, :director, compress=true) # movie's director

#println("Cols' types: ", [eltype(col) for col = eachcol(netflix_df)]) # list variables types again, after changing to categoricals

# investigate number of missings in each column
for col in names(netflix_df)
    println("number of missings in $col column: ", count(ismissing, netflix_df[:, col]))
end

# investigate number of complete cases (with no missing values in any column)
println("number of complete cases: ", nrow(dropmissing(netflix_df)))
dropmissing!(netflix_df) # retaining only complete cases 


# investigate most common values in each columns
for col in names(netflix_df)
    println("most common value in $col column: ", modes(netflix_df[:, col]))
end