# svm poly 

library(tidymodels)
library(tidyverse)
library(tictoc)
library(doMC)
library(kernlab)
library(stacks)

tidymodels_prefer()

load("results/songs_split.rda")
load("results/recipe_3.rda")

######################################
# set up parallel processing
parallel::detectCores()
registerDoMC(cores = 8)

#####################################
## define model engine and workflow 
svm_poly_model <- svm_poly(
  mode = "classification",
  cost = tune(),
  degree = tune(),
  scale_factor = tune()
) %>%
  set_engine("kernlab")

# extract params 
svm_poly_params <- extract_parameter_set_dials(svm_poly_model)

# grid
svm_poly_grid <- grid_regular(svm_poly_params, levels = 5)


# workflow 
svm_poly_workflow <- workflow() %>% 
  add_model(svm_poly_model) %>% 
  add_recipe(recipe_3)

#####################################
# tune grid
tic.clearlog()
tic("svm_poly_3") 

metric <- metric_set(rmse)
ctrl_grid <- control_stack_grid()

svm_poly_tuned <- tune_grid(
  svm_poly_workflow,
  resamples = songs_folds, 
  grid = svm_poly_grid,
  metric = metric,
  # control: makes it run faster
  control = ctrl_grid)

toc(log = TRUE)

time_log <- tic.log(format = FALSE)

# want the tibble to show model name and run time 
svm_poly_tictoc <- tibble(model = time_log[[1]]$msg, 
                          runtime = time_log[[1]]$toc - time_log[[1]]$tic)

save(svm_poly_tuned, svm_poly_tictoc, file = "results/svm_poly_3_tuned.rda")

