# Multiplot Visualization with ggplot2 and ggpubr

This R code shows how to create a multiplot visualization using `ggplot2` and `ggpubr` packages in R. The code creates 5 different plots, labeled A to E, and then arranges them in a 3x2 grid using the `ggarrange()` function.


## Packages Used
- `ggplot2`: A popular data visualization package in R.
- `ggpubr`: An R package for creating publication-ready plots with `ggplot2`.

## Installation

You can install `ggplot2` and `ggpubr` from CRAN as follows:

```r
install.packages("ggplot2")
install.packages("ggpubr")
```

## Usage

1. Load the `ggplot2`, `gridExtra` and `ggpubr` packages:

```r
library(ggplot2)
library(ggpubr)
library(gridExtra)
```

2. Create each of the 5 plots:

```r
# Create plot A
p1 <- ggplot(mtcars, aes(x = mpg, y = wt)) + geom_point() + theme_bw() + labs(title = "A)") + theme(plot.title = element_text(hjust = - 0.02))

# Create plot B
p2 <- ggplot(mtcars, aes(x = hp, y = qsec)) + 
  geom_point() + 
  geom_smooth(method = "lm", se = FALSE, color = "red") + 
  labs(x = "Horsepower", y = "Quarter Mile Time") + theme_bw() + labs(title = "B)") + theme(plot.title = element_text(hjust = - 0.02))

# Create plot C
p3 <- ggplot(mtcars, aes(x = factor(gear), fill = factor(gear))) +
  geom_bar() + labs(x = "Number of Cylinders", y = "Count") + theme_bw() + labs(title = "C)") + theme(plot.title = element_text(hjust = - 0.02))

# Create plot D
p4 <- ggplot(mtcars, aes(x = mpg, y = qsec)) + geom_point() + theme_bw() + labs(title = "D)") + theme(plot.title = element_text(hjust = - 0.02))

# Create plot E
p5 <- ggplot(mtcars, aes(x = factor(vs), y = wt, fill = factor(am))) + 
  geom_boxplot() + 
  labs(x = "Engine Type", y = "Weight") + 
  scale_fill_discrete(name = "Transmission", labels = c("Automatic", "Manual")) + theme_bw() + labs(title = "E)") + theme(plot.title = element_text(hjust = - 0.02))

```

3. Arrange the 5 plots in a 3x2 grid using `ggarrange()`:

```r
grid.arrange(
  arrangeGrob(p1, p2, ncol = 2),
  arrangeGrob(p3, p4, ncol = 2),
  arrangeGrob(p5, ncol = 2),
  nrow = 3
)
```

# Output
![Alt Text](output.png)

