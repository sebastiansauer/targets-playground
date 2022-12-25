# _targets.R file
library(targets)

#source funs:
source("R/recipes.R")
source("R/read-data.R")
source("R/def_models.R")
source("R/helper-funs.R")

config <- config::get()  # see config.yml

tar_option_set(packages = c("readr", 
                            "dplyr", 
                            "ggplot2", 
                            "purrr", 
                            "stringr",
                            "easystats", 
                            "tidymodels", 
                            "stringr",
                            "pradadata",
                            "textrecipes"))


d_train_path <-  "data/GermEval-2018-Data-master/germeval2018.training.txt"
d_test_path <- "data/GermEval-2018-Data-master/germeval2018.test.txt"


# Define pipeline:
list(
  tar_target(data_train_path, d_train_path, format = "file"),
  tar_target(data_test_path, d_test_path, format = "file"), 
  tar_target(data_train, read_data(data_train_path)),
  tar_target(data_test, read_data(data_test_path)), 
  tar_target(recipe1, def_recipe(data_train)),
  tar_target(recipe2, def_recipe2(data_train)),
  tar_target(rec1_prepped, prep(recipe1)),
  tar_target(rec2_prepped, prep(recipe2)),
  tar_target(rec1_baked, bake(rec1_prepped, new_data = NULL)),
  tar_target(rec2_baked, bake(rec2_prepped, new_data = NULL)),
  tar_target(model_glm, def_model_glm()),
  tar_target(model_knn, def_model_knn()),
  tar_target(wflow_set,
             workflow_set(preproc = list(recipe1 = recipe1, recipe2 = recipe2),
                          models = list(model_glm = model_glm, model_knn = model_knn),
                          cross = TRUE)),
  tar_target(wflow_set_fit,
             workflow_map(wflow_set,
                          fn = "tune_grid",
                          grid = config$n_grid_values,
                          resamples = vfold_cv(data_train, v = 2, strata = c1),
                          verbose = TRUE)),
  tar_target(set_autoplot,
             autoplot(wflow_set_fit)),
  tar_target(metrics_train, 
             wflow_set_fit %>% 
               collect_metrics() %>% 
               filter(.metric == "roc_auc") %>% 
               arrange(-mean)),
  tar_target(best_wflow_id,
             metrics_train %>% slice_head(n = 1) %>% pull(wflow_id)),
  tar_target(best_wflow,
             wflow_set_fit %>% extract_workflow(best_wflow_id)),
  tar_target(best_wflow_fit,
             wflow_set_fit %>% 
               extract_workflow_set_result(best_wflow_id)),
  tar_target(best_wflow_finalized,
             best_wflow %>% finalize_workflow(select_best(best_wflow_fit))),
  tar_target(last_fit,
             fit(best_wflow_finalized, data_train)),
  tar_target(test_data_predicted,
               bind_cols(data_test, predict(last_fit, new_data = data_test)) %>% 
               mutate(c1 = factor(c1))),
  tar_target(metrics_test,
             test_data_predicted %>% metrics(c1, .pred_class))
)










