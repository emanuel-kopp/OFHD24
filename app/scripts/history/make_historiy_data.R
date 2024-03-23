

make_example_plot <- function(pest_name) {
  library(xlsx)
  library(ggplot2)
  
  
  bonitur_ID <- seq(1:10)
  plot <- rep("Hinderegg", 10)
  BBCH <- seq(58, 76, by = 2)
  pest <- rep(pest_name, 10)
  unit <- rep("Blütenbüschel", 10)
  nr_of_units_counted <- rep(100, 10)
  unit_infested <- c(0, 1, 2, 5, 10, 25, 5, 10, 8, 10)
  count_pests <- rep(NA, 10)
  
  df_sample <-
    data.frame(bonitur_ID,
               plot,
               BBCH,
               pest,
               unit,
               nr_of_units_counted,
               unit_infested,
               count_pests)
  
  ggplot(data = df_sample, aes(x = BBCH, y = unit_infested)) +
    geom_point() +
    geom_line() +
    theme_classic(base_size = 22) +
    geom_hline(aes(yintercept = 20), col = "red") +
    ggtitle(pest_name) +
    xlab("BBCH") +
    ylab("% Befallene Organe")
}
