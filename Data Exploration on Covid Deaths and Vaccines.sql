SELECT *
FROM PortfolioProject.dbo.CovidDeaths
--WHERE continent IS NOT NULL
ORDER BY 3,4 

---SELECT *
---FROM PortfolioProject.dbo.CovidVaccinations
---ORDER BY 3,4


------------------------------------------------------------------------------------------------
---Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2


---------------------------------------------------------------------------------------------------
-- Looking at total cases v total deaths
-- Shows likelihood of dying if you contract covid on your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2


---------------------------------------------------------------------------------------------------
-- Looking at the total cases V the population
-- Shows what percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2


---------------------------------------------------------------------------------------------------
-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
---WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


---------------------------------------------------------------------------------------------------
-- Showing countries with the highest Death count per population
SELECT location, MAX(CAST(Total_deaths AS INT) AS TotalDeathCount
---WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


---------------------------------------------------------------------------------------------------

--LETS BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(CAST(Total_deaths AS INT) AS TotalDeathCount
---WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


---------------------------------------------------------------------------------------------------
-- Showing the continents with the highest DeathCount per Population
SELECT continent, MAX(CAST(Total_deaths AS INT) AS TotalDeathCount
---WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


---------------------------------------------------------------------------------------------------
-- Global Numbers
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT) AS total_deaths, SUM(CAST(new_deaths AS INT)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths,
WHERE location LIKE '%states%',
AND continent IS NOT NULL,
GROUP BY date,
ORDER BY 1,2






---------------------------------------------------------------------------------------------------
--Looking at Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location) AS RollingPeopleVaccinated, 
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


---------------------------------------------------------------------------------------------------
--USE CTE
WITH PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location) AS RollingPeopleVaccinated, 
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population) *100
FROM PopvsVac






---------------------------------------------------------------------------------------------------
-- Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime
Population Numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location) AS RollingPeopleVaccinated, 
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population) *100
FROM #PercentPopulationVaccinated


---------------------------------------------------------------------------------------------------
-- Creating View to store data for later visualization
CREATE  VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location) AS RollingPeopleVaccinated, 
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3