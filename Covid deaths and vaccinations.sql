select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


-- Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, CAST(total_deaths as int)/CAST(total_cases as int)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%iceland%'
order by 1,2


-- Looking at total cases vs population
-- Shows what percentage of population got covid
select location, date, population, total_cases, CAST(total_cases as int)/(population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%iceland%'
order by 1,2 


-- Looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, 
	MAX(CAST(total_cases as int))/(population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%iceland%'
Group by location, population
order by PercentPopulationInfected desc

--Countries with highest death count per population

select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%iceland%'
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Break it down by continent

select CONTINENT, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%iceland%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Showing continents with highest death count per population

select CONTINENT, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%iceland%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global numbers 

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))
	/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date)
	as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Using CTE

With PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date)
	as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date)
	as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date)
	as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated








