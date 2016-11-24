# Combining all files using R

# Functions
# For list of files, loop over to create an rbind dataset
bind.loop <- function(input) {
  input <- input

  # Creating an empty datalist
  data.list <- list()

  for (x in 1:length(input)) {
    input.data <- input[x]

    temp.data <-  try(
      import(paste0("Input/raw text/", input.data), header = FALSE)
      )

    if (inherits(temp.data, "try-error")) {
      message.text <- paste("Input file;", input.data, "cannot be read.")
      next
    }

    colnames(temp.data) <- c("Heading", "Source", "Date", "Link", "Snippet")

    temp.data %<>%
      data.table()

    data.list[[x]] <- temp.data

    message(paste("Finshed extracting", round(x / length(input) * 100, 2), "% of data"))
  }

  final.data <- rbindlist(data.list)

  # Removing duplicate links
  final.data %<>%
    group_by(Source) %>%
    distinct(Link, .keep_all = TRUE)

  # Exporting final data
  export(final.data, "Input/processed/Corruption.json")
}

# Loading and looping over files
list.files("Input/raw text") %>%
  bind.loop()
