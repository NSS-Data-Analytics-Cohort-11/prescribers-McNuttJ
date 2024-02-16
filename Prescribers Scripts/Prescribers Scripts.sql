--Question 1.
--A. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT npi, SUM(total_claim_count)
FROM prescription
GROUP BY npi
ORDER BY SUM(total_claim_count) DESC
LIMIT 10;
--Answer: Prescriber 1881634483, 99707 claims.

--B. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
SELECT prescriber.npi,
	prescriber.nppes_provider_first_name,
	prescriber.nppes_provider_last_org_name,
	prescriber.specialty_description,
	SUM(total_claim_count)
FROM prescription
	INNER JOIN prescriber
	ON prescriber.npi = prescription.npi
	GROUP BY
	prescriber.npi,
	prescriber.nppes_provider_first_name,
	prescriber.nppes_provider_last_org_name,
	prescriber.specialty_description
ORDER BY SUM(total_claim_count) DESC
LIMIT 10;
--Answer: Repeat of 1.A but add first name, last name, and specialty description.

--Question 2.
--A. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT prescriber.specialty_description, SUM(prescription.total_claim_count)
FROM prescription
	INNER JOIN prescriber
	ON prescription.npi = prescriber.npi
GROUP BY prescriber.specialty_description
ORDER BY SUM(prescription.total_claim_count) DESC
LIMIT 10
--Answer: Family Practice

--B. Which specialty had the most total number of claims for opioids?
SELECT prescriber.specialty_description, SUM(prescription.total_claim_count)
FROM prescription
	INNER JOIN prescriber
	ON prescription.npi = prescriber.npi
	INNER JOIN drug
	ON prescription.drug_name = drug.drug_name
WHERE opioid_drug_flag = 'Y' OR long_acting_opioid_drug_flag = 'Y'
GROUP BY prescriber.specialty_description
ORDER BY SUM(prescription.total_claim_count) DESC
LIMIT 10;
--Answer: Nurse Practicioner

--C. 

--Question 3.
--A. Which drug (generic_name) had the highest total drug cost?
SELECT drug.generic_name, SUM(prescription.total_drug_cost)
FROM prescription
	INNER JOIN drug
	ON prescription.drug_name = drug.drug_name
GROUP BY drug.generic_name
ORDER BY SUM(prescription.total_drug_cost) DESC
LIMIT 10;
--Answer: INSULIN GLARGINE,HUM.REC.ANLOG

--B. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
--This maybe?
SELECT drug.generic_name, ROUND(SUM((prescription.total_drug_cost)/30),2)
FROM prescription
	INNER JOIN drug
	ON prescription.drug_name = drug.drug_name
GROUP BY drug.generic_name
ORDER BY SUM((prescription.total_drug_cost)/30) DESC
LIMIT 10;
--Anser: INSULIN GLARGINE,HUM.REC.ANLOG

--Question 4.
--A. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/ 
SELECT drug_name,
	CASE
	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither'
	END AS drug_type
FROM drug
--ANSWER: See above query

--B. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT MONEY(SUM(total_drug_cost)) AS total_drug_cost,
	CASE
	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither'
	END AS drug_type
FROM drug
	INNER JOIN prescription
	ON drug.drug_name = prescription.drug_name
GROUP BY drug_type
ORDER BY total_drug_cost DESC;
--ANSWER: Opioids, $105,080,626.37

--Question 5.
--A. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT COUNT(cbsa)
FROM cbsa
WHERE cbsaname LIKE '%TN%'
--Answer: 56

--B. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
SELECT cbsa.cbsaname, SUM(population.population)
FROM cbsa
	INNER JOIN population
	ON cbsa.fipscounty = population.fipscounty
WHERE population.population IS NOT NULL
GROUP BY cbsa.cbsaname
ORDER BY SUM(population.population) DESC;
--ANSWER: Largest Population = Nashville-Davidson--Murfreesboro--Franklin, TN, Smallest Population = Morristown, TN

--C. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
--sub query counties not in cbsa???
SELECT population.population


