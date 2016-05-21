# from http://seer.cancer.gov/icd-o-3/
res <- readxl::read_excel(
  path = "data-raw/sitetype.icdo3.d20150918.xls"
)

org.names <- c(
  "Site recode", "Site Description",
  "Histology", "Histology Description",
  "Histology/Behavior", "Histology/Behavior Description")

mod.names <- c(
  "site.recode", "site.description",
  "histology", 'histology.description',
  'histology.behavior', 'histology.behavior.description'
)

stopifnot(all(names(res) == org.names))

names(res) <- mod.names

summary(res)

res.icdo3 <- res %>%
  dplyr::mutate(
    site.recode = stringi::stri_trim_both(site.recode),
    site.description = stringi::stri_trim_both(site.description),
    histology = stringi::stri_trim_both(histology),
    histology = as.numeric(histology),
    histology.description = stringi::stri_trim_both(histology.description),
    histology.behavior = stringi::stri_trim_both(histology.behavior),
    histology.behavior.description = stringi::stri_trim_both(histology.behavior.description)
  )

histology.behavior.descr <- res.icdo3 %>%
  dplyr::select(
    histology.behavior,
    histology.behavior.description) %>%
  dplyr::distinct() %>%
  dplyr::arrange(histology.behavior)

histology.descr <- res.icdo3 %>%
  dplyr::select(
    histology,
    histology.description
    ) %>%
  dplyr::distinct() %>%
  dplyr::arrange(histology)

# Grouppings provided by the 'site recode'

site.recode.descr <- res.icdo3 %>%
  dplyr::select(
    site.recode,
    site.description
    ) %>%
  dplyr::distinct() %>%
  dplyr::arrange(site.recode)

res2 <- readxl::read_excel(
  path = "data-raw/icdo.codes.locality.xlsx"
  ) %>%
  dplyr::mutate(
    ICDO.code = stringi::stri_trim_both(ICDO.code),
    Locality = stringi::stri_trim_both(Locality),
    ICDO.code.num = stringi::stri_replace_all_fixed(
      ICDO.code,
      pattern = "C",
      replacement = ""),
    ICDO.code.num = as.numeric(ICDO.code.num)
  )

stopifnot(length(unique(res2$ICDO.code.num)) == nrow(res2))

site.recode.descr.PK <- 1:nrow(site.recode.descr)
site.recode.descr$siteid <- site.recode.descr.PK

site.ranges.split.list <- stringi::stri_split_fixed(
  site.recode.descr$site.recode,
  ","
  )

site.ranges.split.df <- lapply(
  site.recode.descr.PK,
  function(pkid){
    data.frame(
      ICDO.code = site.ranges.split.list[[pkid]],
      siteid = pkid,
      stringsAsFactors = FALSE)
  }
  ) %>%
  dplyr::bind_rows()

site.ranges.split.ranges2 <- stringi::stri_split_fixed(
  site.ranges.split.df$ICDO.code,
  "-",
  simplify = TRUE
  ) %>%
  as.data.frame(stringsAsFactors=FALSE) %>%
  dplyr::mutate(
    V1 = stringi::stri_trim_both(V1),
    V2 = stringi::stri_trim_both(V2),
    V2 = ifelse(V2 == "", V1, V2)
    ) %>%
  dplyr::rename(code.from = V1, code.to = V2)

site.ranges.split.df2 <- cbind(
  site.ranges.split.df,
  site.ranges.split.ranges2) %>%
  dplyr::mutate(
    code.from = stringi::stri_replace_all_fixed(code.from, "C", ""),
    code.to = stringi::stri_replace_all_fixed(code.to, "C", ""),
    code.from = as.numeric(code.from),
    code.to = as.numeric(code.to)
  )

site.ranges.split.df3 <- lapply(
  1:nrow(site.ranges.split.df2),
  function(rangeid){
    data.frame(
      siteid = site.ranges.split.df2$siteid[rangeid],
      ICDO.code.num = seq(
        from = site.ranges.split.df2$code.from[rangeid],
        to = site.ranges.split.df2$code.to[rangeid],
        by = 1)
    )
    }
  ) %>%
  dplyr::bind_rows()

site.ranges.split.df4 <- dplyr::left_join(
  site.ranges.split.df3,
  res2,
  by = "ICDO.code.num"
  ) %>%
  dplyr::left_join(
    site.recode.descr,
    by = "siteid"
  ) %>%
  dplyr::mutate(
    ICDO.code = ifelse(!is.na(ICDO.code), ICDO.code, paste0("C", ICDO.code.num))
  )

ICD.O.3.pre <- site.ranges.split.df4 %>%
  dplyr::select(
    ICDO3.code = ICDO.code,
    locality = Locality,
    site.recode,
    site.description,
    site.recode.id = siteid
  ) %>% as.data.frame()

res3 <- readxl::read_excel(
  path = "data-raw/icdo3.codes.groups.xlsx"
  ) %>%
  dplyr::mutate(
    topo.group = stringi::stri_trim_both(topo.group),
    description = stringi::stri_trim_both(description)
  ) %>%
  dplyr::rename(
    topography.group = description
  )

ICD.O.3.topo <- ICD.O.3.pre %>%
  dplyr::mutate(
    topo.group = stringi::stri_sub(ICDO3.code, 1, 3)
  ) %>%
  dplyr::left_join(
    res3, by = "topo.group"
  ) %>%
  dplyr::select(
    ICDO3.code,
    locality,
    ICDO3.topography.group = topography.group,
    SEER.site.recode = site.recode,
    SEER.site.description = site.description,
    SEER.site.recode.id = site.recode.id
  ) %>% as.data.frame()

save(ICD.O.3.topo, file = 'data/ICD.O.3.topo.rdata', compress = 'xz')

