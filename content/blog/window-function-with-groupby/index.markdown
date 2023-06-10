---
title: Using window functions after a GROUP BY clause
author: Amit Grinson
date: '2023-06-15'
layout: single
slug: window-function-with-groupby
categories: [SQL]
tags: [SQL, window]
subtitle: 'Leveraging window functions following a group by clause'
summary: 'A short overview of how to use window functions within a group by query. Going over 3 examples that help illustrate how to combine the two, as well as a better understanding the order of opertaions in SQL'
featured: yes
projects: []
format: hugo-md
editor_options: 
  chunk_output_type: inline
---





```r
payments <- read.csv('content/blog/window-function-with-groupby/payments.csv', colClasses = c('numeric', 'character', 'Date', 'numeric'))

dbWriteTable(conn = sqlconn, 'payments', payments, field.types = c(user_id = 'INT', payment_id = 'VARCHAR(12)',payment_date = 'DATE', amount = 'DECIMAL(5,2)' ), overwrite = TRUE)

users <- read.csv('content/blog/window-function-with-groupby/users.csv')

dbWriteTable(conn = sqlconn, 'users', users, field.types = c(user_id = 'INT', country = 'VARCHAR(2)'), overwrite = TRUE)
```

### Intro

I've been using both `GROUP BY` & Window functions for a while now, but for some reason I never thought of combining them. Maybe I tried once and used it wrong, got an error and felt intimidated since. 

Not long ago I encountered a Stackoverflow answer that used a window function & Group by in the same query, and more recently I saw [Ram Kedem] use it to solve a question from a set of questions he posted online. I really liked the use there mainly because I initially solved it in a more cumbersome way, so his solution seemed elegant and informative.

I've since started playing with the two more, so much that I also decided to go ahead and buy a book about it — ["T-SQL Window Functions: For data analysis and beyond"](https://www.amazon.com/gp/product/0135861446/ref=ppx_yo_dt_b_asin_title_o00_s00?ie=UTF8&psc=1).

This post is about some experimentation I played around, and what it taught me about order of operations in a SQL query. We'll start from a basic use case, move to a little more complex and end with what seems as an unintended use case. I'm not that well versed in the SQL infrastructure to state it's an unindetend use, but I have to admit it just doesn't seem right (though it is pretty cool how we'll use it!).

> Basic knowledge in both SQL aggregations and window functions is required. I will not be going over their structure.

Alright then, let's begin!

### Our Data

Similar to many recent posts of mine, we'll be looking at payments information. We also have in another table some information about the users, specifically their countries. Here's a brief glimpse of our data:

<details>
<summary>Setting up a SQL connection in R</summary>

Since I write my blog posts using R, we need to setup a SQL connection to our SSMS localhost. We can do it with the following, and then moving forward just write SQL syntax in a regular code chunk.


```r
library(odbc)
library(DBI)

sqlconn <- dbConnect(odbc(),
                      Driver = "SQL Server",
                      Server = "localhost\\SQLEXPRESS",
                      Database = "window_groupby")
```

</details>


```sql
SELECT TOP 5 * 
FROM USERS U 
LEFT JOIN PAYMENTS P ON P.USER_ID = u.user_id;
```


<div class="knitsql-table">


Table: Table 1: 5 records

| user_id|country | user_id|payment_id  |payment_date | amount|
|-------:|:-------|-------:|:-----------|:------------|------:|
|       1|IL      |       1|754159275-7 |2023-04-03   |    122|
|       1|IL      |       1|841959830-5 |2023-04-06   |    169|
|       1|IL      |       1|780694055-3 |2023-02-17   |    126|
|       1|IL      |       1|871148278-8 |2023-01-19   |     29|
|       2|IL      |       2|795256048-4 |2023-01-04   |    313|

</div>

Great, this will enable us TO aggregate while maintaining other columns we'll manipulate in our window functions. Speaking of them, let's go ahead and start experimenting.


### Classic order by

So the first and pretty simple example would be to add simple window function in the `ORDER BY` clause *after* an aggregation occurred. That is, sort the output by the evaluation of a window function, for example:


```sql
SELECT u.user_id,
  u.Country,
  SUM(amount)
FROM USERS U 
LEFT JOIN PAYMENTS P ON P.USER_ID = u.user_id
GROUP BY u.user_id, u.country
ORDER BY COUNT(*) OVER (PARTITION BY country) DESC 
```


<div class="knitsql-table">


Table: Table 2: 7 records

|user_id |Country |     |
|:-------|:-------|----:|
|1       |IL      |  446|
|2       |IL      | 2398|
|3       |IL      | 1011|
|4       |US      |  830|
|5       |US      | 1067|
|6       |FR      |  691|
|7       |FR      | 1305|

</div>

The interesting thing to notice here is that the output is sorted by the frequency of a country in our outputted data. In this case, we have 3 Israeli users and thus that country appears on top. I find this useful when I aggregate data for users and what interests me is another parameter I used in the group by, sorting the output using that (for example similar passwords). 

If you've run a few window functions you probably used this method; maybe also in a group by query. We got the easy part of the way, let's move forward to some deeper diving in.

### Ranking for additional filters

Let's assume you want to aggregate data, and then take the top X rows for each group. I've actually encountered this (what we'll see shortly) in a stackoverflow answer and later in one of [Ram Kedem](https://ramkedem.com/en/)'s online stream. It was only when I played with it that I understood more how to use it.

So relating to our data, let's return users receiving the most funds within a given country.


```sql
WITH users_sum as (
SELECT u.user_id,
  u.Country,
  SUM(amount) AS total_sum,
  DENSE_RANK() OVER(PARTITION BY COUNTRY ORDER BY SUM(amount) DESC) as rnk
FROM USERS U 
LEFT JOIN PAYMENTS P ON P.USER_ID = u.user_id
GROUP BY u.user_id, u.country
)

SELECT user_id,
  Country,
  total_sum
FROM USERS_SUM
where rnk = 1
```


<div class="knitsql-table">


Table: Table 3: 3 records

| user_id|Country | total_sum|
|-------:|:-------|---------:|
|       7|FR      |      1305|
|       2|IL      |      2398|
|       5|US      |      1067|

</div>

Nice! 

The key part here is the `rnk` column we create which I believe also highlights the order of operations in our query: We use the aggregate value of the group by, `SUM(Amount)`, within our new column that's a window function.

In terms of order of operations it goes as follows:

1. `FROM`

...

2. `GROUP BY`

3. `HAVING`

4. `SELECT`

5. `ORDER BY`

Window functions are evaluated in the `SELECT` statement but separate from the `GROUP BY` operation. Itzik Ben-Gan in his book XXX describes this very well:

> Some quote from Itzik's book.



So in this case, we order our window function conditional on the aggregate sum we called per user. The window function is evaluated separately from the aggregate, in what seems as different contexts altogether.

### New variables based on grouped outputs

The previous example opens up an opportunity to use our aggregate results within a window function. There we used it as an ordering clause, but can we use other forms of aggregation within the window function that reference the previous aggregation? That is, aggregated what we just aggregated?

Let's take an example to better explore this: How would you aggregate the total amount each user received, and the proportion of that amount out of the total funds for all users? And more specifically, can you do this in one query?

Well you can, let's have a look:


```sql
SELECT u.user_id,
  u.Country,
  SUM(amount) AS total_funds,
  SUM(amount) / SUM(SUM(amount)) OVER() * 100 AS pct_funds
FROM USERS U 
LEFT JOIN PAYMENTS P ON P.USER_ID = u.user_id
GROUP BY u.user_id, u.country
ORDER BY pct_funds DESC
```


<div class="knitsql-table">


Table: Table 4: 7 records

| user_id|Country | total_funds| pct_funds|
|-------:|:-------|-----------:|---------:|
|       2|IL      |        2398|   30.9499|
|       7|FR      |        1305|   16.8430|
|       5|US      |        1067|   13.7712|
|       3|IL      |        1011|   13.0485|
|       4|US      |         830|   10.7124|
|       6|FR      |         691|    8.9184|
|       1|IL      |         446|    5.7563|

</div>

Et Voila!

Though this seems like weird syntax it's valid nonetheless.



