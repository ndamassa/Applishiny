library(shiny)
library(shinydashboard)
library(animation)
library(gganimate)
library(leaflet)
library(plotly)
library(lubridate)
library(sqldf)

dashboardPage(skin = "purple",
  dashboardHeader(title = strong("DATAVIZ 2019")),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Accueil", tabName = 'accueil', icon = icon('apple')),
      
      menuItem("Presentation", tabName = "presentation", 
               icon = icon('dashboard'),
               menuSubItem("Description", tabName = 'description', 
                           icon =  icon("book")),
               
               menuSubItem("Informations", tabName = 'informations',
                           icon = icon('info'))
              
               
               
               ),
      menuItem("Analyse", tabName = "analyse", 
               icon = icon('line-chart'),
              menuSubItem("Prix Appat", tabName = 'appat',icon = icon('users')),
              menuSubItem("Proprietaires", tabName = 'proprio', icon =  icon('street-view')),
              menuSubItem("Animation", tabName = 'animation', icon= icon('chart-area')),
              menuSubItem("Geolocalisation", tabName = 'localisation', icon = icon('location-arrow'))
               
               
               ),#fin analyse
      
      menuItem("Remerciements", tabName = "merci",
               icon = icon("users")),
      menuItem("Nous contacter", tabName = 'contacts', icon = icon('envelope-open')),
      
      menuItem("Aide", tabName = "aide", 
               icon = icon('question-circle'))
      
      
      
    )#fin sidebarmenu
    
  ),#fin sidebar

  
  dashboardBody(
  tabItems(
    
#tab1 description
  tabItem(tabName = 'description',
           
 box(width = 5, height = 9, status = 'warning',
                solidHeader = TRUE, collapsible = FALSE,
                 title = "Problématique",
     strong('Variation des prix de logement sur Airbnb  a Paris')),
 
            
box(width = 5, height = 9, status = 'warning',
                solidHeader = TRUE, collapsible = TRUE,
                title = "Données",
    
    tags$li(strong('source:'), 'donnees open source'),
    tags$li(strong('historique:'), '2010-2018')
    )  

),#tab1


#tab2 presentattion
tabItem(tabName = 'presentation'
        
       ),# fin tab presentation

#tab acceil
tabItem(tabName = 'accueil',
        box(strong(h2(Sys.Date())), background = 'green', 
            title = 'Date', footer = TRUE),
        box(background = 'green', title = 'Module',
            strong(h2('Projet Data Visualisation' 
                  )), footer = TRUE),
       
        
        box(
        tags$img(src = 'image3.jpg', width = 450)
                  ),
        box(
        tags$img(src = 'image2.jpg', width = 450, height = '350px')
        ),
        
        box(title = strong("Auteurs"), background = 'aqua', width  = 12,
            tags$li("Joackim"),
            tags$li("Antoine"),
            tags$li("N kmle Damassa")
            )
        
          
        
),#item accueil

#tab information
tabItem(tabName = 'informations',
                  
        infoBox( "Le nombre total d'observations",
           h1(strong(nrow(dbase))), icon = icon("list-ul"), fill = TRUE
           ),
        
        infoBox("Le nombre nombre total de variables", 
            h1(strong(ncol(dbase))), icon = icon("columns"), fill = TRUE,
            width = 4),
            
        infoBox("Departement", 
                    h1(strong("PARIS")), icon = icon("gg-circle"), fill = TRUE),
        
        box(width = 12, height = 650,
        plotlyOutput("plotinfo"),
        
        br(), br(),br(),
    #),
       
  infoBox(strong('Entire home/apt'),   color = 'red',
  strong(h1('86.811 %')), fill = TRUE, icon = icon("home")  
    ),
  
  infoBox(strong('Private room'), color = 'green',
  strong(h1('12.405 %')), fill = TRUE, icon = icon("bed")
      ),
      
      
    infoBox(title = strong('Shared room'), color = 'blue', 
    strong(h1('0.785 %')), fill = TRUE, icon = icon("users")    
  
      )
    )
        
),#tab information


#tab appat
tabItem(tabName = 'appat', 
        
     fluidPage(   
      fluidRow(
        
         box(title = strong('Nombe de Visites et Locations par rapport au prix'), 
             background = 'navy', width = 12, height = 500,
                plotlyOutput('resume', height = "500px", width = "1100px")
                )),
            
      
            fluidRow(box(title = "Neighbord", background = 'navy', width = 12, height = 700,
                  selectInput("Cout", "Selectionnez la catégorie de logement:", 
                              c( "cheaper","expensive" )),
                     plotOutput('mots', height = "500px", width = "1100px")
                  )
      )
  ) #fin fluid page 
  
  
),# fin appat
tabItem(tabName = 'animation',
        
        fluidPage(
        
        box(title = 'évolution des locations 2010-2018', background = 'aqua',
            plotlyOutput('animation2010')),
        box(title = 'évolution des locations 2014-2018', background = 'aqua',
            plotlyOutput('animation2014')),
        box(title = 'Zoom sur 2018', width = 12, background = 'aqua',
        plotlyOutput('animationzoom2018', height = "500px", width = "1060px"))
        
        )
),#fin animation

tabItem(tabName = 'localisation',
        
        fluidPage(
          box(title = strong("Répartion géographique des appats selon le prix"), width = 12, height = 1200,
              leafletOutput('Localisation', height = "800px"))
          
        )
        
    ),


#tab proprio
tabItem(tabName = 'proprio',
        fluidPage(
          
          box(title = 'Proprietaires', width = 11.5, height = 700,
              sliderInput('Noms', "Selectionnez le nombre de mots",
                          min = 1, max = 50, value = 25), background = 'navy',
          plotOutput('nom', height = "500px", width = "1060px")
              
          )
          
          
      )

        
 ),#fin proprio



tabItem(tabName = 'merci', 
        
   fluidPage(
     tags$img(src = 'merci.jpg', width = 1100)
     
        )     
        
      ),#fin Remerciement

tabItem(tabName = 'contacts',
    fluidPage(
        box(title = "Formulaire de contact", width = 1200, height = 12,
        textInput('nom', label = 'Entrez votre Nom', width = 500),
        textInput('prenom', label = 'Entrez votre prenom', width = 500),
        textInput('mail', label = 'Entrez votre mail', width = 500),
        textAreaInput("message", 'Saisissez votre message', width = 500, height = 120),
        passwordInput('motpass', "Entrez votre mot de pass", width = 200),
        submitButton("Envoyer")
        
        )
))

  )#items



)#fin body
  
  
  
  
)#fin de la Page 