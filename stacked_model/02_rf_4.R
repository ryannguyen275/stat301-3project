###################################
# Random forest tuning 

library(tidymodels)
library(tidyverse)
library(tictoc)
library(doMC)
library(tokenizers)
library(tidytext)
library(textrecipes)
library(stacks)
tidymodels_prefer()

load(here::here("data/songs_split.rda"))
load(here::here("recipe_2/results/recipe_2.rda"))

#########################
# Parallel processing
registerDoMC(cores = 4)


#####################################
## define model engine and workflow 

rf_model <- rand_forest(mode = "classification",
                        min_n = tune(),
                        mtry = tune()) %>% 
  set_engine("ranger", importance = "impurity") 




# extract params 
rf_params <- extract_parameter_set_dials(rf_model) %>% 
  update(mtry = mtry(c(15, 30)))

# grid
rf_grid <- grid_regular(rf_params, levels = 5)


# workflow 
rf_workflow <- workflow() %>% 
  add_model(rf_model) %>% 
  add_recipe(recipe_2)


#####################################
# tune grid

tic.clearlog()
tic("RF_4")

rf_tuned_4 <- tune_grid(
  rf_workflow,
  resamples = songs_folds,
  metrics = metric_set(roc_auc),
  grid = rf_grid,
  control = control_stack_grid())

toc(log = TRUE)

time_log <- tic.log(format = FALSE)

# make a tibble of time
rf_tictoc <- tibble(model = time_log[[1]]$msg, 
                    runtime = time_log[[1]]$toc - time_log[[1]]$tic)

save(rf_tuned_4, rf_tictoc, file = "stacked_model/results/rf_4_tuned.rda")

save(rf_tuned_4, rf_tictoc, file = here::here("recipe_4/results/rf_4_tuned.rda"))
