SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3,4

--Select *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data
SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths

ORDER BY 1,2


-- total Cases vs total deaths
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE LOCATION like '%zealand%'
ORDER BY 1,2

-- Total cases vs Population
SELECT Location, Date, total_cases, population, (total_cases/population)*100 AS CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE LOCATION like '%zealand%'
ORDER BY 1,2

-- Countries by infection rate vs Population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS CasePercentage
FROM PortfolioProject..CovidDeaths
-- WHERE LOCATION like '%zealand%'
GROUP BY Location, Population
ORDER BY CasePercentage DESC

-- Highest death total deaths per country
SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Highest death total deaths per continent 1.0
-- Some errors in the data, e.g North America does not include deaths from Canada
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
where  continent is not null 
--and location not like '%income'
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Highest death total deaths per continent 2.0
-- Using where continent is listed in the location column (by negatively filtering for nulls in continent column)
SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is null 
and location not like '%income'
and location not like 'World'
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Global Deaths as a % of Cases across time 
SELECT Date, SUM(new_cases) AS GlobalCases, SUM(cast(new_deaths as int)) AS GlobalDeaths, 
ROUND((SUM(cast(new_deaths as int))/(NULLIF(SUM(new_cases),0)))*100, 2) AS 'GlobalDeathsPerCases(%)'
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION like '%zealand%'
GROUP BY date
ORDER BY 1,2


-- Global Vaccinations Accumulative

SELECT DTHS.continent, DTHS.location, DTHS.date, DTHS.population, VACS.new_vaccinations
, SUM(cast(new_vaccinations AS float)) OVER (PARTITION BY DTHS.location ORDER BY DTHS.location, DTHS.date) AS AccumulativeTotalVacs
FROM PortfolioProject..CovidDeaths AS DTHS
JOIN PortfolioProject..CovidVaccinations as VACS
	ON DTHS.location = VACS.location
	and DTHS.date = VACS.date
WHERE DTHS.continent IS NOT NULL
--AND DTHS.location like 'Albania'
--AND VACS.new_vaccinations IS NOT NULL
ORDER BY 2,3


-- Global Vaccinations per capita using a CTE

WITH VacPerCapCTE (continent, location, date, population, new_vaccinations, AccumulativeTotalVacs)
AS
(
SELECT DTHS.continent, DTHS.location, DTHS.date, DTHS.population, VACS.new_vaccinations
, SUM(cast(new_vaccinations AS float)) OVER (PARTITION BY DTHS.location ORDER BY DTHS.location, DTHS.date) AS AccumulativeTotalVacs
FROM PortfolioProject..CovidDeaths AS DTHS
JOIN PortfolioProject..CovidVaccinations as VACS
	ON DTHS.location = VACS.location
	and DTHS.date = VACS.date
WHERE DTHS.continent IS NOT NULL
--AND DTHS.location like 'Albania'
AND VACS.new_vaccinations IS NOT NULL
--ORDER BY 2,3
)
SELECT*, ROUND((AccumulativeTotalVacs/population)*100, 3) AS 'Accumulative%'
FROM VacPerCapCTE





-- Global Vaccinations per capita using a Temp Table
DROP TABLE IF EXISTS #VacPerCapTemp
CREATE TABLE #VacPerCapTemp
(
continent nvarchar(255), 
location nvarchar(255), 
Date datetime,
population numeric,
new_vaccinations numeric,
AccumulativeTotalVacs float
)

INSERT INTO #VacPerCapTemp
SELECT DTHS.continent, DTHS.location, DTHS.date, DTHS.population, VACS.new_vaccinations
, SUM(cast(new_vaccinations AS float)) OVER (PARTITION BY DTHS.location ORDER BY DTHS.location, DTHS.date) AS AccumulativeTotalVacs
FROM PortfolioProject..CovidDeaths AS DTHS
JOIN PortfolioProject..CovidVaccinations as VACS
	ON DTHS.location = VACS.location
	and DTHS.date = VACS.date
WHERE DTHS.continent IS NOT NULL
--AND DTHS.location like 'Albania'
AND VACS.new_vaccinations IS NOT NULL

SELECT*, ROUND((AccumulativeTotalVacs/population)*100, 3) AS 'Accumulative%'
FROM #VacPerCapTemp


-- Create View for visualizations
DROP VIEW IF EXISTS VacPerCapView

CREATE VIEW VacPerCapView as
SELECT DTHS.continent, DTHS.location, DTHS.date, DTHS.population, VACS.new_vaccinations
, SUM(cast(new_vaccinations AS float)) OVER (PARTITION BY DTHS.location ORDER BY DTHS.location, DTHS.date) AS AccumulativeTotalVacs
FROM PortfolioProject..CovidDeaths AS DTHS
JOIN PortfolioProject..CovidVaccinations as VACS
	ON DTHS.location = VACS.location
	and DTHS.date = VACS.date
WHERE DTHS.continent IS NOT NULL
--AND DTHS.location like 'Albania'
--AND VACS.new_vaccinations IS NOT NULL

Select*
FROM VacPerCapView
-- Create more views
SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

