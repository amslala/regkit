## code to prepare `kommuner` dataset

library(readxl)
data <- read_excel("data_test/kommuner-1994-2024.xlsx")

data$validity <- gsub(".*\\(([^\\)]+)\\).*", "\\1", data$TEKST)

# If there's no match, we'll get the original string back
data$validity[data$validity == data$TEKST] <- 2024

# Split the validity into start_year and end_year
# First, create the columns with default value 2024
data$start_year <- 1994
data$end_year <- 2024

# Process rows with validity information
for (i in 1:nrow(data)) {
  if (data$validity[i] != "") {
    # Check for pattern with hyphen
    if (grepl("-", data$validity[i])) {
      years <- strsplit(data$validity[i], "-")[[1]]

      # Handle case: start_year-end_year (e.g., 2020-2023)
      if (length(years) == 2 && years[1] != "") {
        data$start_year[i] <- as.numeric(years[1])
        data$end_year[i] <- as.numeric(years[2])
      }
      # Handle case: -end_year (e.g., -2019)
      else if (length(years) == 2 && years[1] == "") {
        # Start year remains 2024
        data$end_year[i] <- as.numeric(years[2])
      }
    }
    # Handle single year case if needed
    else if (grepl("^\\d{4}$", data$validity[i])) {
      data$start_year[i] <- as.numeric(data$validity[i])
      data$end_year[i] <- as.numeric(data$validity[i])
    }
  }
}

data$text_clean <- gsub("\\s*\\([^\\)]+\\)", "", data$TEKST)

# Select and rename cols

data <- data |> dplyr::rename("harmonized_code" = "GRUPPEKODE", "harmonized_name" = "GRUPPETEKST", "original_code" = "KODE", "original_name" = "text_clean")
data <- data |> dplyr::select(harmonized_code, harmonized_name, original_code, original_name, start_year, end_year)


# Add information about fylke in 2024

data$harmonized_code_clean <- gsub("K.", "", data$harmonized_code)


fylker <- klassR::get_klass(131, correspond = 104, date = "2024-01-01") |> dplyr::select(sourceCode, targetCode, targetName)

data <- data |> dplyr::left_join(fylker, by=c("harmonized_code_clean" = "sourceCode"))

kommuner <- data |> dplyr::rename("fylke_code"="targetCode", "fylke_name" = "targetName")
