#' ICD-O-3 topographical codes & grouppings
#'
#' The ICD-O-3 locality codes & grouppings as used by ICD-O-3 SEER Site/Histology Validation List
#'
#' @format A data frame with six variables:
#' \describe{
#' \item{\code{ICDO3.code}}{ICD-O-3 topographical code (without the decimal point)}
#' \item{\code{locality}}{ICD-O-3 locality}
#' \item{\code{ICDO3.topography.group}}{ICD-O-3 groupping}
#' \item{\code{SEER.site.recode}}{SEER group}
#' \item{\code{SEER.site.description}}{SEER group description}
#' \item{\code{SEER.site.recode.id}}{SEER group id as used by \code{ICD.O.3.hist}}
#' }
#'
#' For further details, see \url{http://seer.cancer.gov/icd-o-3/} and \url{http://codes.iarc.fr/topography}
#'
"ICD.O.3.topo"


#' ICD-O-3 histological codes & grouppings
#'
#' The ICD-O-3 histological codes & grouppings as used by ICD-O-3 SEER Site/Histology Validation List
#'
#' @format A data frame with 4 variables:
#' \describe{
#' \item{\code{histology}}{}
#' \item{\code{histology.description}}{}
#' \item{\code{histology.behavior}}{}
#' \item{\code{histology.behavior.description}}{}
#' }
#'
#' For further details, see \url{http://seer.cancer.gov/icd-o-3/} and \url{http://codes.iarc.fr/topography}
#'
"ICD.O.3.histo"

#' ICD-O-3 valid mappings between histological & topographical codes
#'
#' The ICD-O-3 valid histological & topographical pairs as provided by ICD-O-3 SEER Site/Histology Validation List
#'
#' @format A data frame with 2 variables:
#' \describe{
#' \item{\code{histology.behavior}}{maps to \code{\link{ICD.O.3.histo}}}
#' \item{\code{SEER.site.recode.id}}{maps to \code{\link{ICD.O.3.topo}}}
#' }
#'
#' For further details, see \url{http://seer.cancer.gov/icd-o-3/} and \url{http://codes.iarc.fr/topography}
#'
"ICD.O.3.valid.histotopo"
