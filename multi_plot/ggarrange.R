library(ggplot2)
library(ggpubr)

# Creation of the first plot
p1 <- ggplot(mtcars, aes(x = mpg, y = wt)) + geom_point() + theme_bw() + labs(title = "A)") + theme(plot.title = element_text(hjust = - 0.1))

# Creation of the second plot
p2 <- ggplot(mtcars, aes(x = mpg, y = qsec)) + geom_point() + theme_bw() + labs(title = "B)") + theme(plot.title = element_text(hjust = - 0.1))

# Creation of the third plot
p3 <- ggplot(mtcars, aes(x = hp, y = qsec)) + 
  geom_point() + 
  geom_smooth(method = "lm", se = FALSE, color = "red") + 
  labs(x = "Horsepower", y = "Quarter Mile Time") + theme_bw() + labs(title = "D)") + theme(plot.title = element_text(hjust = - 0.1))

# Creation of the fourth plot
p4 <- ggplot(mtcars, aes(x = factor(gear), fill = factor(gear))) +
  geom_bar() + labs(x = "Number of Cylinders", y = "Count") + theme_bw() + labs(title = "E)") + theme(plot.title = element_text(hjust = - 0.1))

# Creation of the fifth plot
p5 <- ggplot(mtcars, aes(x = factor(vs), y = wt, fill = factor(am))) + 
  geom_boxplot() + 
  labs(x = "Engine Type", y = "Weight") + 
  scale_fill_discrete(name = "Transmission", labels = c("Automatic", "Manual")) + theme_bw() + labs(title = "C)") + theme(plot.title = element_text(hjust = - 0.1))

# Arrange the plots in a panel side by side
ggarrange(p1, p2, p3, p4, p5, nrow = 3, ncol = 2)
