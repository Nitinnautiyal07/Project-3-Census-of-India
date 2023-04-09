## number of rows into our dataset

select count(*) from growth_literacy_sex_ratio;
select count(*) from population_data;

## Data for only Jharkhand and Bihar

Select * from growth_literacy_sex_ratio
        where State="Jharkhand" OR State="Bihar" ;
        
## Population of India

select (sum(population)/1000000000) as Population_in_Billion from population_data;

## Avg growth

select State,Round(Avg(Growth),2) as avg_state_growth from growth_literacy_sex_ratio
	   group by State
       order by avg_state_growth desc;

## Avg sex ratio

select State,Round(Avg(Sex_ratio),2) as avg_sex_ratio from growth_literacy_sex_ratio
	   group by State
       order by avg_sex_ratio desc;
       
## States with Avg literacy rate>90

with cte1 as (
select state,Round(Avg(literacy),1) as avg_literacy_rate from growth_literacy_sex_ratio
	          group by state
)
select * from cte1
          where avg_literacy_rate > 90
		  group  by state
          order by avg_literacy_rate desc;
          
## Top 3 state showing highest growth ratio.

select state, Round(avg(growth),2) as avg_growth from growth_literacy_sex_ratio
       group by state
       order by avg_growth desc limit 3;
       
## Bottom 3 state showing lowest sex ratio

select state , sex_ratio from growth_literacy_sex_ratio
       group by state
       order by sex_ratio asc limit 3;
       
## Top and bottom 3 states in literacy state

with cte2 as(
       select state,literacy from growth_literacy_sex_ratio
	   group by state
       order by literacy  asc limit 3 
       ),
       
 cte3 as (
	   select state,literacy from growth_literacy_sex_ratio
	   group by state
       order by literacy  desc limit 3
       )
select * from cte2
union 
select * from cte3;

## Data for states starting with letter a

select distinct state from growth_literacy_sex_ratio
       where state like 'a%';
       
## No. of males and females
## Combining both the datsets

with cte5 as
(
select g.District,g.state,g.sex_ratio/1000 as sex_ratio,p.population from growth_literacy_sex_ratio g
inner join population_data p
on p.District=g.District
)
select state,sum(round(population/(sex_ratio+1),0)) as total_males,
sum(round( (population*sex_ratio)/(sex_ratio+1),0)) as total_females from cte5
group by state;

## Total Literacy rate
             
with cte6 as
(select g.District,g.state,g.literacy/100 as literacy,p.population from growth_literacy_sex_ratio g
inner join population_data p
on p.District=g.District
)
select state,sum(Round((Literacy*population),0)) as Total_literate_people,
                      sum(Round(((1-literacy)*population),0)) as  total_illiterate_people from cte6
group by state;

## Population in previouus Census
#### used CTE and sub query at same time to find this result

with last_year_population as
(select g.District,g.state,g.Growth as growth,p.population from growth_literacy_sex_ratio g
inner join population_data p
on p.District=g.District
)
select sum(previous_year_population) as Previous_year_population_of_India, sum(current_year_population) as Previous_year_population_of_India from
(select state,sum(Round((population/(1+growth)),0)) as previous_year_population,
sum(population) as current_year_population
 from last_year_population
group by state) m
;
	
## Top 3 districts from  each State with highest literacy rate

select a.* from
(
select district,state,literacy,
rank() over(partition by state order by literacy desc) rnk from growth_literacy_sex_ratio
) a
Where a.rnk in (1,2,3) order by state


