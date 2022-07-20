
library(tidyverse)

# load FPG excel as a temporary file
httr::GET("https://aspe.hhs.gov/sites/default/files/documents/04fc28a4c7b3c1b55a11e0e825d19656/Guidelines-2022.xlsx", 
          httr::write_disk(path <- tempfile(fileext = ".xlsx")))

# read in the FPG excel file and perform preliminary cleaning
fpg_2022 <- readxl::read_xlsx(path, skip = 2, n_max = 15) %>% 
  rename(`Household Size` = 1)

# rename column names
col_vals <- as.numeric(colnames(fpg_2022)[2:length(fpg_2022)]) * 100
  
# implement the renamed column names
fpg <- fpg_2022 %>% 
  rename_at(vars(2:length(.)), ~ as.character(col_vals))

