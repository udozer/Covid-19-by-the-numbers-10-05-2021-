/*
Queries used for Tableau Visualization
*/

--Getting total cases, deaths and death rate
-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidProjectDB..CovidDeaths
where continent is not null 
Group By date
order by 1,2



-- 2. 
--Getting total deaths per continent

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidProjectDB..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.
--Getting population infection rates per country
Select location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidProjectDB..CovidDeaths
Group by location, population
order by PercentPopulationInfected desc


-- 4.
--Getting daily  change in infection count and population infection rate per country

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidProjectDB..CovidDeaths
Where continent is not null
Group by Location, Population, date
order by 1,3
