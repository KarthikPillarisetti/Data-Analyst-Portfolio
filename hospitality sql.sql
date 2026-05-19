/* 1.Total Revenue*/
select concat(round(sum(revenue_realized)/10000000,2),'bn') as TotalRevenue from fact_bookings;

/* 2.Occupancy */
select concat(round(sum(successful_bookings)/sum(capacity)*100,2),'%') as occupancy_rate from fact_aggregated_bookings;

/* 3. Cancellation Rate*/
select concat(round(sum(case when booking_status = "Cancelled" then 1 else 0 end)*100.0/count(*),2) ,'%')as Cancellation_Rate from fact_bookings;

/* 4.Total Booking*/
select concat(round(count(booking_id)/1000,2),'M') as Total_Bookings from fact_bookings;

/*5.Utilize capacity */
select concat(round(sum(capacity)/1000,2),'M') as UtilizeCapacity from fact_aggregated_bookings;

/*6.Trend Analysis */
select dim_hotels.city,concat(round(sum(fact_bookings.revenue_generated)/10000000,2),'bn') as  RevenueGenerated ,
concat(round(sum(fact_bookings.revenue_realized)/10000000,2),'bn') as RevenueRealized
from dim_hotels join fact_bookings
on dim_hotels.property_id=fact_bookings.property_id
group by dim_hotels.city;

/*7 Weekday  & Weekend  Revenue and Booking */
select
    dim_date.day_type,
    sum(fact_bookings.revenue_realized) AS TotalRevenue,
    count(fact_bookings.booking_id) AS TotalBookings
from dim_date join
    fact_bookings on fact_bookings.check_in_date
group by dim_date.day_type;

/*8.Revenue by State & hotel*/
select h.city,h.property_name,concat(round(sum(fb.revenue_realized)/1000000,2),'bn') as total_revenue
from dim_hotels h
join fact_bookings fb on h.property_id=fb.property_id 
group by h.city,h.property_name order by h.city,h.property_name;

/*9.Class Wise Revenue*/
select r.room_class,concat(round(sum(fb.revenue_realized)/1000000,2),'bn') as total_revenue from dim_rooms r join
fact_bookings fb on r.room_id=fb.room_category group by r.room_class;

/*10.Checked out cancel No show*/
select
booking_status,count(*) as BookingStatusCount
from fact_bookings
where booking_status in ('Checked Out', 'Cancelled', 'No Show') 
group by booking_status ;



/*11.REVENUE BY CATEGORY*/
select
category,
sum(revenue_generated)
 from dim_hotels
  join fact_bookings
 on dim_hotels.property_id = fact_bookings.property_id  group by category;