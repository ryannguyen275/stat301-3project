## svm radial results 

library(tidymodels)
library(tidyverse)
library(kableExtra)

tidymodels_prefer()

set.seed(25)

load("results/songs_split.rda")
load("results/svm_radial_1_tuned.rda")


###########################################################################
# organize results to find best overall 

# individual model results, good to put into an appendix  
autoplot_svm_radial <- autoplot(svm_radial_tuned, metric = "roc_auc")

ggsave("images/autoplot_svm_radial.png")


# we can show the best model, good for looking at a single model  
svm_radial_table <- svm_radial_tuned %>% 
   show_best(metric = "roc_auc")  # %>% 
  # kbl() %>% 
  # kable_classic() %>% 
  # save_kable("nn_table.png", zoom = 10)

# run time table 
svm_radial_time <- svm_radial_tictoc %>% 
  mutate(runtime = runtime/60) # %>% 
  # kbl() %>% 
  # kable_classic() %>% 
  # save_kable("nn_time.png", zoom = 10)

save(svm_radial_table, svm_radial_time, file = "results/svm_radial_1_table.rda")
