# neural network tuning

library(tidymodels)
library(tidyverse)
library(tictoc)
library(doMC)
library(textrecipes)
library(tokenizers)
library(mlr3verse)

tidymodels_prefer()

load("data/songs_split.rda")
load("recipe_1/results/recipe_1.rda")

######################################
# set up parallel processing
parallel::detectCores()
registerDoMC(cores = 4)

#####################################
## define model engine and workflow 
nn_model <- mlp(
  mode = "classification", # or regression
  hidden_units = tune(),
  penalty = tune()) %>%
  set_engine("nnet")

# extract params 
nn_params <- extract_parameter_set_dials(nn_model)

# grid
nn_grid <- grid_regular(nn_params, levels = 5)


# workflow 
nn_workflow <- workflow() %>% 
  add_model(nn_model) %>% 
  add_recipe(recipe_1)

#####################################
# tune grid
tic.clearlog()
tic("Neural Network") 

nn_tuned <- tune_grid(
  nn_workflow,
  resamples = songs_folds, 
  grid = nn_grid,
  # control: makes it run faster
  control = control_grid(save_pred = TRUE,
                         save_workflow = TRUE,
                         parallel_over = "everything"))

toc(log = TRUE)

time_log <- tic.log(format = FALSE)

# want the tibble to show model name and run time 
nn_tictoc <- tibble(model = time_log[[1]]$msg, 
                    runtime = time_log[[1]]$toc - time_log[[1]]$tic)

save(nn_tuned, nn_tictoc, file = "recipe_1/results/nn_1_tuned.rda")




