select *
from Portfolioproject..Coviddeaths
where continent is not null

select location, date, total_cases, new_cases, total_deaths, population
from Portfolioproject..Coviddeaths
order by 1,2
--Percentage of population that got covid

select location, date,Population, total_cases,(total_cases/population)*100 as DeathPercentage
from Portfolioproject..Coviddeaths
order by 1,2

--Countries with highest infection rates compared to population

select location,Population, max(total_cases) as highestinfectioncount,max((total_cases/population))*100 as PopulationPercentageInfected
from Portfolioproject..Coviddeaths
group by location,population
order by PopulationPercentageInfected desc

--Countries with highest death count per population

select location, max(total_deaths) as Totaldeathcount
from Portfolioproject..Coviddeaths
where continent is not null
group by location
order by Totaldeathcount desc

--by continent

select continent, max(total_deaths) as Totaldeathcount
from Portfolioproject..Coviddeaths
where continent is null
group by continent
order by Totaldeathcount desc

--Global numbers

select date,sum(new_cases) as total_cases,sum(new_deaths) as total_deaths,
CASE
        WHEN SUM(new_cases) > 0 THEN SUM(new_deaths) / SUM(new_cases) * 100
        ELSE 0 -- or NULL, depending on your preference
    END AS Deathpercentage
from Portfolioproject..Coviddeaths
where continent is not null
group by date
order by 1,2

select *
from Portfolioproject..Coviddeaths dea
join Portfolioproject..Covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date


--total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations1,
sum(convert(bigint,vac.new_vaccinations1)) over (partition by dea.location order by dea.location,dea.date)
as totalpeoplevaccinated 
from Portfolioproject..Coviddeaths dea
join Portfolioproject..Covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--CTE
with popvsvac(continent, location, date, population, new_vaccinations1, totalpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations1,
sum(convert(bigint,vac.new_vaccinations1)) over (partition by dea.location order by dea.location,dea.date)
as totalpeoplevaccinated 
from Portfolioproject..Coviddeaths dea
join Portfolioproject..Covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(totalpeoplevaccinated/population)*100
from popvsvac

--TEMP TABLE

create table #percentagepopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations1 numeric,
totalpeoplevaccinated numeric
)
insert into #percentagepopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations1,
sum(convert(bigint,vac.new_vaccinations1)) over (partition by dea.location order by dea.location,dea.date)
as totalpeoplevaccinated 
from Portfolioproject..Coviddeaths dea
join Portfolioproject..Covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
select *,(totalpeoplevaccinated/population)*100
from #percentagepopulationvaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

create view percentagepopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations1,
sum(convert(bigint,vac.new_vaccinations1)) over (partition by dea.location order by dea.location,dea.date)
as totalpeoplevaccinated 
from Portfolioproject..Coviddeaths dea
join Portfolioproject..Covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *
from percentagepopulationvaccinated






