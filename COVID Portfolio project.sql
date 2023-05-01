select *
from PortfolioProject1..CovidDeaths
where continent is not null
order by 3,4


-- Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject1..CovidDeaths
where continent is not null
order by 1,2

--Looking at total cases vs total deaths
-- Show likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
where location like '%states%' and  continent is not null
order by 1,2

--Looking at total cases vs population
--Show what percentage of population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject1..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population
Select location, population, max(total_cases) as HighesteInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject1..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population
Select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing the continent with the highest death count per population
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
Select   sum(new_cases) as total_cases ,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
where continent is not null
order by 1,2



--Loking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths as dea
join PortfolioProject1..CovidVaccinations as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3


--USE CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths as dea
join PortfolioProject1..CovidVaccinations as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
from PopvsVac

--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths as dea
join PortfolioProject1..CovidVaccinations as vac
	on dea.location=vac.location
	and dea.date=vac.date

Select *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated

--Creating view to store data for later visualizations
Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths as dea
join PortfolioProject1..CovidVaccinations as vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

Select *
from PercentPopulationVaccinated
