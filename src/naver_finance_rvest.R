rm(list=ls())
gc(reset=T)

if(!require(httr)) install.packages('httr')
if(!require(rvest)) install.packages('rvest')
if(!require(stringr)) install.packages('stringr')

require(httr)
require(rvest)
require(stringr)

kospi_data = NULL


options(scipen = 10)
i = 1
kospi_url_tmp = paste0("http://finance.naver.com/sise/sise_index_day.nhn?code=KOSPI&page=",i)
kospi_url_tmp_get = GET(url, Encoding = 'UTF-8')
last_page = kospi_url_tmp_get %>% read_html() %>% html_nodes('body div.box_type_m table.Nnavi td.pgRR a') %>%
  html_attr('href')
last_page_num = as.numeric(str_extract(last_page, '[0-9]{1,}$'))

kospi_data = NULL
for(page_num in 1:last_page_num)
{
  kospi_url_tmp = paste0("http://finance.naver.com/sise/sise_index_day.nhn?code=KOSPI&page=", page_num)
  kospi_url_tmp_get = GET(url)
  
  kospi_url_tmp_tb = kospi_url_tmp_get %>% read_html() %>% html_nodes('div.box_type_m table')
  kospi_url_tmp_tb = kospi_url_tmp_tb[[1]] %>% html_table(., fill = T) %>% na.omit()
  
  kospi_data = rbind(kospi_data, kospi_url_tmp_tb)
  cat(page_num, "\n")
}

kospi_data
