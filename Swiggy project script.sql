/*#1. top 10 different category wise orders
select pre.city, pre.CATEGORY, pre.orders, pre.item_gmv, post.city, post.CATEGORY, post.orders, post.item_gmv
from (select city, category, orders, qty, price, item_gmv, row_number () over (order by item_gmv desc) as serial
from pre
group by category
order by item_gmv desc
limit 10) as pre, 
(select city, category, orders, qty, price, item_gmv, row_number () over (order by item_gmv desc) as serial
from post
group by category
order by item_gmv desc
limit 10) as post
where pre.serial = post.serial;*/

/*#2. Total pre and post GMV of Sweets and percentage increase in Sweet GMV post*/
select pre.GMV_sweets as pre_diwali_SweetGMV, post.GMV_sweets as post_diwali_SweetGMV, 
post.GMV_sweets-pre.GMV_sweets as diff_GMV , 
round((((post.GMV_sweets-pre.GMV_sweets)*100)/pre.GMV_sweets),2) as percent_inc
from (select sum(ITEM_GMV) as GMV_Sweets
from pre
where category = 'sweets') as pre, 
(select sum(ITEM_GMV) as GMV_Sweets
from post
where category = 'sweets') as post;

/*#3. Top 10 cities, no_of_order wise */
select city, sum(orders) as no_of_orders
from (select date, name, city, category, orders, qty, price, item_gmv
from pre
order by city) as details
group by city
order by no_of_orders desc
limit 10;

select city, sum(orders) as no_of_orders
from (select date, name, city, category, orders, qty, price, item_gmv
from post
order by city) as details
group by city
order by no_of_orders desc
limit 10;


/*#4. Weekday wise GMV and Percentage*/
select pre.order_day, pre.no_of_orders as pre_no_of_order, pre.GMV as pre_GMV, pre.percentage as Pre_percent,
post.no_of_orders as post_no_of_order, post.GMV as post_GMV, post.percentage as post_percent, 
round(((post.gmv - pre.gmv)/pre.gmv)*100, 2) as percent_increase
from (select order_day, no_of_orders, GMV, round((gmv*100)/ (select sum(ITEM_GMV) as gmv from pre), 2) as percentage
 from (select order_day, sum(orders) as no_of_orders, sum(ITEM_GMV) as GMV
 from (select date, name, city, category, orders, qty, price, item_gmv, dayname(date) as order_day
 from pre) as details
 group by weekday(date)
 order by weekday(date)) as orders
 group by order_day) as pre, 
(select order_day, no_of_orders, GMV, round((gmv*100)/ (select sum(ITEM_GMV) as gmv from pre), 2) as percentage
 from (select order_day, sum(orders) as no_of_orders, sum(ITEM_GMV) as GMV
 from (select date, name, city, category, orders, qty, price, item_gmv, dayname(date) as order_day
 from post) as post_details
 group by weekday(date)
 order by weekday(date)) as post_orders
 group by order_day) as post
where pre.order_day = post.order_day;

/*#5. Orders, GMV and percentage GMV as per day timing*/
select pre.time, pre.no_of_orders as pre_orders, pre.GMV as pre_GMV, pre.percentage_GMV as pre_percent_GMV, 
post.no_of_orders as post_orders, post.GMV as post_GMV, post.percentage_GMV as Post_percent_GMV
from (select time, sum(orders) as no_of_orders, sum(ITEM_GMV) as GMV, 
	   round(((sum(ITEM_GMV)*100)/(select sum(ITEM_GMV) from pre)),2) as percentage_GMV
from (select date, city, category, orders, qty, price, item_gmv, `hr of the day`, dayname(date), case
										  when `hr of the day`between 7 and 11 then 'Breakfast'
                                          when `hr of the day`between 12 and 16 then 'Lunch'
                                          when `hr of the day`between 17 and 20 then 'Snacks'
                                          when `hr of the day`between 21 and 23 then 'Dinner'
                                          when `hr of the day`between 0 and 2 then 'Dinner'
                                          end as time
from pre) as details
group by time
order by `hr of the day`) as pre,
(select time, sum(orders) as no_of_orders, sum(ITEM_GMV) as GMV, 
	   round(((sum(ITEM_GMV)*100)/(select sum(ITEM_GMV) from post)),2) as percentage_GMV
from (select date, city, ITEM_ID, item_name, category, orders, qty, price, item_gmv, `hour of the day`, dayname(date), case
										  when `hour of the day`between 7 and 11 then 'Breakfast'
                                          when `Hour of the day`between 12 and 16 then 'Lunch'
                                          when `hour of the day`between 17 and 20 then 'Snacks'
                                          when `hour of the day`between 21 and 23 then 'Dinner'
                                          when `hour of the day`between 0 and 5 then 'Dinner'
                                          end as time
from post) as details
group by time
order by `hour of the day`) as post
where pre.time = post.time;

/*#6. Percentage change in GMV per day over time*/
select pre.day, pre.time, pre.no_of_orders as pre_orders, pre.GMV as pre_GMV,
post.no_of_orders as post_orders, post.GMV as post_GMV, round(((post.gmv - pre.gmv)/pre.gmv)*100,2) as precent_change_in_GMV
From (select day, time, sum(orders) as no_of_orders, sum(ITEM_GMV) as GMV
from (select date, city, category, orders, qty, price, item_gmv, `hr of the day`, dayname(date) as day, case
										  when `hr of the day`between 7 and 11 then 'Breakfast'
                                          when `hr of the day`between 12 and 16 then 'Lunch'
                                          when `hr of the day`between 17 and 20 then 'Snacks'
                                          when `hr of the day`between 21 and 23 then 'Dinner'
                                          when `hr of the day`between 0 and 2 then 'Dinner'
                                          end as time
from pre) as details
group by time, day
order by weekday(date)) as pre,
(select day, time, sum(orders) as no_of_orders, sum(ITEM_GMV) as GMV
from (select date, city, category, orders, qty, price, item_gmv, `hour of the day`, dayname(date) as day, case
										  when `hour of the day`between 7 and 11 then 'Breakfast'
                                          when `Hour of the day`between 12 and 16 then 'Lunch'
                                          when `hour of the day`between 17 and 20 then 'Snacks'
                                          when `hour of the day`between 21 and 23 then 'Dinner'
                                          when `hour of the day`between 0 and 5 then 'Dinner'
                                          end as time
from post) as details
group by time, day
order by weekday(date)) as post
where pre.day=post.day and pre.time = post.time;

/*#7. top 10 city wise GMV and Percentage*/
select city, gmv, round((gmv*100)/ (select sum(ITEM_GMV) as gmv from pre), 2) as percentage
from (select city, sum(orders) as no_of_orders, sum(ITEM_GMV) as GMV
from (select date, name, city, category, orders, qty, price, item_gmv, dayname(date) as order_day
from pre) as details
group by city
order by city) as orders
group by city
order by percentage desc
limit 10;

select city, gmv, round((gmv*100)/ (select sum(ITEM_GMV) as gmv from pre), 2) as percentage
from (select city, sum(orders) as no_of_orders, sum(ITEM_GMV) as GMV
from (select date, name, city, category, orders, qty, price, item_gmv, dayname(date) as order_day
from post) as details
group by city
order by city) as orders
group by city
order by percentage desc
limit 10;

/*Top 10 City wise number of orders*/
select city, sum(orders) as no_of_orders
from (select date, name, city, category, orders, qty, price, item_gmv, dayname(date) as order_day
from pre
order by city) as details
group by city
order by no_of_orders desc
limit 10;

select city, sum(orders) as no_of_orders
from (select date, name, city, category, orders, qty, price, item_gmv, dayname(date) as order_day
from post
order by city) as details
group by city
order by no_of_orders desc
limit 10;