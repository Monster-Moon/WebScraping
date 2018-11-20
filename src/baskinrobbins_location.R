rm(list = ls())
gc(reset = T)

if(!require(httr)) install.packages('httr')
if(!require(rvest)) install.packages('rvest')
if(!require(jsonlite)) install.packages('jsonlite')
require(httr)
require(rvest)
require(jsonlite)

baskin_store_url = 'http://www.baskinrobbins.co.kr/store/map.php'
scs = html(GET(baskin_store_url)) %>% 
  html_nodes('form#nform.form p.location span select.location_1 option') %>% html_text()
scs = scs[-1]

query_data = NULL
for(i in 1:length(scs))
{
  sido_url = 'http://www.baskinrobbins.co.kr/store/addr_gugun_ajax.php'
  scg = read_html(POST(sido_url, body = list( sido = scs[i]))) %>% 
    html_nodes('option') %>% html_text()
  scg = scg[-1]
  temp_query_data = cbind( scs = rep(scs[i], length(scg)), scg)
  query_data = rbind(query_data, temp_query_data)
}

baskin_locat_url = paste0('http://www.baskinrobbins.co.kr/store/list_ajax.php?ScS=', 
                          query_data[, 1],'&ScG=',query_data[, 2],'&ScWord=')

baskin_locat_list = lapply(baskin_locat_url, function(locat_url) jsonlite::fromJSON(txt = locat_url)$list)
baskin_locat_data = do.call('rbind', baskin_locat_list)

