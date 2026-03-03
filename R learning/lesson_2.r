library(datasets)

# Get info on datasets
?mtcars

head(mtcars, -1)

# Create summary table for creating bar chart

# Var_dec   # create object from vector (always count of values?)
cylinders <- table(mtcars$cyl)

# Barplot creation
barplot(cylinders)





