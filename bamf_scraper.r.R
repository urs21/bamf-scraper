# AUTOMATIC SCRAPING

# 📦 Pakete laden
library(httr)
library(tidyr)
library(purrr)
library(dplyr)
library(readr)

# 🚀 Daten abrufen
df <- purrr::map_dfr(1:39, ~{
  url <- sprintf("https://bamf-navi.bamf.de/atlas-backend/behoerden/as%d/rekos", .x)
  res <- httr::GET(url, config = httr::accept_json())
  if (httr::status_code(res) != 200) return(NULL)
  httr::content(res, as = "parsed") %>%
    tibble::tibble(v1 = .) %>%
    tidyr::unnest_wider(v1)
})

# 📊 Aufbereiten
df_preg <- df %>%
  dplyr::mutate(bereich_n = lengths(bereich)) %>%
  tidyr::unnest_longer(bereich) %>%
  dplyr::mutate(vz_reg = 1 / bereich_n)

df_reg <- df_preg %>%
  dplyr::group_by(asId, bereich) %>%
  dplyr::summarize(N_rek = sum(vz_reg), .groups = "drop")

# 💾 Speichern
readr::write_csv(df_reg, "bamf_außenstellen.csv")


