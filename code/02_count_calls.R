# COUNT CALLS IN EACH CITY

# initialise project if necessary
if (!exists("mutate")) {
  source(here::here("code/00_initialise.R"))
} else {
  message("Project already initialised")
}



# load calls data
calls_data <- read_csv(here::here("analysis_data/calls_data.csv.gz"))



# count calls by priority
call_counts_total <- calls_data %>% 
  # remove time portion from date, so it can be used in count()
  mutate(date = date(date_single)) %>% 
  # calculate crimes per day
  count(city_name, date, name = "calls") %>% 
  mutate(category = "total calls")

  

# count calls by category, including priority counts
call_counts <- calls_data %>%
  rename(category = cfs_category) %>% 
  # remove time portion from date, so it can be used in count()
  mutate(date = date(date_single)) %>% 
  # remove crimes not needed
  filter(!is.na(category)) %>%
  # calculate crimes per day
  count(city_name, category, date, name = "calls") %>% 
  # add counts of calls by priorities
  bind_rows(call_counts_total) %>% 
  # fill any gaps in the time series
  as_tsibble(key = c(city_name, category), index = date) %>% 
  fill_gaps(calls = 0) %>% 
  # add if date is holiday
  mutate(
    holiday = date %in% as_date(timeDate::holidayNYSE(year = 2016:2020)),
    week = yearweek(date)
  ) %>% 
  as_tibble() %>% 
  group_by(city_name, category, week) %>%
  summarise(
    calls = sum(calls), 
    days_in_week = length(unique(date)), 
    holidays = sum(holiday),
    # Indicate whether data are missing for that week. Since the call types are
    # all very frequent, we can do this by simply marking data as missing if
    # there are no calls in a category for a given week.
    missing = calls == 0
  ) %>% 
  ungroup() %>% 
  mutate(
    # Indicate whether data from LA are before or after Jan 2019, when LAPD
    # began recording several types of proactive call that were not previously
    # recorded.
    la_proactive = city_name == "Los Angeles, CA" & week > ymd("2018-12-31")
  ) %>% 
  # remove incomplete weeks
  filter(days_in_week == 7) %>% 
  # Remove city-category combinations that time-series plots have shown have
  # missing data or sudden changes likely to be indicative of changes in 
  # recording practice. This is done by filtering for the excluded combinations
  # and then negating that filter using !(). At the same time we remove 
  # combinations with a median of fewer than 10 calls per week.
  filter(!(
    # problematic combinations
    city_name == "Cincinnati, OH" & category == "dropped/silent call to 911" | 
      city_name == "Los Angeles, CA" & category == "missing person" | 
      city_name == "Nashville, TN" & category == "medical emergency" | # not recorded from 2018 onwards
      city_name == "New Orleans, LA" & category == "traffic stop" | 
      city_name == "Sacramento, CA" & category == "sudden death" |
      city_name == "San Jose, CA" & category == "dropped/silent call to 911" | # only recorded after mid-2017
      city_name == "San Jose, CA" & category == "medical emergency" | # not recorded from 2018 onwards
      # rare combinations
      city_name == "Baltimore, MD" & category == "sudden death" |
      city_name == "Baltimore, MD" & category == "trespassing" |
      city_name == "Seattle, WA" & category == "shooting/shots fired" |
      city_name == "Sacramento, CA" & category == "directed/hotspot patrol" |
      city_name == "Sacramento, CA" & category == "shoplifting" |
      city_name == "Sonoma County, CA" & category == "driving while impaired" |
      city_name == "Sonoma County, CA" & category == "drugs" |
      city_name == "Sonoma County, CA" & category == "medical emergency" |
      city_name == "Sonoma County, CA" & category == "robbery" |
      city_name == "Sonoma County, CA" & category == "vehicle theft" |
      city_name == "St Petersburg, FL" & category == "driving while impaired" |
      city_name == "St Petersburg, FL" & category == "shoplifting" |
      city_name == "St Petersburg, FL" & category == "sudden death"
  )) %>% 
  select(-days_in_week) %>% 
  # export data
  write_rds(here::here("analysis_data/call_counts.rds"))



# report when data was updated for each city
call_counts %>% 
  group_by(city_name) %>%
  summarise(last_date = as_date(max(week))) %>% 
  arrange(last_date)



# check for rare combinations of city and category
call_counts %>% 
  as_tibble() %>% 
  group_by(city_name, category) %>% 
  summarise(calls = mean(calls)) %>% 
  arrange(calls)
