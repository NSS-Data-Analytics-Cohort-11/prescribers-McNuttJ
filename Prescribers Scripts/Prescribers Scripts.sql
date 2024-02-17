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

--C.  **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

SELECT prescriber.specialty_description --did not return a value
FROM prescriber
	LEFT JOIN prescription
	ON prescriber.npi = prescription.npi
WHERE prescriber.npi IS NULL

SELECT specialty_description --query run time too long
FROM prescriber
WHERE npi NOT IN (
	SELECT npi
	FROM prescription)
	
SELECT specialty_description --did not return a value
FROM prescriber
WHERE NOT EXISTS
	(SELECT prescription.npi
	FROM prescription
	LEFT JOIN prescriber
	ON prescription.npi = prescriber.npi)
	
WITH cte AS (
	SELECT npi
	FROM )
	

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
SELECT fips_county.county, population.population
FROM fips_county
	LEFT JOIN population
	ON fips_county.fipscounty = population.fipscounty
	LEFT JOIN cbsa
	ON fips_county.fipscounty = cbsa.fipscounty
WHERE fips_county.county NOT IN (
		SELECT fipscounty
		FROM cbsa)
		AND population.population IS NOT NULL
ORDER BY population DESC;
--Answer: Shelby, Population = 937847

--Question 6.
--A. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000
ORDER BY total_claim_count DESC;
--ANSWER 
/*"OXYCODONE HCL"	4538
"LISINOPRIL"	3655
"GABAPENTIN"	3531
"HYDROCODONE-ACETAMINOPHEN"	3376
"LEVOTHYROXINE SODIUM"	3138
"LEVOTHYROXINE SODIUM"	3101
"MIRTAZAPINE"	3085
"FUROSEMIDE"	3083
"LEVOTHYROXINE SODIUM"	3023*/

--B. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT p.drug_name, p.total_claim_count,
	CASE
	WHEN d.opioid_drug_flag = 'Y' THEN 'Opioid'
	ELSE 'Not An Opioid'
	END AS opioid_or_not 
FROM prescription AS p
	INNER JOIN drug AS d
	ON p.drug_name = d.drug_name
WHERE p.total_claim_count >= 3000
ORDER BY p.total_claim_count DESC;
--Answer 
/*"OXYCODONE HCL"	4538	"Opioid"
"LISINOPRIL"	3655	"Not An Opioid"
"GABAPENTIN"	3531	"Not An Opioid"
"HYDROCODONE-ACETAMINOPHEN"	3376	"Opioid"
"LEVOTHYROXINE SODIUM"	3138	"Not An Opioid"
"LEVOTHYROXINE SODIUM"	3101	"Not An Opioid"
"MIRTAZAPINE"	3085	"Not An Opioid"
"FUROSEMIDE"	3083	"Not An Opioid"
"LEVOTHYROXINE SODIUM"	3023	"Not An Opioid"*/

--C. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT prescriber.nppes_provider_first_name,
	prescriber.nppes_provider_last_org_name,
	p.drug_name, 
	p.total_claim_count,
	CASE
	WHEN d.opioid_drug_flag = 'Y' THEN 'Opioid'
	ELSE 'Not An Opioid'
	END AS opioid_or_not 
FROM prescription AS p
	INNER JOIN drug AS d
	ON p.drug_name = d.drug_name
	INNER JOIN prescriber
	ON p.npi = prescriber.npi
WHERE p.total_claim_count >= 3000
ORDER BY p.total_claim_count DESC;
--ANSWER
/*"DAVID"	"COFFEY"	"OXYCODONE HCL"	4538	"Opioid"
"BRUCE"	"PENDLEY"	"LISINOPRIL"	3655	"Not An Opioid"
"BRUCE"	"PENDLEY"	"GABAPENTIN"	3531	"Not An Opioid"
"DAVID"	"COFFEY"	"HYDROCODONE-ACETAMINOPHEN"	3376	"Opioid"
"DEAVER"	"SHATTUCK"	"LEVOTHYROXINE SODIUM"	3138	"Not An Opioid"
"ERIC"	"HASEMEIER"	"LEVOTHYROXINE SODIUM"	3101	"Not An Opioid"
"BRUCE"	"PENDLEY"	"MIRTAZAPINE"	3085	"Not An Opioid"
"MICHAEL"	"COX"	"FUROSEMIDE"	3083	"Not An Opioid"
"BRUCE"	"PENDLEY"	"LEVOTHYROXINE SODIUM"	3023	"Not An Opioid"*/

--Question 7 The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--A. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
SELECT npi, drug_name
FROM prescriber
CROSS JOIN drug
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y'
--Answer: see above query, 637 total rows.

--B. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
SELECT prescriber.npi, drug.drug_name, SUM(prescription.total_claim_count)
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription
ON prescriber.npi = prescription.npi
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y'
GROUP BY prescriber.npi, drug.drug_name
--Answer: see above query, 637 total rows.

--C.Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
SELECT prescriber.npi, drug.drug_name, SUM(COALESCE(prescription.total_claim_count, '0'))
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription
ON prescriber.npi = prescription.npi
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y'
GROUP BY prescriber.npi, drug.drug_name
--ANSWER: Added COALESCE to total_claim_count.





