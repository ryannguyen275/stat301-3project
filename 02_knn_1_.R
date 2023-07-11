# knn tuning

library(tidymodels)
library(tidyverse)
library(tictoc)
library(doMC)
library(tokenizers)
library(tidytext)
library(textrecipes)

tidymodels_prefer()

load("results/songs_split.rda")
load("results/recipe_1.rda")

######################################
# set up parallel processing
registerDoMC(cores = 4)

#####################################
## define model engine and workflow 


knn_model <- nearest_neighbor(mode = "classification",
                              neighbors = tune()) %>%   # have to tune
  set_engine("kknn")

# extract params 
knn_params <- extract_parameter_set_dials(knn_model)

# grid
knn_grid <- grid_regular(knn_params, levels = 5)


# workflow 
knn_workflow <- workflow() %>% 
  add_model(knn_model) %>% 
  add_recipe(recipe_1)


#####################################
# tune grid
tic.clearlog()
tic("KNN") 

knn_tuned <- tune_grid(
  knn_workflow,
  resamples = songs_folds, 
  grid = knn_grid,
  # control: makes it run faster
  control = control_grid(save_pred = TRUE,
                         save_workflow = TRUE,
                         parallel_over = "everything"))

toc(log = TRUE)

time_log <- tic.log(format = FALSE)

# want the tibble to show model name and run time 
knn_tictoc <- tibble(model = time_log[[1]]$msg, 
                     runtime = time_log[[1]]$toc - time_log[[1]]$tic)


save(knn_tuned,knn_tictoc, file = "results/knn_1_tuned.rda")

