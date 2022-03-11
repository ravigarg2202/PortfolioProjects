
									-- COVID DEATHS DATASET



SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT * 
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4

--Select data that I am going to be using

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at total cases vs total deaths
-- Likelihood of dying if you contract Covid in your country

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Canada%' AND continent IS NOT NULL
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of Population got Covid infection

SELECT location,date,Population,total_cases,(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Canada%' AND continent IS NOT NULL
ORDER BY 1,2


--Looking at countries with Highest Infection rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing the countries with Highest Deaths per capita

SELECT location,population, MAX(CAST(total_deaths AS int)) AS TotalDeathCount,MAX(CAST(total_deaths AS int)/Population)*100 AS PercentPopulationDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY PercentPopulationDeaths DESC

	--Let's BREAK THINGS DOWN BY CONTINETS

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC
--Alternate
SELECT continent, SUM(TotalDeathCount) AS TotalDeathCount
FROM (SELECT location,continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,continent) as a
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Showing the continents with the highest death count per population

SELECT location,population, MAX(CAST(total_deaths AS int)) AS TotalDeathCount, MAX(CAST(total_deaths AS int)/Population)*100 AS PercentPopulationDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location,population
ORDER BY PercentPopulationDeaths DESC

-- GLOBAL NUMBERS

--Total global numbers till now
SELECT SUM(DISTINCT(Population)) AS Total_Population,SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL

--Global cases per Day
SELECT date,SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1


								
											-- COVID VACCINATIONS DATASET

-- Lookin at Total Population vs Total Vaccinations

SELECT dea.continent,dea.location,dea.date,population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,               --bigint
dea.date) AS RollingTotalVaccinations
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--USING CTE (Total Vaccinations and Vaccinations per Hundred people)

WITH popvsvac 
AS
(
SELECT dea.continent,dea.location,dea.date,population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,               --bigint
dea.date) AS RollingTotalVaccinations
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *,(RollingTotalVaccinations/population)*100 AS Vaccination_Per_Hundred_people
FROM popvsvac 
ORDER BY 2,3


--USING Temp Table (Total Vaccinations and Vaccinations per Hundred people)

DROP TABLE IF EXISTS #Vaccination_Per_Hundred_people
CREATE TABLE #Vaccination_Per_Hundred_people
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingTotalVaccinations numeric
)

INSERT INTO #Vaccination_Per_Hundred_people
SELECT dea.continent,dea.location,dea.date,population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,               --bigint
dea.date) AS RollingTotalVaccinations
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingTotalVaccinations/Population)*100 AS Vaccination_Per_Hundred_people
FROM #Vaccination_Per_Hundred_people
ORDER BY Location,Date;


--Creating view to store data for later visualizations

CREATE VIEW Vaccination_Per_Hundred_People AS
SELECT dea.continent,dea.location,dea.date,population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,               --bigint
dea.date) AS RollingTotalVaccinations
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * 
FROM Vaccination_Per_Hundred_People