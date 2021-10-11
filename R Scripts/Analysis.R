library(tidyverse)
library(lubridate)
library(gt)
library(glue)
library(broom)
library(scales)

# Goal of Analysis
# Calculate attach rate overall and by merchant per month on a unit and dollar basis. Pick
# two merchants that are outliers (high attach rate and low attach rate) to do a SKU level
# analysis

# attach rate definition:  
#is a concept used broadly in business, especially in marketing,
# to represent the number of units of a secondary product or service sold as a direct
# or implied consequence of the sale of a primary product or service.


con <- dbConnect(RSQLite::SQLite(), "Extend.db")

source("Access_Data.R")


# If the ids present in order line, they are present in the contracts 
# If the ids are present in the contract, then a warranty plan is sold
# If there is an id in the order that is not present in the contract, then no warranty sale was made 
order_lines <- order_lines %>% mutate(warranty_sale_made = (order_lines$line_item_id %in% contracts$line_item_id))

#Calculates general attach rate.
#Takes the number of warranties made and divides by the number of orders
# Filter logic with warranty_sale made to avoid any issues with NA should new data be added
attach_rate <- (order_lines %>% subset(warranty_sale_made == T) %>%  nrow()/ order_lines %>% subset(warranty_sale_made == F | warranty_sale_made == T) %>%  nrow()) 

#Creating Table to present general attach rate 
attach_rate <- attach_rate %>% scales::percent()
attach_rate <- attach_rate %>% as.data.frame()
colnames(attach_rate)  <- c("General Attach Rate")
attach_rate <- gt::gt(attach_rate)

#Ensuring Same Data Types 
order_lines$line_item_id <- order_lines$line_item_id %>% as.character()
contracts$line_item_id <- contracts$line_item_id %>% as.character()
order_lines$variant_id <- order_lines$variant_id %>% as.character()
contracts$variant_id <- contracts$variant_id %>% as.character()

#Joining to get contract ID and store_id
# Using lubridate to specify the time formatting
df <- full_join(order_lines,contracts) %>% unique() 
df <- left_join(df,merchants)
df$ordered_at <- df$ordered_at %>% ymd_hms()
df <- df %>% mutate(month_sale = df$ordered_at %>% month()) 

#Ensuring the formatting of the column
df$order_id <- df$order_id %>% as.character()


#
#Finding Attachment Rate Per Month Per Merchant
#
#

#Subset to rows WHERE warrants are sold
sales_df <- df %>% subset(df$warranty_sale_made == T)

#GROUP BY months and name of merchant and SUM plan purchase price 
sales_df <- aggregate(sales_df$plan_purchase_price, list(sales_df$month_sale, sales_df$name), sum)
colnames(sales_df) <- c("Month","Merchant Name", "Revenue")


#Subset orders WHERE order_ids in orders are part of the set of ids that are correlated with
# the order_ids found in the order table. But they are not found in the contracts table. 
# If there are ids found in order but not found in contracts, then no warranty was made on an order
sales_missed_df <- orders %>% subset((order_id %in% (df %>% subset(df$warranty_sale_made == F) %>% select(order_id))) == F)
sales_missed_df <- left_join(sales_missed_df,merchants)
sales_missed_df$ordered_at <- sales_missed_df$ordered_at %>% ymd_hms()
sales_missed_df <- sales_missed_df %>% mutate(month_sale = ordered_at %>% month())

#Additional Logic to filter out any ids that may be present
sales_missed_df <- sales_missed_df %>% subset((ordered_at %in% contracts$ordered_at) == F) 

#Data Test
#If TRUE, then none of the line_item ids match confirming filter of ids from contract 
left_join(sales_missed_df,contracts) %>% select(line_item_id) %>% is.na() %>% unique() == T

sales_missed_df <- aggregate(sales_missed_df$total_price, list(sales_missed_df$month_sale, sales_missed_df$name), sum)
colnames(sales_missed_df) <- c("Month","Merchant Name", "Sales Not Including Warranties")

attachment_Rate_By_Month <- left_join(sales_df %>% arrange(Month), sales_missed_df %>% arrange(Month))
attachment_Rate_By_Month <- attachment_Rate_By_Month %>% mutate(monthly_attachment = (attachment_Rate_By_Month$Revenue/attachment_Rate_By_Month$`Sales Not Including Warranties`))

#Copy for data viz
attachment_Rate_By_Month_copy <- attachment_Rate_By_Month

#Creating Table For Attachment Rate By Month Per Merchant 
attachment_Rate_By_Month$monthly_attachment <- attachment_Rate_By_Month$monthly_attachment %>% scales::percent()
attachment_Rate_By_Month$Month <- month.abb[attachment_Rate_By_Month$Month]
attachment_Rate_By_Month  <- attachment_Rate_By_Month %>% select(Month,`Merchant Name`,monthly_attachment)
colnames(attachment_Rate_By_Month) <- c("Month","Merchant", "Monthly Attachment Rate ")
attachment_Rate_By_Month <- attachment_Rate_By_Month %>% gt()

#Finding Attachment Rate In Terms of Quantity Per Merchant 
sales_df <- df %>% subset(df$warranty_sale_made == T)
sales_df <- aggregate(sales_df$quantity, list(sales_df$month_sale, sales_df$name), sum)
colnames(sales_df) <- c("Month","Merchant Name", "Number of Units")

#Subset to orders that did not have a warranty
no_warranty_ids <- df %>% subset(df$warranty_sale_made == F) %>% select(order_id)
quant_missed_df <- orders %>% subset(order_id %in% no_warranty_ids == F)

#Confirming Data Types For Joins
quant_missed_df$order_id <- quant_missed_df %>% as.character()
order_lines$order_id <- order_lines$order_id %>% as.character()

quant_missed_df <- left_join(quant_missed_df,order_lines)
quant_missed_df <- left_join(quant_missed_df, merchants)

#Trying to catch any errors in Filtering logic 
test_df <- df %>% subset(df$warranty_sale_made == T) %>% select(order_id)
quant_missed_df  <- quant_missed_df %>% subset( (order_id %in% test_df) == F)

#Specify date format with lubridate package
quant_missed_df$ordered_at <- quant_missed_df$ordered_at %>% ymd_hms()

#Creating a new column from the extracted month 
quant_missed_df <- quant_missed_df %>% mutate(month_sale = ordered_at %>% month())

#Creating Copy For Data Visualization 
quant_missed_df_copy <- quant_missed_df

#GROUP BY MONTH and merchant name SUM Quan
quant_missed_df <- aggregate(quant_missed_df$quantity, list(quant_missed_df$month_sale, quant_missed_df$name), sum)
colnames(quant_missed_df) <- c("Month","Merchant Name", "Number of Units Not Including Warranties")

quant_missed_df <- quant_missed_df %>% subset(`Number of Units Not Including Warranties` != "NA")


#Calculating Attachment Rates in Units Per Month Per Merchant 
quantity_comparison <- left_join(sales_df %>% arrange(Month), quant_missed_df %>% arrange(Month)) %>% na.omit()
quantity_attachment_rate <- quantity_comparison%>% mutate(attachment_rate = (quantity_comparison$`Number of Units`/ quantity_comparison$`Number of Units Not Including Warranties`))

#Format Table
quantity_attachment_rate$Month <- month.abb[quantity_attachment_rate$Month]
quantity_attachment_rate$attachment_rate <- quantity_attachment_rate$attachment_rate %>% scales::percent()
quantity_attachment_rate  <- quantity_attachment_rate %>% select(Month,`Merchant Name`, attachment_rate)
colnames(quantity_attachment_rate) <- c("Month", "Merchant Name", "Monthly Attachment Rate By Unit")
quantity_attachment_rate  <- quantity_attachment_rate %>% gt::gt()

#SKU Analysis is attempting to compare the offerings
df <- right_join(df %>% subset(df$warranty_sale_made == T), contracts) %>% unique()
#RefurbPCLand High Attachment Rate 
#PowerWashersDirect  Lower Attachment Rate 

SKU <- df %>% subset(name == "PowerWashersDirect" | name == "RefurbPCLand")
refurb <- aggregate(SKU$plan_purchase_price, list(SKU$name,SKU$plan_id), sum)
#In terms of plans being purchased through the RefurbPCLand, the laptop warranties seem to be populuar. 
#It seems like an intermediate length warranty is perferred. My intitution suggests two things. Firstly, if these
#are refurbished, people may be more concerned and are willing to spend the extra money for the warranty.
#Additionally, it corresponds to Moore's Law'


#Creating table 
colnames(refurb) <- c("Merchant", "Plan", "Plan Puchase Price Sum")
refurb <- refurb %>% gt::gt()

refurb_2 <- aggregate(SKU$plan_purchase_price, list(SKU$name,SKU$plan_id), mean)
colnames(refurb_2) <- c("Merchant", "Plan", "Plan Puchase Price Mean")
refurb_2 <- refurb_2 %>% gt::gt()

#For PowerWashersDirect, there seems to be less spend. The same trend of the 2 year warranty being most values holds. 
#But the price point for the warrants is far higher. It may be that the warranties for these products are being priced out
# And are thus not being consumed 


###############################

# Creating Data Viz

#Uses attachment_Rate_By_Month_copy 
#Uses quant_missed_df_copy

#
#
# @param filter - to filter out ids or not 
# @param col_name to segment by to convert to discrete 
# @param Plot_title - ggtitle wrapper
# @param yaxis label is for the x axis is the coords are flipped for readability of the graph 
# @param xaxis label is for y the y axis  is the coords are flipped for readability of the graph 

plot_maker <- function(filter, agg_func, col_name, plot_title,  ylab_title, xlab_title)
{
  globalenv()
  df <- analysis_df %>% subset(analysis_df$warranty_sale_made == filter)
  Total_Spend_By_Cat <- aggregate(df$product_purchase_price, list(df$storetype), agg_func)
  colnames(Total_Spend_By_Cat) <- c("Category", col_name)
  
  Total_Spend_By_Cat[,2] <-  as.integer(Total_Spend_By_Cat[,2])
  
  p <- ggplot(data=Total_Spend_By_Cat, aes(x= Category, y= Total_Spend_By_Cat[,2] , color = Category, fill = Category)) +
    geom_bar(stat="identity") + coord_flip() + theme(legend.background = element_rect(fill="lightblue",
                                                                                      size=0.2, linetype="solid", 
                                                                                      colour ="darkblue")) + ggtitle(plot_title) + scale_y_continuous(labels = comma)
  q <- p + ylab(xlab_title) + xlab(ylab_title)
  
  return(q) 
}


#Mean Monthly Attachment Rate By Merchant 
attach_df <- aggregate(attachment_Rate_By_Month_copy$monthly_attachment, list(attachment_Rate_By_Month_copy$`Merchant Name`),mean)
colnames(attach_df) <- c("name", "Mean Monthly Attachment")
attach_df <- left_join(attach_df,merchants) 

analysis_df <- left_join(quant_missed_df_copy,attach_df) %>% distinct()

analysis_df <- analysis_df %>% subset(analysis_df$warranty_sale_made %>% is.na() == F)

# Look at the size of the markets in dollars per store type


#Total Product Price With Waranty
product_purchases_warranty_plot <- plot_maker(T,sum, "Sum of Purchases", "Sum of Product Purchases That Have Warranties",  "Category", "Total of Prices in USD")

#Total Product Price Without Waranty
product_purchases_plot_no_warranty <- plot_maker(F , sum, "Sum of Purchases", "Sum of Product Purchases That Have Warranties",  "Category", "Total of Prices in USD" )


# Total Product Price Throughout
total_product_purchases_plot <- plot_maker(T|F,sum, "Sum of Purchases", "Sum of Product Purchases That Have Warranties",  "Category", "Total of Prices in USD")



# Patchwork Plot that composes the plots 
product_plot <- (product_purchases_warranty_plot | product_purchases_plot_no_warranty)



# Look at attachment rate per cat 

# high attachment in high spending markets 


current_attachment <-  aggregate(analysis_df$`Mean Monthly Attachment`, list(analysis_df$storetype), mean)
colnames(current_attachment) <- c("Category", "Percent Attachment")

#For the scaling in ggplot
current_attachment$`Percent Attachment` <- current_attachment$`Percent Attachment`/100

attachment_plot <- ggplot(data= current_attachment, aes(x= Category, y= `Percent Attachment`, color = Category, fill = Category)) +
  geom_bar(stat="identity") + coord_flip() + theme(legend.background = element_rect(fill="lightblue",
                                                                                    size=0.2, linetype="solid", 
                                                                                    colour ="darkblue")) + ggtitle("Distribution of Attachment Across Industry") + scale_y_continuous(labels = scales::percent)

#Estimate Rev
#With Merchant Cut 
analysis_df <- left_join(analysis_df,contracts) %>% unique()

analysis_df <- analysis_df %>% mutate(net_revenue =  plan_purchase_price - plan_purchase_price*merchantcut)

rev_df <- analysis_df %>% subset((net_revenue %>% is.na()) == F)

#Current Rev After Merchants Take There Cut

# Find Revenue After Merchant CUt
Total_Spend_By_Cat <- aggregate(rev_df$net_revenue, list(rev_df$storetype), sum)
colnames(Total_Spend_By_Cat) <- c("Category", "Revenue After Merchant Cut")
Total_Spend_By_Cat$`Sum of Produce Purchases` <- Total_Spend_By_Cat$`Revenue After Merchant Cut` %>% as.integer()


#Plotting After Merchant Cut
p <- ggplot(data=Total_Spend_By_Cat, aes(x= Category, y=`Revenue After Merchant Cut`, color = Category, fill = Category)) +
  geom_bar(stat="identity") + coord_flip() + theme(legend.background = element_rect(fill="lightblue",
                                                                                    size=0.2, linetype="solid", 
                                                                                    colour ="darkblue")) + ggtitle("Revenue After Merchant Cut") + scale_y_continuous(labels = comma)

#Revenue Plot 
rev_plot <- p + ylab("Total of Prices in USD")

# Taking the Average By Cat For Merchant Cut and Plan 
analysis_df <- left_join(analysis_df, analysis_df %>% group_by(storetype) %>% summarise(average_cut = mean(merchantcut))) 
analysis_df <- left_join(analysis_df, analysis_df  %>% subset(warranty_sale_made == T)  %>% group_by(storetype) %>% summarise(average_plan_purchase_price = mean(plan_purchase_price)))

analysis_df <- left_join(analysis_df,analysis_df %>% mutate(average_net_rev = average_plan_purchase_price - average_plan_purchase_price*average_cut ))



#Using the average cut and plan to determine how much could have been made on average
# for the orders that have no warranties 
# mostly an estimate for what is not being captured

no_warranty_analysis <- analysis_df %>% subset(analysis_df$warranty_sale_made == F)
Total_Spend_By_Cat <- aggregate(no_warranty_analysis$average_net_rev, list(no_warranty_analysis$storetype), sum)
colnames(Total_Spend_By_Cat) <- c("Category", "Expected Potential Revenue")
Total_Spend_By_Cat$`Sum of Produce Purchases` <- Total_Spend_By_Cat$`Expected Potential Revenue` %>% as.integer()

p <- ggplot(data=Total_Spend_By_Cat, aes(x= Category, y=`Sum of Produce Purchases`, color = Category, fill = Category)) +
  geom_bar(stat="identity") + coord_flip() + theme(legend.background = element_rect(fill="lightblue",
                                                                                    size=0.2, linetype="solid", 
                                                                                    colour ="darkblue")) + ggtitle("Average Potential Revenue") + scale_y_continuous(labels = comma)
expected_rev_plot <- p + ylab("Total of Prices in USD")

#Patchwork plot
combined_rev <- rev_plot/ expected_rev_plot

# Warranty Sold or Not 
# What kind of industry 
# Percent Discount 
# Price of the Product 

analysis_df$warranty_sale_made <- analysis_df$warranty_sale_made %>% as.numeric()
analysis_df <- fastDummies::dummy_cols(analysis_df, select_columns = "storetype", remove_first_dummy = T)

model.1 <- lm(warranty_sale_made ~ storetype + merchantcut, data = analysis_df)
summary(model)

#Calculates Variance Inflation Factor for Multicolinearity 
Vif.1 <- car::vif(model.1)

model.2 <- lm(warranty_sale_made ~ storetype + merchantcut + product_purchase_price, data = analysis_df)
summary(model.2)

#Calculates Variance Inflation Factor for Multicolinearity 
vif.2 <- car::vif(model.2)


table <- broom::tidy(model.2) %>% gt::gt()



