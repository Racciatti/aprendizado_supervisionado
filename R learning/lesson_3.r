library(datasets)

?iris

head(iris)

hist(iris$Petal.Length)
hist(iris$Petal.Width)
hist(iris$Sepal.Width)
hist(iris$Sepal.Length)

# change parameter mfrow in order to put graphs in 3 rows and one column ('c' is for concatenating)
par(mfrow=c(3,1))

hist(iris$Petal.Width [iris$Species == "setosa"],
    col="#FF0000",
    xlim = c(0,3),
    breaks = 9, # "Suggestion" of how many bars
    main = "Setosa",
    xlab = "f")

hist(iris$Petal.Width [iris$Species == "versicolor"],
    col="#00FF00",
    xlim = c(0,3),
    breaks = 9, # "Suggestion" of how many bars
    main = "Versicolor",
    xlab = "f")

hist(iris$Petal.Width [iris$Species == "virginica"],
    col="#0000FF",
    xlim = c(0,3),
    breaks = 9, # "Suggestion" of how many bars
    main = "Virginica",
    xlab = "f")

# Small multiples: Similar graphs for comparison