select * from portfolio_project..CovidDeaths order by 3,4
select * from portfolio_project..CovidVaccinations order by 3,4

--select data to be used
select Location, date, total_cases, new_cases,total_deaths,population
from portfolio_project..CovidDeaths
order by 1,2

--total cases vs total deaths
select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from portfolio_project..CovidDeaths
where location='India'
order by 1,2


--total cases vs population
select Location, date, total_cases,population,(total_cases/population)*100 as CovidPercentage
from portfolio_project..CovidDeaths
where location='India'
order by 1,2

--comparing countries with high covid rates
select Location, max(total_cases) as HighestCovidRate,population,max((total_cases/population))*100 as CovidPercentage
from portfolio_project..CovidDeaths
group by Location,population
order by CovidPercentage desc

--countries with high death rates
--select Location, max(total_deaths) as HighestDeathRate
--from portfolio_project..CovidDeaths
--group by Location,population
--order by HighestDeathRate desc

--(cast total_deaths as int as it is nvarchar)+(no continents)
select Location, max(cast(total_deaths as int)) as HighestDeathRate
from portfolio_project..CovidDeaths
where continent is not null
group by Location
order by HighestDeathRate desc

--CONTINENT ANALYSIS-----------------------------------------------------------------------------------------

--continents with highest death count
select continent, max(cast(total_deaths as int)) as HighestDeathRate
from portfolio_project..CovidDeaths
where continent is not null
group by continent
order by HighestDeathRate desc

--GLOBAL NUMBERS

select  date, sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases) )*100 as deathPercentage
from portfolio_project..CovidDeaths
where continent is not null
group by date
order by 1,2


-----------------------------------------------------------------------------------------------------------------------------
--total population vs total vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as cumu_vaccination,
from portfolio_project..CovidDeaths dea
join portfolio_project..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--use cte
with PopulationvsVaccination (continent,location,date,population,new_vaccinations,cumu_vaccination)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as cumu_vaccination
from portfolio_project..CovidDeaths dea
join portfolio_project..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)

select *,(cumu_vaccination/population)*100 as percentage_cumu_vac
from PopulationvsVaccination


--temp table
drop table if exists #percentpopvacc
create table #percentpopvacc
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVacc numeric
)

insert into #percentpopvacc 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVacc
from portfolio_project..CovidDeaths dea
join portfolio_project..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null

select *,(RollingPeopleVacc/population)*100 as percentage_cumu_vac
from #percentpopvacc 


--CREATING VIEW

create view percentpopvacc as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVacc
from portfolio_project..CovidDeaths dea
join portfolio_project..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null


select *
from percentpopvacc