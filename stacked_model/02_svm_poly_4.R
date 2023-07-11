# svm poly 

library(tidymodels)
library(tidyverse)
library(tictoc)
library(doMC) 
library(kernlab)
library(tokenizers)
library(tidytext)
library(textrecipes)
library(stacks)

tidymodels_prefer()

load("data/songs_split.rda")
load("recipe_2/results/recipe_2.rda")

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
  add_recipe(recipe_2)

#####################################
# tune grid
tic.clearlog()
tic("svm_poly_4") 

svm_poly_tuned <- tune_grid(
  svm_poly_workflow,
  resamples = songs_folds, 
  grid = svm_poly_grid,
  metrics = metric_set(roc_auc),
  # control: makes it run faster
  control = control_stack_grid())

toc(log = TRUE)

time_log <- tic.log(format = FALSE)

# want the tibble to show model name and run time 
svm_poly_tictoc <- tibble(model = time_log[[1]]$msg, 
                          runtime = time_log[[1]]$toc - time_log[[1]]$tic)
save(svm_poly_tuned, svm_poly_tictoc, svm_poly_workflow, file = "stacked_model/results/svm_poly_4_tuned.rda")

save(svm_poly_tuned, svm_poly_tictoc, svm_poly_workflow, file = here::here("recipe_4/results/svm_poly_4_tuned.rda"))

