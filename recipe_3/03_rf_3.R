library(tidymodels)
library(tidyverse)
library(kableExtra)

tidymodels_prefer()

set.seed(25)

load("data/songs_split.rda")
load("recipe_2/results/rf_2_tuned.rda")

###########################################################################
# organize results to find best overall 

# individual model results, good to put into an appendix  
autoplot_rf <- autoplot(rf_tuned_2, metric = "roc_auc")

ggsave("autoplot_rf.png")


# we can show the best model, good for looking at a single model  
rf_table <- rf_tuned_2 %>% 
  show_best(metric = "roc_auc") 
# kbl() %>% 
# kable_classic() %>% 
# save_kable("rf_table.png", zoom = 10)

# run time table 
rf_time <- rf_tictoc %>% 
  mutate(runtime = runtime/60) 
# kbl() %>% 
# kable_classic() %>% 
# save_kable("rf_time.png", zoom = 10)

save(rf_table, rf_time, file = "recipe_2/results/rf_2_table.rda")
