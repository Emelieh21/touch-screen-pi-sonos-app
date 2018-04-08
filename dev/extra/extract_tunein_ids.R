library(rvest)

setwd("D:/touch-screen-pi-sonos-app/assets")

# tuneIn <- read_xml("http://opml.radiotime.com/")
# links <- tuneIn %>%
#   xml_nodes("outline") %>%
#   xml_attr("URL")
# text <- tuneIn %>%
#   xml_nodes("outline") %>%
#   xml_attr("text")
# menu <- as.data.frame(text, stringsAsFactors = F)
# menu$links <- links

### Unfortunately blocked from radiotime. Need to find another solution to get station ids

previous_stations <- readRDS("tuneIn_stations.rds")
all_stations <- previous_stations

term = "Radio 10"

radio <- read_html(paste0("http://tunein.com/search/?query=",term))
links <- radio %>% 
  html_nodes("a") %>%
  html_attr("href")
links <- links[grepl("\\-s",links)]
dat <- as.data.frame(links)
names(dat) <- "link"
dat$id <- gsub(".*\\-s(.*)\\/","\\1",links)
dat$name <- gsub("\\/radio/(.*)\\-s.*","\\1",links)
dat$genre <- term
dat$name <- trimws(gsub("\\-"," ",dat$name))

all_stations <- rbind(all_stations, dat)
all_stations <- unique(all_stations)


dat <-as.data.frame("https://tunein.com/radio/Ritmo-95-957-s23950/")
names(dat) <- "link"
dat$id <- "23950"
dat$name <- "Cubaton y mas"
dat$genre <- "CUBATOOOOOOOON"


# by Location ####
radiosByLocation <- function(){ #### GOT BLOCKED AT MONACO :(
  tuneIn <- read_xml("http://opml.radiotime.com/")
  links <- tuneIn %>%
    xml_nodes("outline") %>%
    xml_attr("URL")
  text <- tuneIn %>%
    xml_nodes("outline") %>%
    xml_attr("text")
  menu <- as.data.frame(text, stringsAsFactors = F)
  menu$links <- links
  
  select <- menu$links[menu$text=="By Location"]
  sub <- read_xml(select)
  sub_links <- sub %>% xml_nodes("outline") %>% xml_attr("URL")
  continents <- sub %>% xml_nodes("outline") %>% xml_attr("text")

  menu <- as.data.frame(continents, stringsAsFactors = F)
  menu$links <- sub_links
  print(menu)
  choice <- readline("Which continent do you want to extract stations from?")
  select <- menu$links[menu$continents==choice]
  sub <- read_xml(select)

  dat <- as.data.frame(sub %>% xml_nodes("outline") %>% xml_attr("type"))
  names(dat) = "type"
  dat$text <- sub %>% xml_nodes("outline") %>% xml_attr("text")
  dat$guide_id <- sub %>% xml_nodes("outline") %>% xml_attr("guide_id")
  print(head(dat))
  continue <- readline("Are these countries? [yes/no]")
  
  if (continue == "yes"){
    df <- NULL
    for(i in c(1:nrow(dat))){
    #for(i in c(1:2)){
      sub <- dat[i,]
      country <- sub$text
      print(country)
      Sys.sleep(3)
      url <- paste0("http://opml.radiotime.com/Browse.ashx?id=",sub$guide_id,"&pivot=name&filter=country")
      print(url)
      alphabet <- read_xml(url)
      links <- alphabet %>% xml_nodes("outline") %>% xml_attr("URL")
      
      for (link in links) {
        tryCatch({
          alphsub <- read_xml(link)
          alphdat <- as.data.frame(alphsub %>% xml_nodes("outline") %>% xml_attr("type"))
          names(alphdat) = "type"
          Sys.sleep(3)
          alphdat$text <- alphsub %>% xml_nodes("outline") %>% xml_attr("text")
          alphdat$guide_id <- alphsub %>% xml_nodes("outline") %>% xml_attr("guide_id")
          print(head(alphdat))
          alphdat <- subset(alphdat, type == "audio")
          if(nrow(alphdat) < 1){
            message("No stations here...")
            next
          }
          alphdat$country <- country
          df <- rbind(df, alphdat)
        }, error = function(e) {
            print(e)
            print(link)
          })
      }
      
    }  
  } else {
    message("Don't know how to deal with this...")
    break
  }
  return(df)
} 

collect <- radiosByLocation()

collect$name <- collect$text
collect$genre <- collect$country
collect$link <- collect$guide_id
collect$id <- gsub("s","",collect$guide_id)
collect <- collect[,names(previous_stations)]
all_stations <- rbind(previous_stations,collect)

#clean <- subset(collect, !grepl("\\<U\\+",text))

# by Genre ####
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
all_stations$id <- gsub("s","",all_stations$id)
saveRDS(all_stations, "tuneIn_stations.rds")


### ADD ONE NEW STATION
dat <- as.data.frame("74982", stringsAsFactors = F)
names(dat) <- "id"
dat$genre <- "80s"
dat$name <- "Radio10 - 80s Hits"
dat$link <- "https://www.radio10.nl/"

all_stations <- rbind(all_stations, dat)
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
