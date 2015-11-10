library(data.table)
library(dplyr)
library(ggplot2)
library(reshape2)
library(gridExtra)

setwd('~/code/assemblotron-paper/data/optimisation_simulation/')

dt <- NULL

for (csv in dir(pattern='*/*_scores.csv', recursive = T)) {
  this_dt <- fread(csv)
  rep <- gsub('.*/(.*)_scores.csv', '\\1', csv)
  species <- gsub('(.*)/.*_scores.csv', '\\1', csv)
  this_dt[, rep := rep]
  this_dt[, species := species]
  if (is.null(dt)) {
    dt <- this_dt
  } else {
    dt <- rbind(dt, this_dt)
  }
}

stderr <- function(x) sd(x)/sqrt(length(x))

best <- group_by(dt, species, iteration) %>%
  summarise(mean=mean(best), stderr=stderr(best))
best$type <- 'Best score'
score <- group_by(dt, species, iteration) %>%
  summarise(mean=mean(score), stderr=stderr(score))
score$type <- 'Current score'

score_plot <- rbind(best, score) %>%
  ggplot(aes(x=iteration, y=mean, colour=species,
             ymin=mean-stderr,
             ymax=mean+stderr)) +
  geom_pointrange() +
  xlab('Assemblies performed') +
  ylab('Transrate score (mean +/- stderr over 100 runs)') +
  facet_grid(type~.) +
  theme_bw()

ggsave(plot = score_plot, filename = "../../figures/tabu_optimisation_sim.png")
