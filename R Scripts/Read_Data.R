library(tidyverse)

#Script Calls Access_Data.R to clean data and to factor dataframes to be place into tables 
# to be used to Population_DB.R


source("Access_Data.R")

#Each warranty contract purchased by a consume
DIM_CONTRACTS_TRANSACTION <- contracts %>% select(contract_id,plan_id, ordered_at, plan_purchase_price)
DIM_CONTRACTS_STATUS  <- contracts %>% select(contract_id,plan_id,is_refunded,contract_length_years)


#Data on each merchant that has integrated Extend’s purchase protection product.
DIM_MERCH <- merchants



#individual line items purchased within an order
DIM_ORDER_LINE_TRANSACTION  <- order_lines %>% select(line_item_id, quantity, price, product_purchase_price, discount_per_item)
DIM_ORDER_LINE_STATUS <- order_lines %>% select(line_item_id,is_warrantable,is_warranty)

# Purchase data for Extend’s Shopify merchants.
DIM_ORDER_SHIPPING <- orders %>% select(order_id, app_id, source_name, ordered_at, shipping_country)
DIM_ORDER_TRANSACTION <-  orders %>% select(order_id,app_id,total_price, subtotal_price, total_discount)

# List of all products sold by merchants, with product details and whether or not
# they are warrantable
DIM_PRODUCT_TRANSACTION <- products %>% select(store_id, category, price)
DIM_PRODUCT_STATUS <- products %>% select(store_id,warranty_status, enabled,approved)


