
library(ggplot2)
library(bioinactivation)
library(dplyr)
library(FME)

#==============================================================================

exp_data <- NULL

#==============================================================================

#' 
#' Summary of a dynamic fit object
#' 
#' Returns a data frame with the estimate, standard deviation and 95% confidence
#' interval of the model paramters of an object generated using non linear
#' regression.
#' 
summary_dynamic_fit <- function(dynamic_fit) {
    
    fit_summary <- summary(dynamic_fit)
    
    out_frame <- as.data.frame(fit_summary$par)
    out_frame <- cbind(rownames(out_frame), out_frame)
    out_frame <- out_frame[ , 1:3]
    names(out_frame) <- c("parameter", "estimate", "std")
    n_df <- fit_summary$df[2]
    t_value <- qt(0.975, n_df)
    
    out_frame <- mutate(out_frame,
                        lower95 = estimate - t_value*std,
                        upper95 = estimate + t_value*std
                        )
    
    out_frame
    
}

#'
#' Summary of MCMC fit object
#' 
#' Returns a data frame with the estimate, standard deviation and 95% confidence
#' interval of the model paramters of an object generated using MCMC.
#' 
summary_MCMC_fit <- function(MCMC_fit) {
    
    fit_summary <- summary(MCMC_fit)
    
    intervals <- apply(MCMC_fit$modMCMC$pars, 2, quantile, probs = c(0.025, 0.975))
    
    out_frame <- data.frame(parameter = names(fit_summary),
                            estimate = MCMC_fit$modMCMC$bestpar,
                            std = unlist(fit_summary[2, ]),
                            lower95 = intervals[1, ],
                            upper95 = intervals[2, ])
    
    out_frame
    
}

#==============================================================================

#'
#' Residual analysis of an MCMC fit
#' 
residuals_MCMC_fit <- function(MCMC_fit) {
    
#     loglike <- MCMC_fit$modMCMC$bestfunp
    
    simulation_model <- MCMC_fit$best_prediction$model
    times <- MCMC_fit$data$time
    parms <- MCMC_fit$best_prediction$model_parameters
    temp_profile <- select(exp_data, time, temperature = temp)
    
    
    my_prediction <- predict_inactivation(simulation_model, times, parms,
                                          temp_profile)
    
    exp_data <- mutate(exp_data, logN = log10(N)) %>%
                select(., time, logN)
    
    my_prediction <- my_prediction$simulation %>%
                     select(., time, logN)
    
    my_prediction[my_prediction$time <= 1e-4, ]$time <- 0
    
    model_cost <- modCost(model = my_prediction, obs = exp_data)
    n_points <- nrow(MCMC_fit$data)
    
    out_frame <- data.frame(SSE = model_cost$model,
                            MSE = model_cost$model/n_points,
                            RMSE = sqrt(model_cost$model/n_points)
    )
    out_frame
}

#'
#' Residual analysis of a nlr fit
#' 
residuals_nlr_fit <- function(dynamic_fit) {
    
    out_frame <- data.frame(SSE = dynamic_fit$fit_results$ssr,
                            MSE = dynamic_fit$fit_results$ms,
                            RMSE = sqrt(dynamic_fit$fit_results$ms)
                            )
    out_frame
}

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
    
    output$bigelow_summary <- renderTable({
        
        my_fit <- fit_bigelow()
        
        if (input$algorithm_bigelow == "nlr") {
            
            out_frame <- summary_dynamic_fit(my_fit)
            

        } else {
            out_frame <- summary_MCMC_fit(my_fit)
        }

        out_frame
        
    }, include.rownames = FALSE)
    
    #--------------------------------------------------------------------------
    
    output$bigelow_residuals <- renderTable({
        
        my_fit <- fit_bigelow()
        
        if (input$algorithm_bigelow == "nlr") {
            
            out_frame <- residuals_nlr_fit(my_fit)
            
        } else {
            out_frame <- residuals_MCMC_fit(my_fit)
        }
        
        out_frame
        
    }, include.rownames = FALSE)
    
    #--------------------------------------------------------------------------

    output$bigelow_interval <- renderPlot({
        
        withProgress(message = "Calculating prediction interval", value = 0, {
            
            temp_profile <- select(exp_data, time, temperature = temp)
            prediction_interval <- predict_inactivation_MCMC(fit_bigelow(), temp_profile,
                                                             quantiles = input$bigelow_quantiles)
            plot(prediction_interval)  + ylab("logN")
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
    
    output$peleg_summary <- renderTable({
            
            my_fit <- fit_peleg()
            
            if (input$algorithm_peleg == "nlr") {
                
                out_frame <- summary_dynamic_fit(my_fit)
                
                
            } else {
                out_frame <- summary_MCMC_fit(my_fit)
            }
            
            out_frame
            
        }, include.rownames = FALSE)
    
    #--------------------------------------------------------------------------
    
    output$peleg_residuals <- renderTable({
        
        my_fit <- fit_peleg()
        
        if (input$algorithm_peleg == "nlr") {
            
            out_frame <- residuals_nlr_fit(my_fit)
            
        } else {
            out_frame <- residuals_MCMC_fit(my_fit)
        }
        
        out_frame
        
    }, include.rownames = FALSE)
    
    #--------------------------------------------------------------------------
    
    output$peleg_interval <- renderPlot({
        
        withProgress(message = "Generating prediction interval", value = 0, {
            
            temp_profile <- select(exp_data, time, temperature = temp)
            prediction_interval <- predict_inactivation_MCMC(fit_peleg(), temp_profile,
                                                             quantiles = input$peleg_quantiles)
            plot(prediction_interval) + ylab("logN")
            
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
                
                if (input$algorithm_mafart == "nlr") {
                    
                    fit_results <- fit_dynamic_inactivation(exp_data, "Mafart", temp_profile,
                                                            starting_points, upper, lower,
                                                            known_pars)
                    
                } else {
                    fit_results <- fit_inactivation_MCMC(exp_data, "Mafart", temp_profile,
                                                         starting_points, upper, lower,
                                                         known_pars, niter = input$mafart_niter,
                                                         burninlength = input$mafart_burn)
                    
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
    
    output$mafart_summary <- renderTable({
        
        my_fit <- fit_mafart()
        
        if (input$algorithm_mafart == "nlr") {
            
            out_frame <- summary_dynamic_fit(my_fit)
            
            
        } else {
            out_frame <- summary_MCMC_fit(my_fit)
        }
        
        out_frame
        
    }, include.rownames = FALSE)
    
    #--------------------------------------------------------------------------
    
    output$mafart_residuals <- renderTable({
        
        my_fit <- fit_mafart()
        
        if (input$algorithm_mafart == "nlr") {
            
            out_frame <- residuals_nlr_fit(my_fit)
            
        } else {
            out_frame <- residuals_MCMC_fit(my_fit)
        }
        
        out_frame
        
    }, include.rownames = FALSE)
    
    #--------------------------------------------------------------------------
    
    output$mafart_interval <- renderPlot({
        
        withProgress(message = "Calculating prediction interval", value = 0, {
            
            temp_profile <- select(exp_data, time, temperature = temp)
            prediction_interval <- predict_inactivation_MCMC(fit_mafart(), temp_profile,
                                                             quantiles = input$mafart_quantiles)
            plot(prediction_interval)  + ylab("logN")
            
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
                
                if (input$algorithm_geeraerd == "nlr") {
                    
                    fit_results <- fit_dynamic_inactivation(exp_data, "Geeraerd", temp_profile,
                                                            starting_points, upper, lower,
                                                            known_pars)
                    
                } else {
                    fit_results <- fit_inactivation_MCMC(exp_data, "Geeraerd", temp_profile,
                                                         starting_points, upper, lower,
                                                         known_pars, niter = input$geeraerd_niter,
                                                         burninlength = input$geeraerd_burn)
                    
                }
                
                fit_results
                
            })
        }
        
    }) 
    
    output$geeraerd_plot <- renderPlot({
        
        plot(fit_geeraerd())
        
    })
    
    #--------------------------------------------------------------------------
    
    output$geeraerd_summary <- renderTable({
        
        my_fit <- fit_geeraerd()
        
        if (input$algorithm_geeraerd == "nlr") {
            
            out_frame <- summary_dynamic_fit(my_fit)
            
            
        } else {
            out_frame <- summary_MCMC_fit(my_fit)
        }
        
        out_frame
        
    }, include.rownames = FALSE)
    
    #--------------------------------------------------------------------------
    
    output$geeraerd_residuals <- renderTable({
        
        my_fit <- fit_geeraerd()
        
        if (input$algorithm_geeraerd == "nlr") {
            
            out_frame <- residuals_nlr_fit(my_fit)
            
        } else {
            out_frame <- residuals_MCMC_fit(my_fit)
        }
        
        out_frame
        
    }, include.rownames = FALSE)
    
    #--------------------------------------------------------------------------
    
    output$geeraerd_interval <- renderPlot({
        
        withProgress(message = "Calculating prediction interval", value = 0, {
            
            temp_profile <- select(exp_data, time, temperature = temp)
            prediction_interval <- predict_inactivation_MCMC(fit_geeraerd(), temp_profile,
                                                             quantiles = input$geeraerd_quantiles)
            plot(prediction_interval) + ylab("logN")
            
        })
        
    })
    
    #==========================================================================
    
    ## FUNCTIONS FOR DOWNLOADING RESULTS
    
    output$down_Bigelow_pred <- downloadHandler(
        filename = function() input$filename_Bigelow_pred,
        content = function(file) {
            out_results <- fit_bigelow()
            print(out_results$best_prediction$simulation)
            write.csv(out_results$best_prediction$simulation, file = file, row.names = FALSE)
        }
    )
    
    output$down_Peleg_pred <- downloadHandler(
        filename = function() input$filename_Peleg_pred,
        content = function(file) {
            out_results <- fit_peleg()
            print(out_results$best_prediction$simulation)
            write.csv(out_results$best_prediction$simulation, file = file, row.names = FALSE)
        }
    )
    
    output$down_Mafart_pred <- downloadHandler(
        filename = function() input$filename_Mafart_pred,
        content = function(file) {
            out_results <- fit_mafart()
            print(out_results$best_prediction$simulation)
            write.csv(out_results$best_prediction$simulation, file = file, row.names = FALSE)
        }
    )
    
    output$down_Geeraerd_pred <- downloadHandler(
        filename = function() input$filename_Geeraerd_pred,
        content = function(file) {
            out_results <- fit_geeraerd()
            print(out_results$best_prediction$simulation)
            write.csv(out_results$best_prediction$simulation, file = file, row.names = FALSE)
        }
    )
    
})





















