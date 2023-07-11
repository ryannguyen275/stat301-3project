library(tidymodels) 
library(tidyverse)
library(kableExtra)

tidymodels_prefer()

set.seed(25)

load(here::here("data/songs_split.rda"))
load(here::here("recipe_2/results/bt_1_tuned.rda"))

###########################################################################
# organize results to find best overall 

# individual model results, good to put into an appendix  
autoplot_bt <- autoplot(bt_tune, metric = "roc_auc")

ggsave("autoplot_bt.png")



# we can show the best model, good for looking at a single model  
bt_table <- bt_tune %>% 
  show_best(metric = "roc_auc")
# kbl() %>% 
# kable_classic() %>% 
# save_kable("svm_poly_table.png", zoom = 10)

# run time table 
bt_time <- bt_tictoc %>% 
  mutate(runtime = runtime/60) 
# kbl() %>% 
# kable_classic() %>% 
# save_kable("svm_poly_time.png", zoom = 10)

save(bt_table, bt_time, file = here::here("recipe_2/results/bt_2_tables.rda"))










