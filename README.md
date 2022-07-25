# Aztec Connect Dune Repo
Placeholder repo for Aztec dune queries. Ideally this should be part of Aztec's broader repo ecosystem. There's various existing dashboards documented, and the views created should allow an easy baseline for Dune wizards to go ham on public Aztec Connect usage data.

The repo separates logical categories into folders:
1. Adhoc Queries - various useful queries for data exploration and other random tasks
2. Dashboards - Production Dune dashboards. That way we have version control on the queries. Each query corresponds to one sql file.
  * Aztec Connect Bridge Leaderboard - For bridge-level stats, provide some motivation for independent bridge operators
  * Aztec Connect KPIs - For general usage and revenue across Aztec Connect
  * Data Quality - Data quality dashboard for verifying that bridge labels and price feeds are operating as expected. Also placeholder spot for corroborating data sources, i.e. inner proof logs vs. asset transfers
3. Views - Common transformations that are useful for understanding Aztec Connect data.