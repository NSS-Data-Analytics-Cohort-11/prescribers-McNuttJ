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
SELECT drug.generic_name, SUM((prescription.total_drug_cost)/30)
FROM prescription
	INNER JOIN drug
	ON prescription.drug_name = drug.drug_name
GROUP BY drug.generic_name
ORDER BY SUM((prescription.total_drug_cost)/30) DESC
LIMIT 10;




