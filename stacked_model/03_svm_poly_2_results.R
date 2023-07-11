library(tidymodels) 
library(tidyverse)
library(kableExtra)

tidymodels_prefer()

set.seed(25)

load("results/songs_split.rda")
load("results/svm_poly_4_tuned.rda")

###########################################################################
# organize results to find best overall 

# individual model results, good to put into an appendix  
autoplot_svm_poly <- autoplot(svm_poly_tuned, metric = "roc_auc")

ggsave("autoplot_svm_poly.png")



# we can show the best model, good for looking at a single model  
svm_poly_table <- svm_poly_tuned %>% 
  show_best(metric = "roc_auc")
# kbl() %>% 
# kable_classic() %>% 
# save_kable("svm_poly_table.png", zoom = 10)

# run time table 
svm_poly_time <- svm_poly_tictoc %>% 
  mutate(runtime = runtime/60) 
# kbl() %>% 
# kable_classic() %>% 
# save_kable("svm_poly_time.png", zoom = 10)

save(svm_poly_table, svm_poly_time, file = "results/svm_poly_4_table.rda" )









