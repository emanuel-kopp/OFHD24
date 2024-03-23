

make_example_plot <- function(pest_name) {
  library(ggplot2)
  
  
  bonitur_ID <- rep(seq(1:10), 2)
  plot <- rep(rep("Hinderegg", 10), 2)
  BBCH <- rep(seq(58, 76, by = 2), 2)
  pest <- c(rep("Apfelwickler", 10), rep("Apfelblütenstecher", 10)) 
  unit <- rep("Blütenbüschel", 20)
  nr_of_units_counted <- rep(100, 20)
  unit_infested <- c(0, 1, 2, 5, 10, 25, 5, 10, 8, 10,
                     0, 0, 1, 1, 2, 4, 5, 8, 3, 2)
  threshold <- c(rep(20, 10), rep(7, 10))
  
  df_sample <-
    data.frame(bonitur_ID,
               plot,
               BBCH,
               pest,
               unit,
               nr_of_units_counted,
               unit_infested,
               threshold)
  df_sample <- subset(df_sample, pest == pest_name)
  ggplot(data = df_sample, aes(x = BBCH, y = unit_infested)) +
    geom_point() +
    geom_line() +
    theme_classic(base_size = 22) +
    geom_hline(aes(yintercept = unique(df_sample$threshold)), col = "red") +
    ggtitle(pest_name) +
    xlab("BBCH") +
    ylab("% Befallene Organe")
}
