library(tidyverse)
library(rvest)

dir.create("data")

base_url = "https://www.redbullmusicacademy.com"

lectures_home <- read_html("https://www.redbullmusicacademy.com/lectures")

# get lecture links
lectures_links <- html_nodes(lectures_home, ".iyBYTS")

# get lecture URLs
lectures_urls <- paste0(base_url, html_attr(lectures_links, "href"))

# identify artist portals
artist_urls <- lectures_urls[str_detect(lectures_urls, pattern = "/artist/")]

# root out artist portal's lecture URLs
artist_lecture_urls <- lapply(artist_urls, function(x) {
  
  read_html(x) %>% 
    html_nodes("#gatsby-focus-wrapper") %>% 
    html_nodes(xpath = '//div[contains(@class, "artist__Container")]') %>% 
    html_nodes("a") %>% 
    html_attr("href") %>% 
    paste0(base_url, .)
}) 

# merge urls
lectures_urls <- lectures_urls[str_detect(lectures_urls, pattern = "/artist/", negate = TRUE)]
lectures_urls <- c(lectures_urls, unlist(artist_lecture_urls))

# lecture names
lecture_names <- sub(".*lectures/", "", lectures_urls)

# get transcripts
lectures_transcripts <- lapply(lectures_urls, function(x) {
  
  # hit lecture page
  read_html(x) %>% 
    # find transcript
    html_nodes(".style-normal .ng-scope") %>% 
    html_text()
})

# export text
map2(lectures_transcripts, lecture_names, ~ write_lines(.x, path = paste0("data/" , .y, ".txt")))
