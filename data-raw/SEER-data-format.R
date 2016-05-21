library(dplyr)

# Source: read.seer.research.nov15.sas

seer.format.raw <- readr::read_fwf(
  file = 'data-raw/SEER-data-format.txt',
  col_positions = readr::fwf_positions(
    start = c(7, 11, 32, 41),
    end = c(9, 27, 39, 87),
    col_names = c("col.start", "col.name", "col.format", "comment")
  )
)

parser.seer.format.parsed <- seer.format.raw %>%
  dplyr::mutate(
    col.start = as.numeric(col.start),
    col.name = stringi::stri_trim_both(col.name),
    col.format = stringi::stri_trim_both(col.format),
    comment = stringi::stri_trim_both(comment),
    col.length = stringi::stri_extract_first_regex(col.format, pattern = "([0-9]+)"),
    col.length = as.numeric(col.length),
    comment = stri_replace_all_fixed(comment, "/*", ""),
    comment = stri_replace_all_fixed(comment, "*/", ""),
    comment = stringi::stri_trim_both(comment)
  ) %>% as.data.frame()

save(parser.seer.format.parsed, file = 'data/parser.seer.format.parsed.rdata', compress = 'xz')

