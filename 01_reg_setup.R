# Initial Setup

# Load package(s)
library(tidymodels)
library(tidyverse)

# handle common conflicts
tidymodels_prefer()

# seed
set.seed(3013)

# reading in data
songs <- read_csv("data/raw/Spotify_Youtube.csv") %>% 
  janitor::clean_names() %>% 
  select(-c(x1, url_spotify, uri, url_youtube, description, title, album, track)) %>% 
  filter(!is.na(licensed)) %>% 
  mutate(album_type = as_factor(album_type),
         channel = as_factor(channel),
         licensed = as.integer(licensed),
         licensed = as_factor(licensed),
         official_video = as.integer(official_video),
         official_video = as_factor(official_video)
        )
View(songs)

miss <- naniar::miss_var_summary(songs)

songs %>% 
  ggplot(aes(x=likes)) +
  geom_bar()



###########################################################################
# splitting data to perform eda on only training data 
set.seed(5)
songs_split <- initial_split(songs, likes = .80, strata = likes)

songs_training <- training(songs_split)
songs_testing <- testing(songs_split)

eda_data <- slice_sample(songs_training, prop = .20)

# fold data 
songs_folds <- vfold_cv(songs_training, v = 5, repeats = 3,
                        strata = likes)

save(songs_training, songs_testing, songs_folds, file = "results/songs_split.rda")

#############################################################################
## recipe 1 

recipe_1 <- recipe(likes ~., data = songs_training) %>%
  step_rm(artist) %>% 
  step_dummy(all_nominal_predictors()) %>% 
  step_nzv(all_numeric_predictors()) %>% 
  step_normalize(all_numeric_predictors()) %>% 
  step_impute_mean(all_numeric_predictors()) %>% 
  step_impute_knn(all_nominal_predictors())


recipe_1 %>% 
  prep() %>% 
  bake(new_data = NULL)

save(recipe_1, file = "results/reg_recipe_1.rda")



