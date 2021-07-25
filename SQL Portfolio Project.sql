/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [Portfolioproject].[dbo].['Covid deaths$']
  WHERE continent is not null
  order by 3,4
  --SELECT *
  --FROM [Portfolioproject].[dbo].['Covid vaccination$']
  --order by 3,4

 -- Select data that we are going to be using

  SELECT location,date,total_cases,new_cases, total_deaths,population 
  FROM [Portfolioproject].[dbo].['Covid deaths$']
order by 1,2

-- Looking at total cases vs total deaths
-- Shows the likihood of ou getting infected by covit in your country
SELECT location,date,total_cases,total_deaths, (total_deaths/ total_cases)*100 AS DeathPercentage
  FROM [Portfolioproject].[dbo].['Covid deaths$']
  WHERE location LIKE 'Asia'
order by 1,2


--Looking at the total cases vs population
--Shows the what percentage of population got covid
SELECT location,date,total_cases,population, (total_cases/ population)*100 AS Covidpopulationpercent
  FROM [Portfolioproject].[dbo].['Covid deaths$']
  WHERE location LIKE 'Asia'
  ORDER BY 1,2

  --Looking for countries with highest infection rate
SELECT location,population, MAX (total_cases) AS HighestinfectionCount, MAX ((total_cases/ population))*100 AS Covidpopulationpercent
  FROM [Portfolioproject].[dbo].['Covid deaths$']
  --WHERE location LIKE 'Asia'
  GROUP BY location, population 
  ORDER BY  Covidpopulationpercent desc

  --Showing countries with highet death counts per Population
 SELECT location, MAX (cast (total_deaths AS int)) AS TotalDeathCount
  FROM [Portfolioproject].[dbo].['Covid deaths$']
  --WHERE location LIKE 'Asia'
  WHERE continent is not null
  GROUP BY location
  ORDER BY TotalDeathCount  desc



  --LET'S BREAK THINGS ACCORDING TO CONTINENTS

  -- Showing continents with highest death count per population

    SELECT location, MAX (cast (total_deaths AS int)) AS TotalDeathCount
  FROM [Portfolioproject].[dbo].['Covid deaths$']
  --WHERE location LIKE 'Asia'
  WHERE continent is null
  GROUP BY location
  ORDER BY TotalDeathCount  desc

  -- Global Numbers
  SELECT SUM (new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM (new_cases) *100 as DeathPercentage
  FROM [Portfolioproject].[dbo].['Covid deaths$']
 -- WHERE location LIKE 'Asia'
 WHERE continent is not null
 --GROUP BY date
  ORDER BY 1,2

  SELECT * 
  FROM Portfolioproject..['Covid vaccination$']

  -- Looking at total population vs Vaccination

  SELECT dea.continent, dea.location, dea.date , vac.new_vaccinations
  ,SUM (Cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
  FROM Portfolioproject..['Covid deaths$'] dea
  JOIN Portfolioproject..['Covid vaccination$'] vac
 ON dea.location = vac.location 
 AND dea.date = vac.date
 WHERE dea.continent is not null
 ORDER BY 1,2,3

 --Use CTE
 With PopvsVac(continent,location,date,population,New_vaccinations,RollingPeopleVaccinated)
 as 
 (
 SELECT dea.continent, dea.location, dea.date , vac.new_vaccinations
  ,SUM (Cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
  FROM Portfolioproject..['Covid deaths$'] dea
  JOIN Portfolioproject..['Covid vaccination$'] vac
 ON dea.location = vac.location 
 AND dea.date = vac.date
 WHERE dea.continent is not null
 --ORDER BY 1,2,3
 )
 SELECT *, (RollingPeopleVaccinated/population)
 FROM PopvsVac 



 --TEMP TABLE
 DROP Table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar (255),
 Date datetime,
 Population numeric,
 New_Vaccination numeric,
 RollingPeopleVaccinated numeric
 )
 Insert into #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date , dea.population,vac.new_vaccinations
 ,SUM (Cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
  FROM Portfolioproject..['Covid deaths$'] dea
  JOIN Portfolioproject..['Covid vaccination$'] vac
 ON dea.location = vac.location 
 AND dea.date = vac.date
 WHERE dea.continent is not null
 --ORDER BY 1,2,3
 SELECT *, (RollingPeopleVaccinated/population)*100
 FROM #PercentPopulationVaccinated




 -- Creating view to store data to use later
 Create View PercentPopulationVaccinated as
 Select dea.continent, dea.location, dea.date , vac.new_vaccinations
 ,SUM (Cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
  FROM Portfolioproject..['Covid deaths$'] dea
  JOIN Portfolioproject..['Covid vaccination$'] vac
 ON dea.location = vac.location 
 AND dea.date = vac.date
 WHERE dea.continent is not null
 --ORDER BY 1,2,3

 SELECT * 
 FROM PercentPopulationVaccinated
