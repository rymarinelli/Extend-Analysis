library(RSQLite)

con <- dbConnect(RSQLite::SQLite(), "Extend.db")

dbGetQuery(con, "SELECT line_item_id, MAX(price)
                  FROM order_lines")
                                             

dbGetQuery(con, "SELECT line_item_id, MIN(price)
                  FROM order_lines")

dbGetQuery(con, "SELECT order_id, MAX(total_price)
                  FROM orders")

dbGetQuery(con, "SELECT order_id, MIN(total_price)
                  FROM orders")

dbGetQuery(con, "SELECT MAX(quantity), o.line_item_id
                FROM order_lines AS o 
                JOIN contracts as c  ON 
                o.line_item_id = c.line_item_id")


dbGetQuery(con, "SELECT MIN(quantity), MIN(o.line_item_id) 
                FROM order_lines AS o 
                JOIN contracts as c  ON 
                o.line_item_id = c.line_item_id")
