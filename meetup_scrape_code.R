library(XML)
library(RCurl)
library(RSelenium)
link <- "http://www.meetup.com/London-Kaggle-Meetup/"
remDr <- remoteDriver(browserName = 'firefox')
remDr$open(silent = TRUE)
remDr$navigate(link)
try(elem <- remDr$findElement(using = 'xpath', value = "//a[contains(@href, 'London-Kaggle-Meetup/members')]"))
elem$clickElement()
htmlTree <- htmlParse(remDr$getPageSource()[[1]])
name <- xpathSApply(htmlTree, "//a[@class='memName']", xmlValue)
href <- xpathSApply(htmlTree, "//a[@class='memName']/@href")
totalPages <- xpathSApply(htmlTree, "//li[contains(@class, 'nav-pageitem')]/a", xmlValue) %>% head(-1) %>% as.numeric %>% max
newLink <- "http://www.meetup.com/London-Kaggle-Meetup/members/?offset=%d&sort=last_visited&desc=1   "
for (page in 2:totalPages)
{
  link <- sprintf(newLink, (page-1)*20)
  remDr$navigate(link)
  htmlTree <- htmlParse(remDr$getPageSource()[[1]])
  name <- c(name, xpathSApply(htmlTree, "//a[@class='memName']", xmlValue))
  href <- c(href, xpathSApply(htmlTree, "//a[@class='memName']/@href"))
}
df <- data.frame(name = name, href = href) %>% unique
