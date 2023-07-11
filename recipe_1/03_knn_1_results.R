library(tidymodels)
library(tidyverse)
library(kableExtra)

tidymodels_prefer()

set.seed(25)

load("results/songs_split.rda")
load("results/knn_1_tuned.rda")

###########################################################################
# organize results to find best overall 

# individual model results, good to put into an appendix  
autoplot_knn <- autoplot(knn_tuned, metric = "roc_auc")

ggsave("autoplot_knn.png")



# we can show the best model, good for looking at a single model  
knn_table <- knn_tuned %>% 
  show_best(metric = "roc_auc") 
  # kbl() %>% 
  # kable_classic() %>% 
  # save_kable("knn_table.png", zoom = 10)

# run time table 
knn_time <- knn_tictoc %>% 
  mutate(runtime = runtime/60) 
  # kbl() %>% 
  # kable_classic() %>% 
  # save_kable("knn_time.png", zoom = 10)

save(knn_table, knn_tictoc, file = "results/knn_1_table.rda")







