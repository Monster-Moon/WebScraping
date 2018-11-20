
### Scraping real time price in 'https://finance.naver.com/item/sise.nhn?code=035420' ###

rm(list = ls())
gc(reset = T)
if(!require(RCurl)) install.packages('RCurl')
if(!require(XML)) install.packageS('XML')
require(RCurl)
require(XML)

naver_finance_scrap_fun = function(page_num)
{
  url = paste0('https://finance.naver.com/item/sise_time.nhn?code=035420&thistime=20181108130325&page=', page_num)
  tb = readHTMLTable(doc = getURL(url), encoding = 'UTF-8')[[1]]
  tb = na.omit(tb)
  tb = tb[apply(tb, 1, function(x) any(x != '')),]
  colnames(tb) = c('체결시각', '체결가', '전일비', '매도', '매수', '거래량', '변동량')
  return(tb)
}

page_num_vec = 1L:30L
naver_finance_data_list = lapply(page_num_vec, naver_finance_scrap_fun)
naver_finance_data_list = naver_finance_data_list[1:min(which(unlist(lapply(naver_finance_data_list, nrow)) < 10))]
naver_finance_data = do.call('rbind', naver_finance_data_list)

save(naver_finance_data, file = 'naver_finance_data.Rdata')





