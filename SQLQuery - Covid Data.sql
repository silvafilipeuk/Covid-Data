-- Author: Filipe da Silva

USE [Covid]

GO


-- Looking at Total cases versus total deaths "Per Country"

SELECT Location, date, total_cases, total_deaths, FORMAT((convert(Decimal,total_deaths)/convert(decimal, total_cases))*100, 'N2') as PercentageOfDeaths
FROM [dbo].['owid-covid-data-deaths']
WHERE location LIKE '%United Kingdom%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, population, total_cases,  convert(Decimal,total_cases)/convert(decimal, population)*100 as 'Infection Percentage'
FROM [dbo].['owid-covid-data-deaths']
WHERE location LIKE '%United Kingdom%'
ORDER BY 1,2



-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) as 'Highest Infection Count', convert(Decimal,MAX(total_cases))/convert(decimal, population)*100 as 'Infection Percentage'
FROM [dbo].['owid-covid-data-deaths']
GROUP BY Location, Population
ORDER BY 'Infection Percentage' DESC


-- Showing the Countries with Highest death count
SELECT Location, MAX(cast(total_deaths as int)) as 'Total death Count'
FROM [dbo].['owid-covid-data-deaths']
WHERE Continent is not NULL
GROUP BY Location
ORDER BY 'Total death Count' DESC


-- Showing the Continents with Highest death count
SELECT continent, MAX(cast(total_deaths as int)) as 'Total death Count'
FROM [dbo].['owid-covid-data-deaths']
WHERE Continent is not NULL
GROUP BY continent
ORDER BY 'Total death Count' DESC


-- GLOBAL NUMBERS

-- New cases and deaths daily with percentage
SELECT date, SUM(new_cases) as 'new_cases',  SUM(cast(new_deaths as int)) as 'new_deaths', SUM(cast(new_deaths as int))/nullif(SUM(new_cases),0)*100 as "daily_death_percentage"
FROM [dbo].['owid-covid-data-deaths']
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Totals for the world
SELECT SUM(new_cases) as 'cases',  SUM(cast(new_deaths as int)) as 'deaths', SUM(cast(new_deaths as int))/nullif(SUM(new_cases),0)*100 as "death_percentage"
FROM [dbo].['owid-covid-data-deaths']
WHERE continent is not null
ORDER BY 1,2


-- Looking at Total population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location Order BY dea.location, dea.date) as RollingPeopleVaccinated,
FROM [dbo].['owid-covid-data-deaths'] as dea
JOIN dbo.['owid-covid-data-vaccinations'] as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
ORDER BY 1,2,3


-- Percentage of people vaccinated over time per country using CTE
WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location Order BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [dbo].['owid-covid-data-deaths'] as dea
JOIN dbo.['owid-covid-data-vaccinations'] as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/population)*100 as "Vaccinated_percentage"
from PopVsVac


-- Creating VIEWS to store data for later visualizations (Tableau / PowerBI)

--CREATE VIEW PercentPopulationVaccinated as
--select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
--SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location Order BY dea.location, dea.date) as RollingPeopleVaccinated
--FROM [dbo].['owid-covid-data-deaths'] as dea
--JOIN dbo.['owid-covid-data-vaccinations'] as vac
--	ON dea.location = vac.location
--	AND dea.date = vac.date
--where dea.continent is not null

--CREATE VIEW Covid_Totals as
--SELECT SUM(new_cases) as 'cases',  SUM(cast(new_deaths as int)) as 'deaths', SUM(cast(new_deaths as int))/nullif(SUM(new_cases),0)*100 as "death_percentage"
--FROM [dbo].['owid-covid-data-deaths']
--WHERE continent is not null

--CREATE VIEW Total_Vaccinations_Per_Country as 
SELECT Location, MAX(CAST(total_vaccinations as bigint)) as "Total_Vaccinations"
FROM [dbo].['owid-covid-data-vaccinations']
WHERE Continent is not NULL
GROUP BY Location

--CREATE VIEW Total_Deaths_Per_Country as
SELECT Location, MAX(CAST(total_deaths as int)) as 'Total_Deaths'
FROM [dbo].['owid-covid-data-deaths']
WHERE Continent is not NULL
GROUP BY Location

CREATE VIEW Total_Cases_Per_Country as
SELECT Location, MAX(CAST(total_cases as int)) as 'Total_Cases'
FROM ['owid-covid-data-deaths']
WHERE Continent is not NULL
GROUP BY Location