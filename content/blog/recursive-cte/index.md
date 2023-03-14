---
title: Recursive CTE to Identify Money Transfers
author: Amit Grinson
date: '2023-08-29'
layout: single-sidebar
slug: recursive-cte
categories: [SQL]
tags: [SQL, Recursion]
subtitle: 'Learning recursive CTEs by following money layering and transfers'
summary: 'Though not commonly used, recursive CTEs can be a great tool to work with hierarchal formatted data. In this post we learn to use them to identify where money was moved to by following users transfer activities'
featured: yes
projects: []
mermaid: true
format: hugo-md
editor_options: 
  chunk_output_type: inline
---



> "Roses are red  
> Violets are blue,  
> Write a Recursion
> and the DBA will find you"

<br>

Recursive CTEs is one of those things I occasionally encountered but never really understood. When I did sought out information to learn mroe about it, it was usually one of those 'identify who's who's boss'. While this may work for some, to me it seem like a far fetched example completely unrelated to my work.

The first time I used it was to calculate the weekdays for a given day from the start of the year, an example from Anthony Molinaro's "SQL Cookbook". It worked great and finally clicked how I can further use this. When I wanted to share it with my team, I thought of a more relateable example of using it to identify where the funds went (more on that below).

Hopefully either example (the generic and mine) will help you grasp it a little more. It's probably not a hammer to be used frequently, but not bad to have it in your toolbox.

<details>
<summary>
Setting up a SQL connection
</summary>

I write my blog using the [Rstudio IDE](https://posit.co/) and although this post will focus on SQL, we need to set up a local SQL connection. We're basically connecting to our local RDBMS, here MSSQL, and to a database I setup earlier.

``` r
library(odbc)
library(DBI)

sqlconn <- dbConnect(odbc(),
                      Driver = "SQL Server",
                      Server = "localhost\\SQLEXPRESS",
                      Database = "recursion")
```

We also need to load the data for this post to the database. It's only needed once and we can do it in R as follows:

``` r
dat <- read.csv('content/blog/recursive-cte/payments.csv', colClasses = c('numeric', 'character', 'character', 'numeric', 'Date'))

dbWriteTable(conn = sqlconn, 'payments', dat, field.types = c(payment_id = 'INT', payer = 'VARCHAR(10)', 
                                                  receiver = 'VARCHAR(10)', amount = 'INT',
                                                  payment_date = 'DATE'), overwrite = TRUE)
```

**Aside:** Moving forward we'll be using SQL code only. instead of having to write SQL code through some R function we can use the SQL engine directly in the code chunks. Just add the connection you created to the chunk header as such:

``` r
cat("```{sql connection='sqlconn', echo = TRUE}", '/* SQL code goes here */', '```', sep = '\n')
```

`{sql connection='sqlconn', echo = TRUE} /* SQL code goes here */`

</details>

## Basic Example

Well, before we talk about a recursive CTE let's briefly discuss a recursion in general. A recursion, as Wikipedia notes, is defined in terms of itself or of its type. In other words, I like to think of it as something that calls itself.

In SQL (here MSSQL), **a recursion comes into play with a Common table expression (aka CTE), where we call the table we're currently evaluating.**

For example, to count until 10 (1000, ...) in SQL, we can run the following:

``` sql
WITH RecursiveCTE as (
  SELECT 1 as N
  UNION ALL
  SELECT N + 1 as N
  FROM RecursiveCTE
  WHERE N < 10
)

SELECT * FROM RecursiveCTE
```

| N   |
|:----|
| 1   |
| 2   |
| 3   |
| 4   |
| 5   |
| 6   |
| 7   |
| 8   |
| 9   |
| 10  |

Displaying records 1 - 10

### Block Breakdown

Let's break that query up and understand how it works:

1.  The first part `SELECT 1 as N` is basically the Anchor. You must have one as it sets the ground for the recursion to follow, building up on that.

2.  The second piece is a `UNION ALL` which is required in a recursive CTE. It basically makes sure all rows are returned, 'stacking them on top of one another.

3.  The third part is, in a sense, the recursion itself. When calling the CTE were creating we're bring the value we selected previously before the union --- `1`. We select the value and add a 1 to it, returning for the second iteration the values 1, 2 (unioned). This repeats for the third, fourth... until we reach a threshold we set, `WHERE N < 10`, and our query breaks out.

A threshold is important to break out, especially if the complexity of the problem *might* increase substantially in each iteration as we'll see shortly. Besides the exit option in the `WHERE` clause, the default recursion will go to a max of 100 iterations.

------------------------------------------------------------------------

Unlimited Iterations and Errors

Running the above query for more iterations on the default max (of 100) will throw an error:

XXXXXXX Error XXXXXXX

If you want your recursion to go more than 100 iterations, just set the maxrecursion option to what you need, for example:

``` sql
WITH RecursiveCTE AS (
 ...
)

SELECT * FROM RecursiveCTE
OPTION(MAXRECURSION 200)
```

``` sql
WITH RecursiveCTE as (
  SELECT 1 as N
  UNION ALL
  SELECT N + 1 as N
  FROM RecursiveCTE
  WHERE N < 1000
)

SELECT * FROM RecursiveCTE
```

| N   |
|:----|
| 1   |
| 2   |
| 3   |
| 4   |
| 5   |
| 6   |
| 7   |
| 8   |
| 9   |
| 10  |

Displaying records 1 - 10

I'd think carefully before running an unlimited recursion. But if you do, set the `MAXRECURSION` to 0 and hope your breaking option in the WHERE caluse will help.

------------------------------------------------------------------------

## Following the Money

### The Network & Problem

Let's move on to a more practical example, or at least more practical for me. Payoneer is a payments platform and as a result we analyze large quantities of payments. A scenario that might occur is wanting to track the flow of money sent from one user to another, and then from that user to another and so on down the chain.

So far example, looking at the below figure, assuming Bob is the first step in the process, can we identify where the funds ended up (i.e., with Hanah)?

**Why does a recursion help here?** Well, usually actions like these - a payment of sort - are recorded in a tabular normalized way --- Each row contains the information about one payment, from one payer to one receiver. Even multiple transactions between the same two pairs of individuals will be recorded in separate rows. \*\*This makes it a little complex to track multiple 'hops' between users, making multiple joins a very problematic approach.

<div class="mermaid">

title\[<u>My Title</u>\]
graph LR;
title Flow of funds between users
A(User Bob)--1--\>B(User Dan);
B(User Dan)--2--\>C(User Joe);
C(User Joe)--3--\>D(User Sarah);
C(User Joe)--3--\>E(User Sharon);
E(User Sharon)--4--\>F(User Fred);
D(User Sarah)--4--\>G(User Greg);
G(User Greg)--5--\>H(User Hanah);
F(User Fred)--5--\>H(User Hanah);
caption Given a user, we'd like to know where the funds ended up

</div>

<script async src="https://unpkg.com/mermaid@8.2.3/dist/mermaid.min.js"></script>

Identifying the chain of transactions shows us **where the funds ended up as well as other actors participating along the way, returning a network of senders (payers) and receivers**. This could be relevant to identify patterns of money layering, sending funds between users to masquerade the funds, as well as mapping out large networks and their connections.

#### The Data

Let's have a look at our data:

``` sql
SELECT * 
FROM Payments
```

| payment_id | payer | receiver | amount | payment_date |
|:-----------|:------|:---------|-------:|:-------------|
| 1          | A     | B        |    320 | 2023-01-14   |
| 2          | B     | C        |    301 | 2023-01-15   |
| 3          | C     | D        |    150 | 2023-01-16   |
| 4          | C     | E        |    142 | 2023-01-16   |
| 5          | E     | F        |    141 | 2023-01-17   |
| 6          | D     | G        |    148 | 2023-01-17   |
| 7          | F     | H        |    140 | 2023-01-18   |
| 8          | G     | H        |    140 | 2023-01-18   |

8 records

Our table records payments between users, with each payment recorded as a separate row. We can reframe our whole discussion with the following questions, **given you identified Bob, can you follow the funds to where they ended up?**

### Solution

Let's start by solving it and then we'll break the recursion structure as well as discuss other scenarios:

``` sql
WITH recursivePayments AS (
  SELECT 1 AS Iteration,
    'Bob' as Source,
    Payments.* 
  FROM Payments
  WHERE Payer = 'A'
  UNION ALL
  SELECT Iteration + 1 AS Iteration,
    Source,
    p.payment_id,
    p.Payer,
    p.receiver,
    p.amount,
    p.payment_date
  FROM recursivePayments rp
  JOIN Payments p on rp.receiver = p.payer
    and rp.payment_date < p.payment_date
  WHERE Iteration <= 5
)

SELECT * 
FROM recursivePayments
ORDER BY Iteration
```

| Iteration | Source | payment_id | payer | receiver | amount | payment_date |
|----------:|:-------|-----------:|:------|:---------|-------:|:-------------|
|         1 | Bob    |          1 | A     | B        |    320 | 2023-01-14   |
|         2 | Bob    |          2 | B     | C        |    301 | 2023-01-15   |
|         3 | Bob    |          3 | C     | D        |    150 | 2023-01-16   |
|         3 | Bob    |          4 | C     | E        |    142 | 2023-01-16   |
|         4 | Bob    |          5 | E     | F        |    141 | 2023-01-17   |
|         4 | Bob    |          6 | D     | G        |    148 | 2023-01-17   |
|         5 | Bob    |          8 | G     | H        |    140 | 2023-01-18   |
|         5 | Bob    |          7 | F     | H        |    140 | 2023-01-18   |

8 records
