/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
Data source: ourworldindata.org/coronavirus
*/

-- A look at the CovidDeaths table
Select *
From CovidProjectDB..CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with from CovidDeaths

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidProjectDB..CovidDeaths
Where continent is not null 
order by 1,2


-- Now we have a look at the daily change in the death rate in a country e.g: U.S.

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProjectDB..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2


-- A look at the daily change in global infections per country

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidProjectDB..CovidDeaths
Where continent is not null
order by 1,2


--  A look at each country's highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidProjectDB..CovidDeaths
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc


--Death count per country

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProjectDB..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Death count per continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProjectDB..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidProjectDB..CovidDeaths
where continent is not null 
order by 1,2



-- Joining CovidDeaths to CovidVaccinations on location and date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidProjectDB..CovidDeaths dea
Join CovidProjectDB..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By for rolling vaccination count and rate

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidProjectDB..CovidDeaths dea
Join CovidProjectDB..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 as VacRate
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidProjectDB..CovidDeaths dea
Join CovidProjectDB..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100 as VacRate
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidProjectDB..CovidDeaths dea
Join CovidProjectDB..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select* 
From CovidProjectDB..PercentPopulationVaccinated