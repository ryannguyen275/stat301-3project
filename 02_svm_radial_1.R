# svm radial 
library(tidymodels)
library(tidyverse)
library(tictoc)
library(tokenizers)
library(tidytext)
library(textrecipes)
library(doMC)

tidymodels_prefer()

load("data/songs_split.rda")
load("recipe_1/results/recipe_1.rda")

######################################
# set up parallel processing
parallel::detectCores()
registerDoMC(cores = 4)

#####################################
## define model engine and workflow 
svm_radial_model <- svm_rbf(
  mode = "classification", 
  cost = tune(),
  rbf_sigma = tune()
) %>%
  set_engine("kernlab")

# extract params 
svm_radial_params <- extract_parameter_set_dials(svm_radial_model)

# grid
svm_radial_grid <- grid_regular(svm_radial_params, levels = 5)

# workflow 
svm_radial_workflow <- workflow() %>% 
  add_model(svm_radial_model) %>% 
  add_recipe(recipe_1)

#####################################
# tune grid
tic.clearlog()
tic("svm_radial") 

svm_radial_tuned <- tune_grid(
  svm_radial_workflow,
  resamples = songs_folds, 
  grid = svm_radial_grid,
  verbose = TRUE,
  # control: makes it run faster
  control = control_grid(save_pred = TRUE,
                         save_workflow = TRUE,
                         verbose = TRUE,
                         parallel_over = "everything"))

toc(log = TRUE)

time_log <- tic.log(format = FALSE)

# want the tibble to show model name and run time 
svm_radial_tictoc <- tibble(model = time_log[[1]]$msg, 
                            runtime = time_log[[1]]$toc - time_log[[1]]$tic)

save(svm_radial_tuned, svm_radial_tictoc, file = "recipe_1/results/svm_radial_tuned.rda")

