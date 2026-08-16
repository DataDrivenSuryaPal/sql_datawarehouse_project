# 🚀 Modern Data Warehouse & Analytics Project

## 📌 Project Overview

This project demonstrates the design and implementation of a **modern data warehouse using SQL Server**, following a layered architecture to transform raw data from CRM and ERP source systems into clean, standardized, integrated, and business-ready data for analytics.

The project covers the complete data journey:

**Source Systems → Data Ingestion → Bronze → Silver → Gold → Analytics**

The primary goal is to build a scalable and maintainable data warehouse while applying practical concepts in **ETL, data cleansing, data integration, data modeling, data quality, and analytical SQL**.

---

## 🏗️ Data Architecture

The data warehouse follows a **Medallion Architecture** consisting of three layers:

<img width="6235" height="3216" alt="data_architecture" src="https://github.com/user-attachments/assets/2a6df06d-d35c-4c4a-9065-6afca2247185" />


The project documentation defines Bronze as the raw/unprocessed layer, Silver as the clean and standardized layer, and Gold as the business-ready layer used for reporting and analytics.

---

# 📂 Data Sources

The project uses CSV files representing data from different business source systems.

### CRM Data

| Dataset         | Description                           |
| --------------- | ------------------------------------- |
| `cust_info.csv` | Customer master information           |
| `CUST_AZ12.csv` | Customer demographic information      |
| `LOC_A101.csv`  | Customer location/country information |

### ERP Data

| Dataset             | Description                                  |
| ------------------- | -------------------------------------------- |
| `prd_info.csv`      | Product information                          |
| `PX_CAT_G1V2.csv`   | Product category and subcategory information |
| `sales_details.csv` | Sales transaction information                |

### Dataset Overview

| Dataset             | Records | Key Information              |
| ------------------- | ------: | ---------------------------- |
| `cust_info.csv`     |  18,494 | Customer details             |
| `prd_info.csv`      |     397 | Product details              |
| `sales_details.csv` |  60,398 | Sales transactions           |
| `LOC_A101.csv`      |  18,484 | Customer countries           |
| `PX_CAT_G1V2.csv`   |      37 | Product categories           |
| `CUST_AZ12.csv`     |  18,484 | Customer birth date & gender |

---

# 🥉 Bronze Layer — Raw Data

The Bronze layer is the **raw landing layer** of the data warehouse.

Data is loaded from the source CSV files with minimal transformation in order to preserve the original source data and provide traceability.

### Objectives

* Store raw source data
* Preserve the original source structure
* Provide traceability
* Support debugging and troubleshooting
* Create a reliable starting point for downstream transformations

The Bronze layer uses:

**Load Method:** Full Load
**Loading Pattern:** Truncate & Insert
**Transformation:** None / As-Is

This layer is primarily used by **Data Engineers and Data Analysts**.

---

# 🥈 Silver Layer — Cleaned & Standardized Data

The Silver layer transforms raw Bronze data into **clean, consistent, standardized, and integrated datasets**.

### Transformations

The Silver layer includes:

* Data Cleaning
* Data Standardization
* Data Normalization
* Derived Columns
* Data Enrichment
* Data Integration
* Data Quality Validation

Examples of data-quality activities include:

* Handling NULL values
* Removing unwanted spaces
* Standardizing categorical values
* Standardizing date formats
* Validating data types
* Checking duplicate records
* Validating customer and product keys
* Resolving inconsistencies between source systems

The project documentation identifies these transformations as core Silver-layer activities.

### Loading Strategy

**Load Type:** Full Load
**Loading Pattern:** Truncate & Insert

---

# 🥇 Gold Layer — Business-Ready Data

The Gold layer is the final presentation layer of the warehouse.

It contains **business-ready analytical objects** created from the cleaned and integrated Silver-layer data.

Unlike the Bronze and Silver layers, the Gold layer uses **views** to expose analytical data.

### Gold Layer Responsibilities

* Apply business logic
* Integrate business entities
* Create analytical models
* Build aggregated objects
* Create flat analytical tables/views
* Prepare data for reporting
* Support business analytics

### Data Modeling

The Gold layer follows dimensional modeling concepts such as:

* **Fact tables**
* **Dimension tables**
* **Star schema**
* **Aggregated analytical objects**
* **Business-ready views**

The project documentation specifically identifies star schemas, aggregated objects, and flat tables as Gold-layer modeling approaches.

---

# 🔄 ETL Process

The project follows a complete **Extract, Transform, Load (ETL)** process.

## 1. Extract

Data is extracted from the available CRM and ERP CSV files.

### Extraction Strategy

* **Extraction Type:** Full Extraction
* Complete source datasets are extracted during each execution.

---

## 2. Load — Bronze

The extracted source data is loaded into the Bronze layer.

```text
CSV Files
    ↓
Bronze Tables
    ↓
Raw / As-Is Data
```

**Load Type:** Full Load
**Method:** Truncate & Insert

---

## 3. Transform — Silver

Raw Bronze data is transformed into standardized datasets.

```text
Bronze
   ↓
Cleaning
   ↓
Standardization
   ↓
Normalization
   ↓
Integration
   ↓
Silver
```

---

## 4. Business Transformation — Gold

The Silver data is then integrated and transformed according to business requirements.

```text
Silver
   ↓
Business Logic
   ↓
Data Integration
   ↓
Data Modeling
   ↓
Aggregations
   ↓
Gold Views
```

---

# 🧹 Data Quality Framework

Data quality is considered throughout the warehouse pipeline.

### Bronze Layer Checks

* Data completeness
* Schema validation
* Source structure validation

### Silver Layer Checks

* Data correctness
* Data standardization
* Duplicate checks
* NULL validation
* Data type validation
* Data integration checks

### Gold Layer Checks

* Business-rule validation
* Data integration validation
* Aggregation validation
* Analytical consistency

The project workflow includes completeness/schema checks in Bronze, correctness checks in Silver, and integration checks in Gold.

---

# 📊 Analytics

The Gold layer is designed to support business analytics and reporting.

Potential analytical areas include:

### 👥 Customer Analytics

* Customer distribution by country
* Customer demographics
* Gender analysis
* Customer acquisition trends
* Customer purchasing behavior

### 📦 Product Analytics

* Product performance
* Product category analysis
* Subcategory performance
* Product sales trends
* Product profitability analysis

### 💰 Sales Analytics

* Total sales
* Sales by product
* Sales by customer
* Sales by country
* Sales trends over time
* Quantity sold
* Average selling price
* Top-performing products
* Top customers

### 📈 Advanced Analytics

The project can also support analytical SQL use cases such as identifying **consecutive months of sales for each product**, as reflected in the project documentation.

---

# 🧩 Example Business Data Model

```text
                         ┌─────────────────┐
                         │   dim_customer  │
                         │─────────────────│
                         │ Customer Key    │
                         │ Name            │
                         │ Gender          │
                         │ Birth Date      │
                         │ Country         │
                         └────────┬────────┘
                                  │
                                  │
                                  ▼
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│   dim_product   │──────►│    fact_sales   │◄──────│    dim_date     │
│─────────────────│       │─────────────────│       │─────────────────│
│ Product Key     │       │ Order Number    │       │ Date            │
│ Product Name    │       │ Customer Key    │       │ Month           │
│ Category        │       │ Product Key     │       │ Quarter         │
│ Subcategory     │       │ Order Date      │       │ Year            │
│ Product Cost    │       │ Sales           │       └─────────────────┘
└─────────────────┘       │ Quantity        │
                          │ Price           │
                          └─────────────────┘
```

---

# 🛠️ Technology Stack

| Technology     | Purpose                                         |
| -------------- | ----------------------------------------------- |
| **SQL Server** | Data warehouse database                         |
| **SQL**        | ETL, transformations, data modeling & analytics |
| **CSV**        | Source data                                     |
| **Git**        | Version control                                 |
| **GitHub**     | Source control & project documentation          |

---

# 📁 Project Structure

```text
Modern-Data-Warehouse/
│
├── datasets/
│   ├── crm/
│   │   ├── cust_info.csv
│   │   ├── CUST_AZ12.csv
│   │   └── LOC_A101.csv
│   │
│   └── erp/
│       ├── prd_info.csv
│       ├── PX_CAT_G1V2.csv
│       └── sales_details.csv
│
├── scripts/
│   ├── bronze/
│   ├── silver/
│   ├── gold/
│   └── analytics/
│
├── docs/
│   ├── data_model/
│   ├── data_catalog/
│   └── data_flow/
│
├── tests/
│   └── data_quality/
│
└── README.md
```

---

# 🔍 Data Warehouse Development Process

The development process follows a structured approach:

```text
Source System Analysis
        ↓
Understand Business Process
        ↓
Data Exploration
        ↓
Data Ingestion
        ↓
Bronze Layer
        ↓
Data Cleansing
        ↓
Silver Layer
        ↓
Data Integration
        ↓
Gold Layer
        ↓
Data Modeling
        ↓
Analytics
```

The project documentation also emphasizes understanding source-system ownership, business processes, storage technology, integration capabilities, historical requirements, and extraction strategy before implementation.

---

# 📚 Key Skills Demonstrated

Through this project, I demonstrate practical experience in:

* SQL Server
* Advanced SQL
* ETL development
* Data warehouse architecture
* Medallion architecture
* Data ingestion
* Data cleansing
* Data standardization
* Data integration
* Data quality validation
* Dimensional modeling
* Star schema design
* Fact and dimension modeling
* Analytical SQL
* Business logic implementation
* Data documentation
* Git & GitHub

---

# 🚀 Future Enhancements

The current project uses **full extraction and full loading**. Future improvements could include:

* Incremental data loading
* Change Data Capture (CDC)
* Slowly Changing Dimensions (SCD)
* Automated ETL scheduling
* Pipeline monitoring and logging
* Advanced data quality framework
* Query and warehouse optimization
* Power BI dashboard integration
* Automated testing

---

# 👨‍💻 About Me

Hi, I'm Surya Pal, a **Data Analyst** passionate about transforming raw data into meaningful business insights.

I enjoy working with:

* 📊 Data Analytics
* 🧮 SQL & Advanced SQL
* 🏗️ Data Warehousing
* 🔄 ETL & Data Transformation
* 📈 Business Intelligence
* 🐍 Python
* 📊 Power BI
* 🗄️ SQL Server

This project represents my practical journey into **data warehousing, data engineering concepts, and analytics**, with a focus on building reliable data pipelines and transforming complex source data into business-ready information.
---

⭐ If you found this project useful, feel free to **star the repository** and explore the implementation.
