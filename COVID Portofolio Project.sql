SELECT *
FROM PortofolioProject..CovidDeaths
ORDER BY 3,4


SELECT *
FROM PortofolioProject..CovidVaccinations
ORDER BY 3,4

--SELECT DATA THAT WE ARE GOING TO BE USING 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortofolioProject..CovidDeaths
ORDER BY 1,2

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS
-- shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE location like 'Indonesia'
ORDER BY 1,2

-- LOOKING AT TOTAL CASES VS POPULATION
-- SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID

SELECT location, date, population, total_cases, (total_cases/population)*100 AS CasesPercentageOfPopulation
FROM PortofolioProject..CovidDeaths
WHERE location like 'Indonesia'
ORDER BY 1,2

-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS CasesPercentageOfPopulationInfected
FROM PortofolioProject..CovidDeaths
--WHERE location like 'Indonesia'
GROUP BY location, population
ORDER BY CasesPercentageOfPopulationInfected desc

-- BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortofolioProject..CovidDeaths
--WHERE location like 'Indonesia'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortofolioProject..CovidDeaths
--WHERE location like 'Indonesia'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortofolioProject..CovidDeaths
--WHERE location like 'Indonesia'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2



--LOOKING AT TOTAL POPULATION VS VACCINATIONS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--USE CTE

WITH PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac



-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3



select *
from PercentPopulationVaccinated