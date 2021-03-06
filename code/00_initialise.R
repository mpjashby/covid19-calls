# This file loads the packages and functions necessary to run the scripts for 
# this project.

# install non-CRAN packages
# remotes::install_github("tidyverts/fabletools")

# load packages
library("fable")     # time series analysis
library("furrr")     # parallel processing
library("ggrepel")   # repeal labels in ggplots
library("httr")      # download files
library("lubridate") # handle dates
library("tsibble")   # time series data
library("tidyverse") # wrangle data

# initialise variables
yearFirst <- 2016
yearLast <- 2020
common_vars <- c("city_name", "date_single", "date_year", "cfs_category")



# LOAD COMMON HELPER FUNCTIONS

# Some functions are used across projects, so are loaded from a separate file
source(here::here("../helpers.R"))



# FUNCTIONS

# Add date to data
# This function extracts a date from the data, converts it to a common format
# and creates a new column showing the year (which is needed for filtering 
# later).
add_date_var <- function (data, field_name, date_format, tz) {
  if (!is_tibble(data)) {
    stop("data must be a tibble")
  }
  if (!is.character(field_name)) {
    stop("field_name must be a character string")
  }
  if (!has_name(data, field_name)) {
    stop("field_name must be the name of a column in data")
  }
  if (!is.character(date_format)) {
    stop("date_format must be a character string")
  }
  if (!is.character(tz)) {
    stop("tz must be a character string")
  }
  
  data <- data %>% mutate(
    date_temp = parse_date_time((!!as.name(field_name)), date_format, tz = tz),
    date_year = year(date_temp),
    date_single = strftime(date_temp, format = '%Y-%m-%d %H:%M', tz = tz),
    multiple_dates = FALSE
  ) %>% 
    select(-date_temp)
  
  if (sum(is.na(data$date_single)) > 0) {
    cat("\n✖︎", format(sum(is.na(data$date_single)), big.mark = ","), 
        "dates could not be parsed. Sample of original field:\n")
    data %>% 
      filter(is.na(data$date_single)) %>% 
      sample_n(ifelse(sum(is.na(data$date_single)) > 10, 10, 
                      sum(is.na(data$date_single)))) %>% 
      { print(.[[field_name]]) }
  } else {
    cat("✔︎ All dates parsed\n")
  }
  
  data
  
}

# Filter data by year
filter_by_year <- function (data, year_first, year_last) {
  if (!is_tibble(data)) {
    stop("data must be a tibble")
  }
  if (!has_name(data, "date_year")) {
    stop("data must include a column named 'date_year'")
  }
  if (!is.numeric(year_first) | !is.numeric(year_last)) {
    stop("year_first and year_last must be integers")
  }
  
  year_range <- range(data$date_year, na.rm = TRUE)
  
  cat("Original data includes", format(nrow(data), big.mark = ","), 
      "calls between", year_range[1], "and", year_range[2], "\n")
  
  filtered_data <- data %>% 
    filter(date_year >= year_first & date_year <= year_last)
  
  year_range <- range(filtered_data$date_year)
  
  cat(format(nrow(data) - nrow(filtered_data), big.mark = ","), 
      "rows removed", "\nFiltered data includes", 
      format(nrow(filtered_data), big.mark = ","), "calls between", 
      year_range[1], "and", year_range[2], "\n")
  
  if (min(table(filtered_data$date_year)) < 1000) {
    warning("✖ Some years have fewer than 1,000 calls\n")
    print(table(filtered_data$date_year))
  }
  
  filtered_data
  
}

# Convert small integers to text
number_to_text <- function (x, ...) {
  
  if (length(x) != 1 | !is.numeric(x)) {
    stop("number_to_text() can only convert a single number")
  }
  
  if (x == round(x) & x >= 0 & x <= 10) {
    dplyr::recode(x, `1` = "one", `2` = "two", `3` = "three", `4` = "four",
                  `5` = "five", `6` = "six", `7` = "seven", `8` = "eight",
                  `9` = "nine", `10` = "ten")
  } else {
    scales::comma(x, ...)
  }
  
}

# Convert vector of city names to text, removing state abbreviation
city_vector_to_text <- function (x) {
  
  # vector_to_text() is defined in helpers.R
  
  vector_to_text(str_remove(x, "\\, \\w{2}$"))
  
}

