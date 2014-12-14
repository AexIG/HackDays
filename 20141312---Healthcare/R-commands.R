#Use ebola data to try and plot an interactive plot showing the values
#with date as our interactive column.
library(reshape2)
library(googleVis)
ebola_data <- read.csv('Data//ebola-data-db-format.csv')
#ebola_data <- data.table(ebola_data)
ebola_data$Date <- as.Date(ebola_data$Date)
#Data is in long form, need it in wide
#library(reshape2)
ebola_wide <- dcast(ebola_data, Country + Date ~ Indicator)
ebola_wide2 <- ebola_wide
#Fill in missing values with zeroes.
#Know this is not the correct thing to do, but will mean that 
#country will always appear.
ebola_wide2[which(is.na(ebola_wide), arr.ind = TRUE)] = 0
#Want different colours to represent different counties, but idvar needs to
#be set to country as well, which seemed to cause problems!
#Create a dummy variable for country to be used
ebola_wide2$country2 <- ebola_wide$Country
M <- gvisMotionChart(ebola_wide2, idvar='country2', timevar='Date', 
                     xvar = 'Case fatality rate (CFR) of confirmed Ebola cases', 
                     yvar = 'Number of confirmed Ebola cases in the last 21 days', 
                     colorvar = 'Country')
plot(M)
