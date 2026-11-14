-- 1. Dimension View: Resolves Account + Owner + Card + District into one clean dimension
CREATE OR ALTER VIEW vw_account_owner_dim AS
SELECT 
    a.account_id,
    a.frequency AS statement_frequency,
    a.created_date AS account_created_date,
    c.client_id AS owner_client_id,
    c.gender AS owner_gender,
    c.birth_date AS owner_birth_date,
    c.age_1998 AS owner_age,
    COALESCE(cd.type, 'No Card') AS card_type,
    d.district_id,
    d.district_name,
    d.region,
    d.avg_salary AS district_avg_salary,
    d.unemployment_96 AS district_unemployment_pct
FROM account a
JOIN disp dp ON a.account_id = dp.account_id AND dp.type = 'Owner'
JOIN client c ON dp.client_id = c.client_id
JOIN district d ON a.district_id = d.district_id
LEFT JOIN card cd ON dp.disp_id = cd.disp_id;
GO

-- 2. Fact View: Monthly aggregated transactions for Power BI time-series & category charts
CREATE OR ALTER VIEW vw_monthly_transactions AS
SELECT 
    account_id,
    EOMONTH(trans_date) AS month_end_date,
    type,
    operation,
    k_symbol,
    COUNT(*) AS tx_count,
    SUM(amount) AS total_amount,
    AVG(balance) AS avg_month_balance
FROM trans
GROUP BY account_id, EOMONTH(trans_date), type, operation, k_symbol;
GO