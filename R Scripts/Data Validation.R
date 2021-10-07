library(tidyverse)
library(benford.analysis)

#Each warranty contract purchased by a consume
contracts <- readr::read_csv("https://raw.githubusercontent.com/rymarinelli/Extend-Analysis/main/data/contracts.csv")

#Data on each merchant that has integrated Extend’s purchase protection product.
merchants <- readr::read_csv("https://raw.githubusercontent.com/rymarinelli/Extend-Analysis/main/data/merchants.csv")

#ndividual line items purchased within an order
order_lines <- readr::read_csv("https://raw.githubusercontent.com/rymarinelli/Extend-Analysis/main/data/order_lines.csv")

# Purchase data for Extend’s Shopify merchants.
orders <- readr::read_csv("https://raw.githubusercontent.com/rymarinelli/Extend-Analysis/main/data/orders.csv")

# List of all products sold by merchants, with product details and whether or not
# they are warrantable
products <- readr::read_csv("https://raw.githubusercontent.com/rymarinelli/Extend-Analysis/main/data/products.csv")



# First Conduct Benford Analysis and Look And Conduct Outlier Imputation

# Make SQL tables using SQL Lite
# It will probably make sense to normalize tables 
# It will also make sense to index the tables 

