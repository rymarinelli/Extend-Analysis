source("Create_Database.R")
source("Populate_DB.R")
dbListTables(con)


dbAppendTable(con, "FACT_SALES" , DIM_MERCH %>% select(store_id) %>% distinct())

dbAppendTable(con, "FACT_SALES" , DIM_PRODUCT_TRANSACTION %>% select(variant_id) %>% distinct())
dbAppendTable(con, "FACT_SALES" , DIM_PRODUCT_TRANSACTION %>% select(store_id) %>% distinct())
dbAppendTable(con, "FACT_SALES" , DIM_PRODUCT_STATUS %>% select(variant_id) %>% distinct())
dbAppendTable(con, "FACT_SALES" , DIM_PRODUCT_STATUS %>% select(store_id) %>% distinct())


dbAppendTable(con, "FACT_SALES" , DIM_ORDER_LINE_TRANSACTION %>% select(line_item_id) %>% distinct())
dbAppendTable(con, "FACT_SALES" , DIM_ORDER_LINE_STATUS %>% select(line_item_id) %>% distinct())


dbAppendTable(con, "FACT_SALES" , DIM_ORDER_SHIPPING %>% select(order_id) %>% distinct())
dbAppendTable(con, "FACT_SALES" , DIM_ORDER_SHIPPING %>% select(app_id) %>% distinct())

dbAppendTable(con, "FACT_SALES" , DIM_ORDER_TRANSACTION %>% select(order_id) %>% distinct()) 
dbAppendTable(con, "FACT_SALES" , DIM_ORDER_TRANSACTION %>% select(app_id) %>% distinct()) 

dbAppendTable(con, "FACT_SALES" ,DIM_CONTRACTS_STATUS %>% select(contract_id) %>% distinct())
dbAppendTable(con, "FACT_SALES" ,DIM_CONTRACTS_STATUS %>% select(plan_id) %>% distinct())
dbAppendTable(con, "FACT_SALES" ,DIM_CONTRACTS_TRANSACTION %>% select(contract_id) %>% distinct())
dbAppendTable(con, "FACT_SALES" ,DIM_CONTRACTS_TRANSACTION %>% select(plan_id) %>% distinct())


dbReadTable(con, "FACT_SALES") 


