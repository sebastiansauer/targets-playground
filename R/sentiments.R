sentiments <- function(data_col){
  
  library(tidytext)
  data(sentiws, package = "pradadata")
  sentiws$word <- tolower(sentiws$word)
  
  data <- 
    as_tibble(text = {{data_col}},
              id = row_number())
  
  data %>% 
    unnest_tokens(input = text, output = word, drop = FALSE)  %>% 
    left_join(sentiws, by = "word") %>% 
    group_by(id) %>% 
    summarise(emo_mean = mean(abs(value), na.rm = TRUE)) %>% 
    pull(emo_mean) %>% 
    replace_na(0)
}


