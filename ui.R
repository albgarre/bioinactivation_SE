
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
                                                            sliderInput("bigelow_DR_start", "Initial estimate", 0, 100, 10),
                                                            sliderInput("bigelow_DR_range", "Bounds", 0, 100, c(5, 20)),
                                                            checkboxInput("bigelow_DR_known", "known"),
                                                            
                                                            tags$h4("z-value"),
                                                            sliderInput("bigelow_z_start", "Initial estimate", 0, 100, 10),
                                                            sliderInput("bigelow_z_range", "Bounds", 0, 100, c(5, 20)),
                                                            checkboxInput("bigelow_z_known", "known"),
                                                            
                                                            tags$h4("Reference temperature"),
                                                            sliderInput("bigelow_temRef_start", "Initial estimate", 10, 200, 100),
                                                            sliderInput("bigelow_tempRef_range", "Bounds", 10, 200, c(70, 80)),
                                                            checkboxInput("bigelow_tempRef_known", "known"),
                                                            
                                                            tags$h4("Decimal logarithm of N0"),
                                                            sliderInput("bigelow_logN0_start", "Initial estimate", 3, 8, 5, step = 0.5),
                                                            sliderInput("bigelow_logN0_range", "Bounds", 3, 8, c(4, 6), step = 0.5),
                                                            checkboxInput("bigelow_logN0_known", "known")
                                                            

                                                            ),
                                                   tabPanel("Fitting parameters",
                                                            tags$hr(),
                                                            selectInput("algorithm_bigelow", "Adjustment algorithm", c(nlr = "nlr", MCMC = "MCMC")),
                                                            sliderInput("bigelow_niter", "Number iterations MCMC", 100, 1000, 200, step = 100),
                                                            sliderInput("bigelow_burn", "Burninlength MCMC", 0, 1000, 0, step = 100),
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
                                                            tags$h4("Coefficients"),
                                                            tableOutput("bigelow_summary"),
                                                            helpText("Confidence intervals for parameters from nls calculated considering a t-distribution"),
                                                            helpText("Confidence intervals for parameters from MCMC taken from the quantile of the MCMC simulations"),
                                                            tags$hr(),
                                                            tags$h4("Residuals"),
                                                            tableOutput("bigelow_residuals"),
                                                            tags$hr(),
                                                            tags$h4("Parameter correlation"),
                                                            tableOutput("bigelow_correlation")
                                                            ),
                                                   
                                                   tabPanel("Prediction interval",
                                                            plotOutput("bigelow_interval")),
                                                   
                                                   tabPanel("Export results",
                                                            tags$h4("Adjusted model"),
                                                            textInput("filename_Bigelow_pred", "File name:", "prediction-Bigelow.csv"),
                                                            downloadButton("down_Bigelow_pred", "Download")
                                                            )
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
                                                            sliderInput("peleg_kb_start", "Initial estimate", 0.01, 1, 0.1),
                                                            sliderInput("peleg_kb_range", "Bounds", 0, 1, c(0.01, 0.5)),
                                                            checkboxInput("peleg_kb_known", "known"),
                                                            
                                                            tags$h4("Parameter n"),
                                                            sliderInput("peleg_n_start", "Initial estimate", 0, 5, 0.5, step = 0.1),
                                                            sliderInput("peleg_n_range", "Bounds", 0, 5, c(0.1, 1), step = 0.1),
                                                            checkboxInput("peleg_n_known", "known"),
                                                            
                                                            tags$h4("Critical temperature"),
                                                            sliderInput("peleg_temcrit_start", "Initial estimate", 10, 200, 120),
                                                            sliderInput("peleg_tempcrit_range", "Bounds", 10, 200, c(100, 150)),
                                                            checkboxInput("peleg_tempcrit_known", "known"),
                                                            
                                                            tags$h4("Decimal logarithm of N0"),
                                                            sliderInput("peleg_logN0_start", "Initial estimate", 3, 8, 6, step = 0.5),
                                                            sliderInput("peleg_logN0_range", "Bounds", 3, 8, c(4, 6), step = 0.5),
                                                            checkboxInput("peleg_logN0_known", "known")
                                                            ),
                                                   tabPanel("Fitting parameters",
                                                            tags$hr(),
                                                            selectInput("algorithm_peleg", "Adjustment algorithm", c(nlr = "nlr", MCMC = "MCMC")),
                                                            sliderInput("peleg_niter", "Number iterations MCMC", 100, 1000, 200, step = 100),
                                                            sliderInput("peleg_burn", "Burninlength MCMC", 0, 1000, 0, step = 100),
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
                                                            tags$h4("Coefficients"),
                                                            tableOutput("peleg_summary"),
                                                            helpText("Confidence intervals for parameters from nls calculated considering a t-distribution"),
                                                            helpText("Confidence intervals for parameters from MCMC taken from the quantile of the MCMC simulations"),
                                                            tags$hr(),
                                                            tags$h4("Residuals"),
                                                            tableOutput("peleg_residuals"),
                                                            tags$hr(),
                                                            tags$h4("Parameter correlation"),
                                                            tableOutput("peleg_correlation")
                                                            ),
                                                   tabPanel("Prediction interval",
                                                            plotOutput("peleg_interval")),
                                                   
                                                   tabPanel("Export results",
                                                            tags$h4("Adjusted model"),
                                                            textInput("filename_Peleg_pred", "File name:", "prediction-Peleg.csv"),
                                                            downloadButton("down_Peleg_pred", "Download")
                                                   )
                                               )
                                           )
                                       )
                                       ),
                              
                              #------------------------------------------------------------------
                              
                              tabPanel("Mafart",
                                       sidebarLayout(
                                           sidebarPanel(
                                               tabsetPanel(
                                                   tabPanel("Model parameters",
                                                            tags$h4("Delta at ref. temp"),
                                                            sliderInput("mafart_delta_start", "Initial estimate", 0, 100, 10),
                                                            sliderInput("mafart_delta_range", "Bounds", 0, 100, c(5, 20)),
                                                            checkboxInput("mafart_delta_known", "known"),
                                                            
                                                            tags$h4("Parameter p"),
                                                            sliderInput("mafart_p_start", "Initial estimate", 0, 10, 1, step = 0.5),
                                                            sliderInput("mafart_p_range", "Bounds", 0, 10, c(.5, 1.5), step = 0.5),
                                                            checkboxInput("mafart_p_known", "known"),
                                                            
                                                            tags$h4("Parameter z"),
                                                            sliderInput("mafart_z_start", "z", 0, 100, 10),
                                                            sliderInput("mafart_z_range", "z", 0, 100, c(5, 30)),
                                                            checkboxInput("mafart_z_known", "knwon"),
                                                            
                                                            tags$h4("Reference temperature"),
                                                            sliderInput("mafart_temref_start", "Initial estimate", 10, 200, 100),
                                                            sliderInput("mafart_tempref_range", "Bounds", 10, 200, c(80, 150)),
                                                            checkboxInput("mafart_tempref_known", "known"),
                                                            
                                                            tags$h4("Decimal logarithm of N0"),
                                                            sliderInput("mafart_logN0_start", "Initial estimate", 3, 8, 5, step = 0.5),
                                                            sliderInput("mafart_logN0_range", "Bounds", 3, 8, c(4, 6), step = 0.5),
                                                            checkboxInput("mafart_logN0_known", "known")
                                                            ),
                                                   tabPanel("Adjustment parameters",
                                                            tags$hr(),
                                                            selectInput("algorithm_mafart", "Adjustment algorithm", c(nlr = "nlr", MCMC = "MCMC")),
                                                            sliderInput("mafart_niter", "Number iterations MCMC", 100, 1000, 200, step = 100),
                                                            sliderInput("mafart_burn", "Burninlength MCMC", 0, 1000, 0, step = 100),
                                                            tags$hr(),
                                                            sliderInput("mafart_quantiles", "Quantiles for prediction interval", 0, 100, c(2.5, 97.5), step = 0.5),
                                                            actionButton("btn_mafart", "Adjust")
                                                            )
                                                   )
                                               
                                           ),
                                           mainPanel(
                                               tabsetPanel(
                                                   tabPanel("Plot",
                                                            plotOutput("mafart_plot")),
                                                   tabPanel("Summary",
                                                            tags$h4("Coefficients"),
                                                            tableOutput("mafart_summary"),
                                                            helpText("Confidence intervals for parameters from nls calculated considering a t-distribution"),
                                                            helpText("Confidence intervals for parameters from MCMC taken from the quantile of the MCMC simulations"),
                                                            tags$hr(),
                                                            tags$h4("Residuals"),
                                                            tableOutput("mafart_residuals"),
                                                            tags$hr(),
                                                            tags$h4("Parameter correlation"),
                                                            tableOutput("mafart_correlation")
                                                            ),
                                                   tabPanel("Prediction interval",
                                                            plotOutput("mafart_interval")),
                                                   
                                                   tabPanel("Export results",
                                                            tags$h4("Adjusted model"),
                                                            textInput("filename_Mafart_pred", "File name:", "prediction-Mafart.csv"),
                                                            downloadButton("down_Mafart_pred", "Download")
                                                   )
                                               )
                                           )
                                       )),
                              
                              #------------------------------------------------------------------
                              
                              tabPanel("Geeraerd",
                                       sidebarLayout(
                                           sidebarPanel(
                                               
                                               tabsetPanel(
                                                   tabPanel("Model parameters",
                                                            tags$h4("D-value at ref. temp."),
                                                            sliderInput("geeraerd_DR_start", "Initial estimate", 0, 100, 40),
                                                            sliderInput("geeraerd_DR_range", "Bounds", 0, 100, c(5, 60)),
                                                            checkboxInput("geeraerd_DR_known", "known"),
                                                            
                                                            tags$h4("z-value"),
                                                            sliderInput("geeraerd_z_start", "Initial estimate", 0, 100, 15),
                                                            sliderInput("geeraerd_z_range", "Bounds", 0, 100, c(5, 30)),
                                                            checkboxInput("geeraerd_z_known", "knwon"),
                                                            
                                                            tags$h4("Reference temperature"),
                                                            sliderInput("geeraerd_tempref_start", "Initial estimate", 10, 200, 100),
                                                            sliderInput("geeraerd_tempref_range", "Bounds", 10, 200, c(80, 150)),
                                                            checkboxInput("geeraerd_tempref_known", "known"),
                                                            
                                                            tags$h4("Initial value of C_c"),
                                                            sliderInput("geeraerd_Cc0_start", "Initial estimate", 0, 20, 5),
                                                            sliderInput("geeraerd_C_c0_range", "Bounds", 0, 20, c(0, 5)),
                                                            checkboxInput("geeraerd_Cc0_known", "known"),
                                                            
                                                            tags$h4("Decimal logarithm of N_min"),
                                                            sliderInput("geeraerd_logNmin_start", "Initial estimate", 0, 5, 1),
                                                            sliderInput("geeraerd_logNmin_range", "Bounds", 0, 5, c(0, 3)),
                                                            checkboxInput("geeraerd_logNmin_known", "known"),
                                                            
                                                            tags$h4("Decimal logarithm of N0"),
                                                            sliderInput("geeraerd_logN0_start", "Initial estimate", 3, 8, 5, step = 0.5),
                                                            sliderInput("geeraerd_logN0_range", "Bounds", 3, 8, c(4, 6), step = 0.5),
                                                            checkboxInput("geeraerd_logN0_known", "known")
                                                            ),
                                                   tabPanel("Adjustment parameters",
                                                            
                                                            tags$hr(),
                                                            selectInput("algorithm_geeraerd", "Adjustment algorithm", c(nlr = "nlr", MCMC = "MCMC")),
                                                            sliderInput("geeraerd_niter", "Number iterations MCMC", 100, 1000, 200, step = 100),
                                                            sliderInput("geeraerd_burn", "Burninlength MCMC", 0, 1000, 0, step = 100),
                                                            tags$hr(),
                                                            sliderInput("geeraerd_quantiles", "Quantiles for prediction interval", 0, 100, c(2.5, 97.5), step = 0.5),
                                                            actionButton("btn_geeraerd", "Adjust")
                                                            
                                                            )
                                                   )
                                           ),
                                           mainPanel(
                                               tabsetPanel(
                                                   tabPanel("Plot",
                                                            plotOutput("geeraerd_plot")),
                                                   tabPanel("Summary",
                                                            tags$h4("Coefficients"),
                                                            tableOutput("geeraerd_summary"),
                                                            helpText("Confidence intervals for model degrees of freedom obtained using nls calculated considering a t-distribution"),
                                                            helpText("Confidence intervals for model degrees of freedom obtained using MCMC taken from the quantile of the MCMC simulations"),
                                                            tags$hr(),
                                                            tags$h4("Residuals"),
                                                            tableOutput("geeraerd_residuals"),
                                                            tags$hr(),
                                                            tags$h4("Parameter correlation"),
                                                            tableOutput("geeraerd_correlation")
                                                            ),
                                                   tabPanel("Prediction interval",
                                                            plotOutput("geeraerd_interval")),
                                                   
                                                   tabPanel("Export results",
                                                            tags$h4("Adjusted model"),
                                                            textInput("filename_Geeraerd_pred", "File name:", "prediction-Geeraerd.csv"),
                                                            downloadButton("down_Geeraerd_pred", "Download")
                                                   )
                                               )
                                           )
                                           )
                                       )
                              ),
                   
                   #-----------------------------------------------------------------------------
                   
                   tabPanel("Reset state",
                            sidebarLayout(
                                sidebarPanel(helpText("Clicking the following button resets the state of the internal
                                                      pseudo-random number generator, providing reproducibility of the MCMC
                                                      results"),
                                             actionButton("btn_reset_seed", "Reset PRNG")
                                             ),
                                mainPanel()
                                )
                            ),
                   #-----------------------------------------------------------------------------
                   
                   tabPanel("About",
                            tags$h3("A shiny application for bioinactivation"),
                            tags$hr(),
                            tags$p("This shiny application has been developed in the department
                                   of Food Microbiology of the Universidad Politecnica de Cartagena."),
                            tags$p("This application provides a user interface to the functions for
                                   fitting of non-isothermal experiments implemented in the bionactivation
                                   package of R."),
                            tags$p("A link to the latest version of this application can be found in the following
                                   webpage:"),
                            tags$p("www.TBD.es"),
                            tags$hr(),
                            tags$p("When using this application, please citate it as:"),
                            tags$p("Alberto Garre, Pablo S. Fernandez and Jose A. Egea(2016).
                                   bioinactivation: Simulation of Dynamic Microbial Inactivation.
                                   R package version 1.1.1."),
                            tags$p("A BibTeX entry for LaTeX users is"),
                            tags$p("@Manual{,
                                    title = {bioinactivation: Simulation of Dynamic Microbial Inactivation},
                                    author = {Alberto Garre and Pablo S. Fernandez and Jose A. Egea},
                                    year = {2016},
                                    note = {R package version 1.1.1},
                                    }"
                                   )
                            )
                   
                   
                   #-----------------------------------------------------------------------------
))




















