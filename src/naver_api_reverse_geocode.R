rm(list=ls())
gc(reset= T)

if(!require(httr)) install.packages('httr')
if(!require(rvest)) install.packages('rvest')
require(httr)
require(rvest)

client_id = '************';
client_secret = '************';

header = add_headers('X-Naver-Client-Id' = client_id,'X-Naver-Client-Secret' = client_secret)
lat_point = 37.5806856
long_point = 127.0541885
query = paste(long_point, lat_point, sep = ',')
query = iconv(query, to = 'UTF-8', toRaw = T)[[1]] %>% 
  paste(., collapse = '%') %>% paste0('%', .) %>%
  toupper()

map_api_url = paste0('https://openapi.naver.com/v1/map/reversegeocode.xml?query=', query)
map_api_url_get = GET(map_api_url, header)
if(map_api_url_get$status_code == 200) print('Great !')
address_locat = read_xml(map_api_url_get) %>% xml_nodes('items item address') %>%
  xml_text()

