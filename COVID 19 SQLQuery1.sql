SELECT *
FROM dbo.CovidDeaths
WHERE continent is not null
ORDER by 3,4

SELECT *
FROM dbo.CovidVaccinations
ORDER by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
ORDER by 1,2

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE location like '%States%'
ORDER by 1,2

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM dbo.CovidDeaths
WHERE location like '%States%'
ORDER by 1,2

SELECT Location, population, Max (total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 AS PercentPopulationInfected
FROM dbo.CovidDeaths
--WHERE location like '%States%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

SELECT Location, Max (cast(total_deaths as int)) AS TotalDeathCount
FROM dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

SELECT continent, Max (cast(total_deaths as int)) AS TotalDeathCount
FROM dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null
ORDER by 1,2

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is not null
--GROUP BY date
ORDER by 1,2

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100	
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = dea.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *
FROM PopvsVac

Drop Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100	
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = dea.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 
FROM #PercentPopulationVaccinated

CREATE VIEW
HighestInfections AS 
SELECT Location, population, Max (total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 AS PercentPopulationInfected
FROM dbo.CovidDeaths
WHERE location like '%States%'
GROUP BY Location, population
