rm(list=ls())
gc(reset= T)

if(!require(httr)) install.packages('httr')
if(!require(rvest)) install.packages('rvest')

end_num = 10
display_num = 10

client_id = '************';
client_secret = '************';

start_point = seq(1, end_num, display_num)
header = add_headers('X-Naver-Client-Id' = client_id,'X-Naver-Client-Secret' = client_secret)

query = 'Monster-moon'
query = iconv(query, to = 'UTF-8', toRaw = T)[[1]] %>% 
  paste(., collapse = '%') %>% paste0('%', .) %>%
  toupper()

blog_data = NULL
for(i in 1:length(start_point))
{
  blog_api_url = paste0('https://openapi.naver.com/v1/search/blog.xml?query=',
                        query, 
                        '&display=',
                        display_num,
                        '&start=',
                        start_point[i],'&sort=sim')
  blog_api_url_get = GET(blog_api_url, header)
  if(blog_api_url_get$status_code != 200) break
  
  blog_api_url_body = read_xml(blog_api_url_get)
  title = blog_api_url_body %>% xml_nodes('item title') %>% xml_text()
  bloggername = blog_api_url_body %>% xml_nodes('item bloggername') %>% xml_text()
  postdate = blog_api_url_body %>% xml_nodes('postdate') %>% xml_text()
  link = blog_api_url_body %>% xml_nodes('item link') %>% xml_text()
  description = blog_api_url_body %>% xml_nodes('item description') %>% html_text()
  temp_data = cbind(title, bloggername, postdate, link, description)
  blog_data = rbind(blog_data, temp_data)
  cat(i, '\n')
}

blog_data = data.frame(blog_data, stringsAsFactors = F)
head(blog_data)


