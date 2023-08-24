select *
from [portfolio project ]..CovidDeaths$
order by 3,4

select *
from [portfolio project ]..CovidVaccinations$
order by 3,4

select location ,date,total_cases,new_cases, total_deaths, population
from [portfolio project ]..CovidDeaths$
order by 1,2 
 
 --looking at total cases , total deaths
 --shows liklihood of dying if covid contract at your country 
select location ,date,total_cases, total_deaths, (total_deaths/total_cases)*100  as DeathPercentage 
from [portfolio project ]..CovidDeaths$
where location like '%state%'
where continent is not null 
order by 1,2 

--looking at total cases vs population


select location ,date,total_cases, total_deaths,population , (total_cases/ population)*100  as  percentpopulationinfected
from [portfolio project ]..CovidDeaths$
where location like '%state%'
where continent is not null 
order by 1,2 

--looking to countries with highiest infected rate per population

select location ,population,max (total_cases) as hieghiestinfectedcount , max((total_cases/ population))*100  as percentpopulationinfected 
from [portfolio project ]..CovidDeaths$
--where location like '%state%'
--where location like'%egypt%'
where continent is not null 
Group by location ,population
order by  percentpopulationinfected desc

--showing countries with hieghest death count per population 

select location ,max (cast(total_deaths as int)) as hieghiestdeathcount 
from [portfolio project ]..CovidDeaths$
--where location like '%state%'
--where location like'%egypt%'
where  continent is not null 
Group by location 
order by  hieghiestdeathcount desc

--let's braek things down by continent 
--showing continents with highest deathcount per population 

select continent  ,max (cast(total_deaths as int)) as hieghiestdeathcount 
from [portfolio project ]..CovidDeaths$
--where location like '%state%'
--where location like'%egypt%'
where  continent is not null 
Group by continent
order by  hieghiestdeathcount desc

--GLOBAL Numbers 

select  date , sum(new_cases) as totalnewcases, sum(cast(new_deaths as int))as totalnewdeaths , (sum(cast(new_deaths as int))/ sum(new_cases))*100 as Deathpercentage

from [portfolio project ]..CovidDeaths$
where continent is not null 
group by date 
order by 2,3 desc

--death percentage allover the world

select  sum(new_cases) as totalnewcases, sum(cast(new_deaths as int))as totalnewdeaths , (sum(cast(new_deaths as int))/ sum(new_cases))*100 as Deathpercentage

from [portfolio project ]..CovidDeaths$
where continent is not null 
--group by date 
order by 2,3 desc


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent ,dea.location , dea.date , dea. population , vac.new_vaccinations , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population )*100    need to create CTE 
from [portfolio project ]..CovidDeaths$ dea
join [portfolio project ]..CovidVaccinations$ vac
   on dea.location = vac.location 
   and  dea.date = vac.date
where dea.continent is not null 
order by 2,3

--CREATE CTE 

with popvsvac (continent , location, date, population, new_vaccinations, RollingPeopleVaccinated )
as (select dea.continent ,dea.location , dea.date , dea. population , vac.new_vaccinations , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population )*100    need to create CTE 
from [portfolio project ]..CovidDeaths$ dea
join [portfolio project ]..CovidVaccinations$ vac
   on dea.location = vac.location 
   and  dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select*, (RollingPeopleVaccinated/population )*100
from popvsvac


--Temp table 
Drop table if exists  #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent ,dea.location , dea.date , dea. population , vac.new_vaccinations , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population )*100    need to create CTE 
from [portfolio project ]..CovidDeaths$ dea
join [portfolio project ]..CovidVaccinations$ vac
   on dea.location = vac.location 
   and  dea.date = vac.date
where dea.continent is not null 
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations


CREATE VIEW PercentPopulationVaccinated as
select dea.continent ,dea.location , dea.date , dea. population , vac.new_vaccinations , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population )*100    need to create CTE 
from [portfolio project ]..CovidDeaths$ dea
join [portfolio project ]..CovidVaccinations$ vac
   on dea.location = vac.location 
   and  dea.date = vac.date
where dea.continent is not null 