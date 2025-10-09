# stable CI output for sample incidence

    Code
      calculate_incidence(linked_df, type = "cumulative", id_col = "id", date_col = "year",
        pop_data = pop_df, pop_col = "population", time_p = c(2012, 2013),
        only_counts = FALSE, suppression = TRUE, suppression_threshold = 10, CI = TRUE,
        CI_level = 0.95, log_path = l_path)
    Output
      
    Message
      ! To correctly calculate incidence rates, the provided dataset should only contain new/first time diagnoses.
    Output
      
      
    Message
      v Suppressed counts using 10 threshold
      i Removed 0 cells out of 1
    Output
      
    Message
      Joining with `by = join_by(year)`
    Output
      
    Message
      v Cumulative incidence ready
    Output
      # A tibble: 1 x 8
        year      incidence_cases population cum_incidence ci_results_method
        <chr>               <int>      <dbl>         <dbl> <chr>            
      1 2012-2013              74       4500        0.0164 exact            
      # i 3 more variables: ci_results_mean <dbl>, ci_results_lower <dbl>,
      #   ci_results_upper <dbl>

