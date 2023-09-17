SELECT * FROM PortfolioProyect1..['CovidDeaths']
ORDER BY 3,4

--SELECT * FROM PortfolioProyect1..['CovidVaccinations']
--ORDER BY 3,4

--SELECT DATA THAT WE ARE GOING TO BE USING
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProyect1..['CovidDeaths']
ORDER BY 1,2
--Looking at total cases VS total deaths. 
--Calculation of Death Percentage according to Country
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProyect1..['CovidDeaths']
WHERE location='Argentina'
ORDER BY 1,2

--Looking at Total Cases VS Population
SELECT location, date, population, total_cases,(total_cases/population)*100 as InfectionRate
FROM PortfolioProyect1..['CovidDeaths']
ORDER BY 1,2

--Comparing Countries with highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 as InfectionRate
FROM PortfolioProyect1..['CovidDeaths']
GROUP BY location, population
ORDER BY InfectionRate desc

--Highest Death Count per population
SELECT location, MAX(total_deaths) AS TotalDeathsCount
FROM PortfolioProyect1..['CovidDeaths']
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathsCount desc

--Continents with the highest death count per population
SELECT continent, MAX(total_deaths) AS TotalDeathsCount
FROM PortfolioProyect1..['CovidDeaths']
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathsCount desc

--Global numbers by date
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/nullif(SUM(new_cases),0)*100 as DeathPercentage
FROM PortfolioProyect1..['CovidDeaths']
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Total global numbers
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/nullif(SUM(new_cases),0)*100 as DeathPercentage
FROM PortfolioProyect1..['CovidDeaths']
WHERE continent is not null
ORDER BY 1,2

--Vaccinations
Select * FROM PortfolioProyect1..['CovidVaccinations']

--Tables join
Select * FROM PortfolioProyect1..['CovidVaccinations'] vac
JOIN PortfolioProyect1..['CovidDeaths'] dea
ON dea.location=vac.location
AND dea.date=vac.date

--Total vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as float) ) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProyect1..['CovidVaccinations'] vac
JOIN PortfolioProyect1..['CovidDeaths'] dea
ON dea.location=vac.location
AND dea.date=vac.date
where dea.continent is not null
ORDER BY 1,2,3

--USE CTE
WITH PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
AS(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProyect1..['CovidVaccinations'] vac
JOIN PortfolioProyect1..['CovidDeaths'] dea
ON dea.location=vac.location
AND dea.date=vac.date
where dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationvaccinated
CREATE TABLE #PercentPopulationvaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations nvarchar(255),
RollingPeopleVaccinated numeric)
INSERT INTO #PercentPopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProyect1..['CovidVaccinations'] vac
JOIN PortfolioProyect1..['CovidDeaths'] dea
ON dea.location=vac.location
AND dea.date=vac.date
--where dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationvaccinated

--Creating view to store data for later visualization
CREATE VIEW PercentPopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProyect1..['CovidVaccinations'] vac
JOIN PortfolioProyect1..['CovidDeaths'] dea
ON dea.location=vac.location
AND dea.date=vac.date
where dea.continent is not null

SELECT * FROM PercentPopulationvaccinated

/*

Queries used for Tableau Project

*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProyect1..['CovidDeaths']
-- location like '%states%'
Where continent is not null 
--Group By date
order by 1,2


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProyect1..['CovidDeaths']
--Where location like '%states%'
where location = 'World'
----Group By date
order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProyect1..['CovidDeaths']
--Where location like '%states%'
Where continent is not null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProyect1..['CovidDeaths']
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProyect1..['CovidDeaths']
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc




-- 1.

Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProyect1..['CovidDeaths'] dea
Join PortfolioProyect1..['CovidVaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3

-- 2.
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProyect1..['CovidDeaths']
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProyect1..['CovidDeaths']
----Where location like '%states%'
where location = 'World'
----Group By date
order by 1,2


-- 3.

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProyect1..['CovidDeaths']
--Where location like '%states%'
Where continent is not null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 4.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProyect1..['CovidDeaths']
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc



-- 5.

--Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where continent is not null 
--order by 1,2

-- took the above query and added population
Select Location, date, population, total_cases, total_deaths
From PortfolioProyect1..['CovidDeaths']
--Where location like '%states%'
where continent is not null 
order by 1,2


-- 6. 

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProyect1..['CovidDeaths']
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc



