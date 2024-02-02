select *
from PortfolioProject..CovidDeaths
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows liklihood of dying if you contract Covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2


-- Looking at Total Cases vs Population

select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2




-- Looking at Countries with Highest Infection rate compared to Population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by 4 desc


-- Looking at Countries with Highest Death count
-- 

select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc


-- Looking at Continents with Highest Death Count
-- Location represents continents better in the dataset

select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc


-- Global numbers by date

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, Sum(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where continent is not null
group by date
order by 1,2


-- Total Global Infection vs Death Rate

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, Sum(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Looking at Total Population vs Vaccinations 
-- Using CTE

WITH PopVsVac (Continent, Location, Date, Population, new_vaccinations, CurrentVaccinations) 
as
(

Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, SUM(cast(vacc.new_vaccinations as int)) over (partition by death.location order by death.location, death.date) as CurrentVaccinations
From PortfolioProject..CovidDeaths death
join PortfolioProject..CovidVaccinations vacc
	On death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
--order by 2,3
)

select *, (CurrentVaccinations/Population)*100 as VaccinatedPopPercentage
From PopVsVac


-- Using TEMP TABLE	

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255), location nvarchar(255), date datetime, population numeric, new_vaccinations numeric, CurrentVaccinations numeric
)


Insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, SUM(cast(vacc.new_vaccinations as int)) over (partition by death.location order by death.location, death.date) as CurrentVaccinations
From PortfolioProject..CovidDeaths death
join PortfolioProject..CovidVaccinations vacc
	On death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null



select *, (CurrentVaccinations/Population)*100 as VaccinatedPopPercentage
From #PercentPopulationVaccinated



-- Creating View to store date for later visualization

Create View PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, SUM(cast(vacc.new_vaccinations as int)) over (partition by death.location order by death.location, death.date) as CurrentVaccinations
From PortfolioProject..CovidDeaths death
join PortfolioProject..CovidVaccinations vacc
	On death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null







