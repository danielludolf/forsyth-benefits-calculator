
library(rJava)
library(tabulizer)
library(tabulizerjars)
library(tidyverse)

# link to NC's Subsidized Child Care Market Rates for Child Care Centers Effective October 1, 2018
file <- "https://ncchildcare.ncdhhs.gov/Portals/0/documents/pdf/R/Revised-8-16-Market_Rate_Centers_Eff-10-1-18.pdf?ver=2018-08-28-105655-863"

# extract table area we need
coords <- locate_areas(file, pages = 1)

# extract and output data frame based on the table's area we found above
tables <- extract_tables(file = file, area = coords, guess = F, method = "decide", output = "data.frame")

# clean and combine all counties together into one data frame
dat <- tables %>% 
  map(~ .x %>% 
        pivot_longer(cols = One.Star:Five.Star.3, names_to = "Star Rating", values_to = "Market Rates") %>% 
        mutate(`Age Group` = case_when(
          grepl("1", `Star Rating`) == T ~ "2 Year Old Rates",
          grepl("2", `Star Rating`) == T ~ "3-5 Year Old Rates",
          grepl("3", `Star Rating`) == T ~ "School Age Rates"),
          `Age Group`= ifelse(is.na(`Age Group`), "Infant - Toddler Rates", `Age Group`),
          `Star Rating` = str_trim(gsub("\\.|[0-9]", " ", `Star Rating`)),
          `Market Rates` = as.numeric(gsub("\\$|\\,", "", `Market Rates`))) %>% 
        rename(County = X) %>% 
        relocate(`Age Group`, .before = `Star Rating`)
        ) %>% 
  reduce(bind_rows)

