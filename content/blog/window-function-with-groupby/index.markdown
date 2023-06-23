---
title: 'How To: Group by & Window Functions Together'
author: Amit Grinson
date: '2023-06-15'
layout: single
slug: window-function-with-groupby
categories: [SQL]
tags: [SQL, window]
subtitle: 'Diving into using window functions following a GROUP BY clause - how it works.'
summary: 'A short overview of how to use window functions within a group by query. Going over 3 examples that help illustrate how to combine the two, as well as a better understanding the order of opertaions in SQL'
featured: yes
projects: []
format: hugo-md
editor_options: 
  chunk_output_type: inline
---






### Intro

I've been using both `GROUP BY` & Window functions since I started writing SQL, but never really in the same query. Thinking back I'm assuming I got an error one time and just thought them to be not compatible together so never really tried it since.

Not long ago I encountered a Stackoverflow answer that used a window function & Group by in the same query, and more recently I saw [Ram Kedem](https://ramkedem.com/en/about/) use it to solve a question from a [set of questions he posted online for practice](https://docs.google.com/document/d/1H4Jo215InMGDVxU7Zuk31cJeh8vy_knF1xJ-jtzXST0/edit?fbclid=IwAR1lmuH5GM3yqOpbXnavnBe_v26tD_ZG3cjqtqWeImwfXeBRR2vOI3LcEWA). I really liked the use there mainly because [I initially solved it](https://amitlevinson.github.io/streaming/arena-sql/) in a more cumbersome way (see question 5), so his solution seemed elegant. 

I've since started playing with the two (Windows & GROUP BY) more, so much that I also decided to go ahead and buy a book about it — ["T-SQL Window Functions: For data analysis and beyond"](https://www.amazon.com/gp/product/0135861446/ref=ppx_yo_dt_b_asin_title_o00_s00?ie=UTF8&psc=1). It's mainly about Window Functions but there's a small section specifically about the relationship of the two.

**This post is about some experimentation I did with both concepts and what it taught me about order of operations in a SQL query.** We'll start from a basic use case, move to a little more complex and end with what seems to me as an unintended use case, but helpful nonetheless (and valid SQL code!). 

{{% alert warning %}}
Basic knowledge in both SQL GROUP BY aggregations and Window functions is required. I will not be going over their basics here
{{% /alert %}}

Alright then, let's begin!

### Our Data

Similar to many recent posts of mine, we'll be looking at users and their payments information. Here's a brief glimpse of our data:

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

We've got users, their country, payment ids, dates and amounts. Great, let's go ahead and starting exploring.

#### Classic order by

So the first and pretty simple example would be to add a window function in the `ORDER BY` clause *after* an aggregation occurred. That is, sort the output by the evaluation of a window function, for example:


```sql
SELECT u.user_id,
  u.Country,
  SUM(amount) as total_funds
FROM USERS U 
LEFT JOIN PAYMENTS P ON P.USER_ID = u.user_id
GROUP BY u.user_id, u.country
ORDER BY COUNT(*) OVER (PARTITION BY country) DESC 
```


<div class="knitsql-table">


Table: Table 2: 7 records

|user_id |Country | total_funds|
|:-------|:-------|-----------:|
|1       |IL      |         446|
|2       |IL      |        2398|
|3       |IL      |        1011|
|4       |US      |         830|
|5       |US      |        1067|
|6       |FR      |         691|
|7       |FR      |        1305|

</div>

**The interesting thing to notice here is that the output is sorted by the frequency of a country in our outputted data: values created in a window function and not the aggregation itself.** In this case, we have 3 Israeli users and thus users with that country appear on top. I find this useful when I aggregate data for users and what interests me is another parameter I used in the group by, sorting the output using that (for example similar passwords when it comes to fraud). 

If you've run a few window functions you probably used this method; maybe also in a group by query without noticing. In comparison to the next parts, this also makes sense technically: an `ORDER BY` clause is evaluated after the `GROUP BY`, `HAVING` and even `SELECT`. So ordering by a vector created on the fly doesn't yet create 'tension' between the Window Function and `GROUP BY` being selected together. 

We got the easy part of the way, let's move forward to some deeper diving in and explore the `SELECT` area that I find more interesting for this post.

### The SELECT Clause

Our next two examples will focus on the `SELECT` statement and the relationship between Window Functions and `GROUP BY` there. One question you might have is why can't I use a window function *when the data is still grouped*? Let's see a quick example when we try to collect the total funds by user, but also aggregate the total amount for all users together as a new column (read as a window function of `SUM() OVER ()`).[^1]

[^1]: We could use `WITH ROLLUP` to get the total here in the bottom row, but for the sake of the tutorial let's ignore it for now (plus we want it as a column).

Here's what you'll probably get:


```sql
SELECT u.user_id,
  country,
  SUM(amount) AS total_funds,
  SUM(amount) OVER()
FROM USERS U 
LEFT JOIN PAYMENTS P ON P.USER_ID = u.user_id
GROUP BY u.user_id, Country
```

```
## Error: nanodbc/nanodbc.cpp:1655: 42000: [Microsoft][ODBC SQL Server Driver][SQL Server]Column 'PAYMENTS.amount' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.  [Microsoft][ODBC SQL Server Driver][SQL Server]Statement(s) could not be prepared. 
## <SQL> 'SELECT u.user_id,
##   country,
##   SUM(amount) AS total_funds,
##   SUM(amount) OVER()
## FROM USERS U 
## LEFT JOIN PAYMENTS P ON P.USER_ID = u.user_id
## GROUP BY u.user_id, Country'
```

Ha, that is weird! **The error states that the "_Payments.amount_ column is invalid in the select because it's not in either an aggregate function or `GROUP BY` clause." But we can see it right there in the row above our window function, aggregated as `total_funds`!**

What's going on here? Well hopefully in the next two examples you'll better understand this error, how you can actually do what we're trying here and how do these two concepts relate to one another when used in the same query.

### Ranking for additional filters

Let's assume you want to aggregate data, and then take the top X rows for each group. I've actually encountered this (what we'll see shortly) in a stackoverflow answer and later in one of [Ram Kedem](https://ramkedem.com/en/)'s online stream I previosuly noted. It was only when I played with it that I understood more how to use it.

So relating to our data, let's return users receiving the most funds within a given country:


```sql
WITH users_sum as (
SELECT u.user_id,
  u.Country,
  SUM(amount) AS total_funds,
  DENSE_RANK() OVER(PARTITION BY COUNTRY ORDER BY SUM(amount) DESC) as rnk
FROM USERS U 
LEFT JOIN PAYMENTS P ON P.USER_ID = u.user_id
GROUP BY u.user_id, u.country
)

SELECT user_id,
  Country,
  total_funds
FROM USERS_SUM
where rnk = 1
```


<div class="knitsql-table">


Table: Table 3: 3 records

| user_id|Country | total_funds|
|-------:|:-------|-----------:|
|       7|FR      |        1305|
|       2|IL      |        2398|
|       5|US      |        1067|

</div>

Nice! 

The relevant part for our discussion (and the purpose of this blog post) is the following line to create the `rnk` column:


```sql
DENSE_RANK() OVER(PARTITION BY COUNTRY ORDER BY SUM(amount) DESC) as rnk
```

What's interesting here is that we use the aggregate value of the group by, `SUM(Amount)`, within our new column that's a window function.

Now I'm not a SQL Server savvy, but here's my understanding of it from also reading Itzik Ben-Gan's book[^*]. To better understand this, here's a quick reminder of the order of operations in SQL:

[^*]: Do reach out and share insights about this process if you feel that I got it wrong here (or in the post in general).

1. `FROM`

1. `WHERE`

1. `GROUP BY`

1. `HAVING`

1. `SELECT`

1. `ORDER BY`

Following the `FROM` and others, Window functions are evaluated in the `SELECT` statement but separate from the `GROUP BY` operation statements. Itzik Ben-Gan in his book ["T-SQL Window Functions: For data analysis and beyond"](https://www.amazon.com/gp/product/0135861446/ref=ppx_yo_dt_b_asin_title_o00_s00?ie=UTF8&psc=1) describes this very well, where we can think of the two - When the `GROUP BY` aggregation happens and the evaluation of window functions - occurring in two different contexts: 

> "Grouped aggregates operate on groups of rows defined by the `GROUP BY` clause and return one value per group. Window aggregates operate on windows of rows and return one value for each row in the underlying query"

The `GROUP BY` occurs, we `SELECT` the relevant columns we want in our aggregation, and any window function in the `SELECT` is **evaluated on the post-aggregated data.** In a sense we reference the already-aggregated column `SUM(Amount)` as a column to sort our ranking window function we're creating!

### Aggregating the Aggregated data

**The previous example opens up an opportunity to use our aggregate results within a window function.** There we used it as an ordering clause in a window function, but can we use other forms of aggregation within the window function that reference the previous aggregation? That is, **aggregate what we just aggregated in the `GROUP BY`?**

Let's take an example Itzik's also shares to better explore this: How would you aggregate the total amount each user received, and the proportion of that amount out of the total funds for all users? And more specifically, can you do this in one query?

Well you can, let's have a look:


```sql
SELECT u.user_id,
  u.Country,
  SUM(amount) AS total_funds,
  SUM(amount) / SUM(SUM(amount)) OVER() * 100.0 AS pct_funds
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

Let's look into our important code line:


```sql
SUM(amount) / SUM(SUM(amount)) OVER() * 100 AS pct_funds
```


**What's happening here?** The first `SUM(amount)` is an aggregation from our intial `GROUP BY` clause we have. That's the total_funds for each variable. The second part `SUM(SUM(amount)) OVER()` might take a few readings to grasp but is something as follows: The most inner `SUM(amount)` references our `GROUP BY` aggregation as before, this is then wrapped within an outer `SUM` that invokes a window function with the `OVER()` command to get the total sum of the window passed in. 

**Basically we're dividing each user's funds that we *just* aggregated by the total funds of all users, which is calculated as a window function of summing all users aggregated funds.** This is also how we'd solve the error we got a few sections back. Lastly, we finalize it by multiplying with 100 to get a percentage value.

Personally, this was mind blowing when I played around with it and realized this worked. Only then did the order of operations for a given query with Window functions and Grouping actually clicked.

**I will say, however, that the above syntax might not be easily understood to someone first encountering this.** SQL is a declarative language that usually feels intuitive to read; this somewhat contradicts it. Though valid SQL code, and pretty cool nonetheless, maybe breaking it up to several parts (e.g. with CTE) would make it more readable for others if you're working on something collaboratively. 


### Closing notes

First off, I highly recommend Itzik Ben-Gan's book. I bought it when I learned what I shared in this blog post in order to learn more advanced SQL. I realized that while I know how to *use* window functions and construct them, I still have much more to discover. The book is fantastic and addresses a lot of topics ranging from basics of a window function to optimization. What I address in this post - The relationship between `GROUP BY` and Window Functions - is a very small section of the book, barely two pages; he covers a lot more.

The second thing I'd like to share is about my discovery of this and why it was exciting for me. I love learning new things, which I imagine most of us do. I've learned [correlated sub-queries](https://www.amitgrinson.com/blog/review-of-an-sql-interview-question/) a while back that was cool, [recursive CTE's](https://www.amitgrinson.com/blog/follow-the-money-with-a-recursion/), using things such as `CROSS/OUTER APPLY` and more. But they've all been new concepts altogether, so it was a different kind of excitement compared to what I shared here.

I've been using the `GROUP BY` clause since I started writing SQL a few years ago, and window functions not much after. I became better at both, learned how to maximize the use of them and general tips and tricks. However what I was hopefully able to convey in the post was a different kind of learning: **It was taking what seemed as two concepts I continuously used and learned more about how they each operate separately and in relation to one another.** Definitely an exciting thing to discover.

Hope you enjoyed it too!







