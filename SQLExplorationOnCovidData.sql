select * from [dbo].['covid-death-data$']
where continent is not null
order by 3,4;

--select * from [dbo].['covidvaccination-data$']
where continent is not null
--order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population
from [dbo].['covid-death-data$']
where continent is not null
order by 1,2;

-- Considering the Total Cases Reported against Total Deaths Recorded
-- Represened in percentage to show the likelihood of dying if you contract covid. 

--select location, date, total_cases, total_deaths, cast(total_deaths as float)/ cast(total_cases as int)
--from [dbo].['covid-death-data$']
--where location like '%states%'
where continent is not null
--order by 1,2


select location, date, total_cases, total_deaths, (cast(total_deaths as float)/ total_cases) * 100 AS DeathPercentage
from [dbo].['covid-death-data$']
where location like '%states%'
and continent is not null
order by 1,2

--Cosidering the Total Cases Vs Population
-- Indicate the Percentage of the Population that was infected
select location, date, Population, total_cases, (cast(total_cases as float)/ Population) * 100 AS InfectionPercentage
from [dbo].['covid-death-data$']
where location like '%states%'
and continent is not null
order by 1,2

-- Considering Countries most infected 

select location, Population, MAX(total_cases) as MostInfectedCount, Max ((cast(total_cases as float)/ Population)) * 100 AS PopulationInfectedPercentage
from [dbo].['covid-death-data$']
where continent is not null
Group by location, population
order by 4 desc


--Countries with the Highest death count per population
select location, Max(cast(total_cases as float) )AS TotalDeathCount
from [dbo].['covid-death-data$']
where continent is not null
Group by location
order by 2 desc

-- A quick look at the continent 
select * from 
[dbo].['covid-death-data$']
where continent is null
order by 3

-- Continent with the Highest Death Count
select Continent, Max(cast(total_deaths as float) )AS TotalDeathCount
from [dbo].['covid-death-data$']
where continent is not null
Group by Continent
order by 2 desc

--Taking a global numeric view
Select date, sum(new_cases)	as TotalNewCases
from[dbo].['covid-death-data$']
where continent is not null
Group by date
order by 1,2

-- The global daily death percentage reported 
Select date, 
sum(new_cases)	as TotalNewCases, 
sum(new_deaths) as TotalDeaths,
sum(new_deaths)/NULLIF(sum(new_cases),0)* 100 as DeathPercentage
from [dbo].['covid-death-data$']
--where continent is null
--and new_cases =\ 0
Group by date
order by 1,2

Select date, 
sum(new_cases) as TotalNewCases, 
sum(new_deaths) as TotalDeaths,
(sum(new_deaths)*100)/NULLIF(sum(new_cases),0) as DeathPercentage
from [dbo].['covid-death-data$']
Group by date
order by 1,2

--To change the column datatype 
--Alter Table [dbo].['covid-death-data$']
--Alter Column total_deaths float

--Alter Table [dbo].['covid-death-data$']
--Alter Column new_deaths float

--What is the Total amount of people in the world that is Vaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [dbo].['covid-death-data$'] dea
join [dbo].['covidvaccination-data$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from [dbo].['covid-death-data$'] dea
join [dbo].['covidvaccination-data$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--select * from [dbo].['covidvaccination-data$']
-- Using CTE to know the percentage of people vaccinated per population of the country

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from [dbo].['covid-death-data$'] dea
join [dbo].['covidvaccination-data$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population) * 100 as PopulationVaccinatedPercentage
from PopVsVac;

--Using Temp Table #PercentofPopulationVaccinated
Drop Table if exists #PercentofPopulationVaccinated
Create Table #PercentofPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentofPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from [dbo].['covid-death-data$'] dea
join [dbo].['covidvaccination-data$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population) * 100 as PopulationVaccinatedPercentage
from #PercentofPopulationVaccinated;

--Let's  have a view of Total Death Count by Continent 
Create view 
PercentofPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from [dbo].['covid-death-data$'] dea
join [dbo].['covidvaccination-data$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null