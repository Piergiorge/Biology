library(RColorBrewer)
library(ggplot2)

GO <- read.table("plot.txt",header = T, sep = "\t")
darkcols <- brewer.pal(6, "Dark2")

svg("barplot_PPIs.svg",width=28,height=14)
  p <-ggplot(GO, aes(fill=Code, y=N, x=EC)) + geom_bar(stat="identity") + facet_wrap(~Code)
  # Horizontal bar plot
  p + ggtitle("EC vs Interactions") + theme_bw(base_size = 22) + 
  theme(plot.title = element_text(hjust = 0.5), panel.grid.major = element_blank(), panel.grid.minor = element_blank()) + theme(axis.text.x=element_text(angle=45, hjust=1))  + scale_fill_manual("Legend", values = c("I) PPI (Total)" = darkcols[1], "IV) miR (Total)" = darkcols[2], "II) PPI (Shared)" = darkcols[3], "V) miR (Shared)" = darkcols[4], "III) Gene (Cooperation)" = darkcols[5], "VI) miR (Cooperation)" = darkcols[6]))
dev.off()

