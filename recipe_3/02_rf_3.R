###################################
# Random forest tuning 

library(tidymodels)
library(tidyverse)
library(tictoc)
library(doMC)
library(tokenizers)
library(tidytext)
library(textrecipes)
tidymodels_prefer()

load("data/songs_split.rda")
load("recipe_3/results/recipe_3.rda")

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
  add_recipe(recipe_3)


#####################################
# tune grid

tic.clearlog()
tic("RF_3")

rf_tuned_3 <- tune_grid(
  rf_workflow,
  resamples = songs_folds, 
  grid = rf_grid,
  verbose = TRUE,
  control = control_grid(save_pred = TRUE,
                         save_workflow = TRUE,
                         verbose = TRUE,
                         parallel_over = "everything"))

toc(log = TRUE)

time_log <- tic.log(format = FALSE)

# make a tibble of time
rf_tictoc <- tibble(model = time_log[[1]]$msg, 
                    runtime = time_log[[1]]$toc - time_log[[1]]$tic)

save(rf_tuned_3, rf_tictoc, file = "recipe_3/results/rf_3_tuned.rda")


