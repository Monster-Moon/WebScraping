rm(list = ls())
gc(reset = T)

if(!require(rvest)) install.packages('rvest')
if(!require(httr)) install.packages('httr')
if(!require(stringr)) install.packages('stringr')
require(rvest)
require(httr)
require(stringr)

rm(list = ls())
gc(reset = T)

options(scipen = 10)
movie_code = 154255
last_page_guess = 100000

## Last page
naver_movie_url = paste0('http://movie.naver.com/movie/bi/mi/pointWriteFormList.nhn?code=', 
                         movie_code, 
                         '&type=after&isActualPointWriteExecute=false&isMileageSubscriptionAlready=false&isMileageSubscriptionReject=false&page=',
                         last_page_guess)
naver_movie_url_get = GET(naver_movie_url)
last_page = read_html(naver_movie_url_get) %>% 
  html_nodes('div.input_netizen div.paging a span.on') %>% html_text()
last_page = as.numeric(gsub(',','',last_page))

## 
movie_data = NULL
for(page_num in 1:last_page)
{
  tmp_naver_movie_url = paste0('http://movie.naver.com/movie/bi/mi/pointWriteFormList.nhn?code=',
                               movie_code, 
                               '&type=after&isActualPointWriteExecute=false&isMileageSubscriptionAlready=false&isMileageSubscriptionReject=false&page=',
                               page_num)
  tmp_naver_movie_url_get = GET(tmp_naver_movie_url)
  url_body = read_html(tmp_naver_movie_url_get) %>% html_nodes('div.input_netizen div.score_result ul li')
  star_score = url_body %>% html_nodes('div.star_score em') %>% html_text() %>% as.numeric()
  reply = url_body %>% html_nodes('div.score_reple p') %>% html_text() %>% str_trim()
  reply = gsub('^(BEST)|^(관람객)|^(BEST관람객)','',reply)
  temp_data = cbind(star_score,reply)
  movie_data = rbind(movie_data, temp_data)
  cat('\r',paste(rep('=',floor( page_num /last_page * 80)),collapse=''),
      round(page_num / last_page * 100,2),'% completed')
  flush.console()
}

movie_data = data.frame(movie_data, stringsAsFactors = F)