count_lexicon <- function(txt, lexicon){
  # counts the number of times a string is detected, according to a (regex) pattern 
  # value: integer
  
  txt <- tolower(txt)
  lexicon <- tolower(lexicon)
  lexicon_regex <- paste0("^", lexicon, "$", collapse = "|")
  string_in_words <- unlist(str_split(txt, pattern = boundary("word"))) 
  pattern_detected_in_string_count <- sum(str_detect(string_in_words, pattern = lexicon_regex))
  return(pattern_detected_in_string_count)
}


# count_lexicon(txt = dummy_text$text[3], lexicon = sentiws$word)
