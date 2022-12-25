def_model_glm <- function() {
  
  logistic_reg(penalty = tune(), mixture = 1) %>%
    set_mode("classification") %>%
    set_engine("glmnet")
  
}


def_model_knn <- function() {
  
  nearest_neighbor(neighbors = tune()) %>% 
    set_mode("classification") %>% 
    set_engine("kknn")
}
