library(tidymodels)
library(tidyverse)
library(kableExtra)

tidymodels_prefer()

set.seed(25)

load("data/songs_split.rda")
load("recipe_1/results/en_1_tuned.rda")

###########################################################################
# organize results to find best overall 

# individual model results, good to put into an appendix  
autoplot <- autoplot(en_tuned, metric = "roc_auc")

ggsave("autoplot.png")



# we can show the best model, good for looking at a single model  
en_table <- en_tuned %>% 
  show_best(metric = "roc_auc") 
  # kbl() %>% 
  # kable_classic() %>% 
  # save_kable("en_table.png", zoom = 10)

# run time table 
en_time <- en_tictoc %>% 
  mutate(runtime = runtime/60) 
  # kbl() %>% 
  # kable_classic() %>% 
  # save_kable("en_time.png", zoom = 10)

save(en_table, en_time, file = "recipe_1/results/en_1_table.rda")








