# 🏦 Berka Czech Bank — End-to-End Credit Risk & Retail Banking Analytics

[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=flat&logo=python&logoColor=white)](https://www.python.org/)
[![SQL Server](https://img.shields.io/badge/SQL%20Server-SSMS-CC2927?style=flat&logo=microsoftsqlserver&logoColor=white)](https://www.microsoft.com/en-us/sql-server)
[![Power BI](https://img.shields.io/badge/Power%20BI-Desktop-F2C811?style=flat&logo=powerbi&logoColor=black)](https://powerbi.microsoft.com/)

An end-to-end financial analytics and credit risk intelligence solution built on the **Berka Czech Bank relational dataset** (1993–1998). This project transforms 1M+ raw, multi-table banking records into an interactive **3-page executive Power BI dashboard** backed by a normalized **SQL Server Star Schema** and automated **Python ETL preprocessing**.

---

## 🎯 Business Problem & Objectives
Retail banks must balance deposit growth against loan default exposure while identifying regional and demographic risk concentrations. Using six years of historical Czech banking operations, this project answers four core business questions:
1. **Liquidity & Cash Flow Health:** How do monthly credit inflows compare against customer withdrawals and standing orders over time?
2. **Credit Portfolio Risk:** What percentage of issued loan principal is currently in default, and how are active vs. expired contracts distributed?
3. **Socioeconomic & Card Tier Signals:** Do regional unemployment rates, average salaries, or credit card ownership tiers correlate with higher loan default rates?
4. **Regional Performance:** Which Czech regions and districts generate the highest account volume versus the highest credit risk?

---

## 📊 Key Analytical Findings

| Metric | Value | Business Insight |
| :--- | :--- | :--- |
| **Active Accounts** | `4,500` | Concentrated heavily in **North Moravia (793)**, **South Moravia (778)**, and **Central Bohemia (574)**. |
| **Total Credit Inflow** | `3.23B CZK` | Steady upward cash inflow trajectory from 1993 to 1998, yielding **+197.15M CZK** in Net Cash Flow. |
| **Total Loan Portfolio** | `682 Loans` (`103.26M CZK`) | **606 loans (88.86%)** are paid or running in good standing; **76 loans (11.14%)** are in default. |
| **Principal at Risk** | `15.58M CZK` | Represents **15.09%** of total loaned principal tied to unpaid/in-debt contracts. |
| **Highest-Risk Segment** | `14.83%` Default Rate | Account holders **without credit cards** showed the highest default incidence, compared to **4.48%** among **Classic** cardholders. |
| **Regional Risk Outlier** | `15.79%` Default Rate | **West Bohemia (15.79%)** and **North Moravia (15.38%)** had the highest regional default rates, while **North Bohemia** recorded the lowest (**1.64%**). |

---

## 🏗️ Data Pipeline & Architecture

```text
┌─────────────────────┐     ┌──────────────────────────────┐     ┌─────────────────────────────┐
│   Raw Berka CSVs    │ ──► │  Python (Pandas) ETL Script  │ ──► │     SQL Server (SSMS)       │
│     (raw-data/)     │     │ • berka_eda_and_cleaning     │     │ • Normalized Base Tables    │
└─────────────────────┘     │ • DataBaseScript ingestion   │     │ • vw_account_owner_dim      │
                            └──────────────────────────────┘     │ • vw_monthly_transactions   │
                                                                 └──────────────┬──────────────┘
                                                                                │
┌─────────────────────┐     ┌──────────────────────────────┐                    │
│  3-Page Power BI    │ ◄── │   Star Schema & DAX Model    │ ◄──────────────────┘
│ Interactive Report  │     │ • DimDate (1993–1998)        │
└─────────────────────┘     │ • 5 Single-Direction 1:* Links│
                            │ • 11 Core KPIs (_Measures)   │
                            └──────────────────────────────┘
```

### 1. Data Wrangling & Database Ingestion (`berka_eda_and_cleaning.ipynb`, `DataBaseScript.ipynb`)
* Decoded non-standard Czech 6-digit identification numbers (`YYMMDD` with a `+50` month offset for female account holders) to extract accurate `birth_date` and `owner_gender` fields.
* Standardized Czech banking transaction codes (`k_symbol`, `operation`, `type`, `status`) into clear English business categories (`Household`, `Old-Age Pension`, `Loan Payment`, `Insurance`, etc.).
* Exported processed datasets to `cleaned-data/` and automated bulk ingestion into SQL Server via `DataBaseScript.ipynb`.

### 2. SQL Server Data Modeling (`SQL/`)
* Designed a **Star Schema** in **SQL Server Management Studio (SSMS)** to prevent many-to-many join ambiguity and accelerate Power BI aggregation:
  * **`vw_account_owner_dim` (Dimension View):** Joins `account`, `disp` (owner-level dispositions), `client`, `card`, and `district` into a unified customer-account dimension.
  * **`vw_monthly_transactions` (Aggregated Fact View):** Aggregates 1M+ granular ledger rows into monthly account-level `total_amount`, `tx_count`, and `avg_month_balance` metrics.
  * **`loan` & `order` (Fact Tables):** Captures loan principal, duration, monthly payments, binary `is_default` flags, and recurring standing orders.

### 3. Power BI Dashboard & DAX (`Credit Risk & Defaults.pbix`)
* Engineered a custom **`DimDate`** table (`1993–1998`) with chronological `Month Name` sorting and 5 active single-direction `1:*` relationships.
* Built **11 reusable DAX measures** inside a dedicated `_Measures` folder (`Default Rate %`, `Principal at Risk`, `Net Cash Flow`, `Total Credit Inflow`, `Total Outflow`, `Avg Account Balance`, etc.).
* Added **bookmark-powered Reset Filters buttons** and multi-slicer filtering (`Region`, `Card Tier`, `Year`) for intuitive self-service analysis.

---

## 🖼️ Dashboard Walkthrough

### 1. Executive & Cash Flow Overview
* **KPIs:** Active Accounts (`4,500`), Total Credit Inflow (`3.23B`), Net Cash Flow (`197M`), Avg Account Balance (`38K`).
* **Visuals:** Monthly Credit Inflow vs. Outflow trendline (1993–1998), Transaction Volume by Banking Operation (`Cash Deposit`, `Cash Withdrawal`, `Collection from Bank`, `Remittance to Bank`), and Cash Flow by Payment Category (`k_symbol`).

![Executive Overview](Assets/page1_executive_overview.png)

### 2. Credit Risk & Loan Default Analysis
* **KPIs:** Total Loans (`682`), Total Loan Principal (`103.26M`), Default Rate % (`11.14%`), Principal at Risk (`15.58M`).
* **Visuals:** Loan Portfolio by Contract Status (`403` Running Good, `203` Paid, `45` In Debt, `31` Unpaid), District Unemployment % vs. Loan Default Rate scatter analysis, and Default Rate % by Credit Card Tier & Owner Gender.

![Credit Risk & Defaults](Assets/page2_credit_risk.png)

### 3. Regional & Customer Segmentation
* **Interactive Controls:** Multi-select slicers for `Region`, `Card Tier`, and `Year` with a one-click `Reset` bookmark action.
* **Visuals:** Expandable Region-to-District drill-down matrix (`Active Accounts`, `Avg Salary`, `Total Loan Principal`, `Default Rate %` with conditional data bars) paired with a Regional Account Distribution bar chart.

![Regional Segmentation](Assets/page3_regional_segmentation.png)

### 4. Star Schema Data Model
![Star Schema Model](Assets/star_schema_model.png)

---

## 📁 Repository Structure

```text
berka-bank-analytics/
├── Assets/
│   ├── page1_executive_overview.png
│   ├── page2_credit_risk.png
│   ├── page3_regional_segmentation.png
│   └── star_schema_model.png
├── cleaned-data/
├── raw-data/
├── SQL/
├── berka_eda_and_cleaning.ipynb
├── Credit Risk & Defaults.pbix
├── DataBaseScript.ipynb
└── README.md
```

---

## 🚀 How to Run This Project Locally

1. **Clone the Repository:**
   ```bash
   git clone [https://github.com/KailasH1245/berka-bank-analytics.git](https://github.com/KailasH1245/berka-bank-analytics.git)
   cd berka-bank-analytics
   ```
2. **Run Python ETL & Database Ingestion:**
   * Execute `berka_eda_and_cleaning.ipynb` in Jupyter Notebook to process `raw-data/` into `cleaned-data/`.
   * Run `DataBaseScript.ipynb` to load the cleaned tables into your SQL Server instance.
3. **Create SQL Analytical Views:**
   * Run the scripts inside `SQL/` in SSMS to generate `vw_account_owner_dim` and `vw_monthly_transactions`.
4. **Explore the Power BI Report:**
   * Open `Credit Risk & Defaults.pbix` in **Power BI Desktop** (all data is cached inside the `.pbix` file, or update **Transform data → Data source settings** to connect live to your local SQL Server).

---

## 👤 Author
**Kailash Choudhary**  
*Data Analyst | SQL • Python • Power BI*  
* GitHub: [@KailasH1245](https://github.com/KailasH1245)
