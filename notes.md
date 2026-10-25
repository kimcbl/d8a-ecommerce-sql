# Notes

## Decisions

### 1. Duplicate orders are removed
**Rule:** every query reads from `(SELECT DISTINCT * FROM orders)` instead of `orders`.

**Why:** 20 order rows are exact copies of another row: same id, customer, date, status and amount. A real second sale would have its own order id, so these are loading errors and not extra business. Keeping them would count those sales twice. They add $9,094 to completed revenue ($2,511,444 with them, $2,502,349 without), which is 0.36%. The amount is small, but removing them is the honest choice.

### 2. Orders without an amount still count as orders
**Rule:** an order with an empty `total_amount` still counts in `order_count`. `SUM()` and `AVG()` skip it automatically, so it adds nothing to revenue and is left out of the average order value.

**Why:** the order happened; we just don't know its value. Counting it as $0 would make the average order value look lower than it really is. After removing duplicates there are 200 such orders, and 124 of them are completed. So in Q1, Q2 and Q5, `order_count` includes orders that add no revenue, and `avg_order_value` is the average of the orders that do have an amount.

### 3. Customers without a country are grouped as "Unknown"
**Rule:** `COALESCE(NULLIF(TRIM(country), ''), 'Unknown')`.

**Why:** 48 customers have a blank country. Dropping them would lose 3.46% of revenue, and the country shares in Q3 would no longer add up to 100.

### 4. Status and segment are cleaned before comparing
**Rule:** always compare `LOWER(TRIM(status))` and `LOWER(TRIM(segment))`.

**Why:** the raw data spells the same status in several ways, such as `completed` and `Completed`, or `shipped` with a space in front, or `PENDING`. Without cleaning, 257 completed orders would be missed.

### 5. Two revenue sources: one for product questions, one for order questions
**Rule:**
- **Product questions** (A1) use **order line revenue**: `SUM(quantity * unit_price)` from `order_items`, on completed orders.
- **Order questions** (Q1–Q6, A2) use **order revenue**: `SUM(total_amount)` from `orders`, on completed orders.

**The two sources do not match.** For the same 3,103 completed orders, the order lines add up to **$8,616,325**, but `total_amount` adds up to **$2,502,349**. That's 3.4 times less, a gap of $6,113,975 (from `sql/03_revenue_sources.sql`):
- 2,979 of the 3,103 completed orders have a `total_amount` that differs from the sum of their lines.
- Every completed order has at least one line, so missing lines are not the cause.
- `order_items` has no duplicate rows, so double counting is not the cause either.
- 1,882 of the 9,423 order lines have a `unit_price` that differs from the product's list price.

**Why I kept them apart:** a product's sales can only be measured from the order lines, and an order's value is recorded in `total_amount`. Mixing the two in one answer would give a number that matches neither. So never compare A1's figures with Q1–Q6 or A2. The cause of the gap needs to be checked with whoever owns the data. It could be discounts, a different currency or unit, or test data, but I can't tell from these tables.

## Data checks (from `sql/02_data_quality.sql`)

| Check | Result |
|---|---|
| Rows loaded | customers 1,200 · orders 5,020 · products 200 · order_items 9,423 |
| Exact duplicate order rows | 20 |
| Different spellings of status | 10 raw values → 5 real statuses |
| Orders without an amount (deduplicated) | 200 (124 completed, 27 shipped, 19 cancelled, 19 pending, 11 refunded) |
| Customers without a country | 48 |
| Orders whose customer doesn't exist | 0 |
| Order dates | 2023-01-01 to 2024-12-30 |
| Completed revenue: orders vs order lines | $2,502,349 vs $8,616,325 (they don't match) |
| Duplicate order_items rows | 0 |

## How I checked the numbers
- The row counts after loading match the CSV files: 1,200 / 5,020 / 200 / 9,423.
- The Q5 groups add up to $2,502,349, which equals total completed revenue. The 24 months in A2 add up to the same figure.
- The Q3 country shares add up to 100% (100.01 after rounding).
- The Q4 monthly order counts add up to 5,000, which is 5,020 rows minus the 20 duplicates. The 464 cancelled orders equal 431 `cancelled` plus 33 `Cancelled`.
- A1 returns 30 rows (10 categories × 3) and A2 returns 24 rows (24 months).

## Things I noticed
- Maria Rodriguez (customer 372) is our 2nd best customer at $71,597, but her last purchase was on 18 Oct 2023. She is on the Q6 win-back list and should be first in line for Marketing.
- Desk Model 85 brought in $1.48M of order-line revenue, about 17% of all product sales and more than 10 times the next desk. That is suspicious enough to check before anyone acts on it.
- Over the full year, 2024 revenue was 9.3% lower than 2023 ($1,189,874 against $1,312,475), even though the second half of 2024 was stronger than the first.
- Cancellations rose in the last two months of 2024 (10.2% and 11.1%). The same thing happened in the spring of both years, so it's worth watching, but it isn't a trend yet.
