Select * 
From PortfolioProjects..CovidDeaths
order by 3,4

--Select *
--From PortfolioProjects..CovidVaccinations
--order by 3,4

-- Selecting required Data

Select location, date, total_cases,new_cases, total_deaths, population
From PortfolioProjects..CovidDeaths
order by 1,2

-- Total cases  vs Total Deaths in India
-- what percentage of people died in respect to the infection
Select location, date, total_cases, total_deaths, (CAST(total_deaths as float)/ CAST( total_cases AS float)*100) as DeathPercentage
From PortfolioProjects..CovidDeaths
WHERE location like 'India'
order by 1,2


-- Total cases vs Population
-- shows percentage of population got covid

Select location, date, total_cases, Population, (cast (total_cases as float)/Population)*100  as PercentPopulationInfected
From PortfolioProjects..CovidDeaths
--where location like 'India'
order by 5 desc

--looking at countrieswith Highest Infection Rate compared to population

Select Location, Population, MAX(cast (total_cases as float)) as HighestInfectionCount, MAX((cast (total_cases as float)/Population)*100)  as PercentPopulationInfected
From PortfolioProjects..CovidDeaths
--where location like 'India'
group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select Location, Population, MAX(cast (total_deaths as float)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
--where location like 'India'
where continent is not NULL
group by location, population
order by TotalDeathCount desc

-- by continents
-- Continents with highest death count

Select continent, MAX (cast (total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Number

Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
-- Death percentage w.r.t new cases on that day. 
From PortfolioProjects..CovidDeaths
--where continent is not null and total_cases is not null
--group by date
ORDER BY DeathPercentage DESC



SELECT *
FROM PortfolioProjects..CovidVaccinations

-- Joining both table 

SELECT *
FROM PortfolioProjects..CovidDeaths dea 
JOIN PortfolioProjects..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date


--Total Population vs Vaccination data

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProjects..CovidDeaths dea 
	JOIN PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
and vac.new_vaccinations is not null
order by 2,3

--Cummulative vaccination data

-- using CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
( 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea Join PortfolioProjects..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 as cummulative_percentage
From PopvsVac



--using Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
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
, SUM(CONVERT (bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea Join PortfolioProjects..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating VIEW to store data for later visualization

Create View PercentPopulationVaccinatedview as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT (bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea Join PortfolioProjects..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
