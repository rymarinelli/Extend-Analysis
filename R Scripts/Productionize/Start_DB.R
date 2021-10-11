source("Create_Database.R")
source("Populate_DB.R")

dbReadTable(con, "DIM_CONTRACTS_STATUS")
