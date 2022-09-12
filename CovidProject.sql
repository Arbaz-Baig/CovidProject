
Select *
From PortfolioProject..CovidDeaths
where location like '%income%'
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelyhood of dying if you get covid in your country

Select location,date,total_cases,new_cases,total_deaths,(total_deaths / total_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2

--Lookin at Total Cases vs Population
--Shows what percentage of population got covid

Select location, date, total_cases, population, (total_cases / population) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%India%'
order by 1,2

--Looking Countries with Highest Infection Rate compared to Population

Select location, population,max(total_cases) as HighestInfectionCount, MAX((total_cases / population)) * 100 as
PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%India%'
Group By location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count Per Population
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
Group By location
Order by TotalDeathCount desc

--Let's Breakdown by Continent


--Showing Continents with Highest death count by Continent

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%India%'
where continent is not null
Group By continent
Order by TotalDeathCount desc

--GLOBAL Numbers

Select  SUM(new_cases)as total_cases,sum(cast(new_deaths as int))as total_deaths,
sum(cast(new_deaths as int)) /SUM(new_cases)*100 as
DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%India%'
Where continent is not null
--Group by date
order by 1,2

--Looking at total population by Population

With PopvsVac  (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(cast(vaccine.new_vaccinations as bigint )) OVER (Partition BY death.location order by death.location,death.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
Where death.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--Temp Table

Drop table if exists #PersonPopulationVaccinated
create table #PersonPopulationVaccinated
(
Continent nvarchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingpeopleVaccinated numeric
)

Insert into #PersonPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(cast(vaccine.new_vaccinations as bigint )) OVER (Partition BY death.location order by death.location,death.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
--Where death.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PersonPopulationVaccinated

-- Create View to store data for later visualization 

Create View PersonPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(cast(vaccine.new_vaccinations as bigint )) OVER (Partition BY death.location order by death.location,death.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
Where death.continent is not null
--order by 2,3

Select * 
from PersonPopulationVaccinated
