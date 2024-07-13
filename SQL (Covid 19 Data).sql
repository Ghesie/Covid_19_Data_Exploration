SELECT *
FROM PortfolioProject..CovidDeaths$
ORDER BY 3, 4

SELECT *
FROM PortfolioProject..CovidVaccinations$
ORDER BY 3,4


SELECT continent, location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY continent, location, date

--Total cases vs Total deaths
--likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths,
(cast(total_deaths as decimal)/cast(total_cases as decimal))*100 as DeathPercentage

FROM PortfolioProject..CovidDeaths$
Where location like 'Phil%'

ORDER BY 1,2



--Total cases vs Population
--Shows the percentage of the population got covid

SELECT location, date, population, total_cases,
(cast(total_cases as decimal)/population)*100 as Percent_Population_Infected

FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
--Where location like 'Phil%'
ORDER BY 1,2


--Country with highest infection rate compared to population

SELECT continent, location, population, MAX(total_cases) as Highest_Infection_Count,
MAX((cast(total_cases as decimal)/population))*100 as Percent_Population_Infected

FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent, location, population
ORDER BY Percent_Population_Infected DESC


--Showing Countries with highest death count per population


SELECT continent, location, MAX(cast(total_deaths as decimal)) as Highest_Death_Count

FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent, location
ORDER BY Highest_Death_Count DESC


--Breaking things down by continent / country

SELECT continent, location, MAX(cast(total_deaths as decimal)) as Highest_Death_Count

FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent, location
ORDER BY Highest_Death_Count DESC


--Showing the continents with highest death counts

SELECT continent, MAX(cast(total_deaths as decimal)) as Highest_Death_Count

FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY Highest_Death_Count DESC

--Global numbers

/* Tial code only
SELECT date, total_cases, total_deaths,
(cast(total_deaths as decimal)/cast(total_cases as decimal))*100 as DeathPercentage

FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY date, total_cases*/	
----------

--FOR NEW CASES
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as decimal)) as Sum_of_total_deaths,
SUM(cast(new_deaths as decimal)) / SUM(new_cases) * 100 as Death_Percentage

FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY date, total_cases

--FOR TOTAL CASES
SELECT date, SUM(total_cases) as total_cases, SUM(cast(total_deaths as decimal)) as total_deaths,
SUM(cast(total_deaths as decimal)) / SUM(total_cases) * 100 as Death_Percentage

FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY date, total_cases

/*SELECT date, total_cases, new_cases, total_deaths
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1, 2, 3*/


--LOOKING AT TOTAL POPULATION VS VACCINATIONS

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(cast(VAC.new_vaccinations as int)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) as Total_People_Vaccinated

FROM PortfolioProject..CovidDeaths$ as DEA
JOIN PortfolioProject..CovidVaccinations$ as VAC
	ON DEA.location = VAC.location AND DEA.date = VAC.date

WHERE DEA.continent is not null
ORDER BY 2,3 

--USING A CTE

WITH CTE_Population_VS_Vaccination AS
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(cast(VAC.new_vaccinations as int)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) as Total_People_Vaccinated

FROM PortfolioProject..CovidDeaths$ as DEA
JOIN PortfolioProject..CovidVaccinations$ as VAC
	ON DEA.location = VAC.location AND DEA.date = VAC.date

WHERE DEA.continent is not null and VAC.continent is not null
--ORDER BY 2,3
)

SELECT *, (Total_People_Vaccinated / population)*100 as Percentage_Vaccination
FROM CTE_Population_VS_Vaccination
ORDER BY 2,3


--USING TEMP TABLE
DROP TABLE IF EXISTS #Temp_Population_VS_Vaccination
CREATE TABLE #Temp_Population_VS_Vaccination
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population int,
new_vaccinations int,
Total_People_Vaccinated decimal
)

INSERT INTO #Temp_Population_VS_Vaccination
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(cast(VAC.new_vaccinations as int)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) as Total_People_Vaccinated

FROM PortfolioProject..CovidDeaths$ as DEA
JOIN PortfolioProject..CovidVaccinations$ as VAC
	ON DEA.location = VAC.location AND DEA.date = VAC.date

WHERE DEA.continent is not null and VAC.continent is not null

SELECT *, (Total_People_Vaccinated / population)*100 as Percentage_Vaccination
FROM #Temp_Population_VS_Vaccination
ORDER BY 2,3


--CREATING VIEW FOR DATA VISUALIZATIONS

CREATE VIEW Population_VS_Vaccination AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(cast(VAC.new_vaccinations as int)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) as Total_People_Vaccinated

FROM PortfolioProject..CovidDeaths$ as DEA
JOIN PortfolioProject..CovidVaccinations$ as VAC
	ON DEA.location = VAC.location AND DEA.date = VAC.date

WHERE DEA.continent is not null and VAC.continent is not null

SELECT *
FROM Population_VS_Vaccination
ORDER BY 2,3