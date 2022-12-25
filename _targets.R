# _targets.R file
library(targets)

#source funs:
source("R/recipes.R")
source("R/read-data.R")
source("R/def_model1.R")
source("R/helper-funs.R")
source("R/sentiments.R")

config <- config::get()  # see config.yml

tar_option_set(packages = c("readr", 
                            "dplyr", 
                            "ggplot2", 
                            "purrr", 
                            "stringr",
                            "easystats", 
                            "tidymodels", 
                            "stringr",
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
  tar_target(model1, def_model1()),
  tar_target(wf_set,
             workflow_set(preproc = list(recipe1 = recipe1, recipe2 = recipe2),
                          models = list(model1 = model1))),
  tar_target(set_fit,
             workflow_map(wf_set,
                          fn = "tune_grid",
                          grid = config$n_grid_values,
                          resamples = vfold_cv(data_train, v = 2, strata = c1),
                          verbose = TRUE)),
  tar_target(set_autoplot,
             autoplot(set_fit))
  
)










