select *
from Portfolioproject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from Portfolioproject..CovidVaccinations
--order by 3,4;

--Select Data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from Portfolioproject..CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from Portfolioproject..CovidDeaths
where location like '%india%'
and continent is not null
order by 1,2


--Looking at Total Cases vs population
--Show What Percentage of population got Covid

select location,date,population,total_cases,(total_cases/population)*100 as Percentpopulationinfected
from Portfolioproject..CovidDeaths
where location like '%india%'
order by 1,2


--Looking at Countries with Highest Infection Rate compared to population

select location,population,max(total_cases)as Highhestinfectioncount,max(total_cases/population)*100 as Percentpopulationinfected
from Portfolioproject..CovidDeaths
--where location like '%india%'
group by location,population
order by Percentpopulationinfected desc


--Showing Countries with Highest Death Count per population


select location,max(cast(total_deaths as int))as TotalDeathcount
from Portfolioproject..CovidDeaths
--where location like '%india%'
where continent is not null
group by location
order by TotalDeathcount desc


--Let's Break Down Things By Continent


--Showing continents with highest death count per populatin

select continent,max(cast(total_deaths as int))as TotalDeathcount
from Portfolioproject..CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
order by TotalDeathcount desc



--GLOBAL NUMBERR

select sum(new_cases),sum(cast(new_deaths as int)),sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from Portfolioproject..CovidDeaths
--where location like '%india%'
where continent is not null
--Group by date
order by 1,2


--Looking at total population vs Vaccinations

--USE CTE

with popvsVac (Continent,Location,Date,Population,New_vaccations,RollingpeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingpeopleVaccinated
--(RollingpeopleVaccinated/population)*100
from Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(RollingpeopleVaccinated/Population)*100
from PopvsVac


--TEMP TABLE

create table #PercentpopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingpeopleVaccinated numeric
)

Insert into #PercentpopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingpeopleVaccinated
--(RollingpeopleVaccinated/population)*100
from Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * ,(RollingpeopleVaccinated/Population)*100
from #PercentpopulationVaccinated


--Creating view to store data for later visulazations

create view PercentpopulationVaccin as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingpeopleVaccinated
--(RollingpeopleVaccinated/population)*100
from Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*
from PercentpopulationVaccin
