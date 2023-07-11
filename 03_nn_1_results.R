## neural network results 

library(tidymodels)
library(tidyverse)
library(kableExtra)

tidymodels_prefer()

set.seed(25)

load("results/songs_split.rda")
load("results/nn_1_tuned.rda")


###########################################################################
# organize results to find best overall 

# individual model results, good to put into an appendix  
autoplot_nn <- autoplot(nn_tuned, metric = "roc_auc")

ggsave("autoplot_nn.png")



# we can show the best model, good for looking at a single model  
nn_table <- nn_tuned %>% 
  show_best(metric = "roc_auc")  
  # kbl() %>% 
  # kable_classic() %>% 
  # save_kable("nn_table.png", zoom = 10)

# run time table 
nn_time <- nn_tictoc %>% 
  mutate(runtime = runtime/60)  
  # kbl() %>% 
  # kable_classic() %>% 
  # save_kable("nn_time.png", zoom = 10)


save(nn_table, nn_time, file = here::here("results/nn_tables.rda"))
