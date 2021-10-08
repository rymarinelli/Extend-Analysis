#
# Data Unit Testing For Order Lines 
#


order_lines <- readr::read_csv("https://raw.githubusercontent.com/rymarinelli/Extend-Analysis/main/data/order_lines.csv", 
                               , col_types = cols( variant_id = col_character()))

order_lines <- order_lines %>% subset(price > 0 & variant_id != "NULL" & is_warrantable != "NULL")



test_that("Checking For NA in Order_Lines", {
  
  expect_equal(order_lines %>% dim(), order_lines %>% na.omit() %>% dim())
  
})

test_that("Checking For Duplicates in order_lines", {
  
  expect_equal(order_lines %>% dim(), order_lines[!duplicated(order_lines),] %>% dim())
  
})

#Fails, there are zero prices 
test_that("Checking That Prices Are None Zero FOr order_lines ", {
  
  expect_equal(order_lines %>% subset(order_lines$price > 0) %>% dim(), order_lines %>% dim())
  
})


#Fails NULL data is present, pre-processing added to correct 
test_that("Checking For NULL values in order_lines For variant ID", {
  
  id = subset(order_lines, order_lines$variant_id == "NULL") %>% dim() %>% purrr::pluck()
  expect_equal(0, id[1])
})

test_that("Checking For NULL values in order_lines Lime Item Id", {
  
  id = subset(order_lines, order_lines$line_item_id == "NULL") %>% dim() %>% purrr::pluck()
  expect_equal(0, id[1])
})

test_that("Checking For NULL values in order_lines", {
  
  id = subset(order_lines, order_lines$order_id== "NULL") %>% dim() %>% purrr::pluck()
  expect_equal(0,id[1])
})

#Fails, is corrected with pre-processing 
test_that("Checking For NULL values in is_warrantable", {
  
  id = subset(order_lines, order_lines$is_warrantable == "NULL") %>% dim() %>% purrr::pluck()
  expect_equal(0,id[1])
})


test_that("Confirming discount Logic",{
  test <- order_lines %>% mutate(payment_test = order_lines$price - order_lines$discount_per_item)
  test <- test %>% mutate(test_accounting = product_purchase_price == payment_test)
  test  <- test %>%  subset(test_accounting == F) %>% dim()
  expect_equal(0,test[1])
})


