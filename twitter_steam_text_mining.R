install.packages("ROAuth")
install.packages("twitteR")
install.packages("tm")
install.packages("plyr")
install.packages("dplyr")
install.packages("purrr")
install.packages("RCurl")
install.packages("SnowballC")
install.packages("openssl")
install.packages("wordcloud")
install.packages("ggplot2")
install.packages("RColorBrewed")
install.packages("stringr")
install.packages("textclean")
install.packages("tidytext")
install.packages("readr")
install.packages("xlsx")

install.packages("hms")
install.packages("lubridate") 
install.packages("igraph")
install.packages("glue")
install.packages("networkD3")
install.packages("rtweet")
install.packages("ggeasy")
install.packages("plotly")
install.packages("hms")
install.packages("lubridate") 
install.packages("magrittr")
install.packages("tidyverse")
install.packages("janeaustenr")
install.packages("widyr")





library(ROAuth)
library(twitteR)
library(tm)
library(plyr)
library(dplyr)
library(purrr)
library(RCurl)
library(SnowballC)
library(openssl)
library(wordcloud)
library(ggplot2)
library(RColorBrewer)
library(stringr)
library(tidytext)
library(readr)
library(stringi)

library(hms)
library(lubridate) 
library(igraph)
library(glue)
library(networkD3)
library(rtweet)
library(ggeasy)
library(plotly)
library(hms)
library(lubridate) 
library(magrittr)
library(tidyverse)
library(janeaustenr)
library(widyr)

library(xlsx)
library(readxl)

options(httr_oauth_cache=T)

APIkey <- "SSSSSSSSSSSSSSSSSSSSSSSSSSSS"
APIsecret <- "SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS"
access_token <- "SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS"
access_secret <- "SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS"

setup_twitter_oauth(APIkey, APIsecret, access_token, access_secret)


steam <- searchTwitteR("steam", n=5000,  lang = "tr")


steam.df <- twListToDF(steam)

length(steam)

tweet_clean <- steam.df

tweet_clean$text <- stri_enc_toutf8(tweet_clean$text)

tweet_clean$text <- ifelse(str_sub(tweet_clean$text,1,2) == "RT", 
                           substring(tweet_clean$text,3), 
                           tweet_clean$text)


#URL linklerinin temizlenmesi
tweet_clean$text <- str_replace_all(tweet_clean$text, "http[^[:space:]]*", "")


#Hashtag "#" ve "@" işaretlerinin kaldırılması
tweet_clean$text <- str_replace_all(tweet_clean$text, "#\\S+", "")
tweet_clean$text <- str_replace_all(tweet_clean$text, "@\\S+", "")

#Noktalama işaretlerinin temizlenmesi
tweet_clean$text <- str_replace_all(tweet_clean$text, "[[:punct:][:blank:]]+", " ")

#Tüm harflerin küçük harfe dönüştürülmesi
tweet_clean$text  <- str_to_lower(tweet_clean$text, "tr")

#Rakamların temizlenmesi
tweet_clean$text <- removeNumbers(tweet_clean$text)

#ASCII formatına uymayan karakterlerin temizlenmesi
tweet_clean$text <- str_replace_all(tweet_clean$text, "[<].*[>]", "")
tweet_clean$text <- gsub("\uFFFD", "", tweet_clean$text, fixed =  TRUE)
tweet_clean$text <- gsub("\n", "", tweet_clean$text, fixed =  TRUE)

#Alfabetik olmayan karakterlerin temizlenmesi
tweet_clean$text <- str_replace_all(tweet_clean$text, "[^[:alnum:]]"," " )

steamCorpus <- Corpus(VectorSource(tweet_clean$text))
inspect(steamCorpus[1:10])

steamCorpus <- tm_map(steamCorpus, content_transformer(tolower))
steamCorpus <- tm_map(steamCorpus, removeWords, stopwords("en"))
steamCorpus <- tm_map(steamCorpus, removeNumbers)
steamCorpus <- tm_map(steamCorpus, removePunctuation)


turkish_stopwords <- read_excel("C:/Users/samet/Desktop/twitter_steam_text_mining/Turkish-Stopwords.xlsx")
turkish_stopwords
steamCorpus <- tm_map(steamCorpus, removeWords, turkish_stopwords)

durakkelimeler <- read_excel("C:/Users/samet/Desktop/twitter_steam_text_mining/durakkelimeler.xlsx")
durakkelimeler
steamCorpus <- tm_map(steamCorpus, removeWords, durakkelimeler)

removeURL <- function(x) gsub("http[[:alnum:]]*", "", x)
steamCorpus <- tm_map(steamCorpus, content_transformer(removeURL))
removeURL <- function(x) gsub("edua[[:alnum:]]*", "", x)
steamCorpus <- tm_map(steamCorpus, content_transformer(removeURL))

removeNonAscii <- function(x) textclean::replace_non_ascii(x)
steamCorpus <- tm_map(steamCorpus, content_transformer(removeNonAscii))
steamCorpus <- tm_map(steamCorpus, removeWords, c("amp", "ufef","ufeft", "uufefuufefuufef", "uufef", "s"))
steamCorpus <- tm_map(steamCorpus, stripWhitespace)

inspect(steamCorpus[1:10])



write.xlsx(tweet_clean, "C:/Users/samet/Desktop/twitter_steam_text_mining/17.01.2022tweets.xlsx")



tidy_tweets <- tweet_clean %>% select(text) %>% 
  mutate(linenumber = row_number()) %>% unnest_tokens(word, text)
tidy_tweets <- tidy_tweets %>% anti_join(turkish_stopwords, by=c("word"="STOPWORD"))


tidy_tweets %>%
  count(word, sort = TRUE) %>%
  filter(n > 5) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_col() +
  xlab(NULL) +
  coord_flip() + theme_minimal() +
  ggtitle("tweetlerde en cok kullanilan kelimeler")



tidy_tweets %>% 
  count(word) %>%
  with(wordcloud(word, n, max.words = 100))



