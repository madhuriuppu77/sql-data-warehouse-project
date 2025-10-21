/*
===============================================================
 Script: Create Database and Schemas
 Author: <Your Name>
 Date: <Date>
===============================================================
 Purpose:
 This script creates a new database named 'DataWarehouse' after 
 checking if it already exists. If the database exists, it is 
 dropped and recreated. Additionally, the script sets up three 
 schemas within the database:
   - bronze
   - silver
   - gold

 WARNING:
 Running this script will DROP the existing 'DataWarehouse' 
 database if it exists. All data in the database will be 
 permanently deleted. Proceed with caution and ensure you 
 have proper backups before running this script.
===============================================================
*/

-- Step 0: Switch to the master database
USE master;
GO

-- Step 1: Drop the existing 'DataWarehouse' database if it exists
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    PRINT 'Database "DataWarehouse" already exists. Dropping it...';
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
    PRINT 'Existing database dropped successfully.';
END;
GO

-- Step 2: Create the new 'DataWarehouse' database
PRINT 'Creating new database "DataWarehouse"...';
CREATE DATABASE DataWarehouse;
PRINT 'Database "DataWarehouse" created successfully.';
GO

-- Step 3: Switch context to the new database
USE DataWarehouse;
PRINT 'Switched to "DataWarehouse" database.';
GO

-- Step 4: Create Schemas
PRINT 'Creating schema: bronze...';
GO
CREATE SCHEMA bronze;
GO
PRINT 'Schema "bronze" created successfully.';
GO

PRINT 'Creating schema: silver...';
GO
CREATE SCHEMA silver;
GO
PRINT 'Schema "silver" created successfully.';
GO

PRINT 'Creating schema: gold...';
GO
CREATE SCHEMA gold;
GO
PRINT 'Schema "gold" created successfully.';
GO

PRINT 'All schemas created successfully. DataWarehouse setup complete.';
