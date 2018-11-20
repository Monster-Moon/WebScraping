rm(list=ls())
gc(reset= T)

if(!require(jpeg)) install.packages('jpeg')
if(!require(httr)) install.packages('httr')
if(!require(rvest)) install.packages('rvest')
if(!require(jsonlite)) install.packages('jsonlite')
require(jpeg)
require(httr)
require(rvest)
require(jsonlite)

client_id = '************';
client_secret = '************';

header = add_headers('X-Naver-Client-Id' = client_id,
                     'X-Naver-Client-Secret' = client_secret)

url = paste0("https://openapi.naver.com/v1/vision/celebrity")
url_post = POST(url, config = header, body = list('image' = httr::upload_file('Monster-moon.jpg')),
                write_disk('Monster-moon.json', overwrite = T))

if(url_post$status_code == 200) print('Great !')
result = jsonlite::fromJSON('Monster-moon.json')
result$faces$celebrity
