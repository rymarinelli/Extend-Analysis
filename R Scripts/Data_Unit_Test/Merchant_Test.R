
#
# Data Unit Testing Merchant Data 
#

merchants <- readr::read_csv("https://raw.githubusercontent.com/rymarinelli/Extend-Analysis/main/data/merchants.csv")
merchants$store_id <- stringr::str_remove(merchants$sortkey,"STORE::")
merchants$sortkey <- NULL

test_that("Checking For NA in Merchants", {
  
  expect_equal(merchants %>% dim(),  merchants %>% na.omit() %>% dim())
  
})


test_that("Checking For Duplicates in Contracts", {
  
  expect_equal(merchants %>% dim(), merchants[!duplicated(merchants),] %>% dim())
  
})

test_that("Checking That Merchant Cut Are None Zero", {
  
  expect_equal(merchants %>% subset(merchants$merchantcut > 0) %>% dim(), merchants %>% dim())
})

test_that("Testing for NULL values in store id", {
  id = merchants %>% subset(store_id == "NULL") %>% dim()
  expect_equal(0, id[1])
})
