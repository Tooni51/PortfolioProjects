SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2
--looking at Total Cases vs Total Deaths
--SELECT location, date, total_cases,total_deaths,(total_deaths/total_cases)
--FROM PortfolioProject..CovidDeaths
--ORDER BY 1,2

-- This shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases,total_deaths,
(CONVERT(FLOAT,total_deaths)/
NULLIF(CONVERT(FLOAT,total_cases),0))*100 AS Deathpercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%States%'
ORDER BY 1,2

--Looking at the Total Cases vs Population
SELECT location, date, population, total_cases,
(CONVERT(FLOAT,total_cases)/
NULLIF(CONVERT(FLOAT,population),0))*100 AS PercentageinfectedPopulation
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%States%'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate Compared to Population
SELECT location, population, MAX(total_cases)AS HighestInfectionCount,
MAX((CONVERT(FLOAT,total_cases)/
NULLIF(CONVERT(FLOAT,population),0)))*100 AS PercentageinfectedPopulation
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%States%'
GROUP BY location, population
ORDER BY PercentageinfectedPopulation DESC

-- Showing Countries with the Highest Death Count per Population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--Breaking It Down By Continent
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC
--OR
--Breaking Down Generally
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Global Numbers


SELECT SUM(new_cases) AS total_cases,CONVERT(FLOAT,SUM(new_deaths)) AS total_deaths,
CONVERT(FLOAT,SUM(new_deaths))/
NULLIF(CONVERT(FLOAT,SUM(new_cases)),0) *100 AS Deathpercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%States%'
WHERE continent IS NOT NULL
ORDER BY 1,2

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(CONVERT (DECIMAL,new_deaths))/ SUM(CONVERT(DECIMAL,new_cases))*100
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
 
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths
--SELECT SUM(CONVERT(float,new_deaths)/ SUM(CONVERT(float,new_cases)
FROM PortfolioProject..CovidDeaths


--Looking at Total Population vs Vaccination

SELECT dea.continent,dea.location,dea.date,population,vac.new_vaccinations, SUM (vac.new_vaccinations) 
OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS cumm_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--Using A CTE

WITH PopvsVac(Continent,Location,Date,Population, New_vaccinations, Cumm_people_vaccinated)
AS
(
SELECT dea.continent,dea.location,vac.date,dea.population,vac.new_vaccinations
,SUM (CONVERT(DECIMAL,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS cumm_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
)
SELECT * , (Cumm_people_vaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
cumm_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,population,vac.new_vaccinations, SUM (vac.new_vaccinations) 
OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS cumm_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * , (Cumm_people_vaccinated/Population)*100
FROM #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR VISUALIZATIONS
--NUMBER 1
DROP VIEW IF EXISTS PercentPopulationVaccinated


CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,dea.location,dea.date,population,vac.new_vaccinations, SUM (vac.new_vaccinations) 
OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS cumm_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated

--NUMBER 2
DROP VIEW IF EXISTS DeathPercentage

CREATE VIEW DeathPercentage AS

SELECT location, date, population, total_cases,
(CONVERT(FLOAT,total_cases)/
NULLIF(CONVERT(FLOAT,population),0))*100 AS PercentageinfectedPopulation
FROM PortfolioProject..CovidDeaths
