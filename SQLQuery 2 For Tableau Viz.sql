-- FOR TABLEAU PROJECT


--Total Death Percentage


--Table 1

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as decimal)) as Sum_of_total_deaths, --inalis ung date
SUM(cast(new_deaths as decimal)) / SUM(new_cases) * 100 as Death_Percentage

FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
--GROUP BY date
ORDER BY total_cases


--Table 2

SELECT location, SUM(cast(new_deaths as int)) as Total_Death_Count
FROM PortfolioProject..CovidDeaths$

WHERE continent is null 
and location not in ('World', 'European Union', 'International')

GROUP BY location
ORDER BY Total_Death_Count DESC

--Table 3

SELECT location, population, MAX(total_cases) as Highest_Infection_Count,
MAX((cast(total_cases as decimal)/population))*100 as Percent_Population_Infected
FROM PortfolioProject..CovidDeaths$

GROUP BY location, population
ORDER BY Percent_Population_Infected DESC

--Table 4

SELECT location, population, date, MAX(total_cases) as Highest_Infection_Count,
MAX((cast(total_cases as decimal)/population))*100 as Percent_Population_Infected
FROM PortfolioProject..CovidDeaths$

GROUP BY location, population, date
ORDER BY Percent_Population_Infected DESC