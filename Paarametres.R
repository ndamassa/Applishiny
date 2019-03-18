
library(data.table)
library(datasets)
library(lubridate)
library(ggplot2)
library(sqldf)
library(plotly)
library(tm)
library(wordcloud)
library(memoise)
library(shinythemes)
library(dplyr)
library(readr)

# les couleurs de backgru

# red, yellow, aqua, blue, light-blue, green, navy, teal, olive,
# lime, orange, fuchsia, purple, maroon, black.


dbase<-read.csv("dbase.csv", header = TRUE,
                         sep = ",", dec = ".")[1:10, -5]
dbase<-data.frame(dbase, stringsAsFactors = FALSE)
# convertion es date 
dbase$last_review<-as.Date(dbase$last_review,  "%Y-%m-%d")
dbase<-mutate(dbase, Categorie = " ")

for(i in 1:nrow(dbase)){
if(dbase$price[i] >=1000){
  dbase$Categorie[i]<-"expensive"
}
  else{
  dbase$Categorie[i]<-"cheaper"
  }
  
}

dbase$cout<-as.factor(dbase$Categorie)

# ajout de la colonne année 
dbase<-mutate(dbase, Year = year(last_review))

#Evolution du nombre de visites par refernce, type de logement, et par années 
dbase_regroupement<-sqldf("select neighbourhood,room_type, Year, avg(price) as price, sum(number_of_reviews) as reviews,
    sum(minimum_nights) as nb_nights from dbase group by Year,neighbourhood, room_type")

dbase_regroupement<-na.omit(data.frame(dbase_regroupement))
dbase_regroupement$room_type<-as.character(dbase_regroupement$room_type)

 
#proportion par type de logement 
# animation 1 
Observation<-rbind(nrow(subset(dbase, room_type=="Entire home/apt")),
nrow(subset(dbase, room_type=="Private room")),
nrow(subset(dbase, room_type=="Shared room")))
room<-c("Entire home/apt", "Private room", "Shared room")
homebase<-data.frame(room, Observation)

