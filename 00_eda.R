# Initial Setup

# Load package(s)
library(tidymodels)
library(tidyverse)
library(kableExtra)
library(corrplot)

# handle common conflicts
tidymodels_prefer()

# seed
set.seed(3013)

# reading in data
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

skimr::skim(songs)

# missingness 
naniar::gg_miss_var(songs)
naniar::as_shadow(songs)
naniar::vis_miss(songs)

miss_table <- naniar::miss_var_summary(songs)

View(miss_table)
miss_table %>% 
  kbl() %>% 
  kable_classic() %>% 
  save_kable("miss_table.png", zoom = 10)

## distribution of likes 
ggplot(songs, aes(x = likes)) + 
  geom_histogram(color = "white", fill = "darkolivegreen4") + 
  theme_minimal() + 
  labs(title = "Distribution of likes")

 

dist_popularity <- ggplot(songs, aes(x = popularity)) + 
  geom_bar(color = "white", fill = "darkolivegreen3") + 
  theme_minimal() + 
  labs(title = "Distribution of popularity")

save(dist_popularity, file = "data/processed/dist_popularity.rda")


###########################################################################
# splitting data to perform eda on only training data 
set.seed(5)
songs_split <- initial_split(songs, prop = .80, strata = likes)

songs_training <- training(songs_split)
songs_testing <- testing(songs_split)

eda_data <- slice_sample(songs_training, prop = .20)

## correlations 

# all the variables need to first be numeric 
songs_factor <- eda_data %>% 
  mutate(album_type = as_factor(album_type),
         channel = as_factor(channel),
         licensed = as_factor(licensed),
         official_video = as_factor(official_video)) %>% 
  mutate(album_type = as.numeric(album_type),
         channel = as.numeric(channel),
         licensed = as.numeric(licensed),
         popularity = as.numeric (popularity),
         official_video = as.numeric(official_video)) %>% 
  select(-c(artist, track)) %>% 
  na.omit() # dropping NA values for the matrix 

cor_songs <- cor(songs_factor)

corrplot(cor_songs)

## examine outcome variable (likes) 

# initial histogram
# rllyyy right skewed, should perform log transformation 
ggplot(eda_data, aes(likes)) + 
  geom_histogram() +
  labs(title = "Distribution of Likes")

# initial boxplot
# soo many outliers, maybe set a limit at 10,000,000 likes(?) 
ggplot(eda_data, aes(likes)) + 
  geom_boxplot() 

# log transformation 
ggplot(eda_data, aes(log(likes))) + 
  geom_histogram() +
  labs(title = "Distribution of Likes (Log-Transformed")

# sqrt transformation, still very right-skewed
ggplot(eda_data, aes(sqrt(likes))) + 
  geom_histogram() 

# log transformation without outliers (not much of a difference but can increase)
eda_data %>% 
  filter(likes < 10000000) %>% 
  ggplot(eda_data, mapping = aes(log(likes))) + 
  geom_histogram() 

## examine relationship between likes and predictor variables
# likes and views
ggplot(eda_data, aes(likes, views)) + 
  geom_point(alpha = 0.5)

ggplot(eda_data, aes(likes, views)) + 
  geom_hex()

# likes and streams
ggplot(eda_data, aes(likes, stream)) + 
  geom_point(alpha = 0.5)

# likes and comments
ggplot(eda_data, aes(likes, comments)) + 
  geom_point(alpha = 0.5)
