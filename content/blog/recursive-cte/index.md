---
title: Recursive CTE to Identify Money Transfers
author: Amit Grinson
date: '2023-08-29'
layout: single
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

Recursive CTEs is one of those things I occasionally encountered but never really understood. When I did sought out information to learn mroe about it, it was usually one of those 'identify who's who's boss'. While this may work for some, to me it seem likeed a far fetched example completely unrelated to my work.

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
cat("```{sql connection='sqlconn'}", '/* SQL code goes here */', '```', sep = '\n')
```

    ```{sql connection='sqlconn'}
    /* SQL code goes here */
    ```

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

Let's break that query up and understand how it works (adapted from [sqlservertutorial](https://www.sqlservertutorial.net/sql-server-basics/sql-server-recursive-cte/):

1.  The first part `SELECT 1 as N` is basically the Anchor. You must have one as it sets the ground for the recursion to follow, building up on that.

2.  The second piece is a `UNION ALL` which is required in a recursive CTE. It basically makes sure all rows are returned, 'stacking them on top of one another.

3.  The third part is, in a sense, the recursion itself. When calling the CTE were creating we're bring the value we selected previously before the union --- `1`. We select the value and add a 1 to it, returning for the second iteration the values 1, 2 (unioned). This repeats for the third, fourth... until we reach a threshold we set, `WHERE N < 10`, and our query breaks out.

A threshold is important to break out, especially if the complexity of the problem *might* increase substantially in each iteration as we'll see shortly. Besides the exit option in the `WHERE` clause, the default recursion will go to a max of 100 iterations before throwing an error.

------------------------------------------------------------------------

<details>
<summary>
Unlimited Iterations and Errors
</summary>

Running the above query for more iterations on the default max (of 100) will throw an error:

``` sql
WITH RecursiveCTE as (
  SELECT 1 as N
  UNION ALL
  SELECT N + 1 as N
  FROM RecursiveCTE
  WHERE N < 10
)

SELECT TOP 3 FROM RecursiveCTE
OPTION(MAXRECURSION 5)
```

    Error: nanodbc/nanodbc.cpp:1655: 42000: [Microsoft][ODBC SQL Server Driver][SQL Server]Incorrect syntax near the keyword 'FROM'.  [Microsoft][ODBC SQL Server Driver][SQL Server]Statement(s) could not be prepared. 
    <SQL> 'WITH RecursiveCTE as (
      SELECT 1 as N
      UNION ALL
      SELECT N + 1 as N
      FROM RecursiveCTE
      WHERE N < 10
    )

    SELECT TOP 3 FROM RecursiveCTE
    OPTION(MAXRECURSION 5)'

XXXXXXX Error XXXXXXX

If you want your rec200rsion to go more than 100 iterations, just set the MAXRECURSION option to what you need. For an unlimited option use the value 0:

``` sql
WITH RecursiveCTE AS (
 ...
)

SELECT * FROM RecursiveCTE
OPTION(MAXRECURSION 0)
```

I'd think carefully before running an unlimited recursion. But if you domake sure to set a break-out option in the WHERE clause.

------------------------------------------------------------------------

## Following the Money

### The Network & Problem

Let's move on to a more practical example, or at least more practical for me. Payoneer is a payments platform and as a result we analyze large quantities of payments. A scenario that might occur is wanting to track the flow of money sent from one user to another, and then from that user to another and so on down the chain.

So far example, looking at the below figure, assuming Bob is the first step in the process, can we identify where the funds ended up (i.e., with Hanah)?

**Why does a recursion help here?** Well, usually actions like these - a payment of sort - are recorded in a tabular normalized way --- Each row contains the information about one payment, from one payer to one receiver. Even multiple transactions between the same two pairs of individuals will be recorded in separate rows. \*\*This makes it a little complex to track multiple 'hops' between users, making multiple joins a very problematic approach.

<div class="mermaid">

graph LR;
A(Bob)--1--\>B(Dan);
B(Dan)--2--\>C(Joe);
C(Joe)--3--\>D(Sarah);
C(Joe)--3--\>E(Sharon);
E(Sharon)--\|4\|--\>F(Fred);
D(Sarah)--4--\>G(Greg);
G(Greg)--5--\>H(Hanah);
F(Fred)--5--\>H(Hanah);

</div>

<script async src="https://unpkg.com/mermaid@8.2.3/dist/mermaid.min.js"></script>
<style type="text/css">
#mermaid-1679428403739 .edgeLabel {
  background-color: none;
  z-index: 1;
}

#mermaid-1679428403739 .node rect {
  fill: none;
  stroke: #3f51b5;
}
</style>

Identifying the chain of transactions shows us **where the funds ended up as well as other actors participating along the way, returning a network of senders (payers) and receivers**. This could be relevant to identify patterns of money layering, sending funds between users to masquerade the funds, as well as mapping out large networks and their connections.

#### The Data

Let's have a look at our data:

``` sql
SELECT TOP 10 * 
FROM Payments
```

| payment_id | payer  | receiver | amount | payment_date |
|:-----------|:-------|:---------|-------:|:-------------|
| 1          | Bob    | Dan      |    320 | 2023-01-14   |
| 2          | A      | B        |    140 | 2023-01-08   |
| 3          | Dan    | Joe      |    301 | 2023-01-15   |
| 4          | Joe    | Sarah    |    150 | 2023-01-16   |
| 5          | C      | D        |    100 | 2023-01-16   |
| 6          | Joe    | Sharon   |    142 | 2023-01-16   |
| 7          | Sharon | Fred     |    141 | 2023-01-17   |
| 8          | A      | C        |     40 | 2023-01-18   |
| 9          | Sarah  | Greg     |    148 | 2023-01-17   |
| 10         | Fred   | Hanah    |    140 | 2023-01-18   |

Displaying records 1 - 10

Our table records payments between users, with each payment recorded as a separate row. I added some 'noise' of unrelated payments between users marked as a single letter, but treat them as if they were random names.

We can reframe our requirment with the following questions, **given you identified Bob, can you follow the funds to where they ended up at?**

### Solution

Let's start by solving it and then we'll break the recursion structure as well as discuss other scenarios:

``` sql
WITH recursivePayments AS (
  SELECT 1 AS Iteration,
    Payments.* 
  FROM Payments
  WHERE Payer = 'Bob'
  UNION ALL
  SELECT Iteration + 1 AS Iteration,
    p.*
  FROM recursivePayments rp
  JOIN Payments p on rp.receiver = p.payer
    and rp.payment_date < p.payment_date
  WHERE Iteration <= 5
)

SELECT * 
FROM recursivePayments
ORDER BY Iteration
```

| Iteration | payment_id | payer  | receiver | amount | payment_date |
|----------:|-----------:|:-------|:---------|-------:|:-------------|
|         1 |          1 | Bob    | Dan      |    320 | 2023-01-14   |
|         2 |          3 | Dan    | Joe      |    301 | 2023-01-15   |
|         3 |          4 | Joe    | Sarah    |    150 | 2023-01-16   |
|         3 |          6 | Joe    | Sharon   |    142 | 2023-01-16   |
|         4 |          7 | Sharon | Fred     |    141 | 2023-01-17   |
|         4 |          9 | Sarah  | Greg     |    148 | 2023-01-17   |
|         5 |         12 | Greg   | Hanah    |    140 | 2023-01-18   |
|         5 |         10 | Fred   | Hanah    |    140 | 2023-01-18   |

8 records

Gorgeous!

Let's unpack this query, based on the three pieces comprising the recursion:

1.  We start off with the Anchor, filtering to the user we'd like to track his funds, returing one row. I also added a column 'Iteration' as (a) a way to understand how many hops we did and (b) as a component for breaking out of the recursion.

2.  Our second part is the recursive member, where we're referencing the CTE we previosuly created (with the anchor). What comes next is a `JOIN` of the recursive member on the original payments table. **The key part is joining that who was a receiver previosuly now as a payer.**

So, with regards to our example, if in our anchor section we got Bob -\> Dan, our second iteration of the recursion now takes Dan and `JOIN`s anyone he sent funds to, so Dan -\> Joe. This repeates until the recursion ends, every time UNIONing the previous rows on the next. The recrusive member here only plays a role in helping us identifying the next payer for whom we'd like to pull users he sent funds to. Notice how we only take information from the payments table in each section.

I also added a Non-Equi Join operator so that we only take payments that *occurred after* the user received his funds.

3.  Our third part, the termination condition, enables us to break out of the recursion once we reached 5 iterations. I'd start with a low number and increase if needed.

From here we have the funds pipeline for our original user, Bob, and can follow up with more questions: At whom the funds ended up? How much did each user receive? How long did it take the funds to end up with the final user? And other questions to help us understand the network and what had happened.

It's a pretty slick way to identify a network quickly, without needing to leave the SQL script you're working on. However it does have a few setbacks, specifically this example and a recursion in general, that I'll address below.

### Cons

Some of these cons relate specifically for this particular example, but you might be able to generalize them and be prepared for the recursion you'll run.

1.  Complexity problem --- Since we don't know how many receiver we'll identify in each iteration, you might find yourself with data growing exponentially. For example, assume you have one node at the start, who sends to 5 users, who each send to 5 (or even more!) users and so on. Or even having one user sending to many users at one iteration is risky and can cause setbacks.

Another problem you might face is querying the same users again and again. Even though we took new users' payments sent *after* those they received, they might be sending funds to the original sender. This then repeats and can result with querying the same observations multiple times. It could be cleared with the outer final query referencing the recursion result, but is redundant nonetheless.

#### So what can we use

As I was exploring the recursion I met with one of our DBA who suggested that if this query becomes common, one approach might be to use a scripting language instead, e.g. Python.

Instead of running a recursion we can loop through queries collecting the same flow model: The receiver now becomes the sender and we repeat the search process. This approach also makes it more controllable and robust: we can filter AHs we already queried to not repeat ourselves, break early if the next iteration exceeds a threshold, etc.

### Final words --- Recurse away

Hopefully you arrived here knowing a little more about recursive CTEs in SQL. Truthfully, it's likely you can solve the problem you're facing without a recursion. I don't use them frequently but following the several occasions I did I find them a useful tool to have in your SQL-commands toolbox.

Start with a small data, make sure to set a termination condition and be mindful of your servers.

Good luck!
