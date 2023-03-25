SELECT * 
FROM PortfolioProject..CovidDeaths
Where continent is not null
ORDER BY 3,4


--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

Select location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--Changing data type from nvarchar into float and date into datetime

Alter Table PortfolioProject..CovidDeaths
Alter Column total_deaths float

Alter Table PortfolioProject..CovidDeaths
Alter Column new_cases float

Alter Table PortfolioProject..CovidDeaths
Alter Column date datetime

--Query Covid Vaccinations

Select *
From PortfolioProject..CovidVaccinations

-- Gaining insights at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Order by 1,2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
WHERE location like '%Pakistan%'
and continent is not null
Order by 1,2

-- Gaining insights at Total Cases vs Population
-- Shows what percentage of poulation got Covid

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulation
From PortfolioProject..CovidDeaths
WHERE location like '%Pakistan%'
Order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location,population
Order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like %Pakistan%
Where continent is not null
Group by location
Order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT




-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Pakistan%'
Where continent is not null
Group by date
order by 1,2 -- This query gave me as error that divide by zero encountered 

-- Fixing the Query

Select 
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS INT)) AS total_deaths,
	CASE WHEN SUM(new_cases) = 0 THEN 0 ELSE SUM(CAST(new_deaths AS int)) / SUM(new_cases) END * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, vac.population, dea.new_vaccinations
, SUM(cast(dea.new_vaccinations as bigint)) OVER (Partition by dea.location) as TotalVaccinations
From PortfolioProject..CovidVaccinations dea
JOIN PortfolioProject..CovidDeaths vac 
	 ON dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
order by 2,3



-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, TotalVaccinations)
as
(

Select dea.continent, dea.location, dea.date, vac.population, dea.new_vaccinations
, SUM(cast(dea.new_vaccinations as bigint)) OVER (Partition by dea.location) as TotalVaccinations
From PortfolioProject..CovidVaccinations dea
JOIN PortfolioProject..CovidDeaths vac 
	 ON dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
)
Select *, (TotalVaccinations/population) * 100
From PopvsVac



-- TEMP Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalVaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, vac.population, dea.new_vaccinations
, SUM(cast(dea.new_vaccinations as bigint)) OVER (Partition by dea.location) as TotalVaccinations
From PortfolioProject..CovidVaccinations dea
JOIN PortfolioProject..CovidDeaths vac 
	 ON dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null

Select *, (TotalVaccinations/population) * 100 as PercentageP
From #PercentPopulationVaccinated


-- Creating View to Store Data for Later Visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, vac.population, dea.new_vaccinations
, SUM(cast(dea.new_vaccinations as bigint)) OVER (Partition by dea.location) as TotalVaccinations
From PortfolioProject..CovidVaccinations dea
JOIN PortfolioProject..CovidDeaths vac 
	 ON dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null


Select *
From PercentPopulationVaccinated