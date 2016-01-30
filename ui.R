
## Code for the data input modified from http://rstudio.github.io/shiny/tutorial/#uploads

shinyUI(navbarPage("bioinactivation",
                   
                   #-----------------------------------------------------------------------------
                   
                   tabPanel("Data input",
                            sidebarLayout(
                                sidebarPanel(fileInput('file1', 'Choose CSV File',
                                                       accept=c('text/csv','text/comma-separated-values,text/plain', '.csv')),
                                             tags$hr(),
                                             radioButtons("sep", "Separator",
                                                          c(Comma = ",", Semicolon = ";", Tab = "\t"), "\t")
                                             ),
                                mainPanel(
                                    tabsetPanel(tabPanel("Tabular view", tableOutput('contents')),
                                                tabPanel("Survivor curve", plotOutput("input_survivor")),
                                                tabPanel("Temperature profile", plotOutput("input_temp"))
                                                )
                                    
                                    )
                                )
                            ),
                   
                   #-----------------------------------------------------------------------------
                   
                   navbarMenu("Model fitting",
                              
                              #------------------------------------------------------------------
                              
                              tabPanel("Bigelow",
                                       sidebarLayout(
                                           sidebarPanel(
                                               tabsetPanel(
                                                   tabPanel("Model parameters",
                                                            tags$h4("D-value at ref. temp."),
                                                            sliderInput("bigelow_DR_start", "Starting point", 0, 100, 10),
                                                            sliderInput("bigelow_DR_range", "Bounds", 0, 100, c(5, 20)),
                                                            checkboxInput("bigelow_DR_known", "known"),
                                                            
                                                            tags$h4("z-value"),
                                                            sliderInput("bigelow_z_start", "Starting point", 0, 100, 10),
                                                            sliderInput("bigelow_z_range", "Bounds", 0, 100, c(5, 20)),
                                                            checkboxInput("bigelow_z_known", "known"),
                                                            
                                                            tags$h4("Reference temperature"),
                                                            sliderInput("bigelow_temRef_start", "Starting point", 50, 200, 100),
                                                            sliderInput("bigelow_tempRef_range", "Bounds", 50, 200, c(70, 80)),
                                                            checkboxInput("bigelow_tempRef_known", "known"),
                                                            
                                                            tags$h4("Decimal logarithm of N0"),
                                                            sliderInput("bigelow_logN0_start", "Starting point", 3, 8, 5),
                                                            sliderInput("bigelow_logN0_range", "Bounds", 3, 8, c(4, 6)),
                                                            checkboxInput("bigelow_logN0_known", "known")
                                                            

                                                            ),
                                                   tabPanel("Fitting parameters",
                                                            tags$hr(),
                                                            selectInput("algorithm_bigelow", "Adjustment algorithm", c(nlr = "nlr", MCMC = "MCMC")),
                                                            sliderInput("bigelow_niter", "Number iterations MCMC", 100, 1000, 200, step = 100),
                                                            sliderInput("bigelow_burn", "Burninglength MCMC", 0, 1000, 0, step = 100),
                                                            tags$hr(),
                                                            sliderInput("bigelow_quantiles", "Quantiles for prediction interval", 0, 100, c(2.5, 97.5), step = 0.5),
                                                            actionButton("btn_bigelow", "Adjust")
                                                            )
                                                   )
                                               
                                               ),
                                           mainPanel(
                                               tabsetPanel(
                                                   tabPanel("Plot",
                                                            plotOutput("bigelow_plot")),
                                                   tabPanel("Summary",
                                                            verbatimTextOutput("bigelow_summary")),
                                                   tabPanel("Prediction interval",
                                                            plotOutput("bigelow_interval"))
                                                   )
                                               )
                                           )
                                       ),
                              
                              #------------------------------------------------------------------
                              
                              tabPanel("Peleg",
                                       sidebarLayout(
                                           sidebarPanel(
                                               tabsetPanel(
                                                   tabPanel("Model parameters",
                                                            tags$h4("Parameter k_b"),
                                                            sliderInput("peleg_kb_start", "Starting point", 0.01, 1, 0.1),
                                                            sliderInput("peleg_kb_range", "Bounds", 0, 1, c(0.01, 0.5)),
                                                            checkboxInput("peleg_kb_known", "known"),
                                                            
                                                            tags$h4("Parameter n"),
                                                            sliderInput("peleg_n_start", "Starting point", 0, 5, 0.5, step = 0.1),
                                                            sliderInput("peleg_n_range", "Bounds", 0, 5, c(0.1, 1), step = 0.1),
                                                            checkboxInput("peleg_n_known", "known"),
                                                            
                                                            tags$h4("Critical temperature"),
                                                            sliderInput("peleg_temcrit_start", "Starting point", 50, 200, 120),
                                                            sliderInput("peleg_tempcrit_range", "Bounds", 50, 200, c(100, 150)),
                                                            checkboxInput("peleg_tempcrit_known", "known"),
                                                            
                                                            tags$h4("Decimal logarithm of N0"),
                                                            sliderInput("peleg_logN0_start", "Starting point", 3, 8, 6),
                                                            sliderInput("peleg_logN0_range", "Bounds", 3, 8, c(4, 6)),
                                                            checkboxInput("peleg_logN0_known", "known")
                                                            ),
                                                   tabPanel("Fitting parameters",
                                                            tags$hr(),
                                                            selectInput("algorithm_peleg", "Adjustment algorithm", c(nlr = "nlr", MCMC = "MCMC")),
                                                            sliderInput("peleg_niter", "Number iterations MCMC", 100, 1000, 200, step = 100),
                                                            sliderInput("peleg_burn", "Burninglength MCMC", 0, 1000, 0, step = 100),
                                                            tags$hr(),
                                                            sliderInput("peleg_quantiles", "Quantiles for prediction interval", 0, 100, c(2.5, 97.5), step = 0.5),
                                                            actionButton("btn_peleg", "Adjust")
                                                            )
                                                   )
                                           ),
                                           mainPanel(
                                               tabsetPanel(
                                                   tabPanel("Plot",
                                                            plotOutput("peleg_plot")),
                                                   tabPanel("Summary",
                                                            verbatimTextOutput("peleg_summary")),
                                                   tabPanel("Prediction interval",
                                                            plotOutput("peleg_interval"))
                                               )
                                           )
                                       )
                                       ),
                              
                              #------------------------------------------------------------------
                              
                              tabPanel("Mafart",
                                       sidebarLayout(
                                           sidebarPanel(
                                               tags$h3("Mafart model"),
                                               tags$hr(),
                                               tags$h4("Model parameters"),
                                               sliderInput("mafart_delta_start", "delta_ref", 0, 100, 10),
                                               checkboxInput("mafart_delta_known", "known"),
                                               sliderInput("mafart_p_start", "p", 0, 10, 1, step = 0.5),
                                               checkboxInput("mafart_p_known", "known"),
                                               sliderInput("mafart_z_start", "z", 0, 100, 10),
                                               checkboxInput("mafart_z_known", "knwon"),
                                               sliderInput("mafart_temref_start", "temp_ref", 50, 200, 100),
                                               checkboxInput("mafart_tempref_known", "known"),
                                               sliderInput("mafart_logN0_start", "log(N0)", 3, 8, 5),
                                               checkboxInput("mafart_logN0_known", "known"),
                                               tags$hr(),
                                               tags$h4("Bounds for the adjustment"),
                                               sliderInput("mafart_delta_range", "delta", 0, 100, c(5, 20)),
                                               sliderInput("mafart_p_range", "p", 0, 10, c(.5, 1.5), step = 0.5),
                                               sliderInput("mafart_z_range", "z", 0, 100, c(5, 30)),
                                               sliderInput("mafart_tempref_range", "temp_ref", 50, 200, c(80, 150)),
                                               sliderInput("mafart_logN0_range", "log(N0)", 3, 8, c(4, 6)),
                                               tags$hr(),
                                               tags$h4("Quantiles for the prediction interval"),
                                               sliderInput("mafart_quantiles", "", 0, 100, c(2.5, 97.5), step = 0.5),
                                               actionButton("btn_mafart", "Adjust")
                                           ),
                                           mainPanel(
                                               tabsetPanel(
                                                   tabPanel("Plot",
                                                            plotOutput("mafart_plot")),
                                                   tabPanel("Summary",
                                                            verbatimTextOutput("mafart_summary")),
                                                   tabPanel("Prediction interval",
                                                            plotOutput("mafart_interval"))
                                               )
                                           )
                                       )),
                              
                              #------------------------------------------------------------------
                              
                              tabPanel("Geeraerd",
                                       sidebarLayout(
                                           sidebarPanel(
                                               tags$h3("Geeraerd model"),
                                               tags$hr(),
                                               tags$h4("Model parameters"),
                                               sliderInput("geeraerd_DR_start", "D_R", 0, 100, 40),
                                               checkboxInput("geeraerd_DR_known", "known"),
                                               sliderInput("geeraerd_z_start", "z", 0, 100, 15),
                                               checkboxInput("geeraerd_z_known", "knwon"),
                                               sliderInput("geeraerd_tempref_start", "temp_ref", 50, 200, 100),
                                               checkboxInput("geeraerd_tempref_known", "known"),
                                               sliderInput("geeraerd_Cc0_start", "C_c0", 0, 20, 5),
                                               checkboxInput("geeraerd_Cc0_known", "known"),
                                               sliderInput("geeraerd_logNmin_start", "log(N_min)", 0, 5, 1),
                                               checkboxInput("geeraerd_logNmin_known", "known"),
                                               sliderInput("geeraerd_logN0_start", "log(N0)", 3, 8, 5),
                                               checkboxInput("geeraerd_logN0_known", "known"),
                                               tags$hr(),
                                               tags$h4("Bounds for the adjustment"),
                                               sliderInput("geeraerd_DR_range", "D_R", 0, 100, c(5, 60)),
                                               sliderInput("geeraerd_z_range", "z", 0, 100, c(5, 30)),
                                               sliderInput("geeraerd_tempref_range", "temp_ref", 50, 200, c(80, 150)),
                                               sliderInput("geeraerd_C_c0_range", "C_c0", 0, 20, c(0, 5)),
                                               sliderInput("geeraerd_logNmin_range", "log(N_min)", 0, 5, c(0, 3)),
                                               sliderInput("geeraerd_logN0_range", "log(N0)", 3, 8, c(4, 6)),
                                               tags$hr(),
                                               tags$h4("Quantiles for the prediction interval"),
                                               sliderInput("geeraerd_quantiles", "", 0, 100, c(2.5, 97.5), step = 0.5),
                                               actionButton("btn_geeraerd", "Adjust")
                                           ),
                                           mainPanel(
                                               tabsetPanel(
                                                   tabPanel("Plot",
                                                            plotOutput("geeraerd_plot")),
                                                   tabPanel("Summary",
                                                            verbatimTextOutput("geeraerd_summary")),
                                                   tabPanel("Prediction interval",
                                                            plotOutput("geeraerd_interval"))
                                               )
                                           )
                                           )
                                       )
                              )
                   
                   #-----------------------------------------------------------------------------
))




















