# recipe 2 model comparison

library(tidymodels)
library(tidyverse)
library(kableExtra)

# loading packages

load("recipe_2/results/bt_2_tables.rda")
load("recipe_2/results/rf_2_table.rda")
load("recipe_2/results/svm_poly_2_table.rda")

rf_table <- rf_table %>% 
  slice_head()
bt_table <- bt_table %>% 
  slice_head()
svm_poly_table <- svm_poly_table %>% 
  slice_head()

# making a table of the best from each
best_roc_2 <- tibble(model = c("Random Forest", "Boosted Tree", "SVM Poly"),
                    roc_auc = c(rf_table$mean, bt_table$mean, svm_poly_table$mean),
                    se = c(rf_table$std_err, bt_table$std_err, svm_poly_table$std_err),
                    wflow = c(rf_table$.config, bt_table$.config, svm_poly_table$.config))

best_graph_2 <- ggplot(best_roc_2, aes (x = model, y = roc_auc, color = model)) +
  geom_point() +
  labs(y = "roc_auc", x = "Model") +
  scale_x_discrete(guide = guide_axis(angle = 45))+
  ggtitle(label = "Recipe 2 Model Results") +
  theme(legend.position = "none")

save(best_roc_2, best_graph_2, file = "recipe_2/results/recipe_2_results.rda")

load("recipe_2/results/recipe_2_results.rda")
