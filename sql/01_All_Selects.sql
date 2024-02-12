--01a. Calculating mortality rate for those who contracted COVID
-- probability of dying when contracting  COVID in a certain country
-- for certain locations, dates
-- sorted by location, date
select
   location,continent,date,population,total_cases,total_deaths,
   round((total_deaths/total_cases)*100,3) contracted_mortality_rate_percentage
from
   CovidDeaths
where
   continent is not null and
   total_cases is not null and
   total_deaths is not null
order by
   location, date

--01b. Calculating mortality rate for those who contracted COVID
-- probability of dying when contracting  COVID on a certain continent
-- for certain continents, dates
-- sorted by location, date
select
   location,date,population,total_cases,total_deaths,
   round((total_deaths/total_cases)*100,3) contracted_mortality_rate_percentage
from
   CovidDeaths
where
   continent is null and
   total_cases is not null and
   total_deaths is not null
order by
   location, date

--02a. Calculating COVID infection rate (total cases vs population)
-- for certain locations, dates
-- sorted by location, date
select
   location,continent,date,population,total_cases,total_deaths,
   round((total_cases/population)*100,3) covid_contraction_rate_percentage
from
   CovidDeaths
where
   continent is not null and
   total_cases is not null and
   total_deaths is not null
order by
   location, date

--02b. Calculating COVID infection rate (total cases vs population)
-- for certain global regions, dates
-- sorted by location, date
select
   location,date,population,total_cases,total_deaths,
   round((total_cases/population)*100,3) covid_contraction_rate_percentage
from
   CovidDeaths
where
   continent is null and
   location not like '%income%' and
   total_cases is not null and
   total_deaths is not null
order by
   location, date

--02ñ. Calculating maximum COVID infection rate (maximum total cases vs population)
-- for certain locations, dates
-- sorted by location, date
select
   location,population,
   MAX(total_cases) max_total_cases,
   round(MAX((total_cases/population)*100),3) max_infection_rate
from
   CovidDeaths
where
   continent is not null and
   total_cases is not null
group by
   location,population
order by
   location

--02d. Calculating maximum COVID infection rate (maximum total cases vs population)
-- for certain global regions, dates
-- sorted by location, date
select
   location,population,
   MAX(total_cases) max_total_cases,
   round(MAX((total_cases/population)*100),3) max_infection_rate
from
   CovidDeaths
where
   continent is null and
   location not like '%income%' and
   total_cases is not null
group by
   location,population
order by
   location

--03a. Calculating deaths against population ratio
-- for certain locations, dates
-- sorted by location, date
select
   location,continent,date,population,total_cases,total_deaths,
   round((total_deaths/population)*100,3) death_rate_percentage
from
   CovidDeaths
where
   continent is not null and
   total_cases is not null and
   total_deaths is not null
order by
   location, date

--03b. Calculating deaths against population ratio
-- for certain continents, dates
-- sorted by location, date
select
   location,continent,date,population,total_cases,total_deaths,
   round((total_deaths/population)*100,3) death_rate_percentage
from
   CovidDeaths
where
   continent is not null and
   location not like '%income%' and
   total_cases is not null and
   total_deaths is not null
order by
   location, date

--03c. Calculating maximum deaths against population ratio
-- for certain locations, dates
-- sorted by location, date
select
   location,population,
   MAX(total_deaths) max_total_deaths,
   round(MAX((total_deaths/population)*100),3) max_death_rate_percentage
from
   CovidDeaths
where
   continent is not null and
   total_cases is not null and
   total_deaths is not null
group by
   location,population
order by
   location

--03d. Calculating maximum deaths against population ratio
-- for certain global regions, dates
-- sorted by location, date
select
   location,population,
   MAX(total_deaths) max_total_deaths,
   round(MAX((total_deaths/population)*100),3) max_death_rate_percentage
from
   CovidDeaths
where
   continent is null and
   location not like '%income%' and
   total_cases is not null and
   total_deaths is not null
group by
   location,population
order by
   location

--04. Global numbers for cases, deaths and mortality
-- for certain global regions, dates
-- sorted by location, date
select
   date,
   SUM(total_cases) total_cases,
   SUM(total_deaths) total_deaths,
   round((SUM(new_deaths)/SUM(new_cases))*100,3) contracted_mortality_rate_percentage
from
   CovidDeaths
where
   continent is null and
   location not like '%income%' and
   new_cases is not null and
   new_deaths is not null
group by
   date
order by
   date

--05. Vaccinations vs. population
--two queries return totally different results because we lack data of newn vaccinations
with t as
(
	select
	   dea.continent, dea.location, dea.date, dea.population, max(vac.total_vaccinations) max_total_vaccinations
	from
	   CovidDeaths dea
	join
	   CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date
	where
	   dea.population is not null and
	   vac.total_vaccinations is not null
	group by
	   dea.continent, dea.location, dea.date, dea.population
	--order by
	--   dea.location, dea.date
)
select
   t.*, round(t.max_total_vaccinations/t.population*100, 3) vaccination_rate
from
   t
order by
   t.location,t.date

--this one returns wrong results
select
   dea.location, dea.date, dea.population,
   vac.new_vaccinations,
   SUM(vac.new_vaccinations) over (partition by dea.location order by dea.date) rolling_sum_of_vaccinations
from
   CovidDeaths dea
join
   CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date
where
   dea.population is not null and
   vac.new_vaccinations is not null
order by
   dea.location, dea.date