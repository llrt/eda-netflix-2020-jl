## This is a loose port of original EDA of Netflix 2020 Dataset in R by ygterl (https://github.com/ygterl/EDA-Netflix-2020-in-R)

# load required libraries
using Queryverse # metapackage for DS 
using DataFrames, CategoricalArrays # packages for data frame manipulation
using CSV # package for CSV loading
using StatsKit # metapackage for statistics
using Gadfly # package for plotting


# reading data file
netflix_df = CSV.read("./netflix_titles.csv", delim=',', header=1, dateformat="U d, Y") |> DataFrame

# next, it's useful to take a good look at the dataset
println("Number of obs: ", nrow(netflix_df)) # number of observations
println("Number of cols: ", ncol(netflix_df)) # number of variables (columns)
println("Cols' names: ", names(netflix_df)) # list variables
println("Cols' types: ", [eltype(col) for col = eachcol(netflix_df)]) # list variables types
first(netflix_df, 5) # listing first 5 obs
last(netflix_df, 5) # listing last 5 obs


# discard show id, it's not really relevant
netflix_df = netflix_df |> @select(-:show_id) |> DataFrame

# investigate number of missings in each column
for col in names(netflix_df)
    println("number of missings in $col col: ", count(ismissing, netflix_df[:, col]))
end

# investigate number of complete cases (with no missing values in any column)
println("number of complete cases: ", nrow(dropmissing(netflix_df)))
dropmissing!(netflix_df) # retaining only complete cases 


# investigate most common values in each columns
for col in names(netflix_df)
    println("most common value in $col col: ", modes(netflix_df[:, col]))
end

# change columns to categorical variables (factors)
categorical!(netflix_df, :type, compress=true) # title's type
categorical!(netflix_df, :country, compress=true) # title's country
categorical!(netflix_df, :rating, compress=true) # movie's mature rating
categorical!(netflix_df, :release_year, compress=true) # movie's release year
categorical!(netflix_df, :listed_in, compress=true) # movie's genre
categorical!(netflix_df, :director, compress=true) # movie's director


# explore individual feature (univariate) distribution
set_default_plot_size(14cm, 8cm)

# 1: movie's type
type_df = netflix_df |> 
    @groupby(_.type) |>
    @map({type=key(_), count=length(_)}) |> DataFrame

print(type_df)
    
plot(type_df, y=:type, x=:count, 
     Geom.bar(orientation=:horizontal),
     Theme(bar_spacing=0.5cm),
     Guide.title("Titles by types"))

# 2: movie's country
# unfornately, country is a comma separated column - we'll have to split it

countries_arr = map(x -> split(x, ", "), netflix_df.country)
countries = unique(reduce(append!, countries_arr, init=[]))

countries_dict = Dict()
for c in countries
    countries_dict[c] = length(filter(l -> c in l, countries_arr))
end

countries_df = 
        DataFrame(
            country=collect(String, keys(countries_dict)), 
            count=collect(Int, values(countries_dict))) |>
        @orderby_descending(_.count) |> DataFrame

plot(first(countries_df, 10), y=:country, x=:count, 
     Geom.bar(orientation=:horizontal),
     Theme(bar_spacing=0.5cm),
     Guide.title("Top 10 countries"))