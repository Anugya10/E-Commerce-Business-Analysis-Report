
--1. Identify the top 3 cities with the highest number of customers to determine key markets for targeted marketing and logistics optimization.
     select location, count(customer_id) as number_of_customers
     from customers
     group by location
     order by number_of_customers desc
     limit 3;

--2. Determine how many customers fall into each order frequency category based on the number of orders they have placed.
--   Using the Orders table, calculate the number of customers who placed 1 order, 2 orders, 3 orders, etc.
--   Return a table showing:
--   The number of orders placed
--   The count of customers who placed that many orders
--   Sort the results by NumberOfOrders in ascending order. 
     with Counting as (
         select 
            customer_id, 
            count(order_id) as numberoforders
         from orders
         group by customer_id)
     select 
        numberoforders,
        count(customer_id) as CustomerCount
        from Counting
     group by numberoforders
     order by numberoforders asc;

--3. Identify products where the average purchase quantity per order is 2 but with a high total revenue, suggesting premium product trends.
     select
        Product_id,
        Avg(Quantity) as AvgQuantity,
        Sum(quantity * price_per_unit) as TotalRevenue
     from orderdetails
     group by Product_id
     having Avg(Quantity) = 2
     order by TotalRevenue desc;

--4. For each product category, calculate the unique number of customers purchasing from it. 
--   This will help understand which categories have wider appeal across the customer base.
     select 
        p.category, 
        count(distinct o.customer_id) as Unique_customers
     from products p 
     join orderdetails od 
       on p.product_id = od.product_id
     join orders o 
       on od.order_id = o.order_id
     group by p.category
     order by Unique_customers desc;

--5. Analyze the month-on-month percentage change in total sales to identify growth trends.
     with Changes as (
          select 
             date_format(order_date, '%Y-%m') as Month,
             sum(total_amount) as TotalSales
          from orders
          group by date_format(order_date, '%Y-%m')
     )
     select 
        Month,
        TotalSales,
        round((TotalSales - lag(TotalSales) over(order by Month)) * 100 /
              lag(TotalSales) over(order by Month),2) as PercentChange
     from Changes;

--6. Examine how the average order value changes month-on-month. Insights can guide pricing and promotional strategies to enhance order value.
     with Changes as (
          select 
             date_format(order_date, '%Y-%m') as Month,
             round(avg(total_amount),2) as AvgOrderValue
          from orders
          group by date_format(order_date, '%Y-%m')
      )
      select 
         Month,
         AvgOrderValue,
         round((AvgOrderValue - lag(AvgOrderValue) over(order by Month)),2) as ChangeInValue
      from Changes
      order by ChangeInValue desc;

--7. Based on sales data, identify products with the fastest turnover rates, suggesting high demand and the need for frequent restocking.
     select 
        product_id,
        count(*) as SalesFrequency
     from OrderDetails
     group by product_id
     order by SalesFrequency desc
     limit 5;

--8. List products purchased by less than 40% of the customer base, indicating potential mismatches between inventory and customer interest.
     with total_customers as (
         select 
            count(*) as total_customers
         from Customers
     ),
     product_sales as (
         select
             p.product_id,
             p.name,
             count(distinct o.customer_id) as uniquecustomercount
          from Products p
          join OrderDetails od
            on p.product_id = od.product_id
          join Orders o
            on od.order_id = o.order_id
          group by p.product_id, p.name
      )
      select
         ps.product_id,
         ps.name,
         ps.uniquecustomercount
      from product_sales ps
      cross join total_customers tc
      where ps.uniquecustomercount < tc.total_customers * 0.40;

--9. Evaluate the month-on-month growth rate in the customer base to understand the effectiveness of marketing campaigns and market expansion efforts.
     with NewCustomers as (
         select 
            customer_id,
            min(order_date) as First_purchase
         from orders
         group by customer_id)
     select
        date_format(First_purchase, '%Y-%m') as FirstPurchaseMonth,
        count(customer_id) as TotalNewCustomers
     from NewCustomers
     group by date_format(First_purchase, '%Y-%m')
     order by FirstPurchaseMonth asc;

--10. Identify the months with the highest sales volume, aiding in planning for stock levels, marketing efforts, and staffing in anticipation of peak demand periods.
      select
         date_format(order_date, '%Y-%m') as Month,
         sum(total_amount) as Totalsales
      from Orders
      group by date_format(order_date, '%Y-%m')
      order by Totalsales desc
      limit 3;
