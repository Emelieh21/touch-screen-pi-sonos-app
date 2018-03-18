library(rvest)

tuneIn <- read_xml("http://opml.radiotime.com/")
links <- tuneIn %>%
  xml_nodes("outline") %>%
  xml_attr("URL")
text <- tuneIn %>%
  xml_nodes("outline") %>%
  xml_attr("text")
menu <- as.data.frame(text, stringsAsFactors = F)
menu$links <- links

all_stations <-NULL

select <- menu$links[menu$text=="Music"]

sub <- read_xml(select)
sub_links <- sub %>% xml_nodes("outline") %>% xml_attr("URL")
genres <- sub %>% xml_nodes("outline") %>% xml_attr("text")

dat <- as.data.frame(genres, stringsAsFactors = F)
dat$links <- sub_links

for (genre in dat$genres) {
  print(genre)
  sub <- subset(dat, genres == genre)
  sub_page <- read_xml(sub$links)
  sub_links <- sub_page %>% xml_nodes("outline") %>% xml_attr("URL")
  name <- sub_page %>% xml_nodes("outline") %>% xml_attr("text")
  
  stations <- as.data.frame(name, stringsAsFactors = F)
  stations$link <- sub_links
  
  stations <- subset(stations, grepl("id=s", stations$link) == TRUE)
  stations$genre <- genre
  
  stations$id <- gsub(".*\\=(.*)","\\1",stations$link)
  Sys.sleep(3)
  all_stations <- rbind(all_stations, stations)
}
setwd("D:/touch-screen-pi-sonos-app/assets")
all_stations$id <- gsub("s","",all_stations$id)
saveRDS(all_stations, "tuneIn_stations.rds")


## NOTES ####
# select <- menu$links[menu$text=="By Location"]
# 
# sub <- read_xml(select)
# sub_links <- sub %>% xml_nodes("outline") %>% xml_attr("URL")
# continents <- sub %>% xml_nodes("outline") %>% xml_attr("text")
# 
# dat <- as.data.frame(continents, stringsAsFactors = F)
# dat$links <- sub_links
# 
# for (continent in dat$continents) {
#   print(continent)
#   sub <- subset(dat, continents == continent)
#   sub_page <- read_xml(sub$links)
#   sub_links <- sub_page %>% xml_nodes("outline") %>% xml_attr("URL")
#   countries <- sub_page %>% xml_nodes("outline") %>% xml_attr("text")
#   
#   countries <- as.data.frame(countries, stringsAsFactors = F)
#   countries$link <- sub_links
#   
#   for (country in countries$link) {
#     sub_page <- read_xml(country)
#     sub_links <- sub_page %>% xml_nodes("outline") %>% xml_attr("URL")
#     what <- sub_page %>% xml_nodes("outline") %>% xml_attr("text")
#   }
#   
#   stations <- subset(stations, grepl("id=s", stations$link) == TRUE)
#   stations$genre <- genre
#   
#   stations$id <- gsub(".*\\=(.*)","\\1",stations$link)
#   Sys.sleep(3)
#   all_stations <- rbind(all_stations, stations)
# }


# for (link in links) {
#   print(link)
#   sub <- read_xml(link)
#   sub_links <- sub %>% xml_nodes("outline") %>% xml_attr("URL")
#   sub_text <- sub %>% xml_nodes("outline") %>% xml_attr("text")
#   for (sub_link in sub_links) {
#     stations <- read_xml(sub_link)
#     stations %>% xml_nodes("outline") %>% xml_attr("URL")
#   }
# }
# tuneIn %>%
#   xml_nodes("outline") 
# sub_links
