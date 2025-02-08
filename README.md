# Rental Revenue Analysis

## Overview
This project contains SQL scripts for analyzing rental revenue by film category using a PostgreSQL database. It includes detailed and summary tables, a user-defined function for revenue calculations, a trigger for automatic summary updates, and a stored procedure for refreshing report data.

## Features
- **User-defined function**: `calculate_rental_revenue` to compute revenue per film.
- **Detailed revenue table**: `detailed_category_revenue` listing individual film revenue.
- **Summary revenue table**: `summary_category_revenue` ranking film categories by revenue.
- **Automated updates**: A trigger that updates the summary table when changes occur.
- **Data refresh procedure**: `refresh_report_data()` to update report data dynamically.

## Database Schema
This project is based on the **DVD Rental** database schema, using the following tables:
- `rental`
- `inventory`
- `film`
- `film_category`
- `category`
