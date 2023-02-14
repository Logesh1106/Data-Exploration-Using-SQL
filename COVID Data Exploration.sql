use Portfolio

/*CHECK IF ALL THE DATA ARE IMPORTED */
select * from CovidDeaths
select * from CovidVaccinations

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths 
order by location,date


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location = 'india'
order by location,date

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
order by location,date

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
Where location = 'india'
order by location,date

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  
Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

Select Location,Population, MAX(total_cases) as HighestInfectionCount,  
Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Where location = 'india'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where location = 'india'
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population


Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is  not null 
Group by continent
order by TotalDeathCount desc


-- WORLD WIDE

Select SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 


Select date,SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
Group By date
order by date


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
From CovidDeaths cd
Join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
order by cd.location,cd.date

-- Using CTE to perform Calculation on Partition By in previous query

with cte as (Select cd.continent, cd.location, cd.date, cd.population as population, cv.new_vaccinations,
SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
From CovidDeaths cd
Join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null )
Select *, (RollingPeopleVaccinated/Population)*100
From cte


-- Creating View to store data for later visualizations

create view perpopulationvaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
From CovidDeaths cd
Join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null

select * from perpopulationvaccinated