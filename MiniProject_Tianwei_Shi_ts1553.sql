# Problem 1
/* Find maximal departure delay in minutes for each airline. Sort results from smallest to largest maximum
delay. Output airline names and values of the delay. */
select LAI.Name, max(ap.DepDelayMinutes) as max_DepDelayMinutes
from L_AIRLINE_ID as LAI join al_perf as ap on LAI.ID=ap.DOT_ID_Reporting_Airline
group by LAI.Name
order by max_DepDelayMinutes;
-- 17 rows returned


# Problem 2
/* Find maximal early departures in minutes for each airline. Sort results from largest to smallest. Output
airline names. */
select LAI.Name
from L_AIRLINE_ID as LAI join al_perf as ap on LAI.ID=ap.DOT_ID_Reporting_Airline
group by LAI.Name
order by min(ap.DepDelay) asc;
-- 17 rows returned


# Problem 3
/* Rank days of the week by the number of flights performed by all airlines on that day (1 is the busiest).
Output the day of the week names, number of flights and ranks in the rank increasing order. */
select DayOfWeek, count(Flight_Number_Reporting_Airline),rank()over(order by count(Flight_Number_Reporting_Airline) desc) as rank_number_flights
from al_perf
group by DayOfWeek;
-- 7 rows returned


# Problem 4
/* Find the airport that has the highest average departure delay among all airports. Consider 0 minutes delay
for flights that departed early. Output one line of results: the airport name, code, and average delay */
select LAI.Name, LA.Code, avg(ap.DepDelayMinutes) as avg_DepDelayMinutes
from (L_AIRPORT as LA join L_AIRPORT_ID as LAI on LA.Name=LAI.Name) join al_perf as ap on  ap.OriginAirportID=LAI.ID
group by LAI.Name
order by avg_DepDelayMinutes desc
limit 1;
-- 1 row returned 


# Problem 5
/* For each airline find an airport where it has the highest average departure delay. Output an airline name, a
name of the airport that has the highest average delay, and the value of that average delay. */
create view avg_depdelay as(
select LAL.Name as AIRLINE_Name, LAP.Name as AIRPORT_Name, avg(ap.DepDelayMinutes) as avg_DepDelayMinutes
from (L_AIRLINE_ID as LAL join al_perf as ap on ap.DOT_ID_Reporting_Airline=LAL.ID) join L_AIRPORT_ID as LAP on ap.OriginAirportID=LAP.ID
group by LAL.Name, LAP.Name);

with rank_avg_depdelay as(
select AIRLINE_Name, AIRPORT_Name, avg_DepDelayMinutes, row_number() over(partition by AIRLINE_Name order by avg_DepDelayMinutes desc) as rn
from avg_depdelay)
select AIRLINE_Name, AIRPORT_Name, avg_DepDelayMinutes
from rank_avg_depdelay
where rn = 1
order by avg_DepDelayMinutes;


# Problem 6a
/* Check if your dataset has any canceled flights. */
select exists(select * from al_perf where Cancelled=1) as has_canceled_flights;
-- 1 row returned


# Problem 6b
/* If it does, what was the most frequent reason for each departure airport? Output airport name,
the most frequent reason, and the number of cancelations for that reason. */
with count_cancel as(
select 	LAP.Name as airport, LC.Reason as reason, count(LC.Reason) as num_cancelations, row_number() over(partition by LAP.Name order by count(LC.Reason) desc) as rn
from (L_CANCELATION as LC join al_perf as ap on LC.Code = ap.CancellationCode) join L_AIRPORT_ID as LAP on LAP.ID=ap.OriginAirportID
group by LAP.Name, LC.Reason)
select airport, reason, num_cancelations
from count_cancel
where rn = 1;
-- 261 rows returned


# Problem 7
/* Build a report that for each day output average number of flights over the preceding 3 days. */
/* Build a report that for each day output average number of flights over the preceding 3 days. */
with flights_num as (
select FlightDate, count(Flight_Number_Reporting_Airline) as num_of_flights
from al_perf
group by FlightDate
order by FlightDate)
select FlightDate, avg(num_of_flights) over(order by FlightDate rows between 3 preceding and 1 preceding) as avg_total_flights
from flights_num
-- 30 rows returned