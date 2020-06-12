# This is a loose port of original EDA of Netflix 2020 Dataset in R by ygterl (https://github.com/ygterl/EDA-Netflix-2020-in-R)

## load required libraries
using DataFrames, CategoricalArrays # packages for data frame manipulation
using CSV # package for CSV loading
using StatsBase # base package for statistics
using Queryverse # metapackage for DS 
using Gadfly, Cairo # packages for plotting
using Dates # package for date manipulation


## reading data file
netflix_df = CSV.read("./netflix_titles.csv", delim=',', header=1, dateformat="U d, Y") |> DataFrame

## next, it's useful to take a good look at the dataset
println("Number of obs: ", nrow(netflix_df)) # number of observations
println("Number of cols: ", ncol(netflix_df)) # number of variables (columns)
println("Cols' names: ", names(netflix_df)) # list variables
println("Cols' types: ", [eltype(col) for col = eachcol(netflix_df)]) # list variables types
first(netflix_df, 5) # listing first 5 obs
last(netflix_df, 5) # listing last 5 obs


## discard show id, it's not really relevant
netflix_df = netflix_df |> @select(-:show_id) |> DataFrame

## investigate number of missings in each column
for col in names(netflix_df)
    println("number of missings in $col col: ", count(ismissing, netflix_df[:, col]))
end

## investigate number of complete cases (with no missing values in any column)
println("number of complete cases: ", nrow(dropmissing(netflix_df)))
dropmissing!(netflix_df) # retaining only complete cases 


## investigate most common values (modes) in each columns
for col in names(netflix_df)
    println("most common value in $col col: ", modes(netflix_df[:, col]))
end

## change columns to categorical variables (factors)
# categorical!(netflix_df, :type, compress=true) # title's type
# categorical!(netflix_df, :country, compress=true) # title's country
# categorical!(netflix_df, :rating, compress=true) # title's mature rating
# categorical!(netflix_df, :release_year, compress=true) # title's release year
# categorical!(netflix_df, :listed_in, compress=true) # title's genre
# categorical!(netflix_df, :director, compress=true) # title's director



## 1: explore individual feature (univariate) distribution

### general plotting settings
set_default_plot_size(21cm, 10cm)

### 1a: type
type_df = netflix_df |> 
    @groupby(_.type) |>
    @map({type=key(_), count=length(_)}) |> 
    @mutate(count_str=string(_.count)) |>
    @orderby_descending(_.count) |>
    DataFrame

print(type_df)
    
plot(type_df, y=:type, x=:count, label=:count_str,
     Geom.bar(orientation=:horizontal), Geom.label(position=:right),
     Theme(bar_spacing=0.5cm, background_color=colorant"white"),
     Guide.title("Titles by types")) |> PNG("plot1a-types.png")

### 1b: country
### unfornately, country is a comma separated column - we'll have to split it

countries_arr = map(x -> split(x, ", "), netflix_df.country)
countries = unique(reduce(append!, countries_arr, init=[]))

countries_dict = Dict{String, Int}(
    c => length(filter(l -> c in l, countries_arr))
    for c in countries 
)

countries_df = 
        DataFrame(
            country=collect(String, keys(countries_dict)), 
            count=collect(Int, values(countries_dict))) |>
        @mutate(count_str=string(_.count)) |>
        @orderby_descending(_.count) |> DataFrame

top_countries_df = first(countries_df, 10)
print(top_countries_df)

plot(top_countries_df, y=:country, x=:count, label=:count_str,
     Geom.bar(orientation=:horizontal), Geom.label(position=:right),
     Theme(bar_spacing=0.25cm, background_color=colorant"white"),
     Guide.title("Top 10 countries")) |> PNG("plot1b-countries.png")


### 1c: release year
release_year_df = netflix_df |> 
    @groupby(_.release_year) |>
    @map({release_year=string(key(_)), count=length(_)}) |> 
    @mutate(count_str=string(_.count)) |>
    @orderby_descending(_.count) |>
    DataFrame

top_release_year = first(release_year_df, 10)

print(top_release_year)

plot(top_release_year, y=:release_year, x=:count, label=:count_str,
        Geom.bar(orientation=:horizontal), Geom.label(position=:right),
        Theme(bar_spacing=0.1cm, background_color=colorant"white"),
        Guide.title("Top 10 release years"))  |> PNG("plot1c-release_year.png")


### 1d: director
### director is also a comma separated column - we'll have to split it

directors_arr = map(x -> split(x, ", "), netflix_df.director)
directors = unique(reduce(append!, directors_arr, init=[]))

directors_dict = Dict{String, Int}(
    d => length(filter(l -> d in l, directors_arr))
    for d in directors
)

directors_df = 
        DataFrame(
            director=collect(String, keys(directors_dict)), 
            count=collect(Int, values(directors_dict))) |>
        @mutate(count_str=string(_.count)) |>
        @orderby_descending(_.count) |> DataFrame

top_directors_df = first(directors_df, 10)

print(top_directors_df)

plot(top_directors_df, y=:director, x=:count, label=:count_str,
     Geom.bar(orientation=:horizontal), Geom.label(position=:right),
     Theme(bar_spacing=0.25cm, background_color=colorant"white"),
     Guide.title("Top 10 directors")) |> PNG("plot1d-directors.png")


### 1e: actor
### cast is also a comma separated column - we'll have to split it

actors_arr = map(x -> split(x, ", "), netflix_df.cast)
actors = unique(reduce(append!, actors_arr, init=[]))

actors_dict = Dict{String, Int}(
    a => length(filter(l -> a in l, actors_arr))
    for a in actors
)

actors_df = 
        DataFrame(
            actor=collect(String, keys(actors_dict)), 
            count=collect(Int, values(actors_dict))) |>
        @mutate(count_str=string(_.count)) |>
        @orderby_descending(_.count) |> DataFrame

top_actors_df = first(actors_df, 10)

print(top_actors_df)

plot(top_actors_df, y=:actor, x=:count, label=:count_str,
     Geom.bar(orientation=:horizontal), Geom.label(position=:right),
     Theme(bar_spacing=0.25cm, background_color=colorant"white"),
     Guide.title("Top 10 actors")) |> PNG("plot1e-actors.png")

### 1f: genre
### listed_in is also a comma separated column - we'll have to split it

listed_in = replace.(netflix_df.listed_in, "&" => "&amp;") # fix for bug while displaying '&' character
genres_arr = map(x -> split(x, ", "), listed_in)
genres = unique(reduce(append!, genres_arr, init=[]))

genres_dict = Dict{String, Int}(
    g => length(filter(l -> g in l, genres_arr))
    for g in genres
)

genres_df = 
        DataFrame(
            genre=collect(String, keys(genres_dict)), 
            count=collect(Int, values(genres_dict))) |>
        @mutate(count_str=string(_.count)) |>
        @orderby_descending(_.count) |> DataFrame

top_genres_df = first(genres_df, 10)

print(top_genres_df)

plot(top_genres_df, y=:genre, x=:count, label=:count_str,
     Geom.bar(orientation=:horizontal), Geom.label(position=:right),
     Theme(bar_spacing=0.25cm, background_color=colorant"white"),
     Guide.title("Top 10 genres")) |> PNG("plot1f-genres.png")


### 1g: mature rating
rating_df = netflix_df |> 
    @groupby(_.rating) |>
    @map({rating=key(_), count=length(_)}) |> 
    @mutate(count_str=string(_.count)) |>
    @orderby_descending(_.count) |>
    DataFrame

print(rating_df)
    
plot(rating_df, y=:rating, x=:count, label=:count_str,
     Geom.bar(orientation=:horizontal), Geom.label(position=:right),
     Theme(bar_spacing=0.1cm, background_color=colorant"white"),
     Guide.title("Titles by mature rating")) |> PNG("plot1g-rating.png")



## 2: next, let's analyze certain features over time

### 2a: type by release year

type_year_df = netflix_df |> 
    @groupby({_.type, _.release_year}) |>
    @map({type=key(_)[1], release_year=key(_)[2], count=length(_)}) |> 
    @mutate(count_str=string(_.count)) |>
    @orderby_descending(_.count) |>
    DataFrame

print(type_year_df)
    
plot(type_year_df, y=:count, x=:release_year, color=:type,
     Geom.line, Geom.point,
     Theme(background_color=colorant"white"),
     Guide.title("Evolution of type by release year")) |> PNG("plot2a1-type-release_year.png")

plot(type_year_df, y=:count, x=:release_year, color=:type,
     Geom.bar(position=:stack),
     Theme(bar_spacing=0.05cm, background_color=colorant"white"),
     Guide.title("Evolution of type by release year")) |> PNG("plot2a2-type-release_year.png")



### 2b: type by year it was added

type_added_year_df = netflix_df |>
    @mutate(added_year=Dates.year(_.date_added)) |>
    @groupby({_.type, _.added_year}) |>
    @map({type=key(_)[1], added_year=key(_)[2], count=length(_)}) |> 
    @mutate(count_str=string(_.count)) |>
    @orderby_descending(_.count) |>
    DataFrame

print(type_added_year_df)
    
plot(type_added_year_df, y=:count, x=:added_year, color=:type,
     Geom.line, Geom.point,
     Theme(background_color=colorant"white"),
     Guide.title("Evolution of type by added year")) |> PNG("plot2b1-type-added_year.png")

plot(type_added_year_df, y=:count, x=:added_year, color=:type,
     Geom.bar(position=:stack), 
     Theme(bar_spacing=0.05cm, background_color=colorant"white"),
     Guide.title("Evolution of type by added year")) |> PNG("plot2b2-type-added_year.png")