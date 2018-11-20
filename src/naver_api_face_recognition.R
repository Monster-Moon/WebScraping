rm(list=ls())
gc(reset= T)

if(!require(jpeg)) install.packages('jpeg')
if(!require(httr)) install.packages('httr')
if(!require(rvest)) install.packages('rvest')
require(jpeg)
require(httr)
require(rvest)

client_id = '************';
client_secret = '************';

header = add_headers('X-Naver-Client-Id' = client_id,
                     'X-Naver-Client-Secret' = client_secret)

url = paste0("https://openapi.naver.com/v1/vision/face")
url_post = POST(url, config = header, 
                body = list('image' = httr::upload_file('Monster-moon.jpg')),
                write_disk('Monster-moon.json', overwrite = T))

if(url_post$status_code == 200) print('Great!')
result = jsonlite::fromJSON('Monster-moon.json')

img = readJPEG('Monster-moon.jpg')
img_dim = dim(img)
plot(1:2, 1:2, type = 'n', xlim = c(1, img_dim[2]), ylim = c(1, img_dim[1]))
rasterImage(img, 1, 1, img_dim[2], img_dim[1])
rect(img_dim[2] - result$faces$roi$x, 
     img_dim[1] - result$faces$roi$y, 
     img_dim[2] - result$faces$roi$x - result$faces$roi$width, 
     img_dim[1] - result$faces$roi$y - result$faces$roi$height, border = 'red')

