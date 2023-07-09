
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
ORDER  BY 1,2

--Total cases vs Total Deaths 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
ORDER  BY 1,2

--Total cases vs Population in United States
-- Show percentage of people who contracted covid in the US

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM CovidProject..CovidDeaths
WHERE location like '%states%'
ORDER  BY 1,2

-- Highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM CovidProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER  BY PercentPopulationInfected DESC

-- Highest death rate 

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER  BY TotalDeathCount DESC

--Highest death rate by continent

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER  BY TotalDeathCount DESC

-- Daily total cases and deaths 

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentageGlobally 
FROM CovidProject..CovidDeaths
where continent is not null
GROUP BY date 
ORDER BY 1,2


--Total Population vs Vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) 
OVER 
	(PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac. date 
WHERE dea.continent is not null
ORDER BY 2,3



-- CTE (To find the daily percent of people vaccinated in each country)

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) 
OVER 
	(PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac. date 
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100 AS DailyVaccinationPercentage
FROM PopvsVac

-- Temp Table

CREATE TABLE #PercentPopulationVaccination
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) 
OVER 
	(PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac. date 
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccination








