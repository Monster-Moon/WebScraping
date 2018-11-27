rm(list = ls())
gc(reset = T)

if(!require(httr)) install.packages('httr')
if(!require(stringr)) install.packages('stringr')

require(httr)
require(stringr)

address_char = '서울'
address_char = iconv(address_char, to = 'UTF-8', toRaw = T)[[1]] %>%
  paste(., collapse = '%') %>% paste0('%', .)
ediya_url = paste0('https://www.ediya.com/inc/ajax_adm_map.php?gubun=map&address=', address_char)
ediya_url_post = GET(ediya_url)
if(ediya_url_post$status_code == 200) print('Great !')
lines = read_html(ediya_url_post) %>% html_text()
lines_splited = str_split(lines, '///')[[1]]
ediya_location = lines_splited[str_detect(lines_splited, '^(서울).*\\(.*?\\)$')]
