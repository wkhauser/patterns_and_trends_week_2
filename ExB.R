library("readr")
library("sf")
library(tidyr)
library(dplyr)


caro <- read_delim("data/caro60.csv")

difftime_secs <- function(x, y){
  as.numeric(difftime(x, y, units = "secs"))
}

distance_by_element <- function(later, now){
  as.numeric(
    st_distance(later, now, by_element = TRUE)
  )
}

caro <- caro |>
  st_as_sf(coords = c("E","N"), crs = 2056) |> 
  select(DatetimeUTC)


#1. 

caro <- caro |> 
  mutate(
    timelag = difftime_secs(lead(DatetimeUTC), lag(DatetimeUTC))
  )

caro <- caro |> 
  mutate(
    steplength = distance_by_element(lead(geometry), lag(geometry))
  )


caro <- caro |> 
  mutate(
    speed = (steplength/timelag)
  )

#2. 

caro <- caro |> 
  mutate(
    timelag2 = difftime_secs(lead(DatetimeUTC, n = 2), lag(DatetimeUTC, n = 2))
  )

caro <- caro |> 
  mutate(
    steplength2 = distance_by_element(lead(geometry, n = 2), lag(geometry, n = 2))
  )


caro <- caro |> 
  mutate(
    speed2 = (steplength2/timelag2)
  )

#3. 

caro <- caro |> 
  mutate(
    timelag3 = difftime_secs(lead(DatetimeUTC, n = 4), lag(DatetimeUTC, n = 4))
  )

caro <- caro |> 
  mutate(
    steplength3 = distance_by_element(lead(geometry, n = 4), lag(geometry, n = 4))
  )


caro <- caro |> 
  mutate(
    speed3 = (steplength3/timelag3)
)


#4. 

caro |> 
  st_drop_geometry() |> 
  select(DatetimeUTC, speed, speed2, speed3)

library(ggplot2)

ggplot(caro, aes(y = speed)) + 
  # we remove outliers to increase legibility, analogue
  # Laube and Purves (2011)
  geom_boxplot(outliers = FALSE)


library(tidyr)

# before pivoting, let's simplify our data.frame
caro2 <- caro |> 
  st_drop_geometry() |> 
  select(DatetimeUTC, speed, speed2, speed3)

caro_long <- caro2 |> 
  pivot_longer(c(speed, speed2, speed3))

head(caro_long)


ggplot(caro_long, aes(name, value)) +
  # we remove outliers to increase legibility, analogue
  # Laube and Purves (2011)
  geom_boxplot(outliers = FALSE)
