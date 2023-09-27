select *
from Covid_Project..CovidDeaths$
where continent is not null
order by 3,4

--select *
--from Covid_Project..CovidVaccinations$
--order by 3,4

-- Data to be used

select location, date, total_cases, new_cases, total_deaths, population
from Covid_Project..CovidDeaths$
where continent is not null
order by 1,2

-- Total cases vs Total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Covid_Project..CovidDeaths$
where location like 'Yemen'
and continent is not null
order by 1,2

-- Total cases vs Population

select location, date, population, total_cases, (total_cases/population)*100 as InfectionRate
from Covid_Project..CovidDeaths$
where continent is not null
--where location like 'Yemen'
order by 1,2

-- Countries with highest infection rate compared to population

select location, population, max(total_cases) as total_Cases, max((total_cases/population))*100 as InfectionRate
from Covid_Project..CovidDeaths$
where continent is not null
--where location like 'Yemen'
group by location, population
order by InfectionRate desc

-- Countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as Total_Deaths
from Covid_Project..CovidDeaths$
where continent is not null
--where location like 'Yemen'
group by location
order by Total_Deaths desc

-- Continent vs Total Deaths

select location, MAX(cast(total_deaths as int)) as Total_Deaths
from Covid_Project..CovidDeaths$
where continent is null and location not like '%income' and location not in ('World', 'International')
--where location like 'Yemen'
group by location
order by Total_Deaths desc

-- Global Numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int)) / sum(new_cases)*100 as Death_percentage
from Covid_Project..CovidDeaths$
where continent is not null
group by date
order by 1,2

-- Joining Tables

select *
from Covid_Project..CovidDeaths$ dea
join Covid_Project..CovidVaccinations$ vac
   on dea.location = vac.location
   and dea.date = vac.date


-- Total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Covid_Project..CovidDeaths$ dea
join Covid_Project..CovidVaccinations$ vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Rolling Count

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Covid_Project..CovidDeaths$ dea
join Covid_Project..CovidVaccinations$ vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- 30 and 60 Days Rolling/Moving Average

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
AVG(convert(bigint, vac.new_vaccinations)) over( partition by dea.location order by dea.location, dea.date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS _30DaysRollAvg,
AVG(convert(bigint, vac.new_vaccinations)) over( partition by dea.location order by dea.location, dea.date ROWS BETWEEN 59 PRECEDING AND CURRENT ROW) AS _60DaysRollAvg
from Covid_Project..CovidDeaths$ dea
join Covid_Project..CovidVaccinations$ vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Covid_Project..CovidDeaths$ dea
join Covid_Project..CovidVaccinations$ vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/Population)*100 as Vaccination_Percentage
from PopvsVac

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Covid_Project..CovidDeaths$ dea
join Covid_Project..CovidVaccinations$ vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 as Vaccination_Percentage
from #PercentPopulationVaccinated

-- Creating Views for Visualization

Create View PercentPopulationVaccinatedView as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Covid_Project..CovidDeaths$ dea
join Covid_Project..CovidVaccinations$ vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinatedView