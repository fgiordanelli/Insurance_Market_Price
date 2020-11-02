library(shiny)
library(dplyr)
library(ggplot2)
library(rsconnect)
library(DT)
library(rstatix)
dados <- read.csv("boxplot (1).csv")

shinyServer(function(input, output) {
    
    output$secondSelection <- renderUI({
        selectInput("LOCAL", "LOCAL:", choices = dados[dados$UF == input$UF,"LOCAL"],multiple = T)
    })
    
    dados1<-reactive({ 
        dados %>%
            filter(UF %in% input$UF & LOCAL %in% input$LOCAL & BONUS == input$BONUS  &  VEICULO %in% input$VEICULO &  SEGURADORA %in% input$SEGURADORA & FLAG == "PREMIO") %>%
            group_by(BONUS,UF,VEICULO, SEGURADORA, FLAG) %>%  summarise(VALOR = mean(VALOR),.groups = 'drop')
    })
    
    dados1_media<-reactive({  
        dados1() %>%
            group_by(VEICULO) %>%
            summarise(MEDIA = mean(VALOR), .groups = 'drop') %>% mutate(MEDIA2 = "MÉDIA")
    })
    
    dados2<-reactive({ 
        dados %>%
            filter(UF %in% input$UF & LOCAL %in% input$LOCAL & BONUS == input$BONUS  &  VEICULO %in% input$VEICULO &  SEGURADORA %in% input$SEGURADORA & FLAG == "FRANQUIA") %>%
            group_by(BONUS,UF,VEICULO, SEGURADORA, FLAG) %>%  summarise(VALOR = mean(VALOR), .groups = 'drop')
    })
    
    dados2_media<-reactive({  
        dados2() %>%
            group_by(VEICULO) %>%
            summarise(MEDIA = mean(VALOR), .groups = 'drop') %>%
            mutate(MEDIA2 = "MÉDIA")
    })
    
    dados3<-reactive({ 
        dados %>%
            filter(UF %in% input$UF & LOCAL %in% input$LOCAL & BONUS == input$BONUS  &  VEICULO %in% input$VEICULO &  SEGURADORA %in% input$SEGURADORA) %>%
            group_by(LOCAL,BONUS,UF,VEICULO, SEGURADORA, FLAG) %>%
            summarise(VALOR = mean(VALOR), .groups = 'drop')
    })
    
    output$Ttest <-  renderPrint({
        
        A <- 
            B <- dados1() %>% filter(SEGURADORA %in% c("PORTO","LIBERTY")) %>% arrange(SEGURADORA,VEICULO)
        C <- dados1() %>% filter(SEGURADORA %in% c("PORTO","SAS")) %>% arrange(SEGURADORA,VEICULO)
        D <- dados1() %>% filter(SEGURADORA %in% c("PORTO","TOKIO")) %>% arrange(SEGURADORA,VEICULO)
        E <- dados1() %>% filter(SEGURADORA %in% c("PORTO","YOUSE")) %>% arrange(SEGURADORA,VEICULO)
        
        print("PORTO X HDI")
        
        print(wilcox.test(VALOR ~ SEGURADORA, data = (dados1() %>% filter(SEGURADORA %in% c("PORTO","HDI")) %>% arrange(SEGURADORA,VEICULO)),exact = FALSE, paired = TRUE))
        
        print("PORTO X LIBERTY")
        
        print(wilcox.test(VALOR ~ SEGURADORA,  data = (dados1() %>% filter(SEGURADORA %in% c("PORTO","LIBERTY")) %>% arrange(SEGURADORA,VEICULO)),exact = FALSE, paired = TRUE))
        
        print("PORTO X SAS")
        
        print(wilcox.test(VALOR ~ SEGURADORA, data = (dados1() %>% filter(SEGURADORA %in% c("PORTO","SAS")) %>% arrange(SEGURADORA,VEICULO)),exact = FALSE, paired = TRUE))
        
        print("PORTO X TOKIO")
        
        print(wilcox.test(VALOR ~ SEGURADORA, data = (dados1() %>% filter(SEGURADORA %in% c("PORTO","TOKIO")) %>% arrange(SEGURADORA,VEICULO)),exact = FALSE, paired = TRUE))
        
        print("PORTO X YOUSE")
        
        print(wilcox.test(VALOR ~ SEGURADORA, data = (dados1() %>% filter(SEGURADORA %in% c("PORTO","YOUSE")) %>% arrange(SEGURADORA,VEICULO)),exact = FALSE, paired = TRUE))
        
    })
    
    
    output$dadosPlot2 <-   renderPlot({
        
        cols1 <- c("LIBERTY" = "blank", "HDI" = "blank", "SAS" = "blank", "PORTO" = "blank", "YOUSE" = "blank", "TOKIO" = "blank", "NOVO 10MIN" = "solid","NOVO 20MIN" = "solid", "NOVO 5PTMED" =  "solid", "NOVO MED" = "solid", "med_mkt" = "solid" )
        
        cols2 <- c("LIBERTY"= "blue4", "PORTO" = "BLUE", "HDI" = "darkgreen", "SAS" = "darkorange3", "YOUSE" = "purple", "TOKIO" = "black", "NOVO 10MIN" = "red","NOVO 20MIN" = "red", "NOVO 5PTMED" =  "red", "NOVO MED" = "red", "med_mkt" = "olivedrab4" )
        
        
        ggplot() +
            # aqui é o ponto das seguradoras
            geom_point(data = dados1(), aes(x=reorder(VEICULO, VALOR), y=VALOR, color = SEGURADORA, group = SEGURADORA), size = 2.5) +
            #aqui é o texto das seguradoras 
            geom_text(data= dados1(), aes(x=reorder(VEICULO, VALOR), y=VALOR, color = SEGURADORA, group = SEGURADORA, label = SEGURADORA), hjust=1.5, vjust=0.1, size=3.5) +
            # aqui é o ponto da média
            geom_point(data = dados1_media(), aes(x=reorder(VEICULO, MEDIA), y=MEDIA), colour = "red") +
            # aqui é a linha da média
            geom_line(data = dados1_media(), aes(x=reorder(VEICULO, MEDIA), y=MEDIA), colour = "red", group = 1) +
            # aqui é o texto da média
            geom_text(data= dados1_media(), aes(x=reorder(VEICULO, MEDIA), y=MEDIA, label = MEDIA2), hjust=1.5, vjust=0.1, size=3.5, colour = "red") +
            # detalhe 1
            scale_linetype_manual(values = cols1) +
            #detalhe 2
            scale_color_manual(values=cols2) +
            # detalhe 3
            theme(plot.title = element_text(hjust = 0.5, face="bold")) +
            # detalhe 4
            theme(axis.title.x = element_text(face="bold"), axis.text.x = element_text(face="bold")) +
            # detalhe 5
            theme(axis.title.y = element_text(face="bold"), axis.text.y = element_text(face="bold")) +
            # detalhe 6
            theme(text = element_text(size=11))+ theme(legend.position='none') +
            # detalhe 7
            labs(title = "Prêmios dos veículos",
                 x = "Carro",
                 y = "Prêmio (R$)")
    }, height = 600)
    
    
    output$dadosPlot <- renderPlot({
        
        cols2 <- c("LIBERTY"= "blue4", "PORTO" = "BLUE", "HDI" = "darkgreen", "SAS" = "darkorange3", "YOUSE" = "purple", "TOKIO" = "black", "PREÇO NOVO 5PTMED" = "red","PREÇO NOVO 5 MED" = "red", "PREÇO NOVO MED" =  "red", "PREÇO NOVO 5MIN" = "red", "med_mkt" = "red" )
        
        
        ggplot(dados3(),aes(x = SEGURADORA, y = VALOR, fill=SEGURADORA)) + 
            geom_boxplot() +
            facet_grid(. ~ FLAG)  +
            scale_fill_manual(values=cols2) +
            guides(fill=FALSE) 
        
    })
    
    
    
    # output$Dados <- DT::renderDataTable({
    #     DT::datatable(dados2())
    # })
    
    
}
)
