
library(ggplot2)
library(bioinactivation)
library(dplyr)

#==============================================================================

exp_data <- NULL

#==============================================================================

#'
#'
shinyServer(function(input, output) {
    
    ## FUNCTIONS FOR DATA INPUT
    
    output$contents <- renderTable({
        
        # input$file1 will be NULL initially. After the user selects and uploads a 
        # file, it will be a data frame with 'name', 'size', 'type', and 'datapath' 
        # columns. The 'datapath' column will contain the local filenames where the 
        # data can be found.
        
        inFile <- input$file1
        
        if (is.null(inFile))
            return(NULL)
        
        exp_data <<- read.csv(inFile$datapath, header = TRUE, sep = input$sep)
        exp_data
    })
    
    #---------------------------------------------------------------------------
    
    output$input_survivor <- renderPlot({
        
        inFile <- input$file1
        sep <- input$sep  # Esto es una buena chapuza
        
        if (is.null(inFile))
            return(NULL)
        
        ggplot(exp_data) + geom_point(aes(x = time, y = log.UFC))
    })
    
    #---------------------------------------------------------------------------
    
    output$input_temp <- renderPlot({
        
        inFile <- input$file1
        sep <- input$sep
        
        if (is.null(inFile))
            return(NULL)
        
        ggplot(exp_data) + geom_point(aes(x = time, y = temp))
    })
    
    #==========================================================================
    
    ## FUNCTIONS FOR MODEL ADJUSTMENT
    
    fit_bigelow <- eventReactive(input$btn_bigelow, {
        
        
        if (input$btn_bigelow != 0) {
            
            ## Gather the input data
            
            temp_profile <- select(exp_data, time, temperature = temp)
            
            #- Parameters
            
            known_pars <- numeric()
            starting_points <- numeric()
            upper <- numeric()
            lower <- numeric()
            
            if (input$bigelow_DR_known) {
                known_pars <- c(known_pars, D_R = input$bigelow_DR_start)
            } else {
                starting_points <- c(starting_points, D_R = input$bigelow_DR_start)
                lower <- c(lower, D_R = input$bigelow_DR_range[1])
                upper <- c(upper, D_R = input$bigelow_DR_range[2])
            }
            
            if (input$bigelow_z_known) {
                known_pars <- c(known_pars, z = input$bigelow_z_start)
            } else {
                starting_points <- c(starting_points, z = input$bigelow_z_start)
                lower <- c(lower, z = input$bigelow_z_range[1])
                upper <- c(upper, z = input$bigelow_z_range[2])
            }
            
            if (input$bigelow_tempRef_known) {
                known_pars <- c(known_pars, temp_ref = input$bigelow_temRef_start)
            } else {
                starting_points <- c(starting_points, temp_ref = input$bigelow_temRef_start)
                lower <- c(lower, temp_ref = input$bigelow_tempRef_range[1])
                upper <- c(upper, temp_ref = input$bigelow_tempRef_range[2])
            }
            
            if (input$bigelow_logN0_known) {
                known_pars <- c(known_pars, N0 = 10^input$bigelow_logN0_start)
            } else {
                starting_points <- c(starting_points, N0 = 10^input$bigelow_logN0_start)
                lower <- c(lower, N0 = 10^input$bigelow_logN0_range[1])
                upper <- c(upper, N0 = 10^input$bigelow_logN0_range[2])
            }
            
            ## Make the adjustment
            
            if (input$algorithm_bigelow == "nlr") {
                
                withProgress(message = "Fitting Bigelow model", value = 0, {
                    
                    fit_results <- fit_dynamic_inactivation(exp_data, "Bigelow", temp_profile,
                                                            starting_points, upper, lower,
                                                            known_pars)
                })

                
            } else {
                
                withProgress(message = "Fitting Bigelow model", value = 0, {
                    
                    fit_results <- fit_inactivation_MCMC(exp_data, "Bigelow", temp_profile,
                                                         starting_points, upper, lower,
                                                         known_pars, niter = input$bigelow_niter,
                                                         burninlength = input$bigelow_burn)
                    
                })
            }

            fit_results
        }
        
    }) 
    
    output$bigelow_plot <- renderPlot({
        
        plot(fit_bigelow())
        
    })
    
    #--------------------------------------------------------------------------
    
    output$bigelow_summary <- renderPrint({
        summary(fit_bigelow())
    })
    
    #--------------------------------------------------------------------------

    output$bigelow_interval <- renderPlot({
        
        withProgress(message = "Calculating prediction interval", value = 0, {
            
            temp_profile <- select(exp_data, time, temperature = temp)
            prediction_interval <- predict_inactivation_MCMC(fit_bigelow(), temp_profile,
                                                             quantiles = input$bigelow_quantiles)
            plot(prediction_interval)  
        })
        
    })
    
    #==========================================================================
    
    fit_peleg <- eventReactive(input$btn_peleg, {
        
        if (input$btn_peleg != 0) {
            
            ## Gather the input data
            
            temp_profile <- select(exp_data, time, temperature = temp)
            
            #- Parameters
            
            known_pars <- numeric()
            starting_points <- numeric()
            upper <- numeric()
            lower <- numeric()
            
            if (input$peleg_kb_known) {
                known_pars <- c(known_pars, k_b = input$peleg_kb_start)
            } else {
                starting_points <- c(starting_points, k_b = input$peleg_kb_start)
                lower <- c(lower, k_b = input$peleg_kb_range[1])
                upper <- c(upper, k_b = input$peleg_kb_range[2])
            }
            
            if (input$peleg_n_known) {
                known_pars <- c(known_pars, n = input$peleg_n_start)
            } else {
                starting_points <- c(starting_points, n = input$peleg_n_start)
                lower <- c(lower, n = input$peleg_n_range[1])
                upper <- c(upper, n = input$peleg_n_range[2])
            }
            
            if (input$peleg_tempcrit_known) {
                known_pars <- c(known_pars, temp_crit = input$peleg_temcrit_start)
            } else {
                starting_points <- c(starting_points, temp_crit = input$peleg_temcrit_start)
                lower <- c(lower, temp_crit = input$peleg_tempcrit_range[1])
                upper <- c(upper, temp_crit = input$peleg_tempcrit_range[2])
            }
            
            if (input$peleg_logN0_known) {
                known_pars <- c(known_pars, N0 = 10^input$peleg_logN0_start)
            } else {
                starting_points <- c(starting_points, N0 = 10^input$peleg_logN0_start)
                lower <- c(lower, N0 = 10^input$peleg_logN0_range[1])
                upper <- c(upper, N0 = 10^input$peleg_logN0_range[2])
            }
            
            ## Make the adjustment
            
            withProgress(message = "Fitting Peleg model", value = 0, {
                
                if (input$algorithm_peleg == "nlr") {
                    
                    fit_results <- fit_dynamic_inactivation(exp_data, "Peleg", temp_profile,
                                                            starting_points, upper, lower,
                                                            known_pars)
                    
                } else {
                    fit_results <- fit_inactivation_MCMC(exp_data, "Peleg", temp_profile,
                                                         starting_points, upper, lower,
                                                         known_pars, niter = input$peleg_niter,
                                                         burninlength = input$peleg_burn)
                    
                }
                
            })

            fit_results
        }
        
    })
    
    #--------------------------------------------------------------------------
    
    output$peleg_plot <- renderPlot({
        
        plot(fit_peleg())
        
    })
    
    #--------------------------------------------------------------------------
    
    output$peleg_summary <- renderPrint({
        summary(fit_peleg())
    })
    
    output$peleg_interval <- renderPlot({
        
        withProgress(message = "Generating prediction interval", value = 0, {
            
            temp_profile <- select(exp_data, time, temperature = temp)
            prediction_interval <- predict_inactivation_MCMC(fit_peleg(), temp_profile,
                                                             quantiles = input$peleg_quantiles)
            plot(prediction_interval)
            
        })
        
    })
    
    #==========================================================================
    
    fit_mafart <- eventReactive(input$btn_mafart, {
        
        if (input$btn_mafart != 0) {
            
            ## Gather the input data
            
            temp_profile <- select(exp_data, time, temperature = temp)
            
            #- Parameters
            
            known_pars <- numeric()
            starting_points <- numeric()
            upper <- numeric()
            lower <- numeric()
            
            if (input$mafart_delta_known) {
                known_pars <- c(known_pars, delta_ref = input$mafart_delta_start)
            } else {
                starting_points <- c(starting_points, delta_ref = input$mafart_delta_start)
                lower <- c(lower, delta_ref = input$mafart_delta_range[1])
                upper <- c(upper, delta_ref = input$mafart_delta_range[2])
            }
            
            if (input$mafart_p_known) {
                known_pars <- c(known_pars, p = input$mafart_p_start)
            } else {
                starting_points <- c(starting_points, p = input$mafart_p_start)
                lower <- c(lower, p = input$mafart_p_range[1])
                upper <- c(upper, p = input$mafart_p_range[2])
            }
            
            if (input$mafart_z_known) {
                known_pars <- c(known_pars, z = input$mafart_z_start)
            } else {
                starting_points <- c(starting_points, z = input$mafart_z_start)
                lower <- c(lower, z = input$mafart_z_range[1])
                upper <- c(upper, z = input$mafart_z_range[2])
            }
            
            if (input$mafart_tempref_known) {
                known_pars <- c(known_pars, temp_ref = input$mafart_temref_start)
            } else {
                starting_points <- c(starting_points, temp_ref = input$mafart_temref_start)
                lower <- c(lower, temp_ref = input$mafart_tempref_range[1])
                upper <- c(upper, temp_ref = input$mafart_tempref_range[2])
            }
            
            if (input$mafart_logN0_known) {
                known_pars <- c(known_pars, N0 = 10^input$mafart_logN0_start)
            } else {
                starting_points <- c(starting_points, N0 = 10^input$mafart_logN0_start)
                lower <- c(lower, N0 = 10^input$mafart_logN0_range[1])
                upper <- c(upper, N0 = 10^input$mafart_logN0_range[2])
            }
            
            ## Make the adjustment
            
            withProgress(message = "Fitting Mafart model", value = 0, {
                
                if (input$algorithm == "nlr") {
                    
                    fit_results <- fit_dynamic_inactivation(exp_data, "Mafart", temp_profile,
                                                            starting_points, upper, lower,
                                                            known_pars)
                    
                } else {
                    fit_results <- fit_inactivation_MCMC(exp_data, "Mafart", temp_profile,
                                                         starting_points, upper, lower,
                                                         known_pars)
                    
                }
                
                fit_results
            })
        }
    })
    
    #--------------------------------------------------------------------------
    
    output$mafart_plot <- renderPlot({
        
        plot(fit_mafart())
        
    })
    
    #--------------------------------------------------------------------------
    
    output$mafart_summary <- renderPrint({
        summary(fit_mafart())
    })
    
    output$mafart_interval <- renderPlot({
        
        withProgress(message = "Calculating prediction interval", value = 0, {
            
            temp_profile <- select(exp_data, time, temperature = temp)
            prediction_interval <- predict_inactivation_MCMC(fit_mafart(), temp_profile,
                                                             quantiles = input$mafart_quantiles)
            plot(prediction_interval)
            
        })
        
    })
    
    #==========================================================================
    
    fit_geeraerd <- eventReactive(input$btn_geeraerd, {
        
        
        if (input$btn_geeraerd != 0) {
            
            ## Gather the input data
            
            temp_profile <- select(exp_data, time, temperature = temp)
            
            #- Parameters
            
            known_pars <- numeric()
            starting_points <- numeric()
            upper <- numeric()
            lower <- numeric()
            
            if (input$geeraerd_DR_known) {
                known_pars <- c(known_pars, D_R = input$geeraerd_DR_start)
            } else {
                starting_points <- c(starting_points, D_R = input$geeraerd_DR_start)
                lower <- c(lower, D_R = input$geeraerd_DR_range[1])
                upper <- c(upper, D_R = input$geeraerd_DR_range[2])
            }
            
            if (input$geeraerd_z_known) {
                known_pars <- c(known_pars, z = input$geeraerd_z_start)
            } else {
                starting_points <- c(starting_points, z = input$geeraerd_z_start)
                lower <- c(lower, z = input$geeraerd_z_range[1])
                upper <- c(upper, z = input$geeraerd_z_range[2])
            }
            
            if (input$geeraerd_tempref_known) {
                known_pars <- c(known_pars, temp_ref = input$geeraerd_tempref_start)
            } else {
                starting_points <- c(starting_points, temp_ref = input$geeraerd_tempref_start)
                lower <- c(lower, temp_ref = input$geeraerd_tempref_range[1])
                upper <- c(upper, temp_ref = input$geeraerd_tempref_range[2])
            }
            
            if (input$geeraerd_Cc0_known) {
                known_pars <- c(known_pars, C_c0 = input$geeraerd_Cc0_start)
            } else {
                starting_points <- c(starting_points, C_c0 = input$geeraerd_Cc0_start)
                lower <- c(lower, C_c0 = input$geeraerd_C_c0_range[1])
                upper <- c(upper, C_c0 = input$geeraerd_C_c0_range[2])
            }
            
            if (input$geeraerd_logNmin_known) {
                known_pars <- c(known_pars, N_min = 10^input$geeraerd_logNmin_start)
            } else{
                starting_points <- c(starting_points, N_min = 10^input$geeraerd_logNmin_start)
                lower <- c(lower, N_min = 10^input$geeraerd_logNmin_range[1])
                upper <- c(upper, N_min = 10^input$geeraerd_logNmin_range[2])
            }
            
            if (input$geeraerd_logN0_known) {
                known_pars <- c(known_pars, N0 = 10^input$geeraerd_logN0_start)
            } else {
                starting_points <- c(starting_points, N0 = 10^input$geeraerd_logN0_start)
                lower <- c(lower, N0 = 10^input$geeraerd_logN0_range[1])
                upper <- c(upper, N0 = 10^input$geeraerd_logN0_range[2])
            }
            
            ## Make the adjustment
            
            withProgress(message = "Fitting Geeraerd model", value = 0, {
                
                if (input$algorithm == "nlr") {
                    
                    fit_results <- fit_dynamic_inactivation(exp_data, "Geeraerd", temp_profile,
                                                            starting_points, upper, lower,
                                                            known_pars)
                    
                } else {
                    fit_results <- fit_inactivation_MCMC(exp_data, "Geeraerd", temp_profile,
                                                         starting_points, upper, lower,
                                                         known_pars)
                    
                }
                
                fit_results
                
            })
        }
        
    }) 
    
    output$geeraerd_plot <- renderPlot({
        
        plot(fit_geeraerd())
        
    })
    
    #--------------------------------------------------------------------------
    
    output$geeraerd_summary <- renderPrint({
        summary(fit_geeraerd())
    })
    
    #--------------------------------------------------------------------------
    
    output$geeraerd_interval <- renderPlot({
        
        withProgress(message = "Calculating prediction interval", value = 0, {
            
            temp_profile <- select(exp_data, time, temperature = temp)
            prediction_interval <- predict_inactivation_MCMC(fit_geeraerd(), temp_profile,
                                                             quantiles = input$geeraerd_quantiles)
            plot(prediction_interval)
            
        })
        
    })
    
})





















