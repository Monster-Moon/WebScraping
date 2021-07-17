rm(list = ls())
gc(reset = T)

if(!require(httr)) install.packages('httr'); require(httr)
if(!require(rvest)) install.packages('rvest'); require(rvest)
if(!require(dplyr)) install.packages('dplyr'); require(dplyr)
if(!require(stringr)) install.packages('stringr'); require(stringr)
if(!require(jsonlite)) install.packages('jsonlite'); require(jsonlite)


.naver_tmp_fun = function(x, pages_, sleep_)
{
  search_data = NULL
  for(page_inx in 1:pages_)
  {
    url_addr_tmp = paste0(x, '&pagingIndex=', page_inx)
    url_get = GET(url_addr_tmp)
    url_json = read_html(url_get) %>% 
      html_nodes('script#__NEXT_DATA__') %>% 
      html_text() %>%
      fromJSON()
    names(url_json$props$pageProps$initialState$products$list$item)
    gsub('\\|\\|', '', url_json$props$pageProps$initialState$products$list$item$dlvryCont)
    
    tmp = cbind(
      url_json$props$pageProps$initialState$products$list$item$productName,
      url_json$props$pageProps$initialState$products$list$item$mallName,
      url_json$props$pageProps$initialState$products$list$item$maker,
      url_json$props$pageProps$initialState$products$list$item$lowPrice,
      url_json$props$pageProps$initialState$products$list$item$reviewCount,
      url_json$props$pageProps$initialState$products$list$item$mallProductUrl,
      # url_json$props$pageProps$initialState$products$list$item$overseaTp,
      url_json$props$pageProps$initialState$products$list$item$category1Name,
      url_json$props$pageProps$initialState$products$list$item$category2Name,
      url_json$props$pageProps$initialState$products$list$item$category3Name,
      url_json$props$pageProps$initialState$products$list$item$category4Name,
      substr(url_json$props$pageProps$initialState$products$list$item$openDate, 1, 8),
      gsub('\\|\\|', '', url_json$props$pageProps$initialState$products$list$item$dlvryCont)) %>% data.frame()
    if(page_inx >= 2)
    {
      if(search_data$X6[nrow(search_data)] == tmp$X6[nrow(tmp)] | nrow(tmp) == 0) break
    }
    search_data = rbind(search_data, tmp)
    cat(page_inx, '\n')
    Sys.sleep(sleep_)
  }
  return(search_data)
}

.naver_func = function(query, pages, sleep = 3)
{
  query_utf = iconv(query, to = 'UTF-8', toRaw = T)[[1]] %>% 
    paste(., collapse = '%') %>% paste0('%', .) %>%
    toupper()
  
  mall_seq = c(24, 114, 17703)
  site_list = lapply(mall_seq, function(x) paste0('https://search.shopping.naver.com/search/all?frm=NVSHOVS&mall=',
                                                  x, 
                                                  '&origQuery=pagingIndex=1&pagingSize=80&productSet=overseas&query=',
                                                  query_utf, 
                                                  '&sort=review&rel&timestamp=&viewType=list'))
  
  return_data = lapply(site_list, .naver_tmp_fun, pages_ = pages, sleep_ = sleep)
  # write.csv(search_data, paste0(query, '_', Sys.Date(), '.csv'))
  
}

naver_func = function(query, pages, sleep = 3)
{
  result = .naver_func(query, pages, sleep)
  return(result)
}

gmarket_mall_search_func = function(data)
{
  mall_name = numeric(nrow(data))
  url_vec = paste0('http://item.gmarket.co.kr/DetailView/Item.asp?', str_extract(data$X6, 'goodscode=[0-9]{1,}'))
  for(i in 1:nrow(data))
  {
    # tmp_url = data$X6[i]
    # tmp_url = paste0('http://item.gmarket.co.kr/DetailView/Item.asp?',
    #                  str_split(tmp_url, '\\?')[[1]][2])
    tmp_url_get = GET(url_vec[i])
    if(tmp_url_get$status_code != 200) next;
    
    tmp_url_html = read_html(tmp_url_get)
    mall_name_tmp = tmp_url_html %>% 
      html_nodes('div.item-topinfowrap span.text__seller') %>% 
      html_text() %>%
      gsub('\r|\n|\t', '', .)
    
    if(length(mall_name_tmp) != 1) next;
    mall_name[i] = mall_name_tmp
    cat(paste0(i , ' / ', nrow(data)), '\n')
  }
  return(mall_name)
}

.gmarket_func = function(mall_name, pages, sleep = 0)
{
  entire_data = NULL
  for(mall_name_inx in mall_name)
  {
    mall_name_utf = iconv(mall_name_inx, from = 'UTF-8', to = 'UTF-8', toRaw = T)[[1]] %>%
      paste(., collapse = '%') %>% paste0('%', .) %>%
      toupper()
    item_data = NULL
    for(page_inx in 1:pages)
    {
      tmp_mall_url = paste0('https://browse.gmarket.co.kr/search?keyword=',
                            mall_name_utf, '&k=0&p=', page_inx)
      tmp_mall_get = GET(tmp_mall_url) 
      if(tmp_mall_get$status_code != 200) next;
      tmp_mall_info = tmp_mall_get %>% read_html() %>% html_nodes('div.box__item-container')
      
      if(length(tmp_mall_info) == 0) break;
      item_code = tmp_mall_info %>% html_nodes('div.box__image a') %>% html_attr('href') %>%
        str_split('goodscode=') %>% lapply(., function(x) x[2]) %>% do.call('c', .)
      image_url = paste0('http://gdimg.gmarket.co.kr/', item_code, '/still/600')  
      item_box_info = tmp_mall_info %>% html_nodes('div.box__information')
      item_name = item_box_info %>% html_nodes('div.box__item-title span.text__item') %>% html_attr('title')
      item_value = item_box_info %>% html_nodes('div.box__item-price strong.text.text__value') %>% html_text()
      item_buy_count = item_box_info %>% html_nodes('div.box__information-score ul.list__score') %>% html_text()
      tmp_item_data = data.frame(item_code, image_url, item_name, item_value, item_buy_count)
      
      item_data = rbind(item_data, tmp_item_data)
      Sys.sleep(sleep)
    }
    item_data = cbind(mall_name_inx, item_data)
    entire_data = rbind(entire_data, item_data)
    cat(mall_name_inx, '\n')
  }
  return(entire_data)
}

gmarket_func = function(mall_name, pages, sleep)
{
  result = .gmarket_func(mall_name, pages, sleep)
  return(result)
}


class(naver_func) = 'Function'
class(gmarket_mall_search_func) = 'Function'
class(gmarket_func) = 'Function'

print.Function = function()
{
  NULL
}

save.image(file = 'src.Rprofile')

