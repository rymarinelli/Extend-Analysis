#
# Script adds cleaned data to the database 
#


source("Segment_DataFrames.R")

dbAppendTable(con, "DIM_MERCH" , DIM_MERCH)
dbReadTable(con, "DIM_MERCH")


dbAppendTable(con, "DIM_PRODUCT_TRANSACTION" , DIM_PRODUCT_TRANSACTION)
dbReadTable(con, "DIM_PRODUCT_TRANSACTION")


dbAppendTable(con, "DIM_PRODUCT_STATUS" , DIM_PRODUCT_STATUS)
dbReadTable(con, "DIM_PRODUCT_STATUS")

dbAppendTable(con,"DIM_ORDER_LINE_TRANSACTION", DIM_ORDER_LINE_TRANSACTION)
dbReadTable(con, "DIM_ORDER_LINE_TRANSACTION")


dbAppendTable(con,"DIM_ORDER_LINE_STATUS", DIM_ORDER_LINE_STATUS)
dbReadTable(con, "DIM_ORDER_LINE_TRANSACTION")

dbAppendTable(con,"DIM_ORDER_SHIPPING", DIM_ORDER_SHIPPING)
dbReadTable(con, "DIM_ORDER_SHIPPING")

dbAppendTable(con, "DIM_ORDER_TRANSACTION", DIM_ORDER_TRANSACTION)
dbReadTable(con, "DIM_ORDER_LINE_TRANSACTION")

dbAppendTable(con, "DIM_CONTRACTS_STATUS", DIM_CONTRACTS_STATUS)
dbReadTable(con, "DIM_CONTRACTS_STATUS")

dbAppendTable(con, "DIM_CONTRACTS_TRANSACTION", DIM_CONTRACTS_TRANSACTION)
dbReadTable(con, "DIM_CONTRACTS_TRANSACTION")



