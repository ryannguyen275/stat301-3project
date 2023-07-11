# recipe 1 model comparison

library(tidymodels)
library(tidyverse)
library(kableExtra)

# loading packages
load("recipe_1/results/svm_radial_1_table.rda")
load("recipe_1/results/svm_poly_1_table.rda")
load("recipe_1/results/bt_tables.rda")
load("recipe_1/results/knn_1_table.rda")
load("recipe_1/results/nn_tables.rda")
load("recipe_1/results/rf_1_table.rda")
load("recipe_1/results/en_1_table.rda")

en_table <- en_table %>% 
  slice_head()
rf_table <- rf_table %>% 
  slice_head()
bt_table <- bt_table %>% 
  slice_head()
knn_table <- knn_table %>% 
  slice_head()
svm_radial_table <- svm_radial_table %>% 
  slice_head()
svm_poly_table <- svm_poly_table %>% 
  slice_head()
nn_table <- nn_table %>% 
  slice_head()

# getting times altogether
all_times <- tibble(model  = c("Elastic Net", "Random Forest", "Boosted Tree", "K-Nearest Neighbor", "SVM Radial", "SVM Poly", "Neural Network"),
                    runtime = c(en_time$runtime, rf_time$runtime, bt_time$runtime, knn_tictoc$runtime, svm_radial_time$runtime, svm_poly_time$runtime, nn_time$runtime))

# making a table of the best from each
best_roc_1 <- tibble(model = c("Elastic Net", "Random Forest", "Boosted Tree", "K-Nearest Neighbor", "SVM Radial", "SVM Poly", "Neural Network"),
                    roc_auc = c(en_table$mean, rf_table$mean, bt_table$mean, knn_table$mean, svm_radial_table$mean, svm_poly_table$mean, nn_table$mean),
                    se = c(en_table$std_err, rf_table$std_err, bt_table$std_err, knn_table$std_err, svm_radial_table$std_err, svm_poly_table$std_err, nn_table$std_err),
                    wflow = c(en_table$.config, rf_table$.config, bt_table$.config, knn_table$.config, svm_radial_table$.config, svm_poly_table$.config, nn_table$.config))

best_results <- full_join(best_roc_1, all_times)

best_graph_1 <- ggplot(best_roc_1, aes (x = model, y = roc_auc, color = model)) +
  geom_point() +
  labs(y = "roc_auc", x = "Model") +
  scale_x_discrete(guide = guide_axis(angle = 45))+
  geom_errorbar(aes(ymin = roc_auc - se, ymax = roc_auc + se), width = 0.2) +
  ggtitle(label = "Recipe 1 Model Results") +
  theme(legend.position = "none")


save(best_results, best_roc_1, best_graph_1, all_times, file = "recipe_1/results/recipe_1_results.rda")

best_graph_1

load("recipe_1/results/recipe_1_results.rda")
