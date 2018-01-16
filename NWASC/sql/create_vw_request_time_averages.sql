-- set database
use NWASC;

-- look at request table
-- select * from requests where request_status = 'filled' 

-- create view with datediff and type
create view [request_time_averages] as
select DATEDIFF(day, date_requested, date_filled) as 'duration',
request_type from requests
where request_status in ('filled','partially filled') 
and request_id <> 1

-- determine the average days per type
select request_type, avg(duration) as 'days' from [request_time_averages]
group by request_type

-- remove request_time_averages
drop view request_time_averages
