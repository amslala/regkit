# stable CI output for sample incidence

    Code
      calculate_prevalence(linked_df, id_col = "id", date_col = "year", pop_data = pop_df,
        pop_col = "population", time_p = c(2012, 2020), only_counts = FALSE,
        suppression = TRUE, suppression_threshold = 10, CI = TRUE, CI_level = 0.99,
        log_path = l_path)
    Message
      Computing prevalence rates/counts...
      v Suppressed counts using 10 threshold
      i Removed 0 cells out of 1
      Joining with `by = join_by(year)`
    Output
      
    Message
      v Prevalence rates ready!
      
      -- Summary ---------------------------------------------------------------------
      i Diagnostic and demographic data: linked_df
      i Population data: pop_df
      i Grouped by variables: 
      i For time point/period:  2012 and 2020
    Output
      # A tibble: 1 x 9
        year      unique_id total_events population prev_rate ci_results_method
        <chr>         <int>        <int>      <dbl>     <dbl> <chr>            
      1 2012-2020       691          691      30024    0.0230 exact            
      # i 3 more variables: ci_results_mean <dbl>, ci_results_lower <dbl>,
      #   ci_results_upper <dbl>

