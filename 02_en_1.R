# elastic net tuning

library(tidymodels)
library(tidyverse)
library(tictoc)
library(tokenizers)
library(tidytext)
library(textrecipes)
#library(doMC)

tidymodels_prefer()

load("data/songs_split.rda")
load("recipe_1/results/recipe_1.rda")

######################################
# set up parallel processing
# parallel::detectCores()
# registerDoMC(cores = 4)

#####################################
## define model engine and workflow 
en_model <- multinom_reg(mode = "classification", 
                         penalty = tune(), 
                         mixture = tune()) %>% 
  set_engine("glmnet")

# extract params 
en_params <- extract_parameter_set_dials(en_model)

# grid
en_grid <- grid_regular(en_params, levels = 5)

# workflow 
en_workflow <- workflow() %>% 
  add_model(en_model) %>% 
  add_recipe(recipe_1)


#####################################
# tune grid

# clear and start timer 
## clear log first 
tic.clearlog()
tic("en_1") 

en_tuned <- tune_grid(
  en_workflow,
  resamples = songs_folds, 
  grid = en_grid,
  # control: makes it run faster
  control = control_grid(save_pred = TRUE, # create an extra column for each prediction 
                         save_workflow = TRUE # lets you use extract_workflow 
                        )) # returns measures for ROC, AUC, accuracy 

toc(log = TRUE)

time_log <- tic.log(format = FALSE)

# want the tibble to show model name and run time 
en_tictoc <- tibble(model = time_log[[1]]$msg, 
                    runtime = time_log[[1]]$toc - time_log[[1]]$tic)

save(en_tuned, en_tictoc, en_workflow, file = "recipe_1/results/en_tuned.rda")



