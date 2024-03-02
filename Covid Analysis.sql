select * 
From [Portfolio Project].[dbo].[CovidDeaths]
where continent is not null
Order by 3, 4


select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project].[dbo].[CovidDeaths]
where continent is not null
Order by 1,2

-- Total cases vs Total Deaths to show possibility of death based on location
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project].[dbo].[CovidDeaths]
Where location like '%Kingdom%' 
And continent is not null
Order by 1,2

--Total cases Vs Population to show the percentage of population with covid
select location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
From [Portfolio Project].[dbo].[CovidDeaths]
--Where location like '%Kingdom%'
where continent is not null
Order by 1,2

--countries with highest covid rate
select location, MAX(total_cases) as HighestInfection, population, MAX((total_cases/population))*100 as InfectedPopulationPercentage
From [Portfolio Project].[dbo].[CovidDeaths]
--Where location like '%Kingdom%'
where continent is not null
Group by location, population
Order by InfectedPopulationPercentage desc

-- countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as HighestDeathCount, population, MAX((total_deaths/population))*100 as DeathPercentage
From [Portfolio Project].[dbo].[CovidDeaths]
--Where location like '%Kingdom%'
where continent is not null
Group by location, population
Order by DeathPercentage desc

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project].[dbo].[CovidDeaths]
--Where location like '%Kingdom%'
where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Continents with highest death count 
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project].[dbo].[CovidDeaths]
--Where location like '%Kingdom%'
where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Global Numbers
select Sum(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/ sum(new_cases)*100 as DeathPercentage
From [Portfolio Project].[dbo].[CovidDeaths]
--Where location like '%Kingdom%' 
Where continent is not null
--Group by date
Order by 1,2



select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project].[dbo].[CovidDeaths] as dea
Join [Portfolio Project].[dbo].[CovidVaccination] as vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
	and dea.location = 'Albania'
order by 2,3

--Using CTE

With PopVaccinated (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project].[dbo].[CovidDeaths] as dea
Join [Portfolio Project].[dbo].[CovidVaccination] as vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 as Percentage
From PopVaccinated

--Temp Table

DROP TABLE if exists  #PercentpopulationVaccinated 
Create Table #PercentpopulationVaccinated 
(continent nvarchar(255), 
location nvarchar(255), 
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentpopulationVaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project].[dbo].[CovidDeaths] as dea
Join [Portfolio Project].[dbo].[CovidVaccination] as vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100 as Percentage
FROM #PercentpopulationVaccinated  

--View for visualization 

Create View populationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project].[dbo].[CovidDeaths] as dea
Join [Portfolio Project].[dbo].[CovidVaccination] as vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

select *
from populationVaccinated