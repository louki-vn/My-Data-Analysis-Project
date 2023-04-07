
Select * 
from SQLDataAnalysisProject..CovidDeaths
where continent is not null
order by 3, 4


Select * 
from SQLDataAnalysisProject..CovidVaccinations
order by 3, 4


select location, date, total_cases, new_cases, total_deaths, population
from SQLDataAnalysisProject..CovidDeaths
order by 1, 2

ALTER TABLE SQLDataAnalysisProject..CovidDeaths
ALTER COLUMN total_cases float;
ALTER TABLE SQLDataAnalysisProject..CovidDeaths
ALTER COLUMN total_deaths float;


-- Total cases vs Total Deaths
select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
from SQLDataAnalysisProject..CovidDeaths
where location like '%states%'
order by 1, 2

-- Total cases vs Population, show percentage of population got covid
select location, date,  population, total_cases, (total_cases / population) * 100 as DeathPercentage
from SQLDataAnalysisProject..CovidDeaths
-- where location like '%states%'
order by 1, 2


-- Country with highest infection rate
select location,  population, max(total_cases) as HighestInfectionCount, max((total_cases / population) * 100) as PercentPopulationInfected
from SQLDataAnalysisProject..CovidDeaths
-- where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

-- Country with highest death count per population
select location, max(total_deaths) as TotalDeathCount
from SQLDataAnalysisProject..CovidDeaths
-- where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc

--Continent with highest death count
select continent, max(total_deaths) as TotalDeathCount
from SQLDataAnalysisProject..CovidDeaths
-- where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global number
select  sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths) / sum(new_cases) * 100 as DeathPercentage
from SQLDataAnalysisProject..CovidDeaths
-- where location like '%states%'
where continent is not null
-- group by date
order by 1, 2

-- Total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

with PopvsVac(Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated / Population) * 100
from PopvsVac


-- Temp table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From SQLDataAnalysisProject..CovidDeaths dea
Join SQLDataAnalysisProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
drop view if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLDataAnalysisProject..CovidDeaths dea
Join SQLDataAnalysisProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *
from PercentPopulationVaccinated