# trademe-property-analytics


# 🏡 Trade Me Property Analytics Project

A complete data engineering project using live housing data from Trade Me's API. Built with PySpark, Snowflake, dbt Cloud, and Databricks.

---

## 🚀 Project Overview

This project collects daily property listing data from Trade Me's public API, stores it in a Snowflake data warehouse, transforms it using dbt Cloud, and (optionally) visualizes it with BI tools.

---

## 🛠️ Tech Stack

- **Data Source**: Trade Me API (OAuth 1.0)
- **Ingestion & Processing**: Databricks + PySpark
- **Storage**: Snowflake
- **Transformation**: dbt Cloud (free version)
- **Version Control**: GitHub
- **Visualization**: Power BI / Tableau (optional)

---

## 📈 Use Cases

- Analyze price trends by suburb and region
- Monitor listing frequency and listing durations
- Identify patterns in property types and pricing
- Track price change frequency by listing

---

## 📁 Project Structure

| Folder | Description |
|--------|-------------|
| `/databricks_notebooks` | PySpark notebooks/scripts used to fetch and clean listing data |
| `/snowflake_sql` | Snowflake table and schema DDL scripts |
| `/dbt_project` | All dbt models, tests, docs |
| `/visualization` | (Optional) Dashboards or screenshots |
| `README.md` | You are here. Overview + Setup Instructions |

---

## 📦 How to Use

1. Clone this repo
2. Register accounts for:
   - Trade Me API
   - Databricks Community Edition
   - Snowflake Trial
   - dbt Cloud
3. Run the data pipeline from API to warehouse
4. Transform data in dbt
5. Analyze and visualize the results

---

## 📚 Key Learnings

- Real-world experience building a modern data stack
- Practical use of PySpark, Snowflake SQL, dbt modeling
- Hands-on with OAuth authentication and external APIs

---

## 🧑‍💻 Author

Your Name  
Email | GitHub | LinkedIn

---
