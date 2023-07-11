# Initial Setup

# Load package(s)
library(tidymodels)
library(tidyverse)
library(kableExtra)
library(tokenizers)
library(tidytext)
library(textrecipes)

# handle common conflicts
tidymodels_prefer()

# seed
set.seed(3013)

# reading in data
songs <- read_csv("data/raw/Spotify_Youtube.csv") %>% 
  janitor::clean_names() %>% 
  select(-c(x1, url_spotify, uri, url_youtube, description, title, album, track, channel)) %>% 
  filter(!is.na(likes)) %>% 
  filter(!is.na(licensed)) %>% 
  mutate(album_type = as_factor(album_type),
         licensed = as.integer(licensed),
         licensed = as_factor(licensed),
         official_video = as.integer(official_video),
         official_video = as_factor(official_video),
         popularity = ifelse(likes < 23160, "least popular",
                             ifelse(likes >= 23160 & likes <129251.5, "less popular",
                                    ifelse(likes >=129251.5 & likes < 520054.2, "more popular",
                                           ifelse(likes >= 520054.2, "most popular", "most popular")))),
         popularity = as_factor(popularity))
View(songs)

miss <- naniar::miss_var_summary(songs)

 songs %>% 
  ggplot(aes(x=popularity)) +
  geom_bar()



###########################################################################
# splitting data to perform eda on only training data 
set.seed(5)
songs_split <- initial_split(songs, prop = .80, strata = popularity)

songs_training <- training(songs_split)
songs_testing <- testing(songs_split)

eda_data <- slice_sample(songs_training, prop = .20)

# fold data 
songs_folds <- vfold_cv(songs_training, v = 5, repeats = 3,
                        strata = popularity)

save(songs_training, songs_testing, songs_folds, file = "results/songs_split.rda")
load("results/songs_split.rda")

#############################################################################
## recipe 1 

recipe_1 <- recipe(popularity ~., data = songs_training) %>%
  step_rm(likes) %>% 
  step_tokenize(artist) %>%
  step_tokenfilter(artist, max_tokens = 100) %>%
  step_tfidf(artist) %>%
  step_impute_mean(all_numeric_predictors()) %>% 
  step_impute_knn(all_nominal_predictors()) %>% 
  step_dummy(all_nominal_predictors()) %>% 
  step_zv(all_numeric_predictors()) %>% 
  step_normalize(all_numeric_predictors()) %>% 
  step_pca(all_predictors(), num_comp = 30) # fixed nn error 


recipe_1 %>% 
  prep() %>% 
  bake(new_data = NULL) %>% 
  names() 


save(recipe_1, file = "recipe_1/results/recipe_1.rda")

#####################################################
# lasso vars, recipe 2 

recipe_2 <- recipe(popularity ~ danceability + energy + key + loudness + speechiness + 
                     acousticness + instrumentalness + liveness + 
                     valence + tempo + duration_ms + views + 
                     comments + stream + album_type, data = songs_training) %>%
  step_dummy(all_nominal_predictors()) %>% 
  step_zv(all_numeric_predictors()) %>% 
  step_normalize(all_numeric_predictors()) %>% 
  step_impute_mean(all_numeric_predictors()) %>% 
  step_impute_knn(all_nominal_predictors())


recipe_2 %>% 
  prep() %>% 
  bake(new_data = NULL) %>% 
  View()

save(recipe_2, file = "recipe_2/results/recipe_2.rda")
#######################################################
# recipe 3, rf vars 

recipe_3 <- recipe(popularity ~ views + comments + stream + speechiness
                   + duration_ms + loudness + acousticness 
                   + danceability + valence + energy, data = songs_training) %>%
  step_dummy(all_nominal_predictors()) %>% 
  step_zv(all_numeric_predictors()) %>% 
  step_normalize(all_numeric_predictors()) %>% 
  step_impute_mean(all_numeric_predictors()) %>% 
  step_impute_knn(all_nominal_predictors())


recipe_3 %>% 
  prep() %>% 
  bake(new_data = NULL) %>% 
  View()

save(recipe_3, file = here::here("recipe_3/results/recipe_3.rda"))

#################################
# null model 

null_spec <- null_model() %>% 
  set_engine("parsnip") %>% # have to set it to parsnip, do all work for you
  set_mode("regression")

null_workflow <- workflow() %>% 
  add_model(null_spec) %>% 
  add_recipe(carseats_recipe)

tic.clearlog()
tic("null_model") 

# don't need to do any tuning parameters, just one value at the end
null_fit <- fit_resamples(
  null_workflow,
  resamples = songs_folds
) 


toc(log = TRUE)

time_log <- tic.log(format = FALSE)


null_tictoc <- tibble(model = time_log[[1]]$msg, 
                    runtime = time_log[[1]]$toc - time_log[[1]]$tic)

kbl(null_tictoc) %>% 
  kable_classic() %>% 
  save_kable("null_time.png", zoom = 10)

null_fit <- null_fit %>% 
  collect_metrics

kbl(null_fit) %>% 
  kable_classic() %>% 
  save_kable("null_fit.png", zoom = 10)


