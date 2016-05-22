#' SEER incidence txt data loader
#'
#' Loads the incidence data from SEER base to raw (textual) format
#'
#' @param file a path to data file, e.g. \code{.../SEER_1973_2013_TEXTDATA/incidence/yr1973_2013.seer9/URINARY.TXT}
#' @param n_max maximal number of records to read (\code{-1} - no limit)
#' @export
load.SEER.data.raw <- function(file, n_max = -1){
  seer.form <- parSEER::parser.seer.format.parsed
  # check whether it's possible to use just widths
  # defining the fixed-width format...
  seer.fwf <- readr::fwf_positions(
    start = seer.form$col.start,
    end = seer.form$col.length + seer.form$col.start - 1,
    col_names = seer.form$col.name
  )

  readr::read_fwf(
    file = file,
    col_positions = seer.fwf,
    n_max = n_max)

}