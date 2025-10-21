# hubspot_assessment
**A) Project Overview**

You are an Analytics Engineer at a rental property management company.
The business has recently introduced several new data sources — covering property listings, reviews, booking calendars, and amenity changes.

The goal of this project is to:
1. Model and transform raw source data into clean, analysis-ready datasets.
2. Enable analysts to answer key business questions related to revenue, occupancy, and amenities.
3. Demonstrate solid data modeling, SQL design, and dbt-style modular development using Snowflake as the data platform.

**B) Environment Setup**

**Warehouse:** Snowflake

**Transformation Layer:** dbt-styled SQL (Jinja templating + modular layering)

**Source Data:** Four CSVs uploaded into Snowflake schema:listings.csv, calendar.csv, generated_reviews.csv, amenities_changelog.csv

Each CSV was staged into Snowflake tables.

All transformations were run directly in Snowflake, simulating dbt behavior using Jinja-like macros and ref-style dependencies.

**C) Data Model Architecture - Design Philosophy**

Follows dbt Labs best practices:

**Staging Layer (stg_)** — Cleans and standardizes raw CSV data.


**Intermediate Layer (int_)** — Enriches and combines data across sources.


**Mart / Fact Layer (fct_)** — Builds a final business-ready table for analytical use.


**D) Macros and Reusability (Jinja-Style)**

To maintain clarity, consistency, and reusability, 6 macros were implemented:

| Macro                                     | Purpose                                   | Example                              |
| ----------------------------------------- | ----------------------------------------- | -------------------------------------|
| {{ column_cleaner(column_name) }}         | Cleans & lowercases text                  | {{ column_cleaner('neighborhood') }} |
| {{ date_cast(column_name) }}              | Safely converts to date                   | {{ date_cast('date') }}              |
| {{ format_price(column_name) }}           | Removes currency symbols & casts to float | {{ format_price('price') }}          |
| {{ null_handler(column_name, default) }}  | Handles nulls gracefully                  | {{ null_handler('base_price', 0) }}  |
| {{ safe_divide(numerator, denominator) }} | Prevents divide-by-zero                   | {{ safe_divide('revenue', 'days') }} |
| {{ source_ref(model_name) }}              | Wraps dbt `ref()` for modular sourcing    | {{ source_ref('stg_calendar') }}     |


**E) Model Layers**

**1)Staging Models (models/staging/)**

Clean each CSV from Snowflake into typed and standardized staging tables:
- stg_generated_reviews.sql
  
- stg_amenities_changelog.sql
  
- stg_calendar.sql
  
- stg_listings.sql

**2) Intermediate Models (models/intermediate/)**

- int_reviews_with_scores.sql → Aggregates average review scores.

- int_listing_enriched.sql → Combines listings, reviews, and amenities.

- int_calendar_enriched.sql → Enriches booking availability and price per day.


**3) Mart Model - Final Table**

Creates the final daily listing-level fact table, combining all enriched data for analysis.

