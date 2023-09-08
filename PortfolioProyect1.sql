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

--Grouped by Continent
SELECT continent, MAX(total_deaths) AS TotalDeathsCount
FROM PortfolioProyect1..['CovidDeaths']
GROUP BY continent
ORDER BY TotalDeathsCount desc

