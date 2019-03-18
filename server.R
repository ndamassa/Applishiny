

library(wordcloud)
library(stringr)
dbase<-listing<-read.csv("/Users/Junior/Documents/DAMASS/COURS ESG 2018/AppliShiny/dbase.csv", header = TRUE,
                      sep = ",", dec = ".")[, -5]
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


shinyServer( function(input, output){
  
  output$resume<-renderPlotly({
    library(plotly)
    dbbase<-na.omit(dbase)
    dbase$room_type[which(dbase$room_type == 0)] <- 'Entire home/apt'
    dbase$room_type[which(dbase$room_type == 1)] <- 'Private room'
    dbase$room_type[which(dbase$room_type == 2)] <- 'Shared room'
    dbase$room_type <- as.factor(dbase$room_type)
    
     p<-plot_ly(dbase, x = ~price, y = ~number_of_reviews, z = ~minimum_nights, 
                  color = ~room_type, colors = c('blue', 'red', 'green'))%>%
      add_markers()%>%
      layout(scene = list(xaxis = list(title = 'Price'),
                          yaxis = list(title = 'number of reviews'),
                          zaxis = list(title = 'minimum nigths')))
    p
  })#fin image 3d 
  
  output$plotinfo<-renderPlotly({
    p=ggplot(homebase, aes(x=room, y=Observation, fill = room)) + 
      geom_bar(stat='identity', position = "identity")
    p<-ggplotly(p)
    p
  })
  
  
  
  output$mots<-renderPlot({
   wordcloud( (subset(dbase, Categorie == input$Cout))$neighbourhood,
    scale=c(4,0.5), colors = brewer.pal(6, "Dark2"))
              
              
  })
  
  output$nom<-renderPlot({
    wordcloud(dbase$host_name, scale = c(3, .5), 
              colors = brewer.pal(6, 'Dark2'), max.words = input$Noms)
    
    
  })
  
  output$animation2010<-renderPlotly({
    library(sqldf)
    dbase_regroupement<-sqldf("select neighbourhood,room_type, Year, avg(price) as price, 
    sum(number_of_reviews) as reviews,
    sum(minimum_nights) as nb_nights from dbase group by Year,neighbourhood, room_type")
    dbase_regroupement<-na.omit(data.frame(dbase_regroupement))
    dbase_regroupement$room_type<-as.character(dbase_regroupement$room_type)
    
    p <- dbase_regroupement %>%
      plot_ly(
        x = ~price,
        y = ~reviews,
        size = ~nb_nights,
        frame = ~Year,
        text = ~neighbourhood,
        type = 'scatter',
        mode = 'markers',
        
        color = ~room_type,
        showlegend = T
      )
    p
    
  })
  
  
  output$animation2014<-renderPlotly({
    dbase_regroupement1 <-subset(dbase_regroupement, Year >= 2014)
    
    
    p <- dbase_regroupement1 %>%
      plot_ly(
        x = ~price,
        y = ~reviews,
        size = ~nb_nights,
        frame = ~Year,
        text = ~neighbourhood,
        type = 'scatter',
        mode = 'markers',
        
        color = ~room_type,
        showlegend = T
      )
    
    p <- p %>% 
      animation_opts(1000, transition = 500,   easing = "sin", redraw = TRUE) %>%  
      animation_slider( 
        currentvalue = list(prefix = "Year", font = list(color="red"))
          
      )
    p
  })
  
  
  output$animationzoom2018<-renderPlotly({
  dbase1<-mutate(dbase, periode = str_sub(last_review, 1, 7))
  dbase1<-na.omit(dbase1) 
  dbase1<-subset(dbase1, Year == 2018)
  dbase_regroupement2018<-sqldf("select neighbourhood,room_type, periode, avg(price) as price, 
    sum(number_of_reviews) as reviews,
    sum(minimum_nights) as nb_nights from dbase1 group by periode,neighbourhood, room_type")  
  
  p <- dbase_regroupement2018 %>%
    plot_ly(
      x = ~price,
      y = ~reviews,
      size = ~nb_nights,
      frame = ~periode,
      text = ~neighbourhood,
      type = 'scatter',
      mode = 'markers',
      
      color = ~room_type,
      showlegend = T
    )
  
  p
    
  })
  
  library(leaflet)
  output$Localisation<-renderLeaflet({
    
    other <- dbase %>% 
      filter(cout == "cheaper")
    
    top_100 <- dbase %>% 
      filter(cout == "expensive") 
    
    leaflet() %>% setView(lng = 2.345693, lat =  48.86417, zoom = 12) %>%
      addTiles() %>%
      #addPolygons(data = dbase, color = "#444444", weight = 2, opacity = 1) %>%
      addCircleMarkers(  lng = other$longitude, 
                         lat = other$latitude,
                         radius = 2, 
                         stroke = FALSE,
                         color = "blue",
                         fillOpacity = 0.5, 
                         group = "Other"
      ) %>%
      addCircleMarkers(  lng = top_100$longitude, 
                         lat = top_100$latitude,
                         radius = 3, 
                         stroke = FALSE,
                         color = "red",
                         fillOpacity = 0.9, 
                         group = "Top 100"
      )
    
    
    
  })
  
  
})
  
  
  
  
  
  
  
  
  

