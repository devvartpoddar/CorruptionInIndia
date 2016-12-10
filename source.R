# Source code file for Final paper on Corruption

# Intialisation
rm(list = ls())
pkgs <- c("dplyr", "magrittr", "methods", "rvest", "stringi", "rio", "ggplot2",
  "data.table", "wordnet", "tm", "koRpus")

load <- sapply(pkgs, function(x) {
    suppressPackageStartupMessages(
      require(x, character.only = TRUE)
    )
  }
)
rm(load, pkgs)

# Setting the working directory
try(setwd("/home/devvart/Desktop/CorruptionInIndia"))

# Combining raw csv files
source("Rscripts/file-combine.R")

# Scraping all text from web
source("Rscripts/web-scrape.R")
