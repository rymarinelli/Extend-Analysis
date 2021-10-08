library(testthat)

#
# Data Unit Testing For product data
#

products <- readr::read_csv("https://raw.githubusercontent.com/rymarinelli/Extend-Analysis/main/data/products.csv", col_types = cols(variant_id = col_character(), 
                                                                                                                                     price = col_double()))
products <- products %>% na.omit() %>% distinct()
products <- products %>% subset(stringr::str_detect(products$category, "\\d") == F)
products <- products %>% subset(category != "NULL" & warranty_status != "NULL" & approved != "NULL")
products <- products %>% subset(price > 0.0)
products <- products %>% subset(stringr::str_detect(products$warranty_status, "\\d") == F)

# Fails, corrected with pre-processing 
test_that("Checking For NA in Products", {
  
  expect_equal(products %>% dim(),  products %>% na.omit() %>% dim())
  
})


#Fails, corrected with pre-processing 
test_that("Checking For Duplicates in Products", {
  
  expect_equal(products %>% dim(), products[!duplicated(products),] %>% dim())
  
})

test_that("Testing for NULL values in category", {
  id = products %>% subset(category == "NULL") %>% dim()
  expect_equal(0, id[1])
})

test_that("Testing for irregular values in category", {
  id = products %>% subset(stringr::str_detect(products$category, "\\d") == T) %>% dim()
  expect_equal(0, id[1])
})


test_that("Testing for NULL values in warranty status", {
  id = products %>% subset(warranty_status == "NULL") %>% dim()
  expect_equal(0, id[1])
})


test_that("Testing for irregular values in warranty", {
  id = products %>% subset(stringr::str_detect(products$warranty_status, "\\d") == T) %>% dim()
  expect_equal(0, id[1])
})

test_that("Testing for NULL values in price", {
  id = products %>% subset(price == "NULL") %>% dim()
  expect_equal(0, id[1])
})



test_that("Testing for NULL values in approved", {
  id = products %>% subset(approved == "NULL") %>% dim()
  expect_equal(0, id[1])
})


test_that("Testing for Zero price", {
  id = products %>% subset(price == 0.00) %>% dim()
  expect_equal(0, id[1])
})



