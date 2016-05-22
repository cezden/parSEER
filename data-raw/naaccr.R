# from http://www.naaccr.org/Applications/QueryBuilder/Default.aspx
# Data Version: 16
res <- readxl::read_excel(
  path = "data-raw/NAACCR.xlsx"
)

names(res) <- make.names(names(res))

###
###

#save(, file = 'data/NAACCRitems.rdata', compress = 'xz')
