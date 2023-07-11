# Load package(s) ----
library(tidymodels)
library(tidyverse)
library(stacks)

# Handle common conflicts
tidymodels_prefer()

# Load candidate model info ----
load("stacked_model/results/svm_poly_4_tuned.rda")
load("stacked_model/results/bt_4_tuned.rda")
load("stacked_model/results/rf_4_tuned.rda")
#svm_poly_tictoc

# Load split data object & get testing data
load("data/songs_split.rda")

#wildfires_test <- wildfires_split %>% testing()

# Create data stack ----
stacks()

data_st <- 
  stacks() %>%
  add_candidates(rf_tuned_4) %>% # 15 models 
  add_candidates(svm_poly_tuned) %>% # 25 models 
  add_candidates(bt_tune) # 1 model 

# looks at all these models, asigns some to 0 and a coeficient to others 

data_st 

as_tibble(data_st)


# Fit the stack ----
# penalty values for blending (set penalty argument when blending)
blend_penalty <- c(10^(-6:-1))

# higher penalty values will force more things to 0, more selective on what values to chose 



# Blend predictions using penalty defined above (tuning step, set seed)
set.seed(9876)

data_st <-
  data_st %>%
  blend_predictions(penalty = blend_penalty) 



# Save blended model stack for reproducibility & easy reference (Rmd report)
save(data_st, file = "stacked_model/results/fit_stack.rda")

load("stacked_model/results/fit_stack.rda")


# Explore the blended model stack
autoplot(data_st)

autoplot(data_st, type = "members")

stacked_plot <- autoplot(data_st, type = "weights")
  #scale_y_continuous(limits = c(40,140))
# shows optimal tuning parameter with the dif belnd that it chose 
# optimal blend has linear reg with 7 members 


plot1
# fit to ensemble to entire training set ----
data_model_fit <-
  data_st %>%
  fit_members()


#collect_parameters(data_st, "svm_res")


# Save trained ensemble model for reproducibility & easy reference (Rmd report)

save(data_model_fit, file = "recipe_4/data_model_fit.rdm")


# Explore and assess trained ensemble model
pred <- songs_training %>% 
  select(popularity) %>% 
  bind_cols(predict(data_model_fit, songs_training, type = "prob"))

roc_auc_ensemble <- yardstick::roc_auc(pred, truth = popularity, .pred_unpopular)

data_test <- 
  songs_testing %>%
  bind_cols(predict(data_model_fit, ., type = "prob"))

svm_models <- collect_parameters(data_model_fit, "svm_res") %>% 
  filter(coef != 0) %>% 
  select(member, coef)
bt_models <- collect_parameters(data_model_fit, "bt_res") %>% 
  filter(coef != 0) %>% 
  select(member, coef)
rf_models <- collect_parameters(data_model_fit, "rf_res")


coefs <- full_join(svm_models, bt_models) %>% 
  full_join(rf_models)

save(coefs, stacked_plot, file = "results/stacked_results.rda")


# scatter plot
plot2 <- ggplot(data_test) +
  aes(x = burned, 
      y = .pred) +
  geom_point() + 
  coord_obs_pred() + 
  theme_bw() + 
  labs(title = "Figure 2", subtitle = "Predicted vs. actual values")
#SAVE

load("stacked_model/data_model_fit.rdm")

ggsave("plot2.png")

#show each member/model prediction 
member_preds <- 
  data_test %>%
  select(y) %>%
  bind_cols(predict(data_model_fit, data_test, members = TRUE)) %>% 
  rename(ensamble = .pred)
# shows the predicted values from each chosen model and then blends them into a .pred value 

map(member_preds, rmse_vec, truth = member_preds$burned) %>%
  as_tibble()
library(kableExtra)
member_preds %>% 
  map_df(rmse, truth = burned, data = member_preds) %>% 
  mutate(member = colnames(member_preds)) %>% 
  filter(member != "burned") %>% 
  arrange(.estimate) %>% 
  head(n = 7) %>% 
  kbl(caption = "Model Results Table") %>% 
  kable_classic() %>% 
  save_kable("result_table.png", zoom = 10)


#SAVE AS A NICE TABLE 

member_preds %>% 
  kbl(caption = "Model Results Table") %>% 
  kable_classic() %>% 
  save_kable("result_table.png", zoom = 10)

# .pred is the stacked model, it preformed the best 


