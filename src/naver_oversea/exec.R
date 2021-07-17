rm(list = ls())
gc(reset = T)

if(!require(httr)) install.packages('httr'); require(httr)
if(!require(rvest)) install.packages('rvest'); require(rvest)
if(!require(dplyr)) install.packages('dplyr'); require(dplyr)
if(!require(stringr)) install.packages('stringr'); require(stringr)
if(!require(jsonlite)) install.packages('jsonlite'); require(jsonlite)
if(!require(data.table)) install.packages('data.table'); require(data.table)

load('src.Rprofile')

tmp_data = naver_func(query = '자전거', pages = 1, sleep = 1)

## gmarket [[1]]
head(tmp_data[[1]])
mall_name = gmarket_mall_search_func(data = tmp_data[[1]])
mall_name_uniq = unique(mall_name)
gmarket_result = gmarket_func(mall_name_uniq, pages = 1, sleep = 0)
write.csv(gmarket_result, 'gmarket_result.csv')

## auction [[2]]


## 11st [[3]]
head(tmp_data[[3]])
prdno = str_extract(tmp_data[[3]]$X6, '(?<=prdNo=)[0-9]{1,}(?=&)')
url = paste0('http://www.11st.co.kr/products/', prdno)
st_shop_name = st_shop_code = character(length(url))
for(i in 1:length(url))
{
  url_get = GET(url[i])
  tmp_nodes = read_html(url_get) %>% 
    html_nodes('div.b_product_store h1.c_product_store_title a') 
  
  st_shop_name[i] = tmp_nodes %>%
    html_text() %>% 
    gsub('\n| ', '', .)
  
  st_shop_code[i] = tmp_nodes %>% 
    html_attr('href') %>%
    str_extract('(?<=stores/)[0-9]{1,}(?=\\?)')
  cat(paste0(i , ' / ', length(url)), '\n')
}

## mall_name, item_code, image_url, item_name, item_value

st_shop_name
st_shop_code
mall_name_utf = lapply(st_shop_name, function(x) iconv(x, from = 'UTF-8', to = 'UTF-8', toRaw = T)[[1]] %>%
                         paste(., collapse = '%') %>% paste0('%', .) %>%
                         toupper()) %>% do.call('c', .)
mall_url = paste0('https://search.11st.co.kr/Search.tmall?kwd=', mall_name_utf)

url_get = GET('https://shop.11st.co.kr/stores/546586/category?pageNo=1')
read_html(url_get) %>%
  html_nodes('div.store_product')
 
url_get = GET(mall_url[1])
read_html(url_get) %>% 
  html_nodes('div.search_content.react_app') %>%
  html_children()










