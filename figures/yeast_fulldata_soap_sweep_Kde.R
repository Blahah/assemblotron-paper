library(data.table)
library(dplyr)
library(ggplot2)
library(reshape2)

setwd('~/code/assemblotron-paper/data/yeast/')
d1 <- fread('yeast_stream_100pc_1.csv')
d2 <- fread('yeast_stream_100pc_2.csv')
d3 <- fread('yeast_stream_100pc_3.csv')
stderr <- function(x) sd(x)/sqrt(length(x))
all <- as.data.table(d1) %>%
  mutate(score2 = d2$score,
         score3 = d3$score) %>%
  group_by(K, d, e) %>%
  summarise(mean=mean(score, score2, score3),
            stderr=stderr(c(score, score2, score3))) %>%
  melt(id.vars = c('score', 'score2', 'score3')) %>%


ggplot(all, aes(x=as.factor(value), y=score, group=value)) +
  geom_violin(fill="white") +
  geom_point(position=position_jitter(width=0.2)) +
  facet_grid(.~variable, scales="free") +
  theme(strip.text.x = element_text(size = 18)) +
  xlab("Value") +
  ylab("Transrate score")
ggsave('~/code/phd/figures/yeast_fulldata_soap_sweep_Kde.png')

