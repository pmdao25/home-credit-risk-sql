# Home Credit – Credit Risk Analysis in SQL

A personal SQL Server project on the Home Credit Default Risk dataset. The goal is to classify customers into debt groups by days past due, following Vietnam's Circular 11/2021/TT-NHNN.

**Status:** in progress. Data loading and profiling are done.

## What this project measures

Credit risk at customer level: how likely a customer is to have trouble repaying, and which data explains it.

- **Default rate:** share of customers with `TARGET = 1` (about 8.07% overall).
- **Days past due:** actual payment date minus due date, per instalment of previous loans.
- **Debt group (1–5):** classification by worst days past due (planned).

Each analysis splits customers into groups and compares the default rate of each group.

## Data

Source: [Home Credit Default Risk (Kaggle)](https://www.kaggle.com/c/home-credit-default-risk/data). Data files are not included.

| Table | Rows | One row is |
|---|---|---|
| `application_train` | 307,511 | One loan application, with the `TARGET` column |
| `installments_payments` | 13,605,401 | One payment towards an instalment of a previous loan |

## SQL files

**`SQLQuery1_Nạp data.sql` – loading.** Builds `application_train` with 23 working columns from the raw table, bulk-loads `installments_payments`, adds indexes, and verifies row counts and the `TARGET` rate.

**`SQLQuery2_kiểm tra dữ liệu.sql` – profiling.** Checks missing data, percentiles and outliers, default rate by category and by numeric band, and consistency between columns. For the instalment table, it checks size, coverage of customers, payment lateness and unusual values.

## Findings so far

- **External credit scores separate risk far better than income.** Across five equal groups, default falls from about 15–16% to about 3% for each `EXT_SOURCE` score (4–5x), against 1.3x for income.
- **`DAYS_EMPLOYED = 365243` is a special code** for pensioners and unemployed customers, the same group as `ORGANIZATION_TYPE = 'XNA'`.
- **Default rises with the number of children:** 7.71% with none, 12.82% with four. Values of seven or more cover only 21 customers and include likely entry errors.
- **Income has an extreme outlier:** a maximum of about 117 million against a 99th percentile of about 470 thousand.

## SQL techniques

`BULK INSERT`, CTEs, `CASE WHEN` grouping, window functions (`NTILE`, `SUM() OVER`), `CROSS APPLY (VALUES ...)` to unpivot, `APPROX_PERCENTILE_CONT`.

## Next steps

Clean the application table, compute days past due per instalment, assign debt groups 1–5 and validate them against actual default rates. Part 2 will cover market risk on stock price data (volatility, VaR, maximum drawdown).

## Limitations

The data is not from the Vietnamese market, so the Circular 11 thresholds are applied to demonstrate the method. Results show correlation, not causation.
