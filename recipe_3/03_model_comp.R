# recipe 3 model comparison

library(tidymodels)
library(tidyverse)
library(kableExtra)

# loading packages

load("recipe_3/results/bt_3_tables.rda")
load("recipe_3/results/rf_3_table.rda")
load("recipe_3/results/svm_poly_3_table.rda")

rf_table <- rf_table %>% 
  slice_head()
bt_table <- bt_table %>% 
  slice_head()
svm_poly_table <- svm_poly_table %>% 
  slice_head()

# making a table of the best from each
best_roc_3 <- tibble(model = c("Random Forest", "Boosted Tree", "SVM Poly"),
                    roc_auc = c(rf_table$mean, bt_table$mean, svm_poly_table$mean),
                    se = c(rf_table$std_err, bt_table$std_err, svm_poly_table$std_err),
                    wflow = c(rf_table$.config, bt_table$.config, svm_poly_table$.config))

best_graph_3 <- ggplot(best_roc_3, aes (x = model, y = roc_auc, color = model)) +
  geom_point() +
  labs(y = "roc_auc", x = "Model") +
  scale_x_discrete(guide = guide_axis(angle = 45))+
  ggtitle(label = "Recipe 3 Model Results") +
  theme(legend.position = "none")

save(best_roc_3, best_graph_3, file = "recipe_3/results/recipe_3_results.rda")

load("recipe_3/results/recipe_3_results.rda")
