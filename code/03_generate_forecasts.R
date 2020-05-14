# GENERATE FORECASTS

# initialise project if necessary
if (!exists("mutate")) {
  source(here::here("code/00_initialise.R"))
} else {
  message("Project already initialised")
}

# load crime counts
call_counts <- here::here("analysis_data/call_counts.rds") %>% 
  read_rds() %>% 
  as_tsibble(key = c(city_name, category), index = week) %>% 
  fill_gaps(calls = 0) %>% 
  # remove days in week before first full week of 2016
  filter(week >= ymd("2016-01-01"))

# estimate models, if none exist
if (!file.exists(here::here("analysis_data/call_models.RData"))) {
  
  now()
  
  future::plan(multiprocess)
  
  call_models <- call_counts %>% 
    filter(week < ymd("2020-01-20")) %>% 
    group_by(city_name, category) %>% 
    group_nest(keep = TRUE) %>% 
    pluck("data") %>% 
    future_map(function (x) {
      
      # convert data to tsibble (since nest() converts to tibble)
      x <- as_tsibble(x, key = c(city_name, category), index = week)
      
      # model data
      if (any(x$missing)) {
        y <- model(
          x, 
          arima = ARIMA(calls ~ trend() + season() + holidays + missing)
        )
      } else if (any(x$la_proactive)) {
        y <- model(
          x, 
          arima = ARIMA(calls ~ trend() + season() + holidays + la_proactive)
        )
      } else {
        y <- model(
          select(x, -missing), 
          arima = ARIMA(calls ~ trend() + season() + holidays)
        )
      }
      
      y
      
    }, .progress = TRUE)
  
  # save models
  save(call_models, file = here::here("analysis_data/call_models.RData"))
  
  now()
  
  
} else {
  
  # load existing models
  load(here::here("analysis_data/call_models.RData"))
  
}



# generate data for forecasts
forecast_data <- expand.grid(
  city_name = unique(call_counts$city_name),
  category = unique(call_counts$category),
  date = seq.Date(
    ymd("2020-01-20"), 
    ymd("2020-01-20") + 
      weeks(as.integer(difftime(now(), ymd("2020-01-20"), units = "weeks")) + 2), 
    by = "days"
  ),
  stringsAsFactors = FALSE
) %>% 
  mutate(
    holiday = date %in% as_date(timeDate::holidayNYSE(year = 2016:2020)),
    week = yearweek(date)
  ) %>% 
  group_by(city_name, category, week) %>% 
  summarise(holidays = sum(holiday)) %>% 
  ungroup() %>% 
  mutate(
    la_proactive = city_name == "Los Angeles, CA",
    missing = FALSE
  ) %>% 
  as_tsibble(key = c(city_name, category), index = week)



# generate forecasts
call_forecasts <- map(call_models, forecast, forecast_data)
  


# save forecasts
write_rds(call_forecasts, here::here("analysis_data/call_forecasts.rds"))

