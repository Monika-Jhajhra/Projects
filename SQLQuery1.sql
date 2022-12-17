SELECT *
FROM dbo.covid_deaths
WHERE continent IS NOT NULL

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM dbo.covid_deaths
WHERE location LIKE '%india%'
ORDER BY 1,2

SELECT location, date, total_cases, population, (total_cases/population)*100 AS percent_population_infected
FROM dbo.covid_deaths
WHERE location LIKE '%india%'
ORDER BY 1,2
  
SELECT location,max(cast(total_deaths as int)) AS total_death_count
FROM dbo.covid_deaths
--WHERE location LIKE '%india%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count desc 


SELECT location,max(cast(total_deaths as int)) AS total_death_count
FROM dbo.covid_deaths
--WHERE location LIKE '%india%'
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count desc 


--BY CONTINENTS
SELECT continent,max(cast(total_deaths as int)) AS total_death_count
FROM dbo.covid_deaths
--WHERE location LIKE '%india%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count desc

--global number
SELECT SUM(new_cases)as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM dbo.covid_deaths
--WHERE location LIKE '%india%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--USE CTE
WITH pop_vs_vac (continent,location,date,population,new_vaccinations,rolling_people_vaccinated)
as
(
SELECT  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
FROM dbo.covid_deaths dea
    JOIN dbo.covid_vaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *,(rolling_people_vaccinated/population)*100 
FROM pop_vs_vac

--TEMP TABLE
DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
INSERT INTO #percent_population_vaccinated
SELECT  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
FROM dbo.covid_deaths dea
    JOIN dbo.covid_vaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT *
FROM #percent_population_vaccinated

--CREATING VIEW TO STORE DATA FOR VIZ
CREATE VIEW percent_population_vaccinated AS
(
SELECT  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
FROM dbo.covid_deaths dea
    JOIN dbo.covid_vaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *
FROM dbo.percent_population_vaccinated