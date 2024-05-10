# Superstore Data Warehouse
This project extends the capabilities of the previously developed superstore-pbi-database by implementing a data warehouse approach.
The primary aim is to showcase the advantages of using data warehouses for efficient data analytics and decision-making processes.

## Introduction
Relational databases are optimized for transactional purposes, making them efficient for handling day-to-day operations. However,
when it comes to extracting insights and answering complex business questions, SQL queries in traditional databases can become 
lengthy and complex, often involving numerous table joins and key references. Data warehouses address this challenge by 
employing specialized schemas tailored for managerial inquiries and analytical tasks.

In this project, I employ the star schema design, which consists of a central fact table surrounded by dimension tables. 
This simplified structure facilitates the creation of concise and readable SQL queries, enabling more straightforward data 
analysis and reporting.

## Files Included

**superstore_data_warehouse_creation.sql:** This file contains the SQL script for creating the star schema necessary for conducting 
business analysis. It builds upon the database schema created in the superstore-pbi-database project. Please ensure consistency 
in database names when using this script.

**sql_business_questions_comparison.sql:** Here you'll find SQL code used to answer various business questions, comparing the complexity 
and readability of queries between the transactional database and the star schema.

**superstore_pbi_logical_model.png:** This image illustrates the crow's foot logical model for the original relational database 
(superstore-pbi-database).

**superstore_star_schema.png:** This image presents the logical model for the star schema implemented in the data warehouse. 
Note that primary keys are present in dimension tables, while foreign keys are used in the fact table.

## Design Considerations
In the star schema, some redundancy is intentionally incorporated to enhance the efficiency of business intelligence processes. 
This trade-off allows for faster query execution and simplified data analysis. Additionally, transitive dependencies may exist
within the schema, however this provides flexibility in querying and reporting.
