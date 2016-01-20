
library(ggplot2)
library(bioinactivation)
library(dplyr)

#==============================================================================

exp_data <- NULL

current_plot <- ggplot()

#==============================================================================

#'
#'
shinyServer(function(input, output) {
    
    output$contents <- renderTable({
        
        # input$file1 will be NULL initially. After the user selects and uploads a 
        # file, it will be a data frame with 'name', 'size', 'type', and 'datapath' 
        # columns. The 'datapath' column will contain the local filenames where the 
        # data can be found.
        
        inFile <- input$file1
        
        if (is.null(inFile))
            return(NULL)
        
        exp_data <<- read.csv(inFile$datapath, header=input$header,
                               sep=input$sep, quote=input$quote)
        exp_data
    })
})

