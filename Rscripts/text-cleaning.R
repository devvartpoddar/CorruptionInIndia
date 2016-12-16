# Code to clean text file and lemmatise it

load.data <- import("Output/processed/web-text.json") %>%
  filter(!is.na(text)) %>%
  filter(!grepl("No text available", text))

# Function to lemmatise the text
text.lemma <- function(text) {
  text <- as.character(text) %>%
    tolower()

  # Create a lemma dataframe of the text
  ## Creating a temporary file
  file.con <- file("temp.txt")
  writeLines(text, file.con)
  close(file.con)

  # Creating temporary dataframe with lemma
  temp.data <- treetag("temp.txt",
    treetagger = "manual",
    lang = "en",
    TT.options = list(
      path = "/home/devvart/treetagger",
      preset = "en"
      ))

  temp.data <- temp.data@TT.res %>%
    select(token, lemma) %>%
    mutate(
      lemma = ifelse(lemma == "<unknown>", token, lemma)
      )

  file.remove("temp.txt")

  # Replacing words with their lemma
  for (x in 1:nrow(temp.data)) {
    # Values
    token <- paste0("\\b", temp.data$token[x], "\\b")
    # token <- temp.data$token[x]
    lemma <- temp.data$lemma[x]

    # Replacing
    error <- try(text %<>% stri_replace_all_regex(token, lemma))

    if (inherits(error, "try-error")) {
      message.text <- paste0(token, " ----- ", lemma)
      message(message.text)
      stop("Stopping cleaning until error resolves")
    }
  }

  # Removing text spaces
  text %<>% stri_replace_all_regex("\\s+", " ")

  return(text)
}

# Lemmatising Text
for (x in 1:nrow(load.data)) {
  text <- load.data$text[x]

  clean.text <- text.lemma(text)

  load.data$text[x] <- clean.text

  if (x %% 100 ==0) {
    message.text <- paste("Completed", round(x / nrow(load.data) * 100, 2), "%")
    message(message.text)
  }
}

export(load.data, "Output/processed/web-text.json")
