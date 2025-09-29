select *
from [project 1]..CovidDeaths
where continent is not null
order by 3,4

--select *
--from [project 1]..CovidVaccinations
--order by 3,4

--select the data that we are going to use it
--show what percentage of population got covid
select location, date,population,total_cases,(total_deaths/total_cases)*100 as Death_percentage
from [project 1]..CovidDeaths
where continent is not null
--where location like '%states%'
order by 1,2

--looking for the the countries with the highest infectionrate compared to population
select location, population, max(total_cases) as HigheatInfectionCount,max(total_deaths/total_cases)*100 as percentpopulationinfected
from [project 1]..CovidDeaths
where continent is not null
--where location like '%states%'
group by location,population
order by PercentPopulationInfected desc

--showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotoalDeathCount
from [project 1]..CovidDeaths
where continent is not null
--where location like '%states%'
group by location,population
order by TotoalDeathCount desc


--let's break things down by continent

select continent, max(cast(total_deaths as int)) as TotoalDeathCount
from [project 1]..CovidDeaths
where continent is not null
--where location like '%states%'
group by continent
order by TotoalDeathCount desc

--showing continents with highest death count

select continent, max(cast(total_deaths as int)) as TotoalDeathCount
from [project 1]..CovidDeaths
where continent is not null
--where location like '%states%'
group by continent
order by TotoalDeathCount desc

--Global number

select sum(new_cases)as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [project 1]..CovidDeaths
where continent is not null
--group by date
--where location like '%states%'
order by 1,2

--looking at total population vs total vaccinationas

select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [project 1]..CovidDeaths dea
join [project 1]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE

with popvsvac (continent, location,date,population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [project 1]..CovidDeaths dea
join [project 1]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from popvsvac



--Temp Table
drop table if exists #Percentpopulationvaccinated
create table #Percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #Percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [project 1]..CovidDeaths dea
join [project 1]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #Percentpopulationvaccinated



--create view to store data for later visualization

create view Percentpopulationvaccinated as 
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [project 1]..CovidDeaths dea
join [project 1]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from Percentpopulationvaccinated