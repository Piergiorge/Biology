library(scholar)
library(ggplot2)

# Define the id
id <- 'hxJiGRAAAAAJ&hl'

# Get his profile and print his name
l <- get_profile(id)
l$name 

# Get his citation history, i.e. citations to his work in a given year 
get_citation_history(id)

X <- get_citation_history(id)
ggplot(X, aes (year, cites)) + geom_line() + theme_bw()

# Get his publications (a large data frame)
publicacoes = get_publications(id)

## Predict h-index of original method author - future
y <- predict_h_index(id)
y$years_ahead
y$h_index
ggplot (y, aes (years_ahead, h_index)) + geom_line() + geom_point() + theme_bw()
