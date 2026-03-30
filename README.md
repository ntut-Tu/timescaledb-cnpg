# CNPG PostgreSQL 18 with TimescaleDB

A custom CloudNativePG (CNPG) image based on PostgreSQL 18 (`bookworm`), pre-configured with TimescaleDB and other essential extensions for time-series, geospatial, and vector workloads.

The release packages will be based on `releases` branch.

## Included Extensions

* `timescaledb-2` & `timescaledb-toolkit`
* `postgis-3`
* `pgvector`
* `h3`
