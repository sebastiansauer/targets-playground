read_data <- function(path_to_data) {
  
  d <- data_read(path_to_data, header = FALSE, quote = "")
  
  names(d) <- c("text", "c1", "c2")
  
  d$c2 <- NULL  # remove multinomial classification
  
  d$id <- as.character(1:nrow(d))
  
  config <- config::get()
  
  if (config$tinyfy) d <- head(d, 30)
  
  return(d)
}
