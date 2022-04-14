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


steam <- read_excel("C:/Users/samet/Desktop/twitter_steam_text_mining/butun-tweetler.xlsx")
steam.df <- as.data.frame(steam)
tweet_clean <- steam.df



tweet_clean$text <- stri_enc_toutf8(tweet_clean$text)

tweet_clean$text <- ifelse(str_sub(tweet_clean$text,1,2) == "RT", 
                           substring(tweet_clean$text,3), 
                           tweet_clean$text)


#URL linklerinin temizlenmesi
tweet_clean$text <- str_replace_all(tweet_clean$text, "http[^[:space:]]*", "")

tweet_clean$text <- str_replace_all(tweet_clean$text, "RT", "")


#Hashtag "#" ve "@" iÅaretlerinin kaldÄ±rÄ±lmasÄ±
tweet_clean$text <- str_replace_all(tweet_clean$text, "#\\S+", "")
tweet_clean$text <- str_replace_all(tweet_clean$text, "@\\S+", "")

#Noktalama iÅaretlerinin temizlenmesi
tweet_clean$text <- str_replace_all(tweet_clean$text, "[[:punct:][:blank:]]+", " ")

#TÃ¼m harflerin kÃ¼Ã§Ã¼k harfe dÃ¶nÃ¼ÅtÃ¼rÃ¼lmesi
tweet_clean$text  <- str_to_lower(tweet_clean$text, "tr")

#RakamlarÄ±n temizlenmesi
tweet_clean$text <- removeNumbers(tweet_clean$text)

#ASCII formatÄ±na uymayan karakterlerin temizlenmesi
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


tidy_tweets <- tweet_clean %>% select(text) %>% 
  mutate(linenumber = row_number()) %>% unnest_tokens(word, text)
tidy_tweets <- tidy_tweets %>% anti_join(turkish_stopwords, by=c("word"="STOPWORD"))


tidy_tweets %>%
  count(word, sort = TRUE) %>%
  filter(n > 50) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_col() +
  xlab(NULL) +
  coord_flip() + theme_minimal() +
  ggtitle("tweetlerde en cok kullanilan kelimeler")



tidy_tweets %>% 
  count(word) %>%
  with(wordcloud(word, n, max.words = 100))


write.xlsx(tweet_clean, "C:/Users/samet/Desktop/twitter_steam_text_mining/butun-tweetler-temiz.xlsx")



pos.words <- scan('C:/Users/samet/Desktop/twitter_steam_text_mining/pozitifkelimeler.txt', what = 'character', comment.char = ';', skipNul = TRUE)
dput(pos.words[1289:1293])
neg.words <- scan('C:/Users/samet/Desktop/twitter_steam_text_mining/negatifkelimeler.txt', what = 'character', comment.char = ';', skipNul = TRUE)
dput(neg.words[1967:1971])

score.sentiment <- function(sentences, pos.words, neg.words, .progress='none')
  
{
  require(plyr)
  require(stringr)
  
  scores <- laply(sentences, function(sentence, pos.words, neg.words)
    
  {
    
    # clean up sentences with R's regex-driven global substitute, gsub() function:
    sentence <- gsub('https://','',sentence)
    sentence <- gsub('http://','',sentence)
    sentence <- gsub('[^[:graph:]]', ' ',sentence)
    sentence <- gsub('[[:punct:]]', '', sentence)
    sentence <- gsub('[[:cntrl:]]', '', sentence)
    sentence <- gsub('\\d+', '', sentence)
    sentence <- str_replace_all(sentence,"[^[:graph:]]", " ")
    # and convert to lower case:
    sentence <- tolower(sentence)
    
    # split into words. str_split is in the stringr package
    word.list <- str_split(sentence, '\\s+')
    # sometimes a list() is one level of hierarchy too much
    words <- unlist(word.list)
    
    # compare our words to the dictionaries of positive & negative terms
    pos.matches <- match(words, pos.words)
    neg.matches <- match(words, neg.words)
    
    # match() returns the position of the matched term or NA
    # we just want a TRUE/FALSE:
    pos.matches <- !is.na(pos.matches)
    neg.matches <- !is.na(neg.matches)
    
    # TRUE/FALSE will be treated as 1/0 by sum():
    score <- sum(pos.matches) - sum(neg.matches)
    
    return(score)
  }, pos.words, neg.words, .progress=.progress )
  
  scores.df <- data.frame(score=scores, text=sentences)
  return(scores.df)
}


analysis <- score.sentiment(tweet_clean$text, pos.words, neg.words)
# sentiment score frequency table
table(analysis$score)


analysis %>%
  ggplot(aes(x=score)) + 
  geom_histogram(binwidth = 1, fill = "lightblue")+ 
  ylab("frekans") + 
  xlab("duygu skoru") +
  ggtitle("Tweetlerin duygu skorlari dagilimi histogrami") +
  ggeasy::easy_center_title()


neutral <- length(which(analysis$score == 0))
positive <- length(which(analysis$score > 0))
negative <- length(which(analysis$score < 0))
Sentiment <- c("pozitif","notr","negatif")
Count <- c(positive,neutral,negative)
output <- data.frame(Sentiment,Count)
output$Sentiment<-factor(output$Sentiment,levels=Sentiment)
ggplot(output, aes(x=Sentiment,y=Count))+
  geom_bar(stat = "identity", aes(fill = Sentiment))+
  ggtitle("7500 tweetin duygu tipi grafigi") +
  ggeasy::easy_center_title()


