library(ggplot2)
library(stringr)
library(ggpubr)
library(tidyverse)

# nifH world map

world_coordinates <- map_data("world") 

ggplot() + geom_map(data = world_coordinates, map = world_coordinates, 
  aes(long, lat, map_id = region), fill = "darkgray") + theme_classic() +
  geom_point(data = nifh_map, aes(long, lat), alpha = 1, size = 4, color = "orange")

#% recruitment plot and % detection (made the same way)

group.fill <- c(ALANI8 = "orange", WH0003 = "tan")

bins_percent_recruitment %>%
  ggplot(aes(x = dates, y = RECRUIT, fill= GROUP)) + geom_bar(stat = "identity", position = "dodge", width = 1) +
  labs(x = "", y = "", 
       fill = "group", border = "white") + theme_classic() + 
  theme(axis.text.x = element_text(angle = 90, vjust = 1, hjust=1)) + 
  scale_fill_manual(values=group.fill)

# Prior to plotting in RStudio, I ordered samples by increasing temperature in excel and created a new column 
#called "accessions_3" with TaraOceans metagenome accession numbers ordered 1-20 by increasing temperature.

# I then plotted temperature separately with the same x-axis (accession_3) and overlaid the plots

group.fill2 <- c(WH0401 = "tan", cpsb_1 = "cornflowerblue", aloha = "lightblue2", cwater = "orange")

ggplot(mean_coverage_shallow_mg, aes(x = accession_3, y = mean_coverage, fill = bins)) + 
  geom_bar(stat = "identity", position = "dodge", width = 1) +
  labs(x = "sample", y = "% total mean coverage", color = "group", fill = "bins", border = "white") + theme_classic() + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + 
  scale_fill_manual(values=group.fill2) + facet_wrap(~bins, scales = "free")

ggplot(mean_coverage_shallow_mg, aes(x=accession_3, y=temperature)) + 
  geom_point(size = 3) + geom_line() + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
