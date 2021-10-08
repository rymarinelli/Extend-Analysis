library(RSQLite)
library(DBI)
library(glue)
library(tidyverse)

con <- dbConnect(RSQLite::SQLite(), ":memory:")

create_FACT_TABLE <- "CREATE TABLE FACT_SALES (
  order_id TEXT NOT NULL UNIQUE,
  variant_id, TEXT NOT NULL UNIQUE,
  store_id TEXT NOT NULL UNIQUE,
  line_item_id TEXT NOT NULL UNIQUE, 
  plan_id TEXT NOT NULL UNIQUE, 
  contract_id TEXT NOT NULL UNIQUE, 
  app_id TEXT NOT NULL UNIQUE
);"

create_DIM_MERCH <- "CREATE TABLE DIM_MERCH (
  store_id TEXT NOT NULL UNIQUE,
  name TEXT ,
  createdat DATETIME,
  enabled BOOLEAN,
  merchantcut DOUBLE,
  storetype TEXT
);"

create_DIM_PRODUCT_TRANSACTION <- 
"CREATE TABLE DIM_PRODUCT_TRANSACTION
(
  store_id TEXT NOT NULL UNIQUE,
  category TEXT,
  price DOUBLE
);"

CREATE_DIM_PRODUCT_STATUS <- " 
CREATE TABLE DIM_PRODUCT_STATUS
(
  store_id TEXT NOT NULL UNIQUE,
  warranty_status TEXT,
  enabled BOOLEAN,
  approved BOOLEAN
);"


CREATE_DIM_ORDER_LINE_TRANSACTION <- 
  "CREATE TABLE DIM_ORDER_LINE_TRANSACTION
  (
  line_item_id TEXT NOT NULL UNIQUE,
  quanity INTEGER,
  price DOUBLE ,
  product_purchase_price DOUBLE, 
  discount_per_item DOUBLE 
);"

CREATE_DIM_ORDER_LINE_STATUS <- "CREATE TABLE DIM_ORDER_LINE_STATUS
  (
   line_item_id TEXT NOT NULL UNIQUE,
   is_warrantable BOOLEAN,
   is_warranty BOOLEAN
  );"


CREATE_DIM_ORDER_SHIPPING <- "CREATE TABLE DIM_ORDER_SHIPPING
   (
      order_id TEXT NOT NULL UNIQUE,
      app_id TEXT NOT NULL UNIQUE,
      source_name TEXT,
      ordered_at DATETIME,
      shipping_country TEXT
   );"


CREATE_DIM_ORDER_TRANSACTION <- "CREATE TABLE DIM_ORDER_TRANSACTION
  (
     app_id TEXT NOT NULL UNIQUE,
     ordered_at DATETIME,
     total_price DOUBLE,
     subtotal_price DOUBLE,
     total_discount DOUBLE
  );"

CREATE_DIM_CONTRACTS_TRANSACTION <- "CREATE TABLE DIM_CONTRACTS_TRANSACTION
(
  contract_id TEXT NOT NULL UNIQUE,
  plan_id TEXT NOT NULL UNIQUE,
  ordered_at DATETIME,
  plan_purchased_price DOUBLE

);"

CREATE_DIM_CONTRACTS_STATUS <- "CREATE TABLE DIM_CONTRACTS_STATUS
(
  contract_id TEXT NOT NULL UNIQUE,
  plan_id TEXT NOT NULL UNIQUE,
  is_funded BOOLEAN,
  contract_length_years DOUBLE
)"


tables <- c(create_FACT_TABLE, create_DIM_MERCH, create_DIM_PRODUCT_TRANSACTION, CREATE_DIM_PRODUCT_STATUS,
              CREATE_DIM_ORDER_LINE_TRANSACTION, CREATE_DIM_ORDER_LINE_STATUS, CREATE_DIM_ORDER_SHIPPING, 
              CREATE_DIM_ORDER_TRANSACTION, CREATE_DIM_CONTRACTS_TRANSACTION, CREATE_DIM_CONTRACTS_STATUS)


i = 0
for(i in 1:length(tables))
{
  res <- dbSendQuery(con, tables[i] %>% glue())
}

dbListTables(con)
