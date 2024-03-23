make_example_plot_one_rating <- function(bonitur_ID) {
  library(ggplot2)

  
  bonitur_ID <- c(1,1,1)
  plot <- rep("Hinderegg", 3)
  BBCH <- rep(60, 3)
  pest <- c("Apfelwickler","Blutlaus","Gespinstmotte")
  unit <- rep("Blütenbüschel", 3)
  nr_of_units_counted <- rep(100, 3)
  unit_infested <- c(25,3,20)
  count_pests <- rep(NA, 3)
  threshold <- c(20,12,22)
  
  df_sample <-
    data.frame(bonitur_ID,
               plot,
               BBCH,
               pest,
               unit,
               nr_of_units_counted,
               unit_infested,
               count_pests,
               threshold)
  df_sample$pest <- as.factor(df_sample$pest)
  
  ggplot(data = df_sample, aes(x = pest, y = unit_infested,fill=pest)) +
    geom_bar(stat = "identity", show.legend = F)+
    geom_point(aes(x = pest, y = threshold), show.legend = F,shape = 8, size=4) +
    theme_classic(base_size = 22) +
    ggtitle(paste0("Bonitur # ",bonitur_ID)) +
    xlab("Schädlingsname") +
    ylab("% Befallene Organe")
}