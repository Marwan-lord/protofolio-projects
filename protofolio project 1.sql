select *
from ['covid deathes$']
--where continent is not null
order by 3, 4


--select *
--from ['covid vaccinations$']
--order by 3, 4



select  location, date,total_cases, new_cases, total_deaths, population
from ['covid deathes$']
order by 1, 2

--Total Cases vs Total deaths

Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as  death_percentage
From ['covid deathes$']
where location like '%egy%'
order by 1,2


--countries with the highest infection count 

Select location, max(total_cases) as highest_infection_count , population, (max(total_cases )/ population )*100 as pecentage_of_population_infected 
From ['covid deathes$']
group by location, population
order by pecentage_of_population_infected desc



--countries with the highest death count

Select location, max(cast (total_deaths as int)) as total_death_count  
From ['covid deathes$']
where continent is not null
group by location
order by total_death_count desc

--continents with the highest death count 

Select continent, max(cast (total_deaths as int)) as total_death_count  
From ['covid deathes$']
where continent is not null
group by continent
order by total_death_count desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From ['covid deathes$']
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--total of people vaccinated

with PopvsVac(continent,location , date, population,new_vaccinations  ,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ['covid deathes$'] dea
Join ['covid vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100 
from PopvsVac



DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float
,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ['covid deathes$'] dea
Join ['covid vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--create view PercentPopulationVaccinated as
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(float
--,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
--From ['covid deathes$'] dea
--Join ['covid vaccinations$'] vac
--	On dea.location = vac.location
--	and dea.date = vac.date
----where dea.continent is not null 
----order by 2,3
