# This is a loose port of original EDA of Netflix 2020 Dataset in R by ygterl (https://github.com/ygterl/EDA-Netflix-2020-in-R)

## load required libraries
using DataFrames, CategoricalArrays # packages for data frame manipulation
using CSV # package for CSV loading
using StatsBase # base package for statistics
using Queryverse # metapackage for DS 
using Gadfly, Cairo # packages for plotting
using Colors  # package for color manipulation
using Dates # package for date manipulation

include("./plot_style.jl")


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


## unfornately, some columns are comma separated ones - we'll have to split them, converting into arrays
netflix_df[!, :country_arr] = map(x -> split(x, ", "), netflix_df.country) # countries
netflix_df[!, :genre_arr] = map(x -> split(x, ", "), replace.(netflix_df.listed_in, "&" => "&amp;")) # genres
netflix_df[!, :director_arr] = map(x -> split(x, ", "), netflix_df.director) # directors
netflix_df[!, :actor_arr] = map(x -> split(x, ", "), netflix_df.cast) # actors
## when processing, @mapmany does the magic of unnesting and processing these arrays

## 1: explore individual feature (univariate) distribution

### general plotting settings
Gadfly.push_theme(plot_style())
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
    Guide.title("Titles by types")) |> PNG("plot1a-types.png")

### 1b: country

top_countries_df = netflix_df |>
    @mapmany(_.country_arr, {title=_.title, country=__}) |> 
    @groupby(_.country) |>
    @map({country=key(_), count=length(_), count_str=string(length(_))}) |>
    @orderby_descending(_.count) |>
    @take(10) |>
    DataFrame

print(top_countries_df)

plot(top_countries_df, y=:country, x=:count, label=:count_str,
    Geom.bar(orientation=:horizontal), Geom.label(position=:right),
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
    Guide.title("Top 10 release years"))  |> PNG("plot1c-release_year.png")


### 1d: director

top_directors_df = netflix_df |>
    @mapmany(_.director_arr, {title=_.title, director=__}) |> 
    @groupby(_.director) |>
    @map({director=key(_), count=length(_), count_str=string(length(_))}) |>
    @orderby_descending(_.count) |>
    @take(10) |>
    DataFrame

print(top_directors_df)

plot(top_directors_df, y=:director, x=:count, label=:count_str,
    Geom.bar(orientation=:horizontal), Geom.label(position=:right),
    Guide.title("Top 10 directors")) |> PNG("plot1d-directors.png")


### 1e: actor

top_actors_df = netflix_df |>
    @mapmany(_.actor_arr, {title=_.title, actor=__}) |> 
    @groupby(_.actor) |>
    @map({actor=key(_), count=length(_), count_str=string(length(_))}) |>
    @orderby_descending(_.count) |>
    @take(10) |>
    DataFrame

print(top_actors_df)

plot(top_actors_df, y=:actor, x=:count, label=:count_str,
    Geom.bar(orientation=:horizontal), Geom.label(position=:right),
    Guide.title("Top 10 actors")) |> PNG("plot1e-actors.png")

### 1f: genre
### listed_in is also a comma separated column - we'll have to split it

top_genres_df = netflix_df |>
    @mapmany(_.genre_arr, {title=_.title, genre=__}) |> 
    @groupby(_.genre) |>
    @map({genre=key(_), count=length(_), count_str=string(length(_))}) |>
    @orderby_descending(_.count) |>
    @take(10) |>
    DataFrame

print(top_genres_df)

plot(top_genres_df, y=:genre, x=:count, label=:count_str,
    Geom.bar(orientation=:horizontal), Geom.label(position=:right),
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
    Guide.title("Titles by mature rating")) |> PNG("plot1g-rating.png")



## 2: next, let's do some multivariate analysis

### first, do some frequency table analysis

unnested_netflix_df = netflix_df |>
    @mutate(added_year=Dates.year(_.date_added)) |>
    @mapmany(_.country_arr, {title=_.title, type=_.type, rating=_.rating, added_year=_.added_year, country=__, genre_arr=_.genre_arr, director_arr=_.director_arr, actor_arr=_.actor_arr}) |> 
    @mapmany(_.genre_arr, {title=_.title, type=_.type, rating=_.rating, added_year=_.added_year, country=_.country, genre=__, director_arr=_.director_arr, actor_arr=_.actor_arr}) |>
    @mapmany(_.director_arr, {title=_.title, type=_.type, rating=_.rating, added_year=_.added_year, country=_.country, genre=_.genre, director=__, actor_arr=_.actor_arr}) |>
    @mapmany(_.actor_arr, {title=_.title, type=_.type, rating=_.rating, added_year=_.added_year, country=_.country, genre=_.genre, director=_.director, actor=__}) |>
    DataFrame

### freq tables:
### I: type x country
ft1 = unnested_netflix_df |>
    @groupby({_.type, _.country}) |>
    @map({type=key(_)[1], country=key(_)[2], n=length(_)}) |>
    @orderby(_.type) |> @thenby(_.country) |>
    DataFrame

# long form, more readable, but missing out combinations that did not appear
ft1 |> CSV.write("freqtable_type_country-long.csv")
# wide form, allow for an overview including missing cases
wft1 = unstack(ft1, :country, :n)
wft1 |> CSV.write("freqtable_type_country-wide.csv")


### II: type x genre
ft2 = unnested_netflix_df |>
    @groupby({_.type, _.genre}) |>
    @map({type=key(_)[1], genre=key(_)[2], n=length(_)}) |>
    @orderby(_.type) |> @thenby(_.genre) |>
    DataFrame

# long form, more readable, but missing out combinations that did not appear
ft2 |> CSV.write("freqtable_type_genre-long.csv")
# wide form, allow for an overview including missing cases
wft2 = unstack(ft2, :genre, :n)
wft2 |> CSV.write("freqtable_type_genre-wide.csv")


### III: type x director
ft3 = unnested_netflix_df |>
    @groupby({_.type, _.director}) |>
    @map({type=key(_)[1], director=key(_)[2], n=length(_)}) |>
    @orderby(_.type) |> @thenby(_.director) |>
    DataFrame

# long form, more readable, but missing out combinations that did not appear
ft3 |> CSV.write("freqtable_type_director-long.csv")
# wide form, allow for an overview including missing cases
wft3 = unstack(ft3, :director, :n)
wft3 |> CSV.write("freqtable_type_director-wide.csv")


### IV: type x actor
ft4 = unnested_netflix_df |>
    @groupby({_.type, _.actor}) |>
    @map({type=key(_)[1], actor=key(_)[2], n=length(_)}) |>
    @orderby(_.type) |> @thenby(_.actor) |>
    DataFrame

# long form, more readable, but missing out combinations that did not appear
ft4 |> CSV.write("freqtable_type_actor-long.csv")
# wide form, allow for an overview including missing cases
wft4 = unstack(ft4, :actor, :n)
wft4 |> CSV.write("freqtable_type_actor-wide.csv")


### V: genre x country
ft5 = unnested_netflix_df |>
    @groupby({_.genre, _.country}) |>
    @map({genre=key(_)[1], country=key(_)[2], n=length(_)}) |>
    @orderby(_.genre) |> @thenby(_.country) |>
    DataFrame

# long form, more readable, but missing out combinations that did not appear
ft5 |> CSV.write("freqtable_genre_country-long.csv")
# wide form, allow for an overview including missing cases
wft5 = unstack(ft5, :country, :n)
wft5 |> CSV.write("freqtable_genre_country-wide.csv")


### VI: genre x director
ft6 = unnested_netflix_df |>
    @groupby({_.genre, _.director}) |>
    @map({genre=key(_)[1], director=key(_)[2], n=length(_)}) |>
    @orderby(_.genre) |> @thenby(_.director) |>
    DataFrame

# long form, more readable, but missing out combinations that did not appear
ft6 |> CSV.write("freqtable_genre_director-long.csv")
# wide form, allow for an overview including missing cases
wft6 = unstack(ft6, :director, :n)
wft6 |> CSV.write("freqtable_genre_director-wide.csv")

### VII: genre x actor
ft7 = unnested_netflix_df |>
    @groupby({_.genre, _.actor}) |>
    @map({genre=key(_)[1], actor=key(_)[2], n=length(_)}) |>
    @orderby(_.genre) |> @thenby(_.actor) |>
    DataFrame

# long form, more readable, but missing out combinations that did not appear
ft7 |> CSV.write("freqtable_genre_actor-long.csv")
# wide form, allow for an overview including missing cases
wft7 = unstack(ft7, :actor, :n)
wft7 |> CSV.write("freqtable_genre_actor-wide.csv")

### VIII: genre x rating
ft8 = unnested_netflix_df |>
    @groupby({_.genre, _.rating}) |>
    @map({genre=key(_)[1], rating=key(_)[2], n=length(_)}) |>
    @orderby(_.genre) |> @thenby(_.rating) |>
    DataFrame

# long form, more readable, but missing out combinations that did not appear
ft8 |> CSV.write("freqtable_genre_rating-long.csv")
# wide form, allow for an overview including missing cases
wft8 = unstack(ft8, :rating, :n)
wft8 |> CSV.write("freqtable_genre_rating-wide.csv")


### secondly, make some multivariate plots

### general plotting settings
set_default_plot_size(30cm, 18cm)

### a: type x release year

type_year_df = netflix_df |> 
    @groupby({_.type, _.release_year}) |>
    @map({type=key(_)[1], release_year=key(_)[2], count=length(_)}) |> 
    @mutate(count_str=string(_.count)) |>
    @orderby_descending(_.count) |>
    DataFrame

print(type_year_df)
    
plot(type_year_df, y=:count, x=:release_year, color=:type,
    Geom.line, Geom.point,
    style(line_width=0.8mm),
    Guide.title("Evolution of type by release year")) |> PNG("plot2a1-type-release_year.png")

plot(type_year_df, y=:count, x=:release_year, color=:type,
    Geom.bar(position=:stack),
    Guide.title("Evolution of type by release year")) |> PNG("plot2a2-type-release_year.png")



### b: type x added year

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
    style(line_width=0.8mm),
    Guide.title("Evolution of type by added year")) |> PNG("plot2b1-type-added_year.png")

plot(type_added_year_df, y=:count, x=:added_year, color=:type,
    Geom.bar(position=:stack), 
    Guide.title("Evolution of type by added year")) |> PNG("plot2b2-type-added_year.png")



### c: country x type x added year

country_type_added_year_df = netflix_df |>
    @mutate(added_year=Dates.year(_.date_added)) |>
    @mapmany(_.country_arr, {title=_.title, type=_.type, added_year=_.added_year, country=__}) |> 
    @groupby({_.country, _.type, _.added_year}) |>
    @map({country=key(_)[1], type=key(_)[2], added_year=key(_)[3], count=length(_)}) |>
    @filter(_.count >= 60) |>
    DataFrame

print(country_type_added_year_df)

plot(country_type_added_year_df, y=:count, x=:added_year, color=:country,
    Geom.bar(position=:stack), 
    Guide.title("Number of titles by country, added year")) |> PNG("plot2c1-country-added_year.png")


plot(country_type_added_year_df, y=:count, x=:country, color=:type,
    Geom.bar(position=:stack), 
    Guide.title("Number of titles by country, type")) |> PNG("plot2c2-country-type.png")


plot(country_type_added_year_df, x=:added_year, y=:count, xgroup=:type, ygroup=:country,
    Geom.subplot_grid(Geom.bar), 
    Guide.title("Top country x added year x type")) |> PNG("plot2c3-country-type-added_year.png")



### d: country x genre x added year

country_genre_added_year_df = netflix_df |>
    @mutate(added_year=Dates.year(_.date_added)) |>
    @mapmany(_.country_arr, {title=_.title, added_year=_.added_year, country=__, genre_arr=_.genre_arr}) |> 
    @mapmany(_.genre_arr, {title=_.title, added_year=_.added_year, country=_.country, genre=__}) |>
    @groupby({_.country, _.genre, _.added_year}) |>
    @map({country=key(_)[1], genre=key(_)[2], added_year=string(key(_)[3]), count=length(_)}) |>
    @filter(_.count >= 50) |>
    DataFrame

print(country_genre_added_year_df)

plot(country_genre_added_year_df, y=:count, x=:country, color=:genre,
    Geom.bar(position=:stack), 
#    Scale.color_discrete(n -> convert(Vector{Color}, colormap("RdBu", n)) ), # use a red-blue palette
    Scale.color_discrete(n -> convert(Vector{Color}, # use a custom palette
                                        Scale.lab_gradient("darkorchid4", "snow2", "darkorange2").(0:(1/(n-1)):1) 
                                     )  ),
    Guide.title("Number of titles by country, genre")) |> PNG("plot2d1-country-genre.png")

plot(country_genre_added_year_df, x=:added_year, y=:count, xgroup=:genre, ygroup=:country,
    Geom.subplot_grid(Geom.bar),
    style(minor_label_font_size=09pt),
    Guide.title("Top country x added year x genre")) |> PNG("plot2d2-country-genre-added_year.png")
