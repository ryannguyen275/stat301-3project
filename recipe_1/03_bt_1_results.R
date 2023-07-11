library(tidymodels)
library(tidyverse)

tidymodels_prefer()

set.seed(25)

load("data/songs_split.rda")
load("recipe_1/results/bt_1_tuned.rda")

###########################################################################
# organize results to find best overall 

# we can show the best model, good for looking at a single model  
bt_table <- bt_tune %>% 
  show_best(metric = "roc_auc")  # %>% 
# kbl() %>% 
# kable_classic() %>% 
# save_kable("nn_table.png", zoom = 10)

# run time table 
bt_time <- bt_tictoc %>% 
  mutate(runtime = runtime/60) # %>% 
# kbl() %>% 
# kable_classic() %>% 
# save_kable("nn_time.png", zoom = 10)

save(bt_table, bt_time, file = "recipe_1/results/bt_1_table.rda")

