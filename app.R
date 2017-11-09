# load shiny and DT
library(shiny)
library(data.table)
library(ggmap)
# set dir to location where contains pre-comupted datasets
setwd('DIRECTORY HERE')
# load dataset
DT_t<-fread('data_t.csv')
DT_p<-fread('data_p.csv')

# Define UI for application that visualize results
ui <- fluidPage(

  # Application title
  titlePanel("location based competition - NYC"),
  
  # Sidebar with a slider input for store name and miles radius
  sidebarPanel(
    selectInput('A', 'store - base', unique(DT_t$name), selected = "Shake Shack"),
    selectInput('B', 'store - comp', unique(DT_t$name), selected = "McDonald's"),
    numericInput('R', 'max miles radius', 0.5, min = 0.5)
  ),
  # Show a tab panel with table and plots
  mainPanel(
    tabsetPanel(
      tabPanel('Table', dataTableOutput("table1")),
      #tabPanel('Uptown', plotOutput("plot1")),
      tabPanel('Midtown', plotOutput("plot1")),
      tabPanel('Downtown', plotOutput("plot2"))
    )
  )
)

# Define server logic required to generate panels
server <- function(input, output) {
  # load map
  midtown<-get_map('Midtown, New York', zoom = 14)
  downtown<-get_map('Downtown, New York', zoom = 14)
  #uptown<-get_map('Uptown, New York', zoom = 14)
  
  output$table1 <- renderDataTable({
    # generate results based on input$A,input$B,input$R from ui.R
    base <- input$A
    comp <- input$B
    rad <- input$R
    tc <- DT_t[name == input$B, N]
    res <-
      DT_p[name_l == base][name_r == comp][dist <= rad][, .(
        '% of comp stores' = paste0(round(.N / tc, 2) * 100, '%'),
        'avg dist (mile)' = round(mean(dist), 2)
      ), by = .(name_l, store_id_l, addr_l)]
    setorder(res, store_id_l)
    setnames(res,
             c('name_l', 'store_id_l', 'addr_l'),
             c('store', 'id', 'address'))
    return(res)
  })
  output$plot1 <- renderPlot({
    base <- input$A
    comp <- input$B
    rad <- input$R
    tc <- DT_t[name == input$B, N]
    geo_data<-DT_p[name_l == base][name_r == comp][dist <= rad][, .(
      'comps_perc'=.N/tc
      ), by = .(lat_l, lng_l)]
    ggmap(midtown) + geom_point(
      data = geo_data,
      aes(x = lng_l, y = lat_l),
      color = "red",
      size = geo_data$comps_perc * 20,
      alpha = 0.5
    )
  })
  output$plot2 <- renderPlot({
    base <- input$A
    comp <- input$B
    rad <- input$R
    tc <- DT_t[name == input$B, N]
    geo_data<-DT_p[name_l == base][name_r == comp][dist <= rad][, .(
      'comps_perc'=.N/tc
    ), by = .(lat_l, lng_l)]
    ggmap(downtown) + geom_point(
      data = geo_data,
      aes(x = lng_l, y = lat_l),
      color = "red",
      size = geo_data$comps_perc * 20,
      alpha = 0.5
    )
  })
}

# Run the application
shinyApp(ui = ui, server = server)
