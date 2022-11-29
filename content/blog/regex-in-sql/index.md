---
title: Text Manipulation & RegEx in a Data Analysis Flow (with examples in SQL vs  Python/R)
author: Amit Grinson
date: '2022-08-29'
layout: single-sidebar
slug: regex-in-sql
categories: [R, Python, SQL]
tags: [R, Python, SQL]
subtitle: 'Reviewing text manipulations with the common data analyst toolbox'
summary: 'Going over various cases of text operations in a data analysis flow, showing how to solve it with R/Python compared to SQL.'
featured: yes
projects: []
format: hugo-md
editor_options: 
  chunk_output_type: inline
---



Working as a Data Analyst in the fraud domain I constantly find myself manipulating text, for example to abstract a pattern I identified. This is done with various text manipulation functions in SQL or locally in Python or R using regex and other functions.

Regex is 'a sequence of characters that specifies a search pattern in text' (\~[Wikipedia](https://en.wikipedia.org/wiki/Regular_expression)). Basically, we provide a set of rules and guidelines to identify a pattern in the text. Appreciating the power of Regex and simple text operations in the programs R & Python that I use, doing them in SQL - at least in MSSQL we currently use - requires adaptations.

In this post I'll go over three scenarios I faced in the past, both in some coding language or while using SQL. As I've recently picked up Python I'll solve them using that (and a bit of R), **but the general idea should be language agnostic, and that is using regex and working with text in a data analysis flow.**

What will we be looking at?

[1. Using lookarounds to extract an email domain](#lookarounds)

[2. Joining tables with partial matching of keys](#partial-strings)

[3. Separating text & digits from a string](#separate)

### Setup

Let's start by setting up a local connection to easily write SQL queries as we move forward:

``` r
library(odbc)
library(DBI)

rconn <- dbConnect(odbc(),
                      Driver = "SQL Server",
                      Server = "localhost\\SQLEXPRESS",
                      Database = "regex")
```

Awesome. In this post I'll be working with both Python (mainly) and a little with R. For that let's load the relevant libraries and data:

{{< panelset >}}

{{< panel name=“Python” >}}

``` python
import pandas as pd

payments = pd.read_csv('data.csv')
```

{{< /panel >}}

{{< panel name=“R” >}}

``` r
library(tidyverse)

payments <- read_csv('data.csv')
```

{{< /panel >}}

{{< /panelset >}}

##### The Data

Our main dataset is a simple payments table:

``` r
payments
```

    # A tibble: 6 × 3
      email                    payment_identifier                   payment_descrip…
      <chr>                    <chr>                                <chr>           
    1 johnTheKing2@yahoo.com   4e0fc35a-703f-4ca2-ab4c-57e9824c2e0b John Dalle 1238…
    2 D234AbJarry@rockingit.it b7a0879f-b510-442c-b0d1-595e3c7ca4ef Jarry Cohen 23  
    3 BarbraSA@rockingit.it    2459190c-ff94-4d8c-baf8-2fdf15dd2007 Barbra Smith 322
    4 Shawn@gmail.com          9954c0d3-fc8f-4234-b77f-20eaaf674841 Shawn Brown 927…
    5 me@photoshooting.com     405a073d-44e5-475c-a53f-9541aa578e9d Dan S. Wilson 2…
    6 Lilly3@gmail.com         6df08994-0335-4463-a921-970f2349413f Lilly Taylor 36…

The data has 6 rows in total detailing payment transactions: The receiver's email, the payment identifier (a paymen id) and the payment description containing the receiver's name and some numbers. If you're interested in following along or trying yourself see the relevant dataset in the [website's GitHub repository]().

All right then, let's (^begin\|start\$)

## 1. Lookarounds 👀 --- Extracting the domain from an email address

[lookarounds](https://www.regular-expressions.info/lookaround.html) are definitely one of my favorite and commonly go-to regex operations. As the name implies, **a lookaround searches for a pattern and specified string in a specific piece of text.** A *lookahead* searches for the pattern and takes what's before it, while a *lookbehind* searches for the pattern and takes what follows it. They both can be positive or negative, while the former searches for a match (positive match) and the latter searches for the string without a match to the pattern/symbol referenced (negative match).

Let's explore it with a set of emails. **Say for example you want to extract the email domains, which is everything that's after the @ symbol.**

##### Python

Returning to our table, we can do this using the following regex operation:

``` python
(payments
 .loc[:, ['email']]
 .assign (
   email_domain = payments.email.str.extract(r'((?<=@).+)') # <- relevant part
 )
)
```

                          email       email_domain
    0    johnTheKing2@yahoo.com          yahoo.com
    1  D234AbJarry@rockingit.it       rockingit.it
    2     BarbraSA@rockingit.it       rockingit.it
    3           Shawn@gmail.com          gmail.com
    4      me@photoshooting.com  photoshooting.com
    5          Lilly3@gmail.com          gmail.com

The pattern `(?<=@).+` essentially **extracts any character(s) that follow the @ symbol,** in this case our email domain[^1]. Alternatively if we're interested in extracting email users instead we could use a positive lookahead, looking for the '@' symbol only this time taking what's before it (`r'(.+(?=@))'`). If you're interested in learning more about lookarounds, check out another post of mine where I extracted [libraries I used in \#TidyTuesday R scripts](https://amitlevinson.com/blog/automated-plot-with-github-actions/)

##### SQL

So how can we do some variation of a lookaround in SQL?

Well, I mainly use it for the positive lookahead/behind, identifying the character's location and extract anything after it:

``` sql
SELECT email,
  RIGHT(EMAIL, LEN(EMAIL) - CHARINDEX('@',EMAIL)) AS email_domain
FROM PAYMENTS p
```

| email                    | email_domain      |
|:-------------------------|:------------------|
| johnTheKing2@yahoo.com   | yahoo.com         |
| D234AbJarry@rockingit.it | rockingit.it      |
| BarbraSA@rockingit.it    | rockingit.it      |
| Shawn@gmail.com          | gmail.com         |
| me@photoshooting.com     | photoshooting.com |
| Lilly3@gmail.com         | gmail.com         |

6 records

We're leveraging the function `CHARINDEX` in order to identify the location of the '@' symbol, and then extract all text from that location forward using the `RIGHT` operator.

## 2. Partial string join --- identifying a string from a partial match

I wouldn't say this is a common thing I do, but I had to do it once and was pretty pleased with the solution. Assuming you have another column/dataset with partial matching strings to your primary key, how can you join the two tables?

For example, you received from some partner a list of ids he has for each payment. However, what he has is only a part of the full strings recorded in your system, as we can see below the partial strings:

``` r
partial_identifiers
```

                           id
    1          b510-442c-b0d1
    2          fc8f-4234-b77f
    3 6df08994-0335-4463-a921

these strings are contained in some of our payment_identifier column, but how can we easily join them considering it's not an exact match?

We'll solve it using a join - and not filtering by the pattern - so we can match each identifier to the payment returned.

##### R

At the time I encountered this challenge I was using mainly R and solved it with that, so let's go ahead and use that first:

``` r
library(fuzzyjoin)

regex_left_join(x = payments, y = partial_identifiers,
                by = c('payment_identifier' = 'id')) %>% 
  select(payment_identifier, id)
```

    # A tibble: 6 × 2
      payment_identifier                   id                     
      <chr>                                <chr>                  
    1 4e0fc35a-703f-4ca2-ab4c-57e9824c2e0b <NA>                   
    2 b7a0879f-b510-442c-b0d1-595e3c7ca4ef b510-442c-b0d1         
    3 2459190c-ff94-4d8c-baf8-2fdf15dd2007 <NA>                   
    4 9954c0d3-fc8f-4234-b77f-20eaaf674841 fc8f-4234-b77f         
    5 405a073d-44e5-475c-a53f-9541aa578e9d <NA>                   
    6 6df08994-0335-4463-a921-970f2349413f 6df08994-0335-4463-a921

I initially had a different answer that basically extracted which values matched as a new column, and then joined on that; But I really like this solution instead as it shows the power of the [{fuzzyjoin}](https://cran.r-project.org/web/packages/fuzzyjoin/index.html) R package. **Rows are joined based on partial match of one column in the other column.**

We also do above a left join but moving forward we'll stay with an inner join, as payments found unmatched won't be necessary.

##### Python

I realized this post solves the other two challenges with Python, so I might as well try it with that too. You know, just for the kicks:

``` python
(payments.merge(partial_identifiers, how = 'cross')
.loc[lambda df: df.apply(lambda row: row['id'] in row['payment_identifier'], axis = 1),
    ['payment_identifier', 'id']]
)
```

                          payment_identifier                       id
    3   b7a0879f-b510-442c-b0d1-595e3c7ca4ef           b510-442c-b0d1
    10  9954c0d3-fc8f-4234-b77f-20eaaf674841           fc8f-4234-b77f
    17  6df08994-0335-4463-a921-970f2349413f  6df08994-0335-4463-a921

It's a little packed, so let's break it apart: We first join the two tables using Cartesian product, creating all combinations of payment identifiers and partial strings. The following line goes row by row and checks if the partial string is `in` the payment identifier. If so, it returns `True` which is evaluated in the `.loc[]` argument.

A faster approach (nearly X25 times) instead of the `apply` would be to filter using list comprehension, but I find it much less readable[^2].

Now let's turn to SQL and solve it there.

##### SQL

``` sql
SELECT TOP 6 payment_identifier,
  pi.id
FROM PAYMENTS p
INNER JOIN partial_identifiers pi
  on p.payment_identifier like concat('%', pi.id, '%')
```

| payment_identifier                   | id                      |
|:-------------------------------------|:------------------------|
| b7a0879f-b510-442c-b0d1-595e3c7ca4ef | b510-442c-b0d1          |
| 9954c0d3-fc8f-4234-b77f-20eaaf674841 | fc8f-4234-b77f          |
| 6df08994-0335-4463-a921-970f2349413f | 6df08994-0335-4463-a921 |

3 records

The idea is pretty straight-forward. We can leverage the `LIKE` operator in a join to do the partial matching for us, matching any payment identifiers to the partial identifiers id.

Interestingly, at the time of facing this challenge at work I started it with R. However, this requried downloading many of the payments and wasn't easily scalable so eventually I just implemented it using SQL as shown above.

## 3. Extracting / Separating text & digits.

Occasionally you might encounter values that contain both a string and digits combined; For example: payment descriptions, email users, security answers and more. Being able to separate the text from numbers might be a necessary step for cleaning our data and further analysis.

Let's see how can we do this on the column payment_description that contains both what seems as a name and a set of numbers.

##### Python

``` python
payments[['name', 'number']] = (
  payments.payment_description.str.split(r'(\d+)', expand = True)
  .iloc[:, 0:2]
)

payments[['payment_description', 'name', 'number']]
```

        payment_description            name   number
    0    John Dalle 1238127     John Dalle   1238127
    1        Jarry Cohen 23    Jarry Cohen        23
    2      Barbra Smith 322   Barbra Smith       322
    3     Shawn Brown 92794    Shawn Brown     92794
    4  Dan S. Wilson 283749  Dan S. Wilson    283749
    5     Lilly Taylor 3698   Lilly Taylor      3698

It's pretty straightforward using the python `split` argument. We pass it a pattern to separate by and wrap it in a parenetheses (so it won't drop). From there we just remove an empty column and assign it as new columns into our dataframe.

I don't show it here but in R we could easily use the `tidyr::separate` that does exactly that --- Separates a string into new columns.

##### SQL

This requires a little more work than our solution in question 1 since we want to split the text at varying locations. For this case I really like `TRANSLATE`:

``` sql
SELECT TOP 6
  Payment_Description,
  REPLACE(TRANSLATE(PAYMENT_DESCRIPTION, '0123456789',
                                         '##########'),
          '#','') AS Name,
  REPLACE(TRANSLATE(PAYMENT_DESCRIPTION, 'abcdefghijklmnopqrstuvwxyz.',
                                         '###########################'),
          '#','') AS Numbers
FROM PAYMENTS
```

| Payment_Description  | Name          | Numbers |
|:---------------------|:--------------|:--------|
| John Dalle 1238127   | John Dalle    | 1238127 |
| Jarry Cohen 23       | Jarry Cohen   | 23      |
| Barbra Smith 322     | Barbra Smith  | 322     |
| Shawn Brown 92794    | Shawn Brown   | 92794   |
| Dan S. Wilson 283749 | Dan S. Wilson | 283749  |
| Lilly Taylor 3698    | Lilly Taylor  | 3698    |

6 records

We combine the `TRANSLATE` and `REPALCE` functions to do a string-extract kind of operation. The Translate basically converts any of the characters noted in the second argument to a character in the third argument. We then replace all hashtags with empty values.

This is done both for the name and numbers, creating new columns for each with the clean values.

You might have data that's a little messier, e.g. numbers appearing in between letters, but it should give the main idea and help you start from there (or at least did so for me).

### Additional text operation tips in SQL

Besides the basics you probably know of if you've worked in the past with SQL, there were a few other cases where I learned something new. Here are a few last tips before you go:

1.  Though not shown above, you can use regex-like operations and symbols, for example filtering with the `WHERE` clause a string that is a letter, number, then letter using `...Like [a-z][0-9][a-z]`.

2.  In addition, you can use case sensitive operations to match lower and uppercase when needed, just add `WHERE column COLLATE Latin1_General_BIN LIKE [A-Z]...` to have it case sensitive.

3.  Some symbols have a designated meaning in SQL, e,g, the `%` and `_` operators. But what happens when you want to try and match them? Well, you can use the `ESCAPE` operator. For example to match sentences that use a '%' symbol you can add any symbol before and escape it: `LIKE '%!%% ESCAPE '!'`, matching a text with something before and after a '%' sign.

You can find more more specific tips for text manipulations in MSSQL [here](https://www.sqlshack.com/t-sql-regex-commands-in-sql-server/). Have specific ones in mind that you use daily? I'd love to hear about them!

### Closing remarks

In this blog post we solved three cases using some regex and text manipulations. Sometimes I found myself working with text on the server's side, other times working locally with R or Python. **I think it's mainly knowing that it can be done that gets you most of the way there. The how is just a matter of powering through and past experience 💪**

Now that your data is clean you can run more complex manipulations. See a previous post of mine [explaining about TF-IDF using texts from political theorists](https://amitlevinson.com/blog/learning-tfidf-with-political-theorists/) to see examples of what you can do with text. For more tricks for working with text in SQL, checkout [SQL Cookbook](https://www.amazon.com/SQL-Cookbook-Query-Solutions-Techniques/dp/1492077445).

**Good luck on your text manipulation endeavors!**

[^1]: The extra parentheses is to solve the 'ValueError: pattern contains no capture groups' error, basically including what is it we want to be captured in our regex.

[^2]: It's acually almost 25 times faster to use list comprehension for filtering (3.28ms vs 79ms, tested on 1,000 rows): `.loc[lambda df: [x[0] in x[1] if x[0] is not None else False for x in zip(df['id'], df['payment_identifier'])]`