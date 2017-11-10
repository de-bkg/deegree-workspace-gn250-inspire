# deegree workspace for GN250 INSPIRE
Workspace configuration for deegree implementing INSPIRE services for the Geographical Names 1:250.000 (GN250).

This workspace configuration uses extended INSPIRE-schemas from the European Location Framework (ELF) project.

The following INSPIRE themes are implemented:
* Geographical Names

## Database

The _sql folder contains scripts for creating the required database structures. 
The scripts are optimized for PostgreSQL/PostGIS.

Each INSPIRE theme has its own database schema. Per default the user inspire is owner of all schemas and tables.

## Adjustments

The database connection parameters must be adjusted in jdbc/gn_inspire.xml.
