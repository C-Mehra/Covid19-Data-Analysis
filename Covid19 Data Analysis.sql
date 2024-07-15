## Lets start by cleaning the data ##

set sql_safe_updates = 0;

update coviddeaths
set continent = 0
where location = 'Asia';

update coviddeaths
set continent = 0
where location = 'Africa';

update coviddeaths
set continent = 0
where location = 'Europe';

update coviddeaths
set continent = 0
where location = 'South0America';

update coviddeaths
set continent = 0
where location = 'North0America';

update coviddeaths
set continent = 0
where location = 'Oceania';

update coviddeaths
set continent = 0
where location = 'European0Union';

delete from coviddeaths
where location = 'World';


-- Lets see how many countries are taken into account here --

select Distinct location,
max(total_cases) as tot_cases, max(total_deaths) as tot_deaths from coviddeaths
where continent is null
group by location
order by tot_deaths desc;

-- Lets see what is the death vs case ratio --

select distinct location, max(total_cases) as tot_cases,
max(total_deaths) as tot_deaths, (max(total_deaths)/max(total_cases))*100 as death_rate
from coviddeaths where continent is null
group by location
order by death_rate desc;

-- Which are the top 10 countries with highest deaths --

select distinct location, max(total_deaths) as tot_deaths from coviddeaths
where continent is null
group by location
order by tot_deaths desc
limit 10;

-- Lets see what is the positivity rates --

select distinct location, max(total_cases) as tot_cases,
max(total_tests) as tot_tests, (max(total_cases)/max(total_tests))*100 as positivity_rate
from coviddeaths
where continent is null
group by location
order by positivity_rate desc;

-- Lets see which dates saw the most cases globally --

select date, sum(new_cases) as tot_cases
from coviddeaths where continent is null
group by date
order by tot_cases desc;

-- Lets see which date saw the most deaths globally --

select date, sum(new_deaths) as tot_deaths
from coviddeaths where continent is null
group by date
order by tot_deaths desc;

-- Now lets see if more total cases coincides with more total deaths --

select date, sum(new_cases) as tot_cases, sum(new_deaths) as tot_deaths
from coviddeaths where continent is null
group by date
order by tot_deaths desc;

-- Lets find the total number of cases and deaths worldwide and death Percentage --

select sum(new_cases) as tot_cases, sum(new_deaths) as tot_deaths, 
(sum(new_deaths)/sum(new_cases))*100 as Death_Percentage 
from coviddeaths where continent is null;

-- Lets clean covidvaccination table as well --

update covidvaccination
set continent = null
where location = 'Asia';

update covidvaccination
set continent = null
where location = 'Africa';

update covidvaccination
set continent = null
where location = 'Europe';

update covidvaccination
set continent = null
where location = 'South0America';

update covidvaccination
set continent = null
where location = 'North0America';

update covidvaccination
set continent = null
where location = 'Oceania';

update covidvaccination
set continent = null
where location = 'European0Union';

delete from covidvaccination
where location = 'World';

-- Lets join coviddeaths and covidvaccination tables --

select * from coviddeaths cd
inner join covidvaccination cv
on cd.location = cv.location
and cd.date = cv.date;

-- Lets find out how many people were vaccinated in each country --

select distinct cd.location, max(cv.total_vaccinations) as tot_vac from coviddeaths cd
inner join covidvaccination cv
on cd.location = cv.location
and cd.date = cv.date 
where cd.continent is null
group by 1
order by 2 desc;

-- Lets see how many people were tested in each country --

select distinct cd.location, max(cv.total_tests) as tot_tests from coviddeaths cd
inner join covidvaccination cv
on cd.location = cv.location
and cd.date = cv.date 
where cd.continent is null
group by 1
order by 2 desc;

-- Lets find out positivity rate based on the number of tests --

select distinct cd.location, max(cd.total_cases) as tot_cases, 
max(cv.total_tests) as tot_tests, (max(cd.total_cases)/max(cv.total_tests)) * 100 as positivity_rate
 from coviddeaths cd
inner join covidvaccination cv
on cd.location = cv.location
and cd.date = cv.date 
where cd.continent is null
group by 1
order by 4 desc;

-- Lets find out how many total vaccinations were done in each country based on dates -- 

select cd.location, cd.date, cv.new_vaccinations, 
sum(cv.new_vaccinations) over (partition by cd.location 
order by str_to_date(cd.date, '%m-%d-%Y') rows between 
unbounded preceding and current row) as tot_vaccinations
from coviddeaths cd
join covidvaccination cv on cd.location = cv.location
and cd.date = cv.date
where cd.continent is null
order by cd.location, str_to_date(cd.date, '%m-%d-%Y');

-- Lets see how many people who were tested are also being vaccinated -- 

with testsvsvac (location, date, total_tests, new_vaccinations, tot_vaccinations)
as
(select cd.location, cd.date, cv.total_tests, cv.new_vaccinations, 
sum(cv.new_vaccinations) over (partition by cd.location 
order by str_to_date(cd.date, '%m-%d-%Y') rows between 
unbounded preceding and current row) as tot_vaccinations
from coviddeaths cd
join covidvaccination cv on cd.location = cv.location
and cd.date = cv.date
where cd.continent is null
group by 1, 2,3, 4
order by cd.location, str_to_date(cd.date, '%m-%d-%Y')) 
select *, (tot_vaccinations/total_tests)*100 as Vaccination_rate from  testsvsvac