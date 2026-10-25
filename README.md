# E-commerce Sales Analysis with SQL

A beginner data analyst project. I loaded two years of orders from an online electronics shop (2023–2024) into PostgreSQL. Then I answered eight questions from my manager, each with a single SQL query and a one-sentence answer that someone with no SQL background can read. The data has real-world problems: duplicate rows, inconsistent status spelling, missing amounts, missing countries, and two revenue sources that don't agree. Part of the work was deciding how to handle each one.

**Tools:** PostgreSQL 18, psql

## Key findings

### Business questions ([business_queries.sql](business_queries.sql))

| # | Question | Answer |
|---|---|---|
| Q1 | Who are our 5 best customers? | Our top 5 customers spent $335,295 between them (13% of all completed revenue), led by Sophie Leclerc with $80,762 from just 3 orders. |
| Q2 | How did revenue move month by month in 2024? | 2024 brought in $1.19M; revenue dipped to a low of $66,148 in April, then grew so the second half earned 35% more than the first, peaking at $156,717 in September. |
| Q3 | Which countries bring the revenue? | Revenue is spread evenly across 12 countries, with the USA biggest at 10.9% ($273,428) and USA, Canada and Germany together bringing 29%; customers with no country on file account for 3.5%. |
| Q4 | Are cancellations getting worse? | No: about 9.3 of every 100 orders were cancelled in both 2023 and 2024, and monthly rates swing between 6.3% and 12.9% with no upward trend. |
| Q5 | Do enterprise customers buy differently? | No, the opposite: an enterprise order is worth $691 on average, about 20% less than the $863 of other customers, so Sales' belief is not supported. |
| Q6 | Which customers have gone quiet? | 497 past customers have not bought anything since 1 July 2024, and they have been quiet for between 184 and 724 days. |

### Advanced questions ([advanced_queries.sql](advanced_queries.sql))

| # | Question | Answer |
|---|---|---|
| A1 | What are the 3 best-selling products in each category? | Desk Model 85 is by far our best seller with $1.48M in sales, more than twice the next product (Charger Model 180, $647,520), and in 5 of the 10 categories the number 1 product sells at least twice as much as the number 2. |
| A2 | How does revenue change from one month to the next? | Revenue jumps around a lot from month to month, from a 40.7% drop in October 2024 to a 110.5% rise in June 2023, and over the full year 2024 brought in 9.3% less than 2023 ($1.19M against $1.31M). |

**Worth acting on:** Maria Rodriguez is our 2nd best customer ($71,597), and she hasn't bought anything since October 2023. She should be first on the win-back list.

## Decisions

1. **Duplicate orders are removed.** 20 order rows are exact copies of another row. A real repeat sale would have its own order id, so these are loading errors. Every query reads from `(SELECT DISTINCT * FROM orders)`. This lowers completed revenue by 0.36%.
2. **Orders without an amount still count as orders.** 200 orders have no amount. They count in `order_count`, but `SUM` and `AVG` skip them, so they don't pull the average order value down as if they were $0.
3. **Customers without a country are grouped as "Unknown".** 48 customers have a blank country. Keeping them as their own group means the country shares add up to 100%.
4. **Status and segment are cleaned before comparing.** The raw data has 10 spellings of 5 statuses (for example `Completed` and `completed`), so every comparison uses `LOWER(TRIM(...))`.
5. **Product questions use order-line revenue and order questions use order totals, and the two don't match.** A1 uses `quantity * unit_price` from `order_items`, while Q1–Q6 and A2 use `total_amount` from `orders`. For the same completed orders, the lines add up to $8.62M but the order totals only to $2.50M. So the two sets of figures are never compared or mixed.

More detail, with the data-check results, is in [notes.md](notes.md).

## Interview script

**1. What problem did you work on, and for whom?**
My manager sent eight questions about an online electronics shop: who the best customers are, how revenue moves over time, whether cancellations are rising, and whether enterprise accounts are really worth more. Sales and Marketing were waiting for the answers. Sales wanted to know whether to focus on enterprise accounts, and Marketing wanted a list of customers to win back.

**2. What data did you use, and what are its limits?**
I used four tables covering January 2023 to December 2024: 1,200 customers, 5,020 orders, 200 products and 9,423 order lines. The data had 20 duplicate orders, which I removed, plus 200 orders with no amount and 48 customers with no country. The biggest limit is that the order lines add up to 3.4 times more than the order totals ($8.62M against $2.50M). So I can rank products against each other, but I can't say how much of the shop's revenue each product brings.

**3. How did you go about it, and why that way?**
I loaded the CSVs into PostgreSQL and first ran a set of data-quality queries, because a single `GROUP BY status` showed 10 spellings of 5 statuses. I wrote my cleaning rules down once (remove duplicates, normalise status, keep blank countries as "Unknown") and applied them the same way in every query, so all the numbers can be compared with each other. I used SQL because the questions are all counts, sums and rankings over related tables. For the rankings and month-to-month change I used window functions (`ROW_NUMBER`, `LAG`), because they give the answer in one query.

**4. What did you find? Give the key number.**
Sales believes enterprise customers are worth more per order, but an enterprise order averages $691, which is 20% less than the $863 from other customers. I also found that one of our two best customers, worth $71,597, hasn't bought anything since October 2023.

**5. How do you know it is right?**
I checked that the row counts after loading matched the CSV files. I checked that the totals reconcile across queries: the Q5 groups and the 24 months in A2 both add up to the same $2,502,349 of completed revenue, and the country shares in Q3 add up to 100%. Each query also passed the course playground's automatic check.

**6. With one more day, what would you do?**
I'd find out why the order lines are worth 3.4 times the order totals, because until that's explained, every product figure is uncertain. I'd start with Desk Model 85, which alone is 17% of all product sales and more than 10 times the next desk, so it's either a real hit or a data error. Then I'd look at why 2024 revenue was 9.3% below 2023.

**7. What did you hand to an AI assistant, and what did you check yourself?**
I used Claude to draft the setup script, the data-quality checks and first versions of the queries, and to help word the one-sentence answers. I decided the cleaning rules myself, such as removing the duplicates and keeping blank countries as "Unknown". I ran every query on my own database and in the course playground, checked the row counts and the totals against each other, and confirmed that every number in the answers comes from the query output.

## Data

| Table | Rows | Columns |
|---|---|---|
| customers | 1,200 | id, name, country, segment, signup_date, email, phone |
| orders | 5,020 | id, customer_id, order_date, status, total_amount |
| products | 200 | id, name, category, price, cost |
| order_items | 9,423 | id, order_id, product_id, quantity, unit_price |

The data is fictional and was provided as course material.

## Repo structure

```
d8a-ecommerce-sql/
├── data/                       # the four source CSV files
├── sql/
│   ├── 01_setup.sql            # create the database and tables, load the CSVs
│   ├── 02_data_quality.sql     # checks for duplicates, messy values and missing data
│   ├── 03_revenue_sources.sql  # compares order totals with order-line revenue
│   ├── run_all.sql             # setup + checks + business queries in one go
│   ├── load_data.sql           # load CSVs into existing empty tables, then run
│   ├── run_queries.sql         # checks + business queries only
│   └── run_advanced.sql        # revenue-source check + advanced queries
├── business_queries.sql        # Q1–Q6: questions, answers and queries
├── advanced_queries.sql        # A1–A2: window-function questions
├── results.txt                 # output of the business queries
├── results_advanced.txt        # output of the advanced queries
├── notes.md                    # decisions, data checks and how I verified the numbers
└── README.md
```

## What I learned
- Look at the data before writing queries: a simple `GROUP BY status` exposed 10 spellings of 5 statuses.
- `COUNT(*)` counts rows with NULLs, but `SUM` and `AVG` ignore them. That difference decides what an average means.
- Write the cleaning rules down once and apply them the same way everywhere, so every number in the report can be compared with the others.
- Two columns that both look like "revenue" can tell very different stories. Reconcile them before trusting either one.
- Window functions (`ROW_NUMBER`, `LAG`, `SUM(...) OVER ()`) handle rankings, previous-month values and percent-of-total in a single query.
