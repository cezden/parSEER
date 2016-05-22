seer.dict1 <- raster::readIniFile(
  filename = 'data-raw/yr1973_2013.9reg.public.selected.fmt',
  token = '=',
  commenttoken = ';',
  aslist = FALSE) %>%
  as.data.frame(stringsAsFactors = FALSE)

res <- readxl::read_excel(
  path = "data-raw/SEER.vars.xlsx"
)

res.acc.codes <- res %>%
  dplyr::select(SAS.var.name)
res.acc.codes$rowid <- 1:nrow(res.acc.codes)

seer.dict1.map <- seer.dict1 %>%
  dplyr::rename(
    SAS.var.name = section,
    code = name
  ) %>%
  dplyr::left_join(
    res.acc.codes,
    by = "SAS.var.name"
  ) %>% dplyr::arrange(rowid)

seer.dict1.map.nonmatched <- seer.dict1.map %>%
  dplyr::filter(is.na(rowid))

seer.dict1.map.matched <- seer.dict1.map %>%
  #getting only dictionaries matched to variables
  dplyr::filter(!is.na(rowid)) %>%
  dplyr::mutate(
    #unquote values, clean a little bit...
    value = stringi::stri_trim_both(value, pattern = "[^\\p{Wspace}\\\"]"),
    #checking if 'code' is simple number or a group
    direct = (stringi::stri_count_fixed(code, ",") + stringi::stri_count_fixed(code, "-")) == 0
  )
seer.dict1.map.matched.simple <- seer.dict1.map.matched %>%
  dplyr::filter(direct == TRUE) %>%
  dplyr::mutate(
    code = as.numeric(code)
  )

## group processing...
seer.dict1.map.matched.groups <- seer.dict1.map.matched %>%
  dplyr::filter(!direct) %>%
  dplyr::select(-rowid, -direct)

matched.groups.range <- 1:nrow(seer.dict1.map.matched.groups)
seer.dict1.map.matched.groups$gid <- matched.groups.range
matched.groups.list <- stringi::stri_split_fixed(seer.dict1.map.matched.groups$code, ",")
matched.groups.df <- lapply(
  matched.groups.range,
  function(gid){
    data.frame(code.range = matched.groups.list[[gid]], gid = gid, stringsAsFactors = FALSE)
  }
  ) %>%
  dplyr::bind_rows()

matched.groups.df.spl <- stringi::stri_split_fixed(
  matched.groups.df$code.range,
  "-",
  simplify = TRUE
  ) %>%
  as.data.frame(stringsAsFactors = FALSE) %>%
  dplyr::mutate(
    V2 = ifelse(V2 == "", V1, V2),
    V1 = as.numeric(V1),
    V2 = as.numeric(V2)
  ) %>%
  dplyr::rename(
    code.from = V1,
    code.to = V2
  )

matched.groups.df2 <- cbind(matched.groups.df, matched.groups.df.spl)
# ranges
matched.groups.df2.exp <- lapply(
  1:nrow(matched.groups.df2),
  function(rid){
    data.frame(
      code = seq(
        from = matched.groups.df2$code.from[rid],
        to = matched.groups.df2$code.to[rid],
        by = 1),
      gid = matched.groups.df2$gid[rid])
  }
  ) %>%
  dplyr::bind_rows()


SEER.dictionary.groups.tmp <- seer.dict1.map.matched.groups %>%
  dplyr::select(
    SAS.var.name,
    codes = code,
    value,
    dictionary.group.id = gid
  ) %>%
  as.data.frame()

SEER.dictionary.groups.definition.tmp <- matched.groups.df2.exp %>%
  dplyr::left_join(
    seer.dict1.map.matched.groups %>% dplyr::select(SAS.var.name, gid),
    by = "gid"
  ) %>%
  dplyr::select(
    SAS.var.name,
    dictionary.group.id = gid,
    code
  ) %>% dplyr::arrange(SAS.var.name, dictionary.group.id, code) %>%
  as.data.frame()



seer.dict1.map.matched.simple.adj <- seer.dict1.map.matched.simple %>%
  dplyr::mutate(
    code = ifelse(SAS.var.name == "REG", code + 1500, code)
  )

tmp.ok <- tmp %>% dplyr::filter(!is.na(rowid))
tmp.fail <- tmp %>% dplyr::filter(is.na(rowid))

