#Initial bit of data munging (remove NAs)
setwd('west-africa-ebola-outbreak/')
flights <- read.csv('Data/flights.csv')
newFlights <- filter(flights, complete.cases(flights) == TRUE)
dim(newFlights)

#Use ebola data to try and plot an interactive plot showing the values
#with date as our interactive column.
ebola_data <- read.csv('Data//ebola-data-db-format.csv')
ebola_data <- data.table(ebola_data)
ebola_data$Date <- as.Date(ebola_data$Date)
#Data is in long form, need it in wide
library(reshape2)
ebola_wide <- dcast(ebola_data, Country + Date ~ Indicator)
ebola_wide2 <- ebola_wide
#Fill in missing values with zeroes.
#Know this is not the correct thing to do, but will mean that 
#country will always appear.
ebola_wide2[which(is.na(ebola_wide), arr.ind = TRUE)] = 0
#Want different colours to represent different counties, but idvar needs to
#be set to country as well, which seemed to cause problems!
#Create a dummy variable for country to be used
ebola_wide$country2 <- ebola_wide$Country
M <- gvisMotionChart(ebola_wide2, idvar='country2', timevar='Date', 
                     xvar = 'Case fatality rate (CFR) of confirmed Ebola cases', 
                     yvar = 'Number of confirmed Ebola cases in the last 21 days', 
                     colorvar = 'Country')
plot(M)

#Let's look more closely at data relating to Guinea
medicine <- read.csv('Data/2014-12-03.csv')
#First thing is that epi.week cannot be used
#Split in the word 'to'
date_breakdown <- str_split(medicine$Epi.week, 'to')
source('date_sync.R')
medicine$date_from <- as.Date(sapply(date_breakdown, date_synchronisation), format = '%d %B %Y')
medicine$date_to <- as.Date(sapply(date_breakdown,function(x) x[2]), format = '%d %B %Y')

# #===================================================================
# #Attempted to replicate plot from above, but failed. Look at later
# #Use same thing as before
# #Turn into wide format
# red_medicine = medicine[c(
#   "Location",          "Ebola.measure",
#   "Case.definition",   "Ebola.data.source",         
#   "Numeric", "date_from"
# )]
# red_medicine <- filter(red_medicine, Ebola.measure == 'Number of cases')
# red_medicine$Ebola.measure <- NULL
# medicine2 <- dcast(red_medicine, 
#                    Location + date_from ~ Case.definition, 
# #                   Ebola.data.source + Case.definition + Location + date_from ~ Ebola.measure, 
#                    value.var = 'Numeric', fun.aggregate = sum)
# M2 <- gvisMotionChart(medicine2, idvar='Location', timevar='date_from', 
#                      xvar = 'Probable', 
#                      yvar = 'Suspected')
# #, 
# #                     colorvar = 'Location')
# plot(M2)
# #===================================================================
