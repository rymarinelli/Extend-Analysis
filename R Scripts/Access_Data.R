
library(magrittr)
library(glue)
library(readr)

# Helper Function to Read In Data 
# Does Pre-processing steps as determined from unit testing 
# The Parameter is the name of the csv file to be read in 
# Takes contracts, merchants, order_lines, orders, and products as default 
access_data <- function(x)
{
  file = x
  
  if("{file}" %>% glue() == "contracts")
  {  
    contracts <- readr::read_csv("https://raw.githubusercontent.com/rymarinelli/Extend-Analysis/main/data/{file}.csv" %>% glue())
    contracts <- contracts %>% subset(line_item_id != "NULL")
    return(contracts)
  }
  
  else if("{file}" %>% glue() == "merchants")
  {
    merchants <- readr::read_csv("https://raw.githubusercontent.com/rymarinelli/Extend-Analysis/main/data/{file}.csv" %>% glue())
    merchants$store_id <- stringr::str_remove(merchants$sortkey,"STORE::")
    merchants$sortkey <- NULL
    return(merchants)
  }
  
  else if ("{file}" %>% glue() == "order_lines")
  {
    order_lines <- readr::read_csv("https://raw.githubusercontent.com/rymarinelli/Extend-Analysis/main/data/order_lines.csv" %>% glue(), 
                                   , col_types = cols( variant_id = col_character()))
    order_lines <- order_lines %>% subset(price > 0 & variant_id != "NULL" & is_warrantable != "NULL")
    
    
    return(order_lines)
  }
  
  else if ("{file}" %>% glue() == "orders")
  {
    orders <- readr::read_csv("https://raw.githubusercontent.com/rymarinelli/Extend-Analysis/main/data/{file}.csv" %>% glue(), col_types = cols( order_id = col_character()))
    orders <- orders %>% subset(shipping_country != "NULL" & app_id != source_name & total_price > 0)
    return (orders)
  }
  
else{
    file = "products"
    products <- readr::read_csv("https://raw.githubusercontent.com/rymarinelli/Extend-Analysis/main/data/{file}.csv" %>% glue(), col_types = cols(variant_id = col_character()   ))
    products <- products %>% na.omit() %>% distinct()
    products <- products %>% subset(stringr::str_detect(products$category, "\\d") == F)
    products <- products %>% subset(category != "NULL" & warranty_status != "NULL" & approved != "NULL" & (price %>% as.character()) != "NULL")
    products$price <- products$price %>% as.double()
    products <- products %>% subset(price > 0.0)
    products <- products %>% subset(stringr::str_detect(products$warranty_status, "\\d") == F)
    return(products)
    
  }
   
   
}
