library(testthat)

#
# Data Unit Testing For Orders data
#

orders <- readr::read_csv("https://raw.githubusercontent.com/rymarinelli/Extend-Analysis/main/data/orders.csv", col_types = cols( order_id = col_character()))
orders <- orders %>% subset(shipping_country != "NULL" & app_id != source_name & total_price > 0)

test_that("Testing For NA in Orders", {
  
  expect_equal(orders %>% dim(),  orders %>% na.omit() %>% dim())
  
})

test_that("Testing For Duplicates in Orders", {
  
  expect_equal(orders%>% dim(), orders[!duplicated(orders),] %>% dim())
  
})

test_that("Testing for NULL values in app id", {
  id = orders %>% subset(app_id == "NULL") %>% dim()
  expect_equal(0, id[1])
})

test_that("Testing that only characters are used in app id", {
  id = orders %>% subset(app_id == source_name) %>% dim()
  expect_equal(0, id[1])
})

test_that("Testing for NULL values in source name ", {
  id = orders %>% subset(source_name == "NULL") %>% dim()
  expect_equal(0, id[1])
})

#Fails and is corrected with pre-processing 
test_that("Testing for NULL values in shipping country", {
  id = orders %>% subset(shipping_country == "NULL") %>% dim()
  expect_equal(0, id[1])
})


#Fails, corrected with pre-processing
test_that("Testing That Prices Are None Zero", {
  
  expect_equal(orders %>% subset(orders$total_price > 0) %>% dim(), orders %>% dim())
})
