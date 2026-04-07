CREATE TABLE customer_churn (
    customer_id TEXT,
    gender TEXT,
    age INT,
    married TEXT,
    number_of_dependents INT,
    city TEXT,
    zip_code TEXT,
    latitude FLOAT,
    longitude FLOAT,
    number_of_referrals INT,
    tenure_in_months INT,
    offer TEXT,
    phone_service TEXT,
    avg_monthly_long_distance_charges FLOAT,
    multiple_lines TEXT,
    internet_service TEXT,
    internet_type TEXT,
    avg_monthly_gb_download FLOAT,
    online_security TEXT,
    online_backup TEXT,
    device_protection_plan TEXT,
    premium_tech_support TEXT,
    streaming_tv TEXT,
    streaming_movies TEXT,
    streaming_music TEXT,
    unlimited_data TEXT,
    contract TEXT,
    paperless_billing TEXT,
    payment_method TEXT,
    monthly_charge FLOAT,
    total_charges FLOAT,
    total_refunds FLOAT,
    total_extra_data_charges FLOAT,
    total_long_distance_charges FLOAT,
    total_revenue FLOAT,
    customer_status TEXT,
    churn_category TEXT,
    churn_reason TEXT
);

SELECT * FROM customer_churn LIMIT 5;

SELECT customer_status, COUNT(*)
FROM customer_churn
GROUP BY customer_status;

SELECT DISTINCT customer_status
FROM customer_churn;

SELECT zip_code
FROM customer_churn
LIMIT 5;

SELECT zipcode
FROM zipcode_population
LIMIT 5;

SELECT c.*, z.population
FROM customer_churn c
LEFT JOIN zipcode_population z
ON c.zip_code = z.zipcode;

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'customer_churn';

-- 1. Total customers
SELECT COUNT(*) FROM customer_churn;

-- 2. Churn distribution
SELECT customer_status, COUNT(*)
FROM customer_churn
GROUP BY customer_status;

-- 3. Contract vs churn
SELECT contract, customer_status, COUNT(*)
FROM customer_churn
GROUP BY contract, customer_status;


---CORE KPI
SELECT customer_status,
COUNT(*) AS total_customer
FROM customer_churn
GROUP BY customer_status;

--QUESTION 1
SELECT
    customer_status,
	AVG(tenure_in_months)AS avg_tenure
FROM customer_churn
GROUP BY customer_status;

--QUESTION 2
Group customers by tenure

SELECT 
    CASE 
        WHEN tenure_in_months <= 6 THEN '0-6 months'
        WHEN tenure_in_months <= 12 THEN '6-12 months'
        WHEN tenure_in_months <= 24 THEN '12-24 months'
        ELSE '24+ months'
    END AS tenure_group,
    customer_status,
    COUNT(*) AS total
FROM customer_churn
GROUP BY tenure_group, customer_status
ORDER BY tenure_group;

STEP 3: PRODUCT / SERVICE ANALYSIS
Question 3:
👉 Contract type vs churn
SELECT 
    contract,
    customer_status,
    COUNT(*) AS total
FROM customer_churn
GROUP BY contract, customer_status;

Question 4:
👉 Internet service vs churn

SELECT 
    internet_service,
    customer_status,
    COUNT(*) AS total
FROM customer_churn
GROUP BY internet_service, customer_status;

Question 5:
👉 Tech support impact
SELECT 
    premium_tech_support,
    customer_status,
    COUNT(*) AS total
FROM customer_churn
GROUP BY premium_tech_support, customer_status;


Question 6
omline security impact

SELECT online_security,
        customer_status,
		COUNT(*) AS total
FROM customer_churn
GROUP BY online_security, customer_status;


SELECT 
    online_security,
    customer_status,
    COUNT(*) AS total,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY online_security),
        2
    ) AS percentage
FROM customer_churn
GROUP BY online_security, customer_status;

SELECT 
    premium_tech_support,
    customer_status,
    COUNT(*) AS total,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY premium_tech_support),
        2
    ) AS percentage
FROM customer_churn
GROUP BY premium_tech_support, customer_status;

STEP 1 — Combine TENURE + ONLINE SECURITY

SELECT 
    tenure_group,
    online_security,
    customer_status,
    total,
    ROUND(
        total * 100.0 / SUM(total) OVER (PARTITION BY tenure_group, online_security),
        2
    ) AS percentage
FROM (
    SELECT 
        CASE 
            WHEN tenure_in_months <= 6 THEN '0-6 months'
            WHEN tenure_in_months <= 12 THEN '6-12 months'
            WHEN tenure_in_months <= 24 THEN '12-24 months'
            ELSE '24+ months'
        END AS tenure_group,
        online_security,
        customer_status,
        COUNT(*) AS total
    FROM customer_churn
    GROUP BY tenure_group, online_security, customer_status
) sub;

SELECT 
    tenure_group,
    premium_tech_support,
    customer_status,
    total,
    ROUND(
        total * 100.0 / SUM(total) OVER (PARTITION BY tenure_group, premium_tech_support),
        2
    ) AS percentage
FROM (
    SELECT 
        CASE 
            WHEN tenure_in_months <= 6 THEN '0-6 months'
            WHEN tenure_in_months <= 12 THEN '6-12 months'
            WHEN tenure_in_months <= 24 THEN '12-24 months'
            ELSE '24+ months'
        END AS tenure_group,
        premium_tech_support,
        customer_status,
        COUNT(*) AS total
    FROM customer_churn
    GROUP BY tenure_group, premium_tech_support, customer_status
) sub;


SELECT 
    tenure_group,
    contract,
    premium_tech_support,
    customer_status,
    total,
    ROUND(
        total * 100.0 / SUM(total) OVER (
            PARTITION BY tenure_group, contract, premium_tech_support
        ),
        2
    ) AS percentage
FROM (
    SELECT 
        CASE 
            WHEN tenure_in_months <= 6 THEN '0-6 months'
            WHEN tenure_in_months <= 12 THEN '6-12 months'
            WHEN tenure_in_months <= 24 THEN '12-24 months'
            ELSE '24+ months'
        END AS tenure_group,
        contract,
        premium_tech_support,
        customer_status,
        COUNT(*) AS total
    FROM customer_churn
    GROUP BY tenure_group, contract, premium_tech_support, customer_status
) sub;

---KPI CORES
_TOTAL CUSTOMERS
SELECT COUNT(*) AS total_customers
FROM customer_churn;

_TOTAL CHURNED CUSTOMERS
SELECT COUNT(*)AS churned_customers
FROM customer_churn
WHERE customer_status ='Churned';

_Churn Rate (%)
SELECT 
     ROUND(
     COUNT(*) FILTER (WHERE customer_status ='Churned')*100.0
	 / COUNT(*),
	2
	)AS churn_rate_percentage
FROM customer_churn;

_AVG MONTHLY CHARGE
SELECT ROUND(AVG(monthly_charge)::numeric,2)AS avg_monthly_charge
FROM customer_churn;


_TOTAL REVENUE
SELECT  ROUND(SUM(total_revenue)::numeric,2)AS total_revenue
FROM customer_churn;

_AVERAGE TENURE
SELECT  ROUND(AVG(tenure_in_months)::numeric,2)AS avg_tenure
FROM customer_churn;

--CREATE CLEAN VIEW

CREATE VIEW churn_analysis_view AS
SELECT
      customer_id,
	  customer_status,
	  tenure_in_months,
	  contract,
	  premium_tech_support,
	  online_security,
	  monthly_charge,
	  total_revenue,

      CASE 
            WHEN tenure_in_months <= 6 THEN '0-6 months'
            WHEN tenure_in_months <= 12 THEN '6-12 months'
            WHEN tenure_in_months <= 24 THEN '12-24 months'
            ELSE '24+ months'
        END AS tenure_group
FROM customer_churn;



SELECT *
FROM customer_churn
LIMIT 1;






