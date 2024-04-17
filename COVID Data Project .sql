SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT Location, Date, Total_cases, New_cases, Total_deaths, Population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (cast(total_deaths as int)/cast(total_cases as int))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%states%'
ORDER BY 1,2 


-- Looking at total cases VS population, shows what percentage of people got covid


SELECT location, date, total_cases, population, (total_cases/population) *100 AS CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%states%'
ORDER BY 1,2 



-- Looking at countries with the highest infection rate compared to population

SELECT Location, MAX(total_cases) AS HighestInfectionCount, Population, MAX((Total_cases/Population)) AS PercentageOfPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentageOfPopulationInfected DESC


-- Showing countries with the highest death count per population


SELECT Location, MAX(Cast(total_deaths AS INT)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- Showing continents with the highest death count

SELECT Continent, MAX(Cast(total_deaths AS INT)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC


-- Global numbers

SELECT Date, SUM(New_cases) AS TotalCases, SUM(CAST(New_deaths AS INT)), SUM(CAST(New_deaths AS INT))/SUM(New_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Date
ORDER BY 1,2




-- Looking at total population VS vaccinations

SELECT * 
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.Location = VAC.Location
	AND DEA.Date = VAC.Date




 
SELECT DEA.continent, DEA.Location, DEA.Date, DEA.Population, VAC.new_vaccinations, SUM(CONVERT(INT, VAC.new_vaccinations)) OVER (PARTITION BY DEA.Location) AS RollingVACCount,
(RollingVACCount/Population)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.Location = VAC.Location
	AND DEA.Date = VAC.Date
WHERE DEA.Continent IS NOT NULL
ORDER BY 2,3



--USE CTE

WITH PopVSVac (Continent, Location, Date, Population, New_vaccinations, RollingVACCount)
AS
(
SELECT DEA.continent, DEA.Location, DEA.Date, DEA.Population, VAC.new_vaccinations, SUM(CONVERT(INT, VAC.new_vaccinations)) OVER (PARTITION BY DEA.Location) AS RollingVACCount
--(RollingVACCount/Population)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.Location = VAC.Location
	AND DEA.Date = VAC.Date
WHERE DEA.Continent IS NOT NULL
)
SELECT *, (RollingVACCount/Population)*100 
FROM PopVSVac



-- Creating view to store data for later visulisations 

CREATE VIEW PercentPopulationVaccinated AS
SELECT DEA.continent, DEA.Location, DEA.Date, DEA.Population, VAC.new_vaccinations, SUM(CONVERT(INT, VAC.new_vaccinations)) OVER (PARTITION BY DEA.Location) AS RollingVACCount
--(RollingVACCount/Population)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.Location = VAC.Location
	AND DEA.Date = VAC.Date
WHERE DEA.Continent IS NOT NULL


SELECT * FROM dbo.PercentPopulationVaccinated
