
# recipe1 -----------------------------------------------------------------







def_recipe <- function(data_train) {
  
  config <- config::get()
  
  n_tokens <- config$n_tokens
  
  d_reduced <- data_train %>% select(text, c1, id)
  
  recipe_out <- 
    recipe(c1 ~ ., data = d_reduced) %>%
    update_role(id, new_role = "id") %>%
    step_tokenize(text) %>%
    step_tokenfilter(text, max_tokens = n_tokens) %>%
    step_tfidf(text) %>%
    step_zv(all_predictors()) %>%
    step_normalize(all_numeric_predictors())
  
  return(recipe_out)
}






# recipe2 -----------------------------------------------------------------


def_recipe2 <- function(data_train) {
  
  data("schimpwoerter", package = "pradadata")
  data("sentiws", package = "pradadata")
  data("wild_emojis", package = "pradadata")
  
  config <- config::get()
  
  n_tokens <- config$n_tokens
  
  d_reduced <- data_train %>% select(text, c1, id)
  
  recipe_def <-
    recipe(c1 ~ ., data = d_reduced) %>%
    update_role(id, new_role = "id") %>%
    step_text_normalization(text) %>%
    step_mutate(emo_count = count_lexicon(text, sentiws$word)) %>% 
    step_mutate(schimpf_count = count_lexicon(text, schimpfwoerter$word)) %>% 
    step_mutate(text_copy = text) %>% 
    step_textfeature(text_copy) %>% 
    step_tokenize(text) %>%
    step_stopwords(text, language = "de", stopword_source = "snowball") %>%
    step_stem(text) %>%
    step_tokenfilter(text, max_tokens = n_tokens) %>%
    step_tfidf(text) %>%
    #step_zv(all_predictors()) %>%
    step_normalize(all_numeric_predictors(), -starts_with("textfeature"), -ends_with("_count"))
  
  return(recipe_def)
}
