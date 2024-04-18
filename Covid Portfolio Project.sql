select *from coviddeath 
where continent is not null
order by 3,4;
-- select *from covidvaccinations order by 3,4;

-- select data that we are going to use
select location, date, total_cases , new_cases ,
total_deaths , population 
from coviddeath order by 1,2;

-- total cases vs total deaths
select location, date, total_cases ,
total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from coviddeath
where location LIKE '%ia%'
order by 1,2;

-- looking at the total cases vs population
-- shows what percentage of population got covid
select location, date,population , total_cases,
total_deaths,(total_cases/population)*100 as AffectedPercentage
from coviddeath
-- where location LIKE '%ia%'
order by 1,2;


-- highest infected country
select location, population ,max(total_cases) as maximumInfected,
Max(total_cases/population)*100 as InfectedPopulationPercentage
from coviddeath
group by population, location  
order by infectedPopulationPercentage desc;

-- country with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from coviddeath
where continent is not null
group by location  
order by TotalDeathCount desc;

-- LET'S BREAK THINGS DOWN BY CONTINENT
select continent , max(cast(total_deaths as int)) as TotalDeathCount
from coviddeath
where continent is not null
group by continent  
order by TotalDeathCount desc;

-- IF THE DATA WAS WHOLE

select location , max(cast(total_deaths as int)) as TotalDeathCount
from coviddeath
where continent is null
group by location  
order by TotalDeathCount desc;


-- Showing the continents with the highest death count

select continent  , max(cast(total_deaths as int)) as TotalDeathCount
from coviddeath
where continent is not null
group by continent  
order by TotalDeathCount desc;

-- GLOBAL NUMBERS

select sum(new_cases) as TotalCases, 
SUM(new_deaths) as TotalDeaths,
sum(new_deaths)/sum(new_cases)*100 as DeathPercentage 
-- total_cases, total_deaths,
-- (total_deaths/total_cases)*100 as Deathpercentage
from coviddeath
where continent is not null
-- group by date
order by 1,2

-- OPERATIONS ON NEW TABLE
select *
from covidvaccinations;

select *from coviddeath as dea
join covidvaccinations as vac
on dea.location = vac.location
and dea.date = vac.date;


-- Looking at total pop vs vaccinations
select dea.continent ,dea.location, dea.date, dea.population,
vac.new_vaccinations,
SUM(vac.new_vaccinations) over (partition by dea.location)
from coviddeath as dea
join covidvaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
order by 2,3;

-- USE CTE
with PopvsVac (Continent, Location, date, Population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent ,dea.location, dea.date, dea.population,
vac.new_vaccinations,
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from coviddeath as dea
join covidvaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3;
)
select * , (RollingPeopleVaccinated/Population)*100
from popvsVac


-- temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent ,dea.location, dea.date, dea.population,
vac.new_vaccinations,
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from coviddeath as dea
join covidvaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null 


select * , (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



