library(XML)
library(RCurl)
library(RSelenium)
library(plyr); library(dplyr)
library(gtools)
checkForServer()
startServer()
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
newLink <- "http://www.meetup.com/London-Kaggle-Meetup/members/?offset=%d&sort=last_visited&desc=1"
for (page in 2:totalPages)
{
  link <- sprintf(newLink, (page-1)*20)
  remDr$navigate(link)
  htmlTree <- htmlParse(remDr$getPageSource()[[1]])
  name <- c(name, xpathSApply(htmlTree, "//a[@class='memName']", xmlValue))
  href <- c(href, xpathSApply(htmlTree, "//a[@class='memName']/@href"))
}
df <- data.frame(id = 1:length(name), name = name, href = href) %>% unique
df$intro = ''
listInfo <- list()
#for (i in 1:nrow(df))
for (i in 9:nrow(df))
{
  remDr$navigate(df$href[i])
  Sys.sleep(4)
  htmlTree <- htmlParse(remDr$getPageSource()[[1]])
  moreGroups <- xpathSApply(htmlTree, "//a[@id='see-more-groups-toggle']", xmlValue)
  if (!invalid(moreGroups))
  {
   remDr$findElement(using='xpath', "//a[@id='see-more-groups-toggle']")$clickElement()
   meetups <- xpathSApply(htmlTree, "//div[@class='D_name']/a", xmlValue)
   tryCatch({
     intro <- xpathSApply(htmlTree, "//div[@class='D_memberProfileContentItem']/p", xmlValue) %>%
       last
     df$intro[i] = intro
   },error = function(e){x <- 1:10}
  )
  listInfo[[i]] <- data.frame(id = df$id[i], meetups = meetups)
  }
}
