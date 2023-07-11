## Variable Selection

library(tidymodels)
library(tidyverse)
library(tokenizers)
library(tidytext)
library(textrecipes)

tidymodels_prefer()
load("results/songs_split.rda")


##### SET INITIAL RECIPE #################

init_recipe <- recipe(popularity ~., data = songs_training) %>%
  step_rm(likes) %>% 
  step_tokenize(artist) %>% 
  step_tokenfilter(artist, max_tokens = 100) %>% 
  step_tfidf(artist) %>% 
  step_dummy(all_nominal_predictors()) %>% 
  step_nzv(all_numeric_predictors()) %>% 
  step_normalize(all_numeric_predictors()) %>% 
  step_impute_mean(all_numeric_predictors()) %>% 
  step_impute_knn(all_nominal_predictors())
 

init_recipe %>% 
  prep() %>% 
  bake(new_data = NULL)

################################################
lasso_mod <- multinom_reg(mode = "classification",
                        penalty = tune(),
                        mixture = 1) %>% 
  set_engine("glmnet")

lasso_params <- extract_parameter_set_dials(lasso_mod)
lasso_grid <- grid_regular(lasso_params, levels = 5)

lasso_workflow <- workflow() %>% 
  add_model(lasso_mod) %>% 
  add_recipe(init_recipe)

lasso_tune <- lasso_workflow %>% 
  tune_grid(resamples = songs_folds,
            grid = lasso_grid)

lasso_wkflw_final <- lasso_workflow %>% 
  finalize_workflow(select_best(lasso_tune, metric = "roc_auc"))

lasso_fit <- fit(lasso_wkflw_final, data = songs_training)

# view estimate parameters, does not work for tree based models 
lasso_variables <- lasso_fit %>% tidy()
save(lasso_variables, lasso_tune, file = "results/lasso_variables.rda")

lasso_var <- load("results/lasso_variables.rda")

lasso_variables %>% 
  filter(penalty != 0)

# danceability + energy + key + loudness + speechiness + 
#acousticness + instrumentalness + liveness + valence + tempo + duration_ms + views + comments + stream + album_type_single


# sets unimporant variables to 0  

#########################################
# rf var selection 

rf_mod <- rand_forest(mode = "classification",
                      mtry = tune()) %>% 
  set_engine("ranger", importance = "impurity")

rf_params <- extract_parameter_set_dials(rf_mod) %>% 
  recipes::update(mtry = mtry(range = c(1,5)))

rf_grid <- grid_regular(rf_params, levels = 5)

rf_workflow <- workflow() %>% 
  add_model(rf_mod) %>% 
  add_recipe(init_recipe)

rf_tune <- rf_workflow %>% 
  tune_grid(resamples = songs_folds,
            grid = rf_grid)

rf_wkflw_final <- rf_workflow %>% 
  finalize_workflow(select_best(rf_tune, metric = "roc_auc"))

rf_fit <- fit(rf_wkflw_final, data = songs_training)

# view estimate parameters
rf_variables <- rf_fit %>% 
  extract_fit_parsnip() %>% 
  vip::vip()

save(rf_variables, rf_tune, file = "results/rf_variables.rda")

load("results/rf_variables.rda")

# rf vars 
# views + comments + stream + speechiness + duration_ms + loudness + acousticness + danceability + valence + energy 
