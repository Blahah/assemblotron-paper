#! /usr/bin/env RScript

# usage: ./produce_figures.R
# generates paper figures

# get list of figure code files
figures <- dir(".", pattern = "\\.R", full.names = TRUE, ignore.case = TRUE)

# don't load this file
figures <- figures[which(figures != sys.frame(1)$ofile)]

# preload
library(ggplot2)
library(reshape2)

# generate the figures
sapply(figures, source)

# friendly message
print(paste(length(files), 'figures generated', sep=' '))
