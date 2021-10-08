library(tidyverse)

 

#Each warranty contract purchased by a consume
contracts <- readr::read_csv("https://raw.githubusercontent.com/rymarinelli/Extend-Analysis/main/data/contracts.csv")
DIM_CONTRACTS_TRANSACTION <- contracts %>% select(contract_id,plan_id, ordered_at, plan_purchase_price)
DIM_CONTRACTS_STATUS  <- contracts %>% select(contract_id,plan_id,is_refunded,contract_length_years)


#Data on each merchant that has integrated Extend’s purchase protection product.
merchants <- readr::read_csv("https://raw.githubusercontent.com/rymarinelli/Extend-Analysis/main/data/merchants.csv")
merchants$store_id <- stringr::str_remove(merchants$sortkey,"STORE::")
merchants$sortkey <- NULL
DIM_MERCH <- merchants



#individual line items purchased within an order
order_lines <- readr::read_csv("https://raw.githubusercontent.com/rymarinelli/Extend-Analysis/main/data/order_lines.csv")
DIM_ORDER_LINE_TRANSACTION  <- order_lines %>% select(line_item_id, quantity, price, product_purchase_price, discount_per_item)
DIM_ORDER_LINE_STATUS <- order_lines %>% select(line_item_id,is_warrantable,is_warranty)

# Purchase data for Extend’s Shopify merchants.
orders <- readr::read_csv("https://raw.githubusercontent.com/rymarinelli/Extend-Analysis/main/data/orders.csv")
DIM_ORDER_SHIPPING <- orders %>% select(order_id, app_id, source_name, ordered_at, shipping_country)
DIM_ORDER_TRANSACTION <-  orders %>% select(order_id,app_id,total_price, subtotal_price, total_discount)

# List of all products sold by merchants, with product details and whether or not
# they are warrantable
products <- readr::read_csv("https://raw.githubusercontent.com/rymarinelli/Extend-Analysis/main/data/products.csv")
DIM_PRODUCT_TRANSACTION <- products %>% select(store_id, category, price)
DIM_PRODUCT_STATUS <- products %>% select(store_id,warranty_status, enabled,approved)


