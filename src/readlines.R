
### Scraping rising words in 'https://www.naver.com/' ###

rm(list = ls())
gc(reset = T)
if(!require(stringr)) install.packages('stringr')
require(stringr)
url = 'https://www.naver.com/'
lines = readLines(url, encoding = 'UTF-8')

rising_words_inx = str_detect(lines, '<span class=\"ah_k\">')
rising_words = unique(gsub('<.*?>', '', lines[rising_words_inx]))
rising_words_data = data.frame(rank = 1:length(rising_words), rising_words, stringsAsFactors = F)
save(rising_words_data, file = 'rising_words_data.Rdata')