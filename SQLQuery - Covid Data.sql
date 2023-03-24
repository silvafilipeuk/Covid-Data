USE [Covid]

GO
--SELECT *
--FROM [dbo].['owid-covid-data-deaths']

--GO

--SELECT *
--  FROM [dbo].['owid-covid-data-vaccinations']

--GO

--SELECT Location, date, total_cases, new_cases, total_deaths, population
--FROM [dbo].['owid-covid-data-deaths']
--ORDER BY 1,2


-- Looking at Total cases versus total deaths
SELECT Location, date, total_cases, total_deaths, (convert(Decimal,total_deaths)/convert(decimal, total_cases))*100 as PercentageOfDeaths
FROM [dbo].['owid-covid-data-deaths']
ORDER BY 1,2