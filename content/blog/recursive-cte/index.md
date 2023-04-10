---
title: Following Money Transfers and Layering using a Recursive CTE
author: Amit Grinson
date: '2023-04-03'
layout: single
slug: recursive-cte-to-follow-the-money-flow
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

Recursive CTEs are one of those things I encountered as a SQL beginner but never really understood. When I sought out information to learn more about it, it was usually explained through the 'identify who's who's boss' example. While this may work for some, to me it seemed liked an example completely unrelated to my work, making it harder to understand what it is.

The first time I used it was to calculate the weekdays for a given day from the start of the year, an example adapted from Anthony Molinaro's [SQL Cookbook](https://www.oreilly.com/library/view/sql-cookbook/0596009763/) I keep at home. It worked great and finally clicked how I can further use this.

When I wanted to share with my team how to use a recursion, I thought of a more relateable example for us: **Using it to identify the flow of funds in our tublar data** (more on that below). Hopefully either example I go through --- a generic basic one and another more practical for me --- will help you grasp it a little better.

<details>
<summary>
Setting up a SQL connection in R
</summary>

I write my blog using the [Rstudio IDE](https://posit.co/). Since we'll be writing SQL in this post, we need to set up a local SQL connection. We're basically connecting to our local RDBMS, here MSSQL, and to a database I setup earlier.

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
# dat <- read.csv('content/blog/recursive-cte/payments.csv', colClasses = c('numeric', 'character', 'character', 'numeric', 'Date'))

dbWriteTable(conn = sqlconn, 'payments', dat, field.types = c(payment_id = 'INT', payer = 'VARCHAR(10)', 
                                                  receiver = 'VARCHAR(10)', amount = 'INT',
                                                  payment_date = 'DATE'), overwrite = TRUE)
```

**Aside:** Moving forward we'll be using SQL code only. instead of having to write SQL code through some R function we can use the SQL engine directly in the code chunks. Just add the connection you created to the chunk header as such:

`{sql connection='sqlconn'} /* SQL code goes here */`

</details>

## Basic Example

Well, before we talk about a recursive CTE let's briefly discuss a recursion in general. **A recursion is defined in terms of itself or of its type (\~Wikipedia).** In other words, I like to think of it as something that calls itself.

In SQL (here MSSQL), **a recursion comes into play with a Common table expression (aka CTE), where we call the table we're currently evaluating.**

For example, to count until 10 (1000, ...) in SQL using a recursion, we can run the following:

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

Let's break this query up and understand how it works (adapted from [sqlservertutorial](https://www.sqlservertutorial.net/sql-server-basics/sql-server-recursive-cte/)):

1.  The first part `SELECT 1 as N` is basically **the Anchor**. It's the first query from which the recursion will build on, and here we're explicit in our reference of a specific value: We're creating a table with one column named `N` that contains the value `1`.

2.  The second piece is a `UNION ALL` that enables the returning of all rows for each recursion.

3.  The third part is, in a sense, the recursion itself. When calling the CTE for the first time (R<sub>1</sub>) we're returning the iteration before the union, here `1`. We select the value and add a 1 to it, returning for the second iteration (R<sub>2</sub>) with the value 2. This repeats for the third, fourth (R<sub>n</sub>)... until we reach a **termination condition**, a threshold we set, here `WHERE N < 10`, and our query breaks out.

A threshold is important to break out, especially if the complexity of the problem *might* increase substantially in each iteration as we'll see shortly. Besides the exit option in the `WHERE` clause, the *default* recursion will go to a max of 100 iterations before throwing an error.

<details>
<summary>
More / Unlimited Iterations
</summary>

If we were to run the above query and try to produce 1000 numbers we'd get an error since we'd exceed the default of 100 iterations. If you want your recursion to go more than the default, just set the `MAXRECURSION OPTION` to what you need. For an unlimited option use the value 0:

``` sql
WITH RecursiveCTE AS (
 ...
)

SELECT * FROM RecursiveCTE
OPTION(MAXRECURSION 0)
```

**Though I'd think carefully before running an unlimited recursion and if you do**, make sure to set a break-out option in the `WHERE` clause.

</details>

## Following the Money 💸

Let's move on to a more practical example, or at least more practical for me. Payoneer is a payments platform, and as a result we analyze large quantities of payments to, from and between users. **A scenario that might occur is wanting to track the flow of money sent from one user to another, and then from that user to another and so on down the chain.**

**Why would we want a recursion here?** Well, usually actions like these - a payment of sort - are recorded in a tabular normalized way. Each row contains the information about a payment: date, amount, loader, receiver, etc. Even multiple transactions between the same two pairs of individuals will be recorded in separate rows. **Tabluar data like this makes it complex to track multiple 'iterations' between users and, as such, makes a recursive more suitable than multiple (if not endless) joins on the same table.**

#### The Network & Problem

<div class="mermaid">

graph LR;
A(Bob)--1--\>B(?);
B(?)--2--\>C(?);
C(?)--3--\>D(?);
C(?)--3--\>E(?);
E(?)--4--\>F(?);
D(?)--4--\>G(?);
G(?)--5--\>H(Hanah);
F(?)--5--\>H(Hanah);

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

Looking at the above figure our goal will be to try and track Bob's funds --- Assuming Bob is the first step in the process, can we identify where the funds ended up (i.e., with Hanah)?

Identifying Bob's flow of funds shows us where the funds ended up as well as other actors participating along the way, returning a network of senders (payers) and receivers[^1]. **Tracking funds could be relevant to identify patterns of money layering, sending funds between users to masquerade the funds, as well as mapping out large networks and their connections for other purposes.**

### The Data

Let's have a look at our data:

``` sql
SELECT TOP 5 * 
FROM Payments
```

| payment_id | payer | receiver | amount | payment_date |
|:-----------|:------|:---------|-------:|:-------------|
| 1          | Bob   | Dan      |    320 | 2023-01-14   |
| 2          | A     | B        |    140 | 2023-01-08   |
| 3          | Dan   | Joe      |    301 | 2023-01-15   |
| 4          | Joe   | Sarah    |    150 | 2023-01-16   |
| 5          | C     | D        |    100 | 2023-01-16   |

5 records

Our table records payments between users, with each payment recorded as a separate row. I added some 'noise' of unrelated payments between users marked as a single letter, but treat them as if they were random names.

> Given you identified Bob as someone you want to investigate to where his funds ended up, can you follow his receivers, their receivers and eventually identify where the funds ended up?

### Solution --- Using a recursion to follow the money

Let's start by solving it and then we'll break the recursion structure similar to our basic example at the start:

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

**Gorgeous! Notice how we have all users participating in the flow of funds along with a number referencing what 'iteration' they are in the transaction flow.**

Let's unpack this query, based on the three pieces comprising the recursion:

1.  We start off with the Anchor, filtering to the user we'd like to track his funds, returing one row. I also added a column *Iteration* as (a) a way to understand how many hops we did and (b) as a component for later terminating the recursion.

2.  Our second part is the recursive member, where we're referencing the CTE we previously created (with the anchor). What comes next is a `JOIN` of the recursive member on the original payments table. **The key part is joining that who was a receiver with the original payments now as a payer.**  
    If in our anchor section (the first select statement) we got Bob -\> Dan, our second iteration of the recursion now takes Dan and `JOIN`s anyone he sent funds to, so Dan -\> Joe. This repeates until the recursion ends, every time UNIONing the previous rows on to the next; **think of stacking each recursion output on top of the next, where the last iteration is now the table for the next step in the recursion.**  
    We can see that the recursive member here mainly plays a role in helping us identifying the next payer for whom we'd like to pull users he sent funds to. All the information added is just from the payments table, the recursion helps us iterate across the network.  
    I also added a Non-Equi Join operator so that we only take payments that *occurred after* the user received his funds. Though not sure how critical it is, you can read more on that below in the cons section.

3.  **Our third part, the termination condition, enables us to break out of the recursion once we reached 5 iterations.** I would start with a low number and increase if needed.

{{% alert warning %}}
Make sure to have a terminating condition in place if you're querying large quantities of data. Start with a low number and increase gradually if the complexity of the network might grow substantially.
{{% /alert %}}

From here we have the funds pipeline for our original user, Bob, and can follow up with more questions: At whom the funds ended up? How much did each user receive? How long did it take the funds to end up with the final user? We can answer these and other questions as well as visualize the network once its collection is completed, whatever helps us gets the job done.

Here's our diagram of the network now complete with the intermediate users:

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

It's a pretty slick way to identify a network quickly, without needing to leave the SQL script you're working on. However it does have a few setbacks, specifically this example and a SQL recursion in general, that I'll address below.

### Cons

Some of these cons relate specifically for this particular example, but you might be able to generalize them and be prepared for the recursion you'll run.

1.  Complexity --- Since we don't know how many receiver we'll identify in each iteration, you might find yourself with data growing exponentially. For example, assume you have one node at the start who sends to 5 users, who each send to 5 (or even more!) users and so on.

2.  Querying the same data --- Even though we took new users' payments sent *after* those they received, they might be sending funds to the original sender. This then repeats and can result with querying the same observations multiple times. It could be dealt with in the outer final query referencing the recursion result, but it is redundant nonetheless.

#### So what else can we use

As I was exploring the recursion I met with one of our DBA who suggested that if this query becomes common, one approach might be to use a scripting language instead, e.g. Python/R.

Instead of running a recursion we can loop through queries collecting the same flow model: The receiver now becomes the sender and we repeat the search process. This approach increases the control and makes it more robust: we can filter AHs we already queried to not repeat ourselves, break early if the next iteration exceeds a threshold, etc.

You can also employ more complex SQL operations, a procedure or other operations. However this already steps out of the recursion and becomes longer and maybe even repetitive.

### Final words --- Recurse away

Truthfully, it's likely you can solve the problem you're facing without a recursion. I don't use them often but following the several occasions I did I find them a useful tool to have in my SQL-commands toolbox.

Start with small data, make sure to set a termination condition and be mindful of your servers.

Good luck!

[^1]: For simplicty we'll use a unilateral flow of funds, but the solution can be generalized both ways exploring receivers' senders as well.