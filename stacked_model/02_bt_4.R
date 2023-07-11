# Boosted Tree Tuning 

library(tidymodels)
library(tidyverse)
library(tictoc)
library(doMC)
library(tidytext)
library(textrecipes)
library(stacks)
tidymodels_prefer()

load(here::here("data/songs_split.rda"))
load(here::here("recipe_2/results/recipe_2.rda"))

#########################
# Parallel processing
registerDoMC(cores = 4)
#########################
# define model engine 
bt_model <- boost_tree(mode = "classification",
                       min_n = tune(),
                       mtry = tune(),
                       learn_rate = tune()) %>%
  set_engine("xgboost", importance = "impurity")


bt_params <- extract_parameter_set_dials(bt_model) %>% 
  update(mtry = mtry(range = c(1, 15)))

bt_grid <- grid_regular(bt_params, levels = 5)

bt_workflow <- workflow() %>% 
  add_model(bt_model) %>% 
  add_recipe(recipe_2)


########################################################################
# Tune grid 
# clear and start timer
tic.clearlog()
tic("boosted_tree_4")


bt_tune <- tune_grid(
  bt_workflow,
  resamples = songs_folds,
  grid = bt_grid,
  control = control_stack_grid(),
  metrics = metric_set(roc_auc)
)

toc(log = TRUE)

time_log <- tic.log(format = FALSE)

bt_tictoc <- tibble(model = time_log[[1]]$msg,
                    runtime = time_log[[1]]$toc - time_log[[1]]$tic)


save(bt_tune, bt_tictoc, bt_workflow, file = "stacked_model/results/bt_4_tuned.rda")

save(bt_tune, bt_tictoc, bt_workflow,
     file = here::here("stacked_model/results/bt_4_tuned.rda"))


