create database Project;
use Project;

/*
Project Title: 
				Electricity Usage Analysis by Household and Month using MySQL
Objective: 
				Design and implement a MySQL-based project to analyze electricity consumption patterns using 
				various tables related to household appliance usage, billing, environmental data, and household information. 
				The project should include the following tasks:
*/



-- task 1

/*
Project Task 1: Update the payment_status in the billing_info table 
based on the cost_usd value. Use CASE...END logic.
Hint:  
Cost_usd > 200 set “high”
Cost_usd >  100 and 200  set “medium”
Else “Low”
 Use the UPDATE statement along with CASE to set values conditionally.

*/


update billing_info set payment_status =
case when cost_usd > 200 then "High" else
case when cost_usd between 100 and 200 then "Medium" else 
"Low"
end
end;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- task 2

/*Project Task 2: For each household, show the monthly electricity usage, rank of usage within each year, and classify usage level.
Hint: Use SUM, MONTHNAME, Date_format, RANK() OVER, and CASE.
Hint2: update Usage level criteria using total Kwh 
total kwh > 500 then “High”
Else “Low” */

select  year,month,total_kwh,rank() over(partition by year order by total_kwh desc) as rank_no,case when 
  total_kwh>500 then "high" 
  else "Low"  end as usage_level
  from billing_info;


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- task 3

/*Project Task 3: 
Create a monthly usage pivot table showing usage for January, February, and March.
Hint: Use conditional aggregation using Pivot concept with CASE WHEN.
*/

select household_id,
round(case when month = "jan" then total_kwh end) as january,
round(case when month = "feb" then total_kwh end)as feburary,
round(case when month = "mar" then total_kwh end) as march
from billing_info where month in('jan','feb','mar');

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- task 4

/*Show average monthly usage per household with city name.
Hint: Use a subquery grouped by household and month.*/

-- using sub query
select a.month,avg(a.total_kwh) as avg_kwh,h.city from (select city,household_id from household_info) h ,billing_info a  
where a.household_id = h.household_id group by a.month,h.city;

-- using join
select a.month,avg(a.total_kwh) as avg_kwh,b.city from billing_info a join household_info b on a.household_id=b.household_id group by a.month,b.city;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- task 5

/*Project Task 5: Retrieve AC usage and outdoor temperature for households where AC usage is high.
Hint: Use a subquery to filter AC usage above 100.(High)*/


select *from environmental_data;
select* from appliance_usage;

-- using join
select e.household_id,e.avg_outdoor_temp,f.kwh_usage_ac from environmental_data e join appliance_usage f  on 
e.household_id = f.household_id where f.household_id in 
(select household_id from appliance_usage where kwh_usage_ac > 100);

-- using sub query
select e.household_id,e.avg_outdoor_temp,f.kwh_usage_ac from environmental_data e,
(select household_id ,kwh_usage_ac from appliance_usage where kwh_usage_ac >100) f where e.household_id = f.household_id ;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- task 6

/*Project Task 6: Create a procedure to return billing info for a given region.
Hint: Use IN parameter in a CREATE PROCEDURE.*/


select *from billing_info;
select *from household_info;


delimiter @@ 
create procedure return_billing_info(in region_name varchar(50)) 
begin
select e.*,f.region from billing_info e join household_info f on e.household_id=f.household_id where region=region_name;
end @@ 
delimiter ;


call return_billing_info('north');
call return_billing_info('south');
call return_billing_info('west');
call return_billing_info('east');

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- task 7

/*Project Task 7: Create a procedure to calculate total usage for a household and return it.
Hint: Use INOUT parameter and assign with SELECT INTO.
*/


delimiter @@ 
create procedure total_usage(in id varchar(50),inout total int) 
begin 

select total_kwh  INTO total from billing_info where household_id =id;
 end @@ 
delimiter ;

call TOTAL_USAGE('h0001',@TOTAL) ;
SELECT @TOTAL;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- task 8

/*Project Task 8: Automatically calculate cost_usd before inserting into billing_info.
Hint: Use BEFORE INSERT trigger and assign NEW.cost_usd.
*/


create table billing_info2 (household_id text ,month text,year int,
billing_cycle text,payment_status text,rate_per_kwh double,cost_usd double,total_kwh double );


delimiter @@
create trigger calculate_cost_usd before insert on billing_info2 
for each row 
begin 
set new.cost_usd =new.rate_per_kwh*new.total_kwh;
end @@ 
delimiter ;


create table billing_info2 (household_id text ,month text,year int,
billing_cycle text,payment_status text,rate_per_kwh double,cost_usd double,total_kwh double );

insert into billing_info2 select *from billing_info;

select*from billing_info2;

drop trigger calculate_cost_usd;
truncate billing_info2;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- task 9

/*Project Task 9 : After a new billing entry, insert calculated metrics into calculated_metrics.
Hint1: Use AFTER INSERT trigger and NEW keyword.
Hint 2:  Calculations(metrics)
House hold_id = new.house_hold_id
KWG per_occupant = total_kwh /Num_occupants
Usage category = total_kwh > 600 set “High” else “Moderate”*/


create table calculated_metrics2 (household_id text,kwh_per_occupant double,usage_category varchar(50)); 


delimiter @@ 
create trigger metrics_calculations  after insert on billing_info2 
for each row
begin
if new.total_kwh > 600 then
insert into calculated_metrics2 (household_id,kwh_per_occupant,usage_category) values
 (new.household_id,new.total_kwh/(select num_occupants from household_info where household_id = new.household_id),"HIGH");
else insert into calculated_metrics2(household_id,kwh_per_occupant,usage_category) values 
(new.household_id,new.total_kwh/(select num_occupants from household_info where household_id = new.household_id),"LOW");
end if;
 
end @@ 
delimiter ;



insert into billing_info2 select *from billing_info;

select *from calculated_metrics2;
