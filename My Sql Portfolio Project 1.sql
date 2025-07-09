Select * From PortfolioProject2..CovidDeaths
where continent is not null order by 3,4

--Select * From PortfolioProject2..CovidVaccinations order by 3,4

--Select Data that I will use

Select Location, date, total_cases, new_cases, total_deaths, population From PortfolioProject2..CovidDeaths order by 1,2

--Looking at Total cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage From PortfolioProject2..CovidDeaths
where location like 'United States' order by 1,2

--Looking at Total Cases vs Population

--Shows what % of people got Covid
Select Location, date, total_cases, population, (total_cases/population)*100 From PortfolioProject2..CovidDeaths
-- location like 'United States' 
order by 1,2

--Looking at countries with highest infection rate compared to population

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as 
PercentPopulationInfected From PortfolioProject2..CovidDeaths Group by location, population order by PercentPopulationInfected desc

--Showing Countries with the highest death count per population

Select location, Max(cast(Total_deaths as int)) as TotalDeathCount From PortfolioProject2..CovidDeaths
where continent is not null
Group by location
Order by TotalDeathCount desc

--Let's break things down by continent

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount From PortfolioProject2..CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global Numbers

Select Sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths, 
Sum(cast(new_deaths as int)) / sum(new_cases) as DeathPercentage 
From PortfolioProject2..CovidDeaths
--where location like 'United States'
where continent is not null
--Group by date
order by 1,2


--Looking at total pop vs vac

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) Over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject2..CovidDeaths dea
Join PortfolioProject2..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

with popvsvac (contintent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) Over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject2..CovidDeaths dea
Join PortfolioProject2..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population) from popvsvac


--Temp table

Drop Table if exists #percentpopulationvaccinated
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
, Sum(cast(vac.new_vaccinations as int)) Over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject2..CovidDeaths dea
Join PortfolioProject2..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated


--Create view for visualization

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) Over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject2..CovidDeaths dea
Join PortfolioProject2..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null


Select * from PercentPopulationVaccinated