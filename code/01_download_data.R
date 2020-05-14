# This file downloads data from the city website for each city and extracts the
# calls for service categories we are interested in, since there are too many
# categories to harmonise them all.
# The call types we are interested in are:
#  1. **alarm**
#  2. **assault**
#  3. **burglary*
#  4. **directed/hotspot patrol**
#  5. disturbance (including noise nuisance etc)
#  6. domestic violence/family dispute
#  7. driving while impaired
#  8. dropped 911 call
#  9. **drugs possession/supply/use**
# 10. mental health/concern for safety/welfare
# 11. missing person
# 12. **pedestrian stop**
# 13. **robbery**
# 14. shooting/shots fired (not ShotSpotter)
# 15. **shoplifting**
# 16. sudden death
# 17. suspicious person/vehicle
# 18. traffic collision
# 19. traffic stop
# 20. **trespassing**
# 21. **vehicle theft**



# initialise project if necessary
if (!exists("mutate")) {
  source(here::here("code/00_initialise.R"))
} else {
  message("Project already initialised")
}

# create tibble of data URLs
data_urls <- tribble(
  ~city, ~url,
  "Baltimore", "https://data.baltimorecity.gov/api/views/xviu-ezkt/rows.csv?accessType=DOWNLOAD",
  
  "Cincinnati", "https://data.cincinnati-oh.gov/api/views/gexm-h6bt/rows.csv?accessType=DOWNLOAD",
  
  # "Los Angeles 2016", "https://data.lacity.org/api/views/xwgr-xw5q/rows.csv?accessType=DOWNLOAD",
  # "Los Angeles 2017", "https://data.lacity.org/api/views/ryvm-a59m/rows.csv?accessType=DOWNLOAD",
  # "Los Angeles 2018", "https://data.lacity.org/api/views/nayp-w2tw/rows.csv?accessType=DOWNLOAD",
  # "Los Angeles 2019", "https://data.lacity.org/api/views/r4ka-x5je/rows.csv?accessType=DOWNLOAD",
  "Los Angeles 2020", "https://data.lacity.org/api/views/84iq-i2r6/rows.csv?accessType=DOWNLOAD",
  
  # "Nashville 2016", "https://data.nashville.gov/api/views/g2k4-yps7/rows.csv?accessType=DOWNLOAD",
  # "Nashville 2017", "https://data.nashville.gov/api/views/7wd6-tamg/rows.csv?accessType=DOWNLOAD",
  # "Nashville 2018", "https://data.nashville.gov/api/views/kqb6-kd6q/rows.csv?accessType=DOWNLOAD",
  # "Nashville 2019", "https://data.nashville.gov/api/views/h92w-r6hq/rows.csv?accessType=DOWNLOAD",
  "Nashville 2020", "https://data.nashville.gov/api/views/nhhg-pnxf/rows.csv?accessType=DOWNLOAD",

  # "New Orleans 2016", "https://data.nola.gov/api/views/wgrp-d3ma/rows.csv?accessType=DOWNLOAD",
  # "New Orleans 2017", "https://data.nola.gov/api/views/bqmt-f3jk/rows.csv?accessType=DOWNLOAD",
  # "New Orleans 2018", "https://data.nola.gov/api/views/9san-ivhk/rows.csv?accessType=DOWNLOAD",
  # "New Orleans 2019", "https://data.nola.gov/api/views/qf6q-pp4b/rows.csv?accessType=DOWNLOAD",
  "New Orleans 2020", "https://data.nola.gov/api/views/hp7u-i9hf/rows.csv?accessType=DOWNLOAD",
  
  # "Phoenix 2016", "https://www.phoenixopendata.com/dataset/64a60154-3b2d-4583-8fb5-6d5e1b469c28/resource/d53e8f3f-2ce5-4e58-b03d-fe3721c9354e/download/calls-for-service2016-calls-for-servicecallsforsrvc2016.csv",
  # "Phoenix 2017", "https://www.phoenixopendata.com/dataset/64a60154-3b2d-4583-8fb5-6d5e1b469c28/resource/14435329-45ff-4584-8eda-5218b52cca56/download/calls-for-service2017-calls-for-servicecallsforsrvc2017.csv",
  # "Phoenix 2018", "https://www.phoenixopendata.com/dataset/64a60154-3b2d-4583-8fb5-6d5e1b469c28/resource/30a4d911-41a3-4d4a-a817-ade6f12b8131/download/callsforsrvc2018.csv",
  # "Phoenix 2019", "https://www.phoenixopendata.com/dataset/64a60154-3b2d-4583-8fb5-6d5e1b469c28/resource/7edc831c-9167-41a9-9b7b-61a167cb9739/download/callsforsrvc2019.csv",
  "Phoenix 2020", "https://www.phoenixopendata.com/dataset/64a60154-3b2d-4583-8fb5-6d5e1b469c28/resource/3c0ae3ec-456f-45f4-801d-b8d6699ba32e/download/callsforsrvc2020.csv",
  
  # "Sacramento 2016", "https://opendata.arcgis.com/datasets/4bdb47c80f844d779795f62b35b83984_0.csv",
  # "Sacramento 2017", "https://opendata.arcgis.com/datasets/d6c26871b5ca46dca132c7707d9e80e8_0.csv",
  # "Sacramento 2018", "https://opendata.arcgis.com/datasets/1692315bba964832b235a76755928c06_0.csv",
  # "Sacramento 2019", "https://opendata.arcgis.com/datasets/396e0bc72dcd4b038206f4a7239792bb_0.csv",
  # "Sacramento 2020", "https://opendata.arcgis.com/datasets/9efe7653009b448f8d177c1da0cc068f_0.csv",
  
  # "San Diego 2016", "http://seshat.datasd.org/pd/pd_calls_for_service_2016_datasd_v1.csv",
  # "San Diego 2017", "http://seshat.datasd.org/pd/pd_calls_for_service_2017_datasd_v1.csv",
  # "San Diego 2018", "http://seshat.datasd.org/pd/pd_calls_for_service_2018_datasd.csv",
  # "San Diego 2019", "http://seshat.datasd.org/pd/pd_calls_for_service_2019_datasd.csv",
  "San Diego 2020", "http://seshat.datasd.org/pd/pd_calls_for_service_2020_datasd.csv",
  
  # "San Jose 2016", "https://data.sanjoseca.gov/dataset/c5929f1b-7dbe-445e-83ed-35cca0d3ca8b/resource/92bb6e3f-8e11-4c51-b232-911dc618604a/download/policecalls2016.csv",
  # "San Jose 2017", "https://data.sanjoseca.gov/dataset/c5929f1b-7dbe-445e-83ed-35cca0d3ca8b/resource/80093bd5-386a-4345-b7c0-5877ffd6a6c4/download/policecalls2017.csv",
  # "San Jose 2018", "https://data.sanjoseca.gov/dataset/c5929f1b-7dbe-445e-83ed-35cca0d3ca8b/resource/355c3448-b90c-4955-9321-e78e2396648b/download/policecalls2018.csv",
  # "San Jose 2019", "https://data.sanjoseca.gov/dataset/c5929f1b-7dbe-445e-83ed-35cca0d3ca8b/resource/d0bb4502-2ee2-49c7-afbd-7692dcc3e692/download/policecalls2019.csv",
  "San Jose 2020", "https://data.sanjoseca.gov/dataset/c5929f1b-7dbe-445e-83ed-35cca0d3ca8b/resource/aa926acb-63e0-425b-abea-613d293b5b46/download/policecalls2020.csv",
  
  "Seattle", "https://data.seattle.gov/api/views/33kz-ixgy/rows.csv?accessType=DOWNLOAD",
  
  "Sonoma County", "https://data.sonomacounty.ca.gov/api/views/bpq8-s7gr/rows.csv?accessType=DOWNLOAD",
  
  "St Petersburg", "https://stat.stpete.org/api/views/2eks-pg5j/rows.csv?accessType=DOWNLOAD"
) %>% 
  mutate(string = str_to_lower(str_replace_all(city, "\\s", "_")))



# download data
walk2(data_urls$string, data_urls$url, function (string, url) {

  message(glue::glue("\n\nDownloading {string} data from {url}"))

  raw_data_file <- glue::glue("original_data/raw_{string}.csv")

  GET(url, write_disk(raw_data_file, overwrite = TRUE), progress())

})



# process Baltimore data, updated more than once per day
# https://data.baltimorecity.gov/Public-Safety/911-Police-Calls-for-Service/xviu-ezkt
# includes call priority (high, medium, low, non-emergency) and free-text description
# descriptions for call priorities on page 44 of https://www.baltimorepolice.org/sites/default/files/General%20Website%20PDFs/BPD%20Staffing%20Study%20Report%20for%20Website.pdf
message("Processing Baltimore data")
here::here("original_data/raw_baltimore.csv") %>% 
  read_csv(col_types = cols(.default = col_character())) %>% 
  janitor::clean_names() %>% 
  # add date variable
  add_date_var("call_date_time", "mdY IMS p", "America/New_York") %>% 
  # remove offenses before start date
  filter_by_year(yearFirst, yearLast) %>%
  # identify calls of interest
  mutate(
    description = str_replace_all(str_to_lower(description), "\\W+", " "),
    cfs_category = case_when(
      str_detect(description, "(audible|holdup|silent) alarm") ~ "intruder alarm",
      str_detect(description, "assault") ~ "assault",
      str_detect(description, "burglary") ~ "burglary",
      description %in% c("hot spot check", "foot patrol") ~ 
        "directed/hotspot patrol",
      str_detect(description, "^disord") | str_detect(description, "^dispu") | 
        str_detect(description, "^disturb") | 
        str_detect(description, "^juv disturb") |
        str_detect(description, "^loud") | str_detect(description, "^noise") |
        str_detect(description, "^vehicle disturb") ~ "disturbance",
      str_detect(description, "^dwi") ~ "driving while impaired",
      str_detect(description, "^91") ~ "dropped/silent call to 911",
      str_detect(description, "narcotics") ~ "drugs",
      str_detect(description, "^family dis") 
      ~ "domestic violence/family dispute",
      str_detect(description, "\\bsick\\b") ~ "medical emergency",
      str_detect(description, "^behavior crisis") |
        str_detect(description, "^behaviorl crisis") |
        str_detect(description, "^well") | str_detect(description, "well bei") | 
        str_detect(description, "wellbei") | str_detect(description, "^lying") | 
        str_detect(description, "^mental") ~ "mental health/concern for safety",
      description == "missing person" ~ "missing person",
      str_detect(description, "robbery") ~ "robbery",
      str_detect(description, "\\bshooting\\b") ~ "shooting/shots fired",
      str_detect(description, "^doa") ~ "sudden death",
      str_detect(description, "^susp") ~ "suspicious person/vehicle",
      str_detect(description, "^auto acc") | description == "hit and run" ~ 
        "traffic collision",
      description == "traffic stop" ~ "traffic stop",
      str_detect(description, "trespass") ~ "trespassing",
      str_detect(description, "auto theft") ~ "vehicle theft",
      TRUE ~ NA_character_
    ),
    emergency = priority == "High"
  ) %>%
  # add city name
  mutate(city_name = "Baltimore, MD") %>%
  # select core variables
  select(one_of(common_vars)) %>%
  # save data
  write_rds(here::here("analysis_data/calls_data_baltimore.rds"), 
            compress = "gz")



# process Cincinnati data, updated daily
# https://data.cincinnati-oh.gov/Safety/PDI-Police-Data-Initiative-Police-Calls-for-Servic/gexm-h6bt
# includes call priority (with some missing), categories and result
message("Processing Cincinnati data")
here::here("original_data/raw_cincinnati.csv") %>%
  read_csv(col_types = cols(.default = col_character())) %>%
  janitor::clean_names() %>% 
  # add date variable
  add_date_var("create_time_incident", "mdY IMS p", "America/Chicago") %>% 
  # remove offenses before start date
  filter_by_year(yearFirst, yearLast) %>%
  # identify calls of interest
  mutate(
    cfs_category = case_when(
      incident_type_id %in% c("HOLDUP", "AWAREJ", "NRBURG", "RALARM", "RBURG") ~ 
        "intruder alarm",
      incident_type_id %in% c("ASSLT", "ASSLTI", "ASSLTP", "ASSLTP-COMBINED", 
                              "ASSLTR") ~ "assault",
      incident_type_id %in% c("RBURG", "NRBURG") ~ "burglary",
      incident_type_id %in% c("DIRPAM", "DIRPAT", "DIRPAW", "DIRVCT", "UDIRPT") 
      ~ "directed/hotspot patrol",
      incident_type_id %in% c("DRUG", "DRUGR") ~ "drugs",
      incident_type_id == "SS" ~ "pedestrian stop",
      str_detect(incident_type_id, "^ROBB") ~ "robbery",
      incident_type_id == "TRESP" ~ "trespassing",
      incident_type_id %in% c("AUTO", "AUTOR") ~ "vehicle theft",
      incident_type_id %in% c("CROWD", "DISORD", "FIGHT", "NBRTRB", "NOISE") 
      ~ "disturbance",
      incident_type_id %in% c("911CALL", "911EMER", "CELL", "DISCON", "SICALL") 
      ~ "dropped/silent call to 911",
      str_detect(incident_type_id, "^DOM") | 
        incident_type_id == "^FAMTRB" ~ "domestic violence/family dispute",
      str_detect(incident_type_id, "SICK") ~ "medical emergency",
      incident_type_id %in% c("MHRT", "MHRTV", "PERDWN", "PERDWP-COMBINED") 
      ~ "mental health/concern for safety",
      str_detect(incident_type_id, "MISS") ~ "missing person",
      str_detect(incident_type_id, "^SHOOT") ~ "shooting/shots fired",
      str_detect(incident_type_id, "^PDOA") ~ "sudden death",
      incident_type_id %in% c("SUSP") ~ "suspicious person/vehicle",
      str_detect(incident_type_id, "^ACC") ~ "traffic collision",
      incident_type_id %in% c("TS", "TSTOP") ~ "traffic stop",
      TRUE ~ NA_character_
    )
  ) %>%
  # add city name
  mutate(city_name = "Cincinnati, OH") %>%
  # select core variables
  select(one_of(common_vars)) %>%
  # save data
  write_rds(here::here("analysis_data/calls_data_cincinnati.rds"), 
            compress = "gz")



# process Los Angeles data, updated weekly
# https://data.lacity.org/browse?category=A+Safe+City&limitTo=datasets&q=LAPD+Calls+For+Service&sortBy=relevance&utf8=✓
# includes call description
message("Processing Los Angeles data")
dir(path = "original_data", pattern = "raw_los_angeles", full.names = TRUE) %>% 
  map(read_csv, col_types = cols(.default = col_character())) %>%
  map(janitor::clean_names) %>% 
  # harmonise variable names across years
  map_dfr(function (x) {
    if ("area_occurred" %in% names(x)) {
      rename(x, area_occ = area_occurred, rpt_dist = reporting_district,
             call_type_text = call_type_description)
    } else {
      x
    }
  }) %>% 
  # add date variable
  mutate(dispatch_date = paste(
    date(parse_date_time(dispatch_date, orders = c("mdY", "mdY IMS p"))), 
    dispatch_time
  )) %>% 
  add_date_var("dispatch_date", "Ymd T", "America/Los_Angeles") %>% 
  # remove offenses before start date
  filter_by_year(yearFirst, yearLast) %>%
  # identify calls of interest
  mutate(
    cfs_category = case_when(
      # check for shooting description first because some shootings are coded in
      # other categories
      str_detect(call_type_text, "\\bSHOTS\\b") ~ "shooting/shots fired",
      # check for domestic violence first because it is a sub-type of assault
      str_detect(call_type_code, "^207D") | 
        str_detect(call_type_code, "^242AD") | 
        str_detect(call_type_code, "^242D") | 
        str_detect(call_type_code, "^245AD") | 
        str_detect(call_type_code, "^245D") | 
        str_detect(call_type_code, "^6201") | 
        str_detect(call_type_code, "^620D") | 
        str_detect(call_type_code, "^620F") | 
        str_detect(call_type_code, "^620M") 
      ~ "domestic violence/family dispute",
      str_detect(call_type_code, "^906") ~ "intruder alarm",
      str_detect(call_type_code, "^242") | str_detect(call_type_code, "^245") ~ 
        "assault",
      str_detect(call_type_code, "^459") | str_detect(call_type_code, "^906") ~ 
        "burglary",
      str_detect(call_type_code, "^110") ~ "drugs",
      str_detect(call_type_code, "^211") ~ "robbery",
      str_detect(call_type_code, "^9212") ~ "trespassing",
      str_detect(call_type_code, "^4591") | str_detect(call_type_code, "^5032") 
      | str_detect(call_type_code, "^5033") ~ "vehicle theft",
      str_detect(call_type_code, "^415") | 
        str_detect(call_type_code, "^507") | 
        str_detect(call_type_code, "^620N") ~ "disturbance",
      str_detect(call_type_code, "^904.*6$") ~ "driving while impaired",
      str_detect(call_type_code, "^907") | str_detect(call_type_code, "^929") ~ 
        "medical emergency",
      str_detect(call_type_code, "^918") ~ "mental health/concern for safety",
      call_type_code == "920" ~ "missing person",
      str_detect(call_type_code, "^927") ~ "sudden death",
      str_detect(call_type_code, "^242S") ~ "suspicious person/vehicle",
      str_detect(call_type_code, "^904") ~ "traffic collision",
      str_detect(call_type_code, "^902") ~ "traffic stop",
      TRUE ~ NA_character_
    )
  ) %>%
  # add city name
  mutate(city_name = "Los Angeles, CA") %>%
  # select core variables
  select(one_of(common_vars)) %>%
  # save data
  write_rds(here::here("analysis_data/calls_data_los_angeles.rds"), 
            compress = "gz")



# process Nashville data, updated daily
# https://data.nashville.gov/Police/Metro-Nashville-Police-Department-Calls-for-Servic/nhhg-pnxf
# data dictionary: https://data.nashville.gov/api/views/nhhg-pnxf/files/bd380cea-a728-45c9-aea9-42ed44bb691e?download=true&filename=Metro-Nashville-and-Davidson-County-Calls-for-Service-2020-Metadata-v2.pdf
# includes call description and disposition
dir(path = "original_data", pattern = "raw_nashville", full.names = TRUE) %>% 
  map_dfr(read_csv, col_types = cols(.default = col_character())) %>%
  janitor::clean_names() %>% 
  # add date variable
  add_date_var("call_received", "mdY IMS p", "America/Chicago") %>% 
  # remove offenses before start date
  filter_by_year(yearFirst, yearLast) %>%
  # identify calls of interest
  mutate(
    cfs_category = case_when(
      tencode_suffix == "A" ~ "intruder alarm",
      tencode %in% c("51", "57") ~ "assault",
      tencode %in% c("70", "71") ~ "burglary",
      tencode_suffix == "TS" ~ "pedestrian stop",
      tencode == "53" ~ "robbery",
      tencode %in% c("42", "44") ~ "disturbance",
      tencode == "88" ~ "dropped/silent call to 911",
      tencode == c("35", "63") ~ "mental health/concern for safety",
      tencode == "75" ~ "missing person",
      tencode == c("52", "83") ~ "shooting/shots fired",
      tencode == "64" ~ "sudden death",
      tencode == "40" ~ "suspicious person/vehicle",
      tencode %in% c("45", "46") ~ "traffic collision",
      tencode == "93" ~ "traffic stop",
      TRUE ~ NA_character_
    )
  ) %>%
  # add city name
  mutate(city_name = "Nashville, TN") %>%
  # select core variables
  select(one_of(common_vars)) %>%
  # save data
  write_rds(here::here("analysis_data/calls_data_nashville.rds"), 
            compress = "gz")



# process New Orleans data, updated daily
# https://data.nola.gov/Public-Safety-and-Preparedness/Call-for-Service-2020/hp7u-i9hf
# data dictionary: https://data.nola.gov/api/views/hp7u-i9hf/files/722e7c76-1176-4976-b4be-6df24399f545?download=true&filename=NOPD_-_Data_dictionary_for_Calls_For_Service_Open_Data.xlsx
# includes call origin, priority, description and disposition
message("Processing New Orleans data")
dir(path = "original_data", pattern = "raw_new_orleans", full.names = TRUE) %>% 
  map_dfr(read_csv, col_types = cols(.default = col_character())) %>%
  janitor::clean_names() %>% 
  # add date variable
  add_date_var("time_create", "mdY IMS p", "America/Chicago") %>% 
  # remove offenses before start date
  filter_by_year(yearFirst, yearLast) %>% 
  # identify calls of interest
  mutate(
    cfs_category = case_when(
      str_detect(type_text, "ALARM") ~ "intruder alarm",
      type_text %in% c("AGGRAVATED ASSAULT", "SIMPLE ASSAULT") ~ "assault",
      type_text %in% c("RESIDENCE BURGLARY", "SIMPLE BURGLARY", 
                       "BUSINESS BURGLARY", "AGGRAVATED BURGLARY") ~ "burglary",
      type_text == "DIRECTED PATROL" ~ "directed/hotspot patrol",
      type_text == "DRUG VIOLATIONS" ~ "drugs",
      str_detect(type_text, "ROBBERY") ~ "robbery",
      type_text == "SHOPLIFTING" ~ "shoplifting",
      type_text %in% c("AUTO THEFT", "SIMPLE BURGLARY VEHICLE") ~ 
        "vehicle theft",
      type_text %in% c("DISPERSE SUBJECTS", "DISTURBANCE (OTHER)", "FIGHT", 
                       "NOISE COMPLAINT") ~ "disturbance",
      type_text == "DRIVING WHILE UNDER INFLUENCE" ~ "driving while impaired",
      type_text == "SILENT 911 CALL" ~ "dropped/silent call to 911",
      str_detect(type_text, "DOMESTIC") ~ "domestic violence/family dispute",
      type_text %in% c("MEDICAL", "UNCLASSIFIED DEATH") ~ "medical emergency",
      type_text %in% c("MENTAL PATIENT") | str_detect(type_text, "^SUICIDE") ~ 
        "mental health/concern for safety",
      str_detect(type_text, "^MISSING") ~ "missing person",
      type_text == "DISCHARGING FIREARM" ~ "shooting/shots fired",
      type_text == "DEATH" ~ "sudden death",
      type_text == "SUSPICIOUS PERSON" ~ "suspicious person/vehicle",
      str_detect(type_text, "^AUTO ACCIDENT") | 
        str_detect(type_text, "^HIT & RUN") ~ "traffic collision",
      type_text == "TRAFFIC STOP" ~ "traffic stop",
      TRUE ~ NA_character_
    ),
    emergency = str_detect(priority, "^[23]")
  ) %>%
  # add city name
  mutate(city_name = "New Orleans, LA") %>%
  # select core variables
  select(one_of(common_vars)) %>%
  # save data
  write_rds(here::here("analysis_data/calls_data_new_orleans.rds"), 
            compress = "gz")


# process Phoenix data, updated daily
# https://www.phoenixopendata.com/dataset/calls-for-service
message("Processing Phoenix data")
dir(path = "original_data", pattern = "raw_phoenix", full.names = TRUE) %>% 
  map_dfr(read_csv, col_types = cols(.default = col_character())) %>%
  janitor::clean_names() %>%
  # add date variable
  add_date_var("call_received", "mdY IMS p", "America/Phoenix") %>% 
  # remove offenses before start date
  filter_by_year(yearFirst, yearLast) %>% 
  # identify calls of interest
  mutate(
    cfs_category = case_when(
      str_detect(final_call_type, "ALARM") ~ "intruder alarm",
      str_detect(final_call_type, "ASSAULT") ~ "assault",
      # BURGLARY must be searched for after ALARM
      str_detect(final_call_type, "BURGLARY") ~ "burglary",
      str_detect(final_call_type, "DRUG") | 
        str_detect(final_call_type, "NARCOTIC") ~ "drugs",
      # ROBBERY must be searched for after ALARM
      str_detect(final_call_type, "ROBBERY") ~ "robbery",
      str_detect(final_call_type, "SHOPLIFTING") ~ "shoplifting",
      final_call_type == "TRESPASSING" ~ "trespassing",
      str_detect(final_call_type, "BURGLARY FROM VEHICLE") | 
        str_detect(final_call_type, "RECOVERY OF VEHICLE") | 
        str_detect(final_call_type, "STOLEN VEHICLE") | 
        str_detect(final_call_type, "THEFT FROM VEHICLE") ~ "vehicle theft",
      str_detect(final_call_type, "^(FIGHT|LOUD|NEIGHBOR)\\b") ~ "disturbance",
      str_detect(final_call_type, "^DRUNK DRIVER\\b") | 
        final_call_type == "DUI DRIVER-BROADCAST" ~ "driving while impaired",
      final_call_type == "9-1-1 HANG-UP CALL" ~ "dropped/silent call to 911",
      str_detect(final_call_type, "^DOMESTIC VIOLENCE\\b") ~ 
        "domestic violence/family dispute",
      str_detect(final_call_type, "^INJURED") ~ "medical emergency",
      str_detect(final_call_type, "^CHECK WELFARE\\b") | 
        final_call_type == "MENTALLY ILL SUBJECT TRANSPORT" ~ 
        "mental health/concern for safety",
      str_detect(final_call_type, "\\bMISSING\\b") ~ "missing person",
      str_detect(final_call_type, "^(SHOT|SHOOT)") ~ "shooting/shots fired",
      str_detect(final_call_type, "^DEAD BODY\\b") ~ "sudden death",
      str_detect(final_call_type, "^SUSPICIOUS\\b") ~ 
        "suspicious person/vehicle",
      str_detect(final_call_type, "^ACCIDENT\\b") | 
        str_detect(final_call_type, "^HIT & RUN\\b") ~ "traffic collision",
      TRUE ~ NA_character_
    )
  ) %>%
  # add city name
  mutate(city_name = "Phoenix, AZ") %>%
  # select core variables
  select(one_of(common_vars)) %>%
  # save data
  write_rds(here::here("analysis_data/calls_data_phoenix.rds"), compress = "gz")



# process Sacramento data, updated at least daily
# http://data.cityofsacramento.org/search?q=dispatch
# includes call description
# message("Processing Sacramento data")
# dir(path = "original_data", pattern = "raw_sacramento", full.names = TRUE) %>%
#   map(read_csv, col_types = cols(.default = col_character())) %>%
#   map(janitor::clean_names) %>% 
#   # harmonise variable names across years
#   map_dfr(function (x) {
#     if ("occurence_date" %in% names(x)) {
#       rename(x, occurence_date_time = occurence_date, 
#              received_date_time = received_date, 
#              dispatch_date_time = dispatch_date, 
#              enroute_date_time = enroute_date, 
#              at_scene_date_time = at_scene_date, 
#              clear_date_time = clear_date)
#     } else {
#       x
#     }
#   }) %>% 
#   # add date variable
#   add_date_var("received_date_time", "Ymd T", "America/Los_Angeles") %>% 
#   # remove offenses before start date
#   filter_by_year(yearFirst, yearLast) %>% 
#   # identify calls of interest
#   mutate(
#     cfs_category = case_when(
#       str_detect(description, "^ALARM") ~ "intruder alarm",
#       str_detect(description, "ASSAULT") ~ "assault",
#       str_detect(description, "BURGLARY") ~ "burglary",
#       str_detect(description, "PATROL") ~ "directed/hotspot patrol",
#       str_detect(description, "NARCOTIC") ~ "drugs",
#       str_detect(description, "SUBJECT STOP") ~ "pedestrian stop",
#       str_detect(description, "ROBBERY") ~ "robbery",
#       str_detect(description, "SHOPLIFTING") ~ "shoplifting",
#       str_detect(description, "STOLEN VEHICLE") ~ "vehicle theft",
#       description %in%  c("DISTURBANCE-AGRESSIVE PANHANDLING", 
#                           "DISTURBANCE-CLARIFY", "DISTURBANCE-NOISE", 
#                           "DISTURBANCE-WEAPON") ~ "disturbance",
#       description == "DRUNK DRIVER" ~ "driving while impaired",
#       str_detect(description, "^INCOMPLETE CALL") ~ "dropped/silent call to 911",
#       description == "DISTURBANCE-FAMILY" | 
#         str_detect(description, "^DOMESTIC VIOLENCE") ~ 
#         "domestic violence/family dispute",
#       str_detect(description, "MEDIC") ~ "medical emergency",
#       description == "WELFARE CHECK" ~ "mental health/concern for safety",
#       str_detect(description, "^(SHOOTING|SHOTS)\\b") ~ "shooting/shots fired",
#       description %in% c("DEAD BODY", "DEAD BODY-CSI") ~ "sudden death",
#       str_detect(description, "^SUSPICIOUS") ~ "suspicious person/vehicle",
#       str_detect(description, "^VEHICLE ACCIDENT") | 
#         str_detect(description, "^HIT (&|AND) RUN") ~ "traffic collision",
#       description == "TRAFFIC STOP" ~ "traffic stop",
#       TRUE ~ NA_character_
#     )
#   ) %>%
#   # add city name
#   mutate(city_name = "Sacramento, CA") %>%
#   # select core variables
#   select(one_of(common_vars)) %>%
#   # save data
#   write_rds(here::here("analysis_data/calls_data_sacramento.rds"), 
#             compress = "gz")



# process San Diego data, updated about weekly
# https://data.sandiego.gov/datasets/police-calls-for-service/
# data dictionary: http://seshat.datasd.org/pd/pd_calls_for_service_dictionary_datasd.csv
# includes call priority, description and disposition
message("Processing San Diego data")
dir(path = "original_data", pattern = "raw_san_diego", full.names = TRUE) %>%
  map_dfr(read_csv, col_types = cols(.default = col_character())) %>%
  janitor::clean_names() %>%
  # add date variable
  add_date_var("date_time", "Ymd T", "America/Los_Angeles") %>%
  # remove offenses before start date
  filter_by_year(yearFirst, yearLast) %>%
  # identify calls of interest
  left_join(
    read_csv("http://seshat.datasd.org/pd/pd_cfs_calltypes_datasd.csv"),
    by = "call_type"
  ) %>%
  mutate(
    call_type = str_to_upper(call_type),
    cfs_category = case_when(
      str_detect(call_type, "^24[25]") ~ "assault",
      # must be searched before burglary
      str_detect(description, "ALARM") ~ "intruder alarm",
      str_detect(call_type, "^459") ~ "burglary",
      str_detect(call_type, "^41[57]") | str_detect(call_type, "^PARTY") ~
        "disturbance",
      # ~ "domestic violence/family dispute",
      str_detect(call_type, "^2315") | call_type == "AU23152" ~
        "driving while impaired",
      call_type == "NARC" ~ "drugs",
      str_detect(description, "AMBULANCE") | call_type == "11-8" ~ 
        "medical emergency",
      call_type == "CW" | str_detect(call_type, "^515") ~
        "mental health/concern for safety",
      call_type %in% c("MJ", "MP", "MS", "AU-MP") ~ "missing person",
      str_detect(call_type, "^211") ~ "robbery",
      call_type == "11-6" ~ "shooting/shots fired",
      call_type %in% c("1144", "1146") ~ "sudden death",
      # ~ "suspicious person/vehicle",
      str_detect(call_type, "^118[0123]") | str_detect(call_type, "^2000") ~
        "traffic collision",
      call_type %in% c("1149", "1150", "MCTSTP", "T") ~ "traffic stop",
      call_type == "602" ~ "trespassing",
      str_detect(call_type, "10851") ~ "vehicle theft",
      TRUE ~ NA_character_
    ),
    emergency = priority %in% c("1", "1P", "E")
  ) %>%
  # add city name
  mutate(city_name = "San Diego, CA") %>%
  # select core variables
  select(one_of(common_vars)) %>%
  # save data
  write_rds(here::here("analysis_data/calls_data_san_diego.rds"),
            compress = "gz")



# process San Jose data, updated daily
# https://data.sanjoseca.gov/dataset/police-calls-for-service
# call priorities at http://www.sjpd.org/faq.html
message("Processing San Jose data")
dir(path = "original_data", pattern = "raw_san_jose", full.names = TRUE) %>% 
  map_dfr(read_csv, col_types = cols(.default = col_character())) %>%
  janitor::clean_names() %>% 
  # add date variable
  mutate(offense_date = paste(
    date(parse_date_time(offense_date, c("mdY IMS p", "mdY"))), 
    offense_time
  )) %>% 
  add_date_var("offense_date", "Ymd T", "America/Los_Angeles") %>% 
  # remove offenses before start date
  filter_by_year(yearFirst, yearLast) %>% 
  # identify calls of interest
  mutate(
    cfs_category = case_when(
      str_detect(calltype_code, "^1033") ~ "intruder alarm",
      str_detect(calltype_code, "^24") | str_detect(calltype_code, "^ADW") ~ 
        "assault",
      str_detect(call_type, "^BURGLARY") ~ "burglary",
      str_detect(calltype_code, "^113") ~ "drugs",
      str_detect(calltype_code, "^109[56]") ~ "pedestrian stop",
      str_detect(calltype_code, "^211") ~ "robbery",
      calltype_code == "602PC" ~ "trespassing",
      calltype_code == "459VEH" | str_detect(calltype_code, "^10851") ~ 
        "vehicle theft",
      str_detect(calltype_code, "^415") ~ "disturbance",
      calltype_code %in% c("23152", "23153") ~ "driving while impaired",
      calltype_code == "911UNK" ~ "dropped/silent call to 911",
      calltype_code %in% c("1045", "1046", "1053") ~ "medical emergency",
      calltype_code %in% c("WELCK", "WELCKEMS") ~ 
        "mental health/concern for safety",
      str_detect(calltype_code, "^1065") ~ "missing person",
      calltype_code %in% c("1057", "1071", "246") ~ "shooting/shots fired",
      calltype_code == "1055" ~ "sudden death",
      str_detect(calltype_code, "^1066") | 
        calltype_code %in% c("1154", "SUSCIR", "SUSCIREMS") ~ 
        "suspicious person/vehicle",
      calltype_code %in% c("1179", "1180", "1181", "1182", "1193", "20001", 
                           "20002") ~ "traffic collision",
      calltype_code %in% c("1195", "1195X") ~ "traffic stop",
      TRUE ~ NA_character_
    ),
    emergency = priority %in% c("1", "2")
  ) %>%
  # add city name
  mutate(city_name = "San Jose, CA") %>%
  # select core variables
  select(one_of(common_vars)) %>%
  # save data
  write_rds(here::here("analysis_data/calls_data_san_jose.rds"), 
            compress = "gz")



# process Seattle data, updated daily
# https://data.seattle.gov/Public-Safety/Call-Data/33kz-ixgy
# includes call origin, priority, description and disposition
# call priorities at https://seattle.gov/police/information-and-data/calls-for-service-dashboard under 'Methodology'
message("Processing Seattle data")
here::here("original_data/raw_seattle.csv") %>%
  read_csv(col_types = cols(.default = col_character())) %>%
  janitor::clean_names() %>% 
  # add date variable
  add_date_var("original_time_queued", "mdY HMS p", "America/Los_Angeles") %>% 
  # remove offenses before start date
  filter_by_year(yearFirst, yearLast) %>% 
  # identify calls of interest
  mutate(
    final_call_type = str_remove(str_to_upper(final_call_type), "^--"),
    cfs_category = case_when(
      str_detect(final_call_type, "ALARM") ~ "intruder alarm",
      str_detect(final_call_type, "ASSAULTS") ~ "assault",
      # search for BURGLARY must be after ALARM
      str_detect(final_call_type, "BURGLARY") ~ "burglary",
      str_detect(final_call_type, "PATROL") ~ "directed/hotspot patrol",
      str_detect(final_call_type, "NARCOTICS") & 
        !str_detect(final_call_type, "EXCL NARCOTICS") ~ "drugs",
      initial_call_type == "SUSPICIOUS STOP - OFFICER INITIATED ONVIEW" ~ 
        "pedestrian stop",
      str_detect(final_call_type, "ROBBERY") ~ "robbery",
      str_detect(final_call_type, "SHOPLIFT") & 
        !str_detect(final_call_type, "\\bNOT\\b") ~ "shoplifting",
      str_detect(final_call_type, "TRESPASS") ~ "trespassing",
      str_detect(final_call_type, "AUTO THEFT") | 
        str_detect(final_call_type, "AUTO ACCESSORIES") ~ "vehicle theft",
      str_detect(final_call_type, "^DISTURBANCE\\b") | 
        str_detect(final_call_type, "^FIGHT\\b") ~ "disturbance",
      final_call_type %in% 
        c("TRAFFIC - D.U.I.", "DUI - DRIVING UNDER INFLUENCE") ~ 
        "driving while impaired",
      str_detect(final_call_type, "\\bDV\\b") ~ 
        "domestic violence/family dispute",
      str_detect(initial_call_type, "PERSON DOWN") | 
        str_detect(initial_call_type, "SICK PERSON") ~ "medical emergency",
      str_detect(final_call_type, "^CRISIS\\b") | 
        str_detect(initial_call_type, "^SUICIDE\\b") | 
        final_call_type == "PERSON IN BEHAVIORAL/EMOTIONAL CRISIS" ~ 
        "mental health/concern for safety",
      str_detect(final_call_type, "\\bSHOT") ~ "shooting/shots fired",
      final_call_type == "DOA - CASUALTY, DEAD BODY" | 
        str_detect(final_call_type, "^CASUALTY") ~ "sudden death",
      str_detect(final_call_type, "^SUSPICIOUS") ~ "suspicious person/vehicle",
      final_call_type == "TRAFFIC - MV COLLISION INVESTIGATION" | 
        str_detect(final_call_type, "\\bACC\\b") | 
        str_detect(final_call_type, "\\bMVC\\b") ~ "traffic collision",
      initial_call_type == "TRAFFIC STOP - OFFICER INITIATED ONVIEW" ~ 
        "traffic stop",
      TRUE ~ NA_character_
    ),
    emergency = priority %in% c("1", "2")
  ) %>%
  # add city name
  mutate(city_name = "Seattle, WA") %>%
  # select core variables
  select(one_of(common_vars)) %>%
  # save data
  write_rds(here::here("analysis_data/calls_data_seattle.rds"), 
            compress = "gz")



# process Sonoma County data, updated daily
# https://data.sonomacounty.ca.gov/Public-Safety/Sonoma-County-Sheriff-s-Office-Event-Data/bpq8-s7gr/data
# includes call origin, description and disposition
message("Processing Sonoma County data")
here::here("original_data/raw_sonoma_county.csv") %>%
  read_csv(col_types = cols(.default = col_character())) %>%
  janitor::clean_names() %>% 
  # add date variable
  add_date_var("date_time", "mdY IMS p", "America/Los_Angeles") %>% 
  # remove offenses before start date
  filter_by_year(yearFirst, yearLast) %>% 
  # identify calls of interest
  mutate(
    cfs_category = case_when(
      str_detect(nature_description, "ALARM") ~ "intruder alarm",
      str_detect(nature_description, "ASSAULT") | 
        str_detect(nature_description, "BATTERY") ~ "assault",
      str_detect(nature_description, "BURGLARY") ~ "burglary",
      str_detect(nature_description, "PATROL") ~ "directed/hotspot patrol",
      str_detect(nature_description, "NARCOTIC") ~ "drugs",
      str_detect(nature_description, "ROBBERY") ~ "robbery",
      str_detect(nature_description, "TRESPASS") ~ "trespassing",
      str_detect(nature_description, "^STOLEN VEHICLE") | 
        nature_description == "BURGLARY AUTO REPORT" ~ "vehicle theft",
      str_detect(nature_description, "^DISTURBANCE") ~ "disturbance",
      nature_description == "DRUNK DRIVER DUI" ~ "driving while impaired",
      str_detect(nature_description, "^911") ~ "dropped/silent call to 911",
      str_detect(nature_description, "MAN DOWN") ~ "medical emergency",
      nature_description == "CHECK THE WELFARE" | 
        str_detect(nature_description, "^SUICIDE") ~ 
        "mental health/concern for safety",
      str_detect(nature_description, "\\bSHOOTING\\b")~ "shooting/shots fired",
      nature_description %in% c("CORONER`S CASE", "POSSIBLE DEAD BODY") ~ 
        "sudden death",
      str_detect(nature_description, "^SUSPICIOUS") ~ 
        "suspicious person/vehicle",
      str_detect(nature_description, "^HIT & RUN") | 
        str_detect(nature_description, "^TRAFF ACC") ~ "traffic collision",
      nature_description == "TRAFFIC STOP" ~ "traffic stop",
      TRUE ~ NA_character_
    )
  ) %>%
  # add city name
  mutate(city_name = "Sonoma County, CA") %>%
  # select core variables
  select(one_of(common_vars)) %>%
  # save data
  write_rds(here::here("analysis_data/calls_data_sonoma_county.rds"), 
            compress = "gz")



# process St Petersburg data, updated daily
# https://stat.stpete.org/dataset/Police-Calls/2eks-pg5j
message("Processing St Petersburg data")
here::here("original_data/raw_st_petersburg.csv") %>%
  read_csv(col_types = cols(.default = col_character())) %>%
  janitor::clean_names() %>% 
  # add date variable
  add_date_var("crime_date", "mdY IMS p", "America/New_York") %>% 
  # remove offenses before start date
  filter_by_year(yearFirst, yearLast) %>% 
  # identify calls of interest
  mutate(
    cfs_category = case_when(
      str_detect(type_of_event, "^DOMESTIC") ~ 
        "domestic violence/family dispute",
      type_of_event %in% c("BURGLARY VEHICLE", "AUTO THEFT") ~ "vehicle theft",
      # the search for assault/battery must be after the search for domestic
      str_detect(type_of_event, "(ASSAULT|BATTERY)") ~ "assault",
      # the search for burglary must be after the search for vehicle theft
      str_detect(type_of_event, "BURGLARY") ~ "burglary",
      type_of_event == "PARK WALK TALK" ~ "directed/hotspot patrol",
      type_of_event == "NARC DRUG LAW VIOL" ~ "drugs",
      str_detect(type_of_event, "ROBBERY") ~ "robbery",
      type_of_event == "SHOPLIFTER IN CUSTODY" ~ "shoplifting",
      type_of_event == "TRESPASSING" ~ "trespassing",
      type_of_event %in% c("BRAWLING", "NEIGHBORHD DISPUTE", "NOISE NUISANCE") | 
        str_detect(type_of_event, "^DISORDERLY") ~ "disturbance",
      type_of_event == "DRIVING UNDER INFLUENCE" ~ "driving while impaired",
      type_of_event %in% c("PERSON BLEEDING", "PERSON DOWN") ~ 
        "medical emergency",
      type_of_event %in% c("CHECK WELFARE", "MENTAL PERSON") | 
        str_detect(type_of_event, "^SUICIDE") ~ 
        "mental health/concern for safety",
      str_detect(type_of_event, "\\b(SHOT|SHOOT)") ~ "shooting/shots fired",
      type_of_event == "UNATTENDED DEATH" ~ "sudden death",
      str_detect(type_of_event, "^SUSPICIOUS") ~ "suspicious person/vehicle",
      str_detect(type_of_event, "^ACC\\b") | 
        type_of_event == "FATALITY ACCIDENT" ~ "traffic collision",
      type_of_event == "TRAFFIC STOP" ~ "traffic stop",
      TRUE ~ NA_character_
    )
  ) %>%
  # add city name
  mutate(city_name = "St Petersburg, FL") %>%
  # select core variables
  select(one_of(common_vars)) %>%
  # save data
  write_rds(here::here("analysis_data/calls_data_st_petersburg.rds"), 
            compress = "gz")
  


# merge data
calls_data <- here::here("analysis_data") %>% 
  dir(pattern = "^calls_data_.*rds$", full.names = TRUE) %>% 
  map_dfr(read_rds) %>% 
  # remove categories not present in enough cities (it's easier to remove them 
  # now than in the code for individual cities)
  filter(
    !cfs_category %in% c(
      "directed/hotspot patrol", "dropped/silent call to 911", 
      "pedestrian stop", "shoplifting"
    )
  ) %>% 
  write_csv(here::here("analysis_data/calls_data.csv.gz"))
