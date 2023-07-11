# Boosted Tree Tuning 

library(tidymodels)
library(tidyverse)
library(tictoc)
library(doMC)
library(tidytext)
library(textrecipes)
tidymodels_prefer()

load(here::here("data/songs_split.rda"))
load(here::here("recipe_3/results/recipe_3.rda"))

#########################
# Parallel processing
registerDoMC(cores = 8)
#########################
# define model engine 
bt_model <- boost_tree(mode = "classification",
                       min_n = tune(),
                       mtry = tune(),
                       learn_rate = tune()) %>%
  set_engine("xgboost", importance = "impurity")


bt_params <- extract_parameter_set_dials(bt_model) %>% 
  update(mtry = mtry(range = c(15, 30)))

bt_grid <- grid_regular(bt_params, levels = 5)

bt_workflow <- workflow() %>% 
  add_model(bt_model) %>% 
  add_recipe(recipe_3)

########################################################################
# Tune grid 
# clear and start timer
tic.clearlog()
tic("Boosted Tree")

bt_tune <- tune_grid(
  bt_workflow,
  resamples = songs_folds,
  grid = bt_grid,
  control = control_grid(save_pred = TRUE,
                         save_workflow = TRUE,
                         parallel_over = "everything",
                         verbose = TRUE) # this helps with parrallel processing
)

toc(log = TRUE)

time_log <- tic.log(format = FALSE)

bt_tictoc <- tibble(model = time_log[[1]]$msg,
                    runtime = time_log[[1]]$toc - time_log[[1]]$tic)


save(bt_tune, bt_tictoc, 
     file = here::here("recipe_3/results/bt_3_tuned.rda" ))


