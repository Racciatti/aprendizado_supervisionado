library(datasets)

hist(mtcars$wt)
hist(mtcars$mpg)

plot(mtcars$wt, mtcars$mpg)

plot(mtcars$wt, mtcars$mpg,
    pch=19,
    cex=1.5, # size of things,
    main="Miles per galon in function of weight",
    col="#FF0000"
    )
