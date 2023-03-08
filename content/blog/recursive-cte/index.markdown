---
title: Recursive CTE to Identify Money Transfers
author: Amit Grinson
date: '2023-08-29'
layout: single-sidebar
slug: recursive-cte
categories: [SQL]
tags: [SQL, Recursion]
subtitle: 'Learning recursive CTEs by following payment activity'
summary: 'Though not commonly used, recursive CTEs can be a great tool to work with hierarchal data. In this post we learn to use them to identify where money was moved to by following the transfer activity'
featured: yes
projects: []
format: hugo-md
editor_options: 
  chunk_output_type: inline
---







> "Roses are red  
  Violets are blue,  
  Write a Recursion
  and the DBA will find you"
  
<br>

Recursive CTEs is one of those things I occasionally encountered but never really understood. When I did sought out information to learn mroe about it, it was usually one of those 'identify who's who's boss'. While this may work for some, to me it seem like a far fetched example completely unrelated to my work.

The first time I used it was to calculate the weekdays for a given day from the start of the year, an example from Anthony Molinaro's "SQL Cookbook". It worked great and finally clicked how I can further use this. When I wanted to share it with my team, I thought of a more relateable example of using it to identify where the funds went (more on that below).

Hopefully either example (the generic and mine) will help you grasp it a little more. It's probably not a hammer to be used frequently, but not bad to have it in your toolbox.



```r
library(odbc)
library(DBI)

sqlconn <- dbConnect(odbc(),
                      Driver = "SQL Server",
                      Server = "localhost\\SQLEXPRESS",
                      Database = "regex")
```


## Recursive CTE — Basic Example

### Example

Well, before we talk about a recursive CTE let's briefly discuss a recursion in general. A recursion, as Wikipedia notes, is defined in terms of itself or of its type. In other words, I like to think of it as something that calls itself.

In SQL (here MSSQL), **a recursion comes into play with a Common table expression (aka CTE), where we call the table we're currently evaluating.** 

For example, to count until 10 (1000, ...) in SQL, we can run the following:




```sql
WITH RecursiveCTE as (
  SELECT 1 as N
  UNION ALL
  SELECT N + 1 as N
  FROM RecursiveCTE
  WHERE N < 10
)

SELECT * FROM RecursiveCTE
```


<div class="knitsql-table">


Table: Table 1: Displaying records 1 - 10

|N  |
|:--|
|1  |
|2  |
|3  |
|4  |
|5  |
|6  |
|7  |
|8  |
|9  |
|10 |

</div>


### Block Breakdown

Let's break that query up and understand how it works:

1. The first part `SELECT 1 as N` is basically the Anchor. You must have one as it sets the ground for the recursion to follow, building up on that.

2. The second piece is a `UNION ALL` which is required in a recursive CTE. It basically makes sure all rows are returned, 'stacking them on top of one another.

3. The third part is, in a sense, the recursion itself. When calling the CTE were creating we're bring the value we selected previously before the union — `1`. We select the value and add a 1 to it, returning for the second iteration the values 1, 2 (unioned). This repeats for the third, fourth... until we reach a threshold we set, `WHERE N < 10`, and our query breaks out. 

A threshold is important to break out, especially if the complexity of the problem *might* increase substantially in each iteration as we'll see shortly. Besides the exit option in the `WHERE` clause, the default recursion will go to a max of 100 iterations. 

-----

Unlimited Iterations and Errors

Running the above query for more iterations on the default max (of 100) will throw an error:

XXXXXXX Error XXXXXXX

If you want your recursion to go more than 100 iterations, just set the maxrecursion option to what you need, for example:

```{.sql}
WITH RecursiveCTE AS (
 ...
)

SELECT * FROM RecursiveCTE
OPTION(MAXRECURSION 200)
```




```sql
WITH RecursiveCTE as (
  SELECT 1 as N
  UNION ALL
  SELECT N + 1 as N
  FROM RecursiveCTE
  WHERE N < 102
)

SELECT * FROM RecursiveCTE
```


<div class="knitsql-table">


Table: Table 2: Displaying records 1 - 10

|N  |
|:--|
|1  |
|2  |
|3  |
|4  |
|5  |
|6  |
|7  |
|8  |
|9  |
|10 |

</div>


I'd think carefully before running an unlimited recursion. But if you do, set the `MAXRECURSION` to 0 and hope your breaking option in the WHERE caluse will help.


----------


-- Counting to 10
-- another hidden example of creating weekday from start of the year

## Recursive CTE — Following the Money

## 

- our example







