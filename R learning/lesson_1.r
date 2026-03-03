library(datasets)

head(iris)


# Continous, continuous -> scatter
plot(iris$Petal.Length,iris$Petal.Width)

# Continous, categorical -> box
plot(iris$Species, iris$Sepal.Width)

# Categorical -> Histogram
plot(iris$Species)



plot(iris$Petal.Length,iris$Petal.Width,
     # color
     col = "#FF0000",

     # point character
     pch = 19,

     # title
     main = "Iris: Petal Length vs Petal Width",
     
     # x axis label
     xlab = "Length" ,

     # y axis label
     ylab = "Width"
     )
