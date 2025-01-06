#install.packages("jsonlite")
#install.packages("httr")
#install.packages("openSkies")
library(httr)
library(openSkies)
library(jsonlite)
library(telegram.bot)




telegram_token <- "YOUR_TELEGRAM_BOT_TOKEN" #### REMEMBER TO CHANGE THIS ####
url <- paste0("https://api.telegram.org/bot", telegram_token, "/getUpdates")
response <- GET(url)

# Parse JSON response
response_content <- fromJSON(content(response, as = "text", encoding = "UTF-8"))

#SNAK MED BOTTEN
# Define your Telegram bot t
chat_id <- "YOUR_CHAT_ID" #### REMEMBER TO CHANGE THIS ####

# Function to send a message via Telegram bot
send_telegram_message <- function(message) {
  url <- paste0("https://api.telegram.org/bot", telegram_token, "/sendMessage")
  POST(url, body = list(chat_id = chat_id, text = message), encode = "form")
}



url <- "https://opensky-network.org/api/states/all"
north_korea_bbox <- list(
  lamin = 37.669070543,  # Sydlig breddegrad
  lamax = 39.9853868678,  # Nordlig breddegrad
  lomin = 123.265624628, # Vestlig længdegrad
  lomax = 130.78000735  # Østlig længdegrad
)
### THIS IS JUST FOR TESTING SINCE ITS VERY RARE THAT AIRPLANES ENTER NORTHKOREAN AIRSPACE ###
DENMARK_bbox <- list(
  lamin = 8.08997684086,  # Sydlig breddegrad
  lamax = 54.8000145534,  # Nordlig breddegrad
  lomin = 12.6900061378, # Vestlig længdegrad
  lomax = 57.730016588  # Østlig længdegrad
)


#   DK': ('Denmark', (8.08997684086, 54.8000145534, 12.6900061378, 57.730016588)),
#   KP': ('N. Korea', (124.265624628, 37.669070543, 130.780007359, 42.9853868678)),   
#   KR': ('S. Korea', (126.117397903, 34.3900458847, 129.468304478, 38.6122429469))
#   wCN': ('China', (73.6753792663, 18.197700914, 135.026311477, 53.4588044297)),


Sresponse <- GET(url, query = north_korea_bbox,  authenticate(user = "YOUR_USERNAME", password = "YOUR_PASSWORD")) #### REMEMBER TO CHANGE THIS ####

data <- fromJSON(content(Sresponse, as = "text"), flatten = T)

df <- as.data.frame(data$states)
colnames(df) <- c(
  "icao24", "callsign", "origin_country", "time_position", "last_contact", 
  "longitude", "latitude", "baro_altitude", "on_ground", "velocity", 
  "true_track", "vertical_rate", "sensors", "geo_altitude", 
  "squawk", "spi", "position_source"
)

icao24 <- df$icao24[1]
altitude <- df$geo_altitude[1]
Land <- df$origin_country[1]

message <- paste0(
  format(Sys.time(), "%d-%m-%Y %H:%M:%S"), 
  ". Der er fly i Nordkoreas luftrum: ", icao24, ", fra: ", Land,", i ", altitude, " meters højde"
)

# Send the message via Telegram
send_telegram_message(message)

