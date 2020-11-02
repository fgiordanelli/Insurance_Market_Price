library(shiny)
library(dplyr)
library(ggplot2)
library(rsconnect)
library(DT)
library(rstatix)
dados <- read.csv("boxplot (1).csv")

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    
    title = "Estatísticas e Gráficos para comparar prêmios das seguradoras", sidebarLayout(sidebarPanel(width = 2,selectInput("UF","UF:", choices = unique(dados$UF),multiple = F),
                                                                                                        uiOutput("secondSelection"),
                                                                                                        #selectInput("LOCAL","Local",choices =  unique(dados$LOCAL),multiple = T),
                                                                                                        selectInput("BONUS","BONUS:", choices = unique(dados$BONUS)),
                                                                                                        selectInput("VEICULO","Veículos",choices =  unique(dados$VEICULO),multiple = T),
                                                                                                        selectInput("SEGURADORA","Seguradora",choices =  unique(sort(dados$SEGURADORA)),multiple = T)),
                                                                                           #checkboxGroupInput("VALOR", "Selecione", unique(dados$FLAG))),
                                                                                           #selectInput("FLAG","Selecione",choices =  unique(dados$FLAG),multiple = T)),                          
                                                                                           mainPanel(
                                                                                               tabsetPanel(type = "tab",
                                                                                                           #tabPanel("Base",DT::dataTableOutput("Dados")),
                                                                                                           tabPanel("Gráfico prêmio médio",plotOutput("dadosPlot2")),
                                                                                                           tabPanel("Boxplot prêmio e franquia",plotOutput("dadosPlot")),
                                                                                                           tabPanel("Test T pareado - Não paramétrico",verbatimTextOutput("Ttest"))
                                                                                                           
                                                                                               )
                                                                                           )
    )
)
)