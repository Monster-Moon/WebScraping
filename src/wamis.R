if(!require(httr)) install.packages('httr'); require(httr)
if(!require(rvest)) install.packages('rvest'); require(rvest)
if(!require(jsonlite)) install.packages('jsonlite'); require(jsonlite)

url = 'http://www.wamis.go.kr/wkw/we_dtdata_list.do'
body_list
url_post = POST(url, body = list(code = '30111131', 
                                 date1 = '20210115',
                                 date2= '20210214'))
url_post$status_code
df = jsonlite::fromJSON(read_html(url_post) %>% html_nodes('p') %>% html_text())[[1]]