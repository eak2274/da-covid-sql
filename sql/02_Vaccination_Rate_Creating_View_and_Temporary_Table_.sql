CREATE OR ALTER VIEW VaccinationRateByDate AS
WITH t AS
(
    SELECT
        dea.continent, dea.location, dea.date, dea.population, MAX(vac.total_vaccinations) AS max_total_vaccinations
    FROM
        CovidDeaths dea
    JOIN
        CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL AND
        dea.population IS NOT NULL AND
        vac.total_vaccinations IS NOT NULL
    GROUP BY
        dea.continent, dea.location, dea.date, dea.population
)
SELECT
    t.*, ROUND(t.max_total_vaccinations / t.population * 100, 3) AS vaccination_rate
FROM
    t;
GO

drop table if exists #VaccinationRateByDate;

--05. Vaccinations vs. population
--two queries return totally different results because we lack data of newn vaccinations
with t as
(
	select
	   dea.continent, dea.location, dea.date, dea.population, max(vac.total_vaccinations) max_total_vaccinations
	from
	   CovidDeaths dea
	join
	   CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date
	where
	   dea.continent is not null and
	   dea.population is not null and
	   vac.total_vaccinations is not null
	group by
	   dea.continent, dea.location, dea.date, dea.population
	--order by
	--   dea.location, dea.date
)
select
   t.*, round(t.max_total_vaccinations/t.population*100, 3) vaccination_rate
into 
   #VaccinationRateByDate
from
   t
order by
   t.location,t.date

select * from #VaccinationRateByDate;
select * from VaccinationRateByDate;
