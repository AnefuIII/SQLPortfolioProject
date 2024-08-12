SELECT *
FROM CovidDeaths$
--ORDER BY 3,4

-- select data to use
SELECT location, date, new_cases, total_cases, total_deaths, population
FROM SQLPortfolio.dbo.CovidDeaths$
ORDER BY 1,2

-- Total cases vs total deaths
-- percentage of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 AS DeathPercentage
FROM SQLPortfolio.dbo.CovidDeaths$
--WHERE Location like '%state%'
ORDER BY 1,2

-- Total cases vs population
-- percentage of population that has covid
SELECT location, date, total_cases, total_deaths, (total_cases/population) *100 AS PopPercentage
FROM SQLPortfolio.dbo.CovidDeaths$
ORDER BY 1,2

--ALTER TABLE coviddeaths ALTER COLUMN total_deaths INT

--Countries with highest death count per population
SELECT location, MAX(Total_deaths) AS TotalDeaths
FROM CovidDeaths$
WHERE total_deaths IS NOT NULL
GROUP BY Location
ORDER BY totaldeaths DESC

-- BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(Total_deaths) AS TotalDeaths
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totaldeaths DESC

SELECT continent, population, MAX(Total_deaths) AS TotalDeaths
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent, population
ORDER BY totaldeaths DESC

-- GLOBAL NUMBERS
SELECT Date, SUM(new_cases) AS totalcases, SUM(CAST(new_deaths AS INT)) AS totaldeaths, SUM(CAST
(new_deaths AS INT))/SUM(new_cases) * 100 AS DEATHPERCENTAGE
FROM CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--TABLE 1
SELECT SUM(new_cases) AS totalcases, SUM(CAST(new_deaths AS INT)) AS totaldeaths, SUM(CAST
(new_deaths AS INT))/SUM(new_cases) * 100 AS DEATHPERCENTAGE
FROM CovidDeaths$
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- TABLE 2
SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
WHERE continent IS NULL
and location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount desc

-- TABLE 3 Countries with highest infection rate vs population
SELECT Location, population, MAX(total_cases) as highestinfectionCount, MAX((total_cases/population)) * 100 AS PercentagePopulationInfected
from CovidDeaths$
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC


-- TABLE 4 
SELECT Location, population, date, MAX(total_cases) as highestinfectionCount, MAX((total_cases/population)) * 100 AS PercentagePopulationInfected
from CovidDeaths$
GROUP BY location, population, date
ORDER BY PercentagePopulationInfected DESC


-- JOIN THE BOTH TABLES

--DROP TABLE Covvacpy$
SELECT total_vaccinations, new_vaccinations FROM Covvacpy
--WHERE new_vaccinations NOT LIKE '0'
SELECT * FROM CovidVaccinations$
SELECT * FROM Covvacpy

SELECT *
FROM SQLPortfolio..CovidDeaths$ dea
JOIN SQLPortfolio.. Covvacpy vac
ON dea.location = vac.location AND
dea.date = vac.date

-- total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.total_vaccinations
FROM SQLPortfolio..CovidDeaths$ dea
JOIN SQLPortfolio.. CovidVaccinations$ vac
ON dea.location = vac.location AND
dea.date = vac.date
--WHERE dea.continent IS NOT NULL AND vac.continent IS NOT NULL
WHERE vac.total_vaccinations IS NOT NULL
ORDER BY 2,3



SELECT continent, MAX(new_cases) AS MAXNEWCASE
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY MAXNEWCASE DESC

SELECT continent, location, MAX(new_cases)
FROM CovidDeaths
GROUP BY continent, location

SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY vac.Location order by dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE vac.continent IS NOT NULL --AND VAC.new_vaccinations IS NOT NULL
ORDER BY 2,3

--CTE

WITH PopvsVac ( continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY vac.Location order by dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE vac.continent IS NOT NULL --AND VAC.new_vaccinations IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population) * 100 as vacvspop FROM PopvsVac