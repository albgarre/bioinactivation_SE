
## Code for the data input modified from http://rstudio.github.io/shiny/tutorial/#uploads

shinyUI(navbarPage("bioinactivation",
                   
                   #-----------------------------------------------------------------------------
                   
                   tabPanel("Data input",
                            sidebarLayout(
                                sidebarPanel(fileInput('file1', 'Choose CSV File',
                                                       accept=c('text/csv','text/comma-separated-values,text/plain', '.csv')),
                                             tags$hr(),
                                             radioButtons("sep", "Separator",
                                                          c(Comma = ",", Semicolon = ";", Tab = "\t"), "\t"),
                                             tags$hr(),
                                             radioButtons("dec", "Decimal Point", c(Point = ".", Comma = ","), ".")
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
                                       titlePanel("Bigelow model"),
                                       sidebarLayout(
                                           sidebarPanel(
                                               tabsetPanel(
                                                   tabPanel("Model parameters",
                                                            tags$h4("D-value at ref. temp."),
                                                            numericInput("bigelow_DR_start", "Initial estimate/Fixed value", 10, 0, 100),
                                                            sliderInput("bigelow_DR_range", "Bounds", 0, 100, c(5, 20)),
                                                            checkboxInput("bigelow_DR_known", "known"),
                                                            
                                                            tags$h4("z-value"),
                                                            numericInput("bigelow_z_start", "Initial estimate/Fixed value", 10, 0, 100),
                                                            sliderInput("bigelow_z_range", "Bounds", 0, 100, c(5, 20)),
                                                            checkboxInput("bigelow_z_known", "known"),
                                                            
                                                            tags$h4("Reference temperature"),
                                                            numericInput("bigelow_temRef_start", "Initial estimate/Fixed value", 100, 10, 200),
                                                            sliderInput("bigelow_tempRef_range", "Bounds", 10, 200, c(70, 80)),
                                                            checkboxInput("bigelow_tempRef_known", "known"),
                                                            
                                                            tags$h4("Decimal logarithm of N0"),
                                                            numericInput("bigelow_logN0_start", "Initial estimate/Fixed value", 5, 3, 8),
                                                            sliderInput("bigelow_logN0_range", "Bounds", 3, 8, c(4, 6), step = 0.5),
                                                            checkboxInput("bigelow_logN0_known", "known")
                                                            

                                                            ),
                                                   tabPanel("Fitting parameters",
                                                            tags$hr(),
                                                            selectInput("algorithm_bigelow", "Fitting algorithm", c(nlr = "nlr", MCMC = "MCMC")),
                                                            sliderInput("bigelow_niter", "Number iterations MCMC", 1000, 10000, 2000, step = 100),
                                                            sliderInput("bigelow_burn", "Burninlength MCMC", 0, 1000, 0, step = 100),
                                                            tags$hr(),
                                                            sliderInput("bigelow_quantiles", "Quantiles for prediction interval", 0, 100, c(2.5, 97.5), step = 0.5)
                                                            ),
                                                   tabPanel("Fit model",
                                                            tags$hr(),
                                                            actionButton("btn_bigelow", "Fit"),
                                                            tags$hr(),
                                                            actionButton("btn_bigelow_seed", "Reset PRNG")
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
                                                            tags$h4("Fitted model"),
                                                            textInput("filename_Bigelow_pred", "File name:", "prediction-Bigelow.csv"),
                                                            downloadButton("down_Bigelow_pred", "Download"),
                                                            tags$hr(),
                                                            tags$h4("Summary tables"),
                                                            downloadButton("down_Bigelow_coef", "Coefficients"),
                                                            downloadButton("down_Bigelow_res", "Residuals"),
                                                            downloadButton("down_Bigelow_cor", "Correlation")
                                                            )
                                                   )
                                               )
                                           )
                                       ),
                              
                              #------------------------------------------------------------------
                              
                              tabPanel("Peleg",
                                       titlePanel("Peleg model"),
                                       sidebarLayout(
                                           sidebarPanel(
                                               tabsetPanel(
                                                   tabPanel("Model parameters",
                                                            tags$h4("Parameter k_b"),
                                                            numericInput("peleg_kb_start", "Initial estimate/Fixed value", 0.1, 0.01, 1),
                                                            sliderInput("peleg_kb_range", "Bounds", 0, 1, c(0.01, 0.5)),
                                                            checkboxInput("peleg_kb_known", "known"),
                                                            
                                                            tags$h4("Parameter n"),
                                                            numericInput("peleg_n_start", "Initial estimate/Fixed value", 0.5, 0, 5),
                                                            sliderInput("peleg_n_range", "Bounds", 0, 5, c(0.1, 1), step = 0.1),
                                                            checkboxInput("peleg_n_known", "known"),
                                                            
                                                            tags$h4("Critical temperature"),
                                                            numericInput("peleg_temcrit_start", "Initial estimate/Fixed value", 120, 10, 200),
                                                            sliderInput("peleg_tempcrit_range", "Bounds", 10, 200, c(100, 150)),
                                                            checkboxInput("peleg_tempcrit_known", "known"),
                                                            
                                                            tags$h4("Decimal logarithm of N0"),
                                                            numericInput("peleg_logN0_start", "Initial estimate/Fixed value", 6, 3, 8),
                                                            sliderInput("peleg_logN0_range", "Bounds", 3, 8, c(4, 6), step = 0.5),
                                                            checkboxInput("peleg_logN0_known", "known")
                                                            ),
                                                   tabPanel("Fitting parameters",
                                                            tags$hr(),
                                                            selectInput("algorithm_peleg", "Fitting algorithm", c(nlr = "nlr", MCMC = "MCMC")),
                                                            sliderInput("peleg_niter", "Number iterations MCMC", 1000, 10000, 2000, step = 100),
                                                            sliderInput("peleg_burn", "Burninlength MCMC", 0, 1000, 0, step = 100),
                                                            tags$hr(),
                                                            sliderInput("peleg_quantiles", "Quantiles for prediction interval", 0, 100, c(2.5, 97.5), step = 0.5)
                                                            ),
                                                   tabPanel("Fit model",
                                                            tags$hr(),
                                                            actionButton("btn_peleg", "Fit"),
                                                            tags$hr(),
                                                            actionButton("btn_peleg_seed", "Reset PRNG")
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
                                                            tags$h4("Fitted model"),
                                                            textInput("filename_Peleg_pred", "File name:", "prediction-Peleg.csv"),
                                                            downloadButton("down_Peleg_pred", "Download"),
                                                            tags$hr(),
                                                            tags$h4("Summary tables"),
                                                            downloadButton("down_Peleg_coef", "Coefficients"),
                                                            downloadButton("down_Peleg_res", "Residuals"),
                                                            downloadButton("down_Peleg_cor", "Correlation")
                                                   )
                                               )
                                           )
                                       )
                                       ),
                              
                              #------------------------------------------------------------------
                              
                              tabPanel("Mafart",
                                       titlePanel("Mafart model"),
                                       sidebarLayout(
                                           sidebarPanel(
                                               tabsetPanel(
                                                   tabPanel("Model parameters",
                                                            tags$h4("Delta at ref. temp"),
                                                            numericInput("mafart_delta_start", "Initial estimate/Fixed value", 10, 0, 100),
                                                            sliderInput("mafart_delta_range", "Bounds", 0, 100, c(5, 20)),
                                                            checkboxInput("mafart_delta_known", "known"),
                                                            
                                                            tags$h4("Parameter p"),
                                                            numericInput("mafart_p_start", "Initial estimate/Fixed value", 1, 0, 10),
                                                            sliderInput("mafart_p_range", "Bounds", 0, 10, c(.5, 1.5), step = 0.5),
                                                            checkboxInput("mafart_p_known", "known"),
                                                            
                                                            tags$h4("Parameter z"),
                                                            numericInput("mafart_z_start", "Initial estimate/Fixed value", 10, 0, 100),
                                                            sliderInput("mafart_z_range", "Bounds", 0, 100, c(5, 30)),
                                                            checkboxInput("mafart_z_known", "known"),
                                                            
                                                            tags$h4("Reference temperature"),
                                                            numericInput("mafart_temref_start", "Initial estimate/Fixed value", 100, 10, 200),
                                                            sliderInput("mafart_tempref_range", "Bounds", 10, 200, c(80, 150)),
                                                            checkboxInput("mafart_tempref_known", "known"),
                                                            
                                                            tags$h4("Decimal logarithm of N0"),
                                                            numericInput("mafart_logN0_start", "Initial estimate/Fixed value", 5, 3, 8),
                                                            sliderInput("mafart_logN0_range", "Bounds", 3, 8, c(4, 6), step = 0.5),
                                                            checkboxInput("mafart_logN0_known", "known")
                                                            ),
                                                   tabPanel("Fitting parameters",
                                                            tags$hr(),
                                                            selectInput("algorithm_mafart", "Fitting algorithm", c(nlr = "nlr", MCMC = "MCMC")),
                                                            sliderInput("mafart_niter", "Number iterations MCMC", 1000, 10000, 2000, step = 100),
                                                            sliderInput("mafart_burn", "Burninlength MCMC", 0, 1000, 0, step = 100),
                                                            tags$hr(),
                                                            sliderInput("mafart_quantiles", "Quantiles for prediction interval", 0, 100, c(2.5, 97.5), step = 0.5)
                                                            ),
                                                   tabPanel("Fit model",
                                                            tags$hr(),
                                                            actionButton("btn_mafart", "Fit"),
                                                            tags$hr(),
                                                            actionButton("btn_mafart_seed", "Reset PRNG")
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
                                                            tags$h4("Fitted model"),
                                                            textInput("filename_Mafart_pred", "File name:", "prediction-Mafart.csv"),
                                                            downloadButton("down_Mafart_pred", "Download"),
                                                            tags$hr(),
                                                            tags$h4("Summary tables"),
                                                            downloadButton("down_Mafart_coef", "Coefficients"),
                                                            downloadButton("down_Mafart_res", "Residuals"),
                                                            downloadButton("down_Mafart_cor", "Correlation")
                                                   )
                                               )
                                           )
                                       )),
                              
                              #------------------------------------------------------------------
                              
                              tabPanel("Geeraerd",
                                       titlePanel("Geeraerd model"),
                                       sidebarLayout(
                                           sidebarPanel(
                                               
                                               tabsetPanel(
                                                   tabPanel("Model parameters",
                                                            tags$h4("D-value at ref. temp."),
                                                            numericInput("geeraerd_DR_start", "Initial estimate/Fixed value", 40, 0, 100),
                                                            sliderInput("geeraerd_DR_range", "Bounds", 0, 100, c(5, 60)),
                                                            checkboxInput("geeraerd_DR_known", "known"),
                                                            
                                                            tags$h4("z-value"),
                                                            numericInput("geeraerd_z_start", "Initial estimate/Fixed value", 15, 0, 100),
                                                            sliderInput("geeraerd_z_range", "Bounds", 0, 100, c(5, 30)),
                                                            checkboxInput("geeraerd_z_known", "known"),
                                                            
                                                            tags$h4("Reference temperature"),
                                                            numericInput("geeraerd_tempref_start", "Initial estimate/Fixed value", 100, 10, 200),
                                                            sliderInput("geeraerd_tempref_range", "Bounds", 10, 200, c(80, 150)),
                                                            checkboxInput("geeraerd_tempref_known", "known"),
                                                            
                                                            tags$h4("Initial value of C_c"),
                                                            numericInput("geeraerd_Cc0_start", "Initial estimate/Fixed value", 5, 0, 20),
                                                            sliderInput("geeraerd_C_c0_range", "Bounds", 0, 20, c(0, 5)),
                                                            checkboxInput("geeraerd_Cc0_known", "known"),
                                                            
                                                            tags$h4("Decimal logarithm of N_min"),
                                                            numericInput("geeraerd_logNmin_start", "Initial estimate/Fixed value", 1, 0, 5),
                                                            sliderInput("geeraerd_logNmin_range", "Bounds", 0, 5, c(0, 3)),
                                                            checkboxInput("geeraerd_logNmin_known", "known"),
                                                            
                                                            tags$h4("Decimal logarithm of N0"),
                                                            numericInput("geeraerd_logN0_start", "Initial estimate/Fixed value", 5, 3, 8),
                                                            sliderInput("geeraerd_logN0_range", "Bounds", 3, 8, c(4, 6), step = 0.5),
                                                            checkboxInput("geeraerd_logN0_known", "known")
                                                            ),
                                                   tabPanel("Fitting parameters",
                                                            
                                                            tags$hr(),
                                                            selectInput("algorithm_geeraerd", "Fitting algorithm", c(nlr = "nlr", MCMC = "MCMC")),
                                                            sliderInput("geeraerd_niter", "Number iterations MCMC", 1000, 10000, 2000, step = 100),
                                                            sliderInput("geeraerd_burn", "Burninlength MCMC", 0, 1000, 0, step = 100),
                                                            tags$hr(),
                                                            sliderInput("geeraerd_quantiles", "Quantiles for prediction interval", 0, 100, c(2.5, 97.5), step = 0.5)
                                                            ),
                                                   tabPanel("Fit model",
                                                            tags$hr(),
                                                            actionButton("btn_geeraerd", "Fit"),
                                                            tags$hr(),
                                                            actionButton("btn_geeraerd_seed", "Reset PRNG")
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
                                                            tags$h4("Fitted model"),
                                                            textInput("filename_Geeraerd_pred", "File name:", "prediction-Geeraerd.csv"),
                                                            downloadButton("down_Geeraerd_pred", "Download"),
                                                            tags$hr(),
                                                            tags$h4("Summary tables"),
                                                            downloadButton("down_Geeraerd_coef", "Coefficients"),
                                                            downloadButton("down_Geeraerd_res", "Residuals"),
                                                            downloadButton("down_Geeraerd_cor", "Correlation")
                                                   )
                                               )
                                           )
                                           )
                                       )
                              ),
                   
                   #-----------------------------------------------------------------------------
                   
#                    tabPanel("Reset state",
#                             sidebarLayout(
#                                 sidebarPanel(helpText("Clicking the following button resets the state of the internal
#                                                       pseudo-random number generator, providing reproducibility of the MCMC
#                                                       results"),
#                                              actionButton("btn_reset_seed", "Reset PRNG")
#                                              ),
#                                 mainPanel()
#                                 )
#                             ),
                   #-----------------------------------------------------------------------------
                   
                   tabPanel("About",
                            tags$h3("Bioinactivation SE. Version 0.1.1"),
                            tags$hr(),
                            tags$p("Bioinactivation SE (simplified environment) has been developed at the Universidad Politecnica
                                    de Cartagena together by the departments of Applied Mathematics and Food Microbiology."),
                            tags$p("This application provides a user interface to the functions for
                                   model fitting of non-isothermal experiments and for the generation of prediction intervals
                                   implemented in the bionactivation package of R (a.k.a. bioinactivation core)."),
                            tags$p("A link to the latest version of this application can be found in the following
                                   webpage:"),
                            tags$p("https://opada-upct.shinyapps.io/bioinactivation_SE/"),
                            tags$hr(),
                            tags$p("For bug reports and support, please use one of the following e-mail accounts:"),
                            tags$p("garre.alberto@gmail.com"),
                            tags$p("pablo.fernandez@upct.es"),
                            tags$hr(),
                            tags$p("When using this application, please citate it as:"),
                            tags$p("Alberto Garre, Pablo S. Fernandez, Roland Lindqvist,Jose A. Egea,
                                    Bioinactivation: Software for modelling dynamic microbial inactivation,
                                    Food Research International, Volume 93, March 2017, Pages 66-74, ISSN 0963-9969,
                                    http://dx.doi.org/10.1016/j.foodres.2017.01.012."),
                            tags$p("A BibTeX entry for LaTeX users is"),
                            tags$p("@Article{,
                                   author = {Alberto Garre and Pablo S. Fernandez and Roland Lindqvist and Jose A. Egea},
                                   title = {Bioinactivation: Software for modelling dynamic microbial inactivation },
                                   journal = {Food Research International },
                                   volume = {93},
                                   pages = {66 - 74},
                                   year = {2017},
                                   issn = {0963-9969},
                                   doi = {10.1016/j.foodres.2017.01.012},
                                   url = {//www.sciencedirect.com/science/article/pii/S0963996917300200},
                                   }"
                                   )
                            )
                   
                   
                   #-----------------------------------------------------------------------------
))




















