# File for scraping data from webpages

# Functions
## Basic Text cleaning
text.clean <- function(text) {
  text <- as.character(text)

  # Social media words
  social.words <- c("mirror", "facebook", "twitter", "like", "share", "comment", "brand",
    "review", "reviews", "online", "gadget", "songs", "movies", "entertaintment",
    "world", "business", "sports", "shopping", "matrimonial", "astrology", "jobs", "tech",
    "community", "property", "buy", "car", "bikes", "comments")

  # Remove puncuation, numbers and convert to lower
  text %<>%
    stri_replace_all_regex("[[:punct:]]|\\$|\\+|\\=|\\||\\<|\\>", "") %>%
    stri_replace_all_regex("\\s+", " ") %>%
    VectorSource() %>%
    VCorpus() %>%
    tm_map(content_transformer(tolower)) %>%
    tm_map(removeNumbers) %>%
    tm_map(removeWords, social.words) %>%
    sapply(as.character)

  return(text)
}

## Webscraping function
web.scrape <- function(URL, node = "p") {
  # Forcing variables to character
  # URL <- as.character(URL)
  node <- as.character(node)

  # Base list  of nodes
  # Remember to change the total iterations to
  # run in the loop below
  node.list <- c("p", "#ins_storybody", ".Normal", "span",
    ".body", ".rtejustify", ".text")

  # Closing connection on exit
  # on.exit(close(URL))

  # Function for node scraping
  node.scrape <- function(html) {
    html.text <- try(
      html %>%
      html_nodes(node) %>%
      html_text() %>%
      paste(collapse = " ") %>%
      text.clean()
      )

    return(html.text)
  }

  # Reading in the html text
  html <- try(
    read_html(URL, encoding = "utf-8")
    )

  if (inherits(html, "try-error")) return(NA)

  html.text <- node.scrape(html)

  # Looping if base text less than specific characters
  if (nchar(html.text) <= 300) {
    # message("Text less than 280")
    # List of nodes sans the original
    node.new <- node.list[!grepl(node, node.list)]
    x <- 1
    # Looping while text is less than 280
    while (nchar(html.text)  <= 300) {
      # Stoping for iteratins beyond our list
      if (x > 5) {
        html.text <- "No text available"
        break
      }

      # Trying with a different node
      node <- node.new[x]
      message(paste("Trying node;", node))

      html.text <- node.scrape(html)

      # Moving on if no selector
      if (inherits(html.text, "try-error")) {
        x <- x + 1
        next
      }
      # Increasing value of x
      x <- x + 1
    }
  }

  return(html.text)
}

# Getting data
link.data <- import("Input/processed/Corruption.json") %>%
  select(Date, Link) %>%
  mutate(text = NA)

for (x in 1:nrow(link.data)) {
  # Writing out data if 100 links
  if (x %% 100 == 0) {
    message.text <- paste("Completed", round(x / nrow(link.data) * 100, 2), "% of scraping")
    message(message.text)

    # Exporting data
    export(link.data, "Output/processed/web-text.json")
  }
  if (x %% 500 == 0) {
    message.text <- paste("Sleeping for 120 seconds")
    message(message.text)

    # Sleeping
    Sys.sleep(120)
  }


  URL <- link.data$Link[x]

  web.text <- try(web.scrape(URL))

  if (inherits(web.text, "try-error")) {
    next
  }

  # Closing all connections
  closeAllConnections()

  link.data$text[x] <- web.text
}

message.text <- paste("Completed data scraping of all websites")
message(message.text)

# Exporting data
export(link.data, "Output/processed/web-text.json")
