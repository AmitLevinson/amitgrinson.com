---
title: Making updating exam grades easy with R
author: Amit Grinson
date: '2020-02-15'
slug: update-exam-grades-easy-with-r
categories: [R]
tags: [challenges, clipr]
subtitle: ''
summary: 'In this post I discuss my use of the xlsx and clipr packages for optimizing how I updated students exams'
featured: no
projects: []
draft: false
editor_options: 
  chunk_output_type: console
layout: single-sidebar
format: hugo
---



<script src="index_files/libs/kePrint-0.0.1/kePrint.js"></script>
<link href="index_files/libs/lightable-0.0.1/lightable.css" rel="stylesheet" />


**TL;DR** Instead of each time searching for an id in the xlsx template the university provides we make our own xlsx and merge between the two. I then run through two options of either saving the new data frame as an `.xlsx` using the `{xlsx}` package, and I show another option where I extract the new column I need using `write_clip` from the `{clipr}` package.

> "Progress isn't made by early risers. It's made by lazy men trying to find easier ways to do something." </br> ― Robert Heinlein

### What's the story?

The other day I had to update students' exams into a blank excel file. Every course exam each student gets an exam id. Their id is comprised from a number / number, for example, 26/1; 1/1; 42/15 and so forth. In our course of up to 70 students the left number goes all the way to the number of students in the exam class, and the right number goes up to 15 or 20 and starts again from 1.

This would make it easy to insert the grade for each id into the excel file that is already organized. However, since this is a new system and I was waiting to get access to download the excel I decided to open a new spreadsheet instead. Also, writing the id instead of looking it up in the excel file each time can save, in my opinion, a little time of searching.  
So we have our spreadsheet which is not sorted, and we have the university's spreadsheet which is sorted - how are we going to sync between them, considering our id column we wrote is recognized as a `character` class? I know, let's turn to `R`[^1].

### Looking at our data

Let's start off with loading our packages:

``` r
library(tidyverse)
# For reading xlsx files
library(readxl)
# To nicely display the tables in the following paragraph
library(kableExtra)
library(knitr)
```

Now let's read both files: Our spreadsheet with just the id and grade of each student we wrote in, and the other spreadsheet with the students' id and a numerical vector to sort by that the university provides.

``` r
messy <- read_excel("messy_grades.xlsx")
clean <- read_excel("clean.xlsx")
```

This gives us the following tables where on the left we have our **messy** table we wrote and on the right our **clean** table we want to merge to:

<table class="table" style="width: auto !important; float: left; margin-right: 10px;">
 <thead>
  <tr>
   <th style="text-align:center;"> id </th>
   <th style="text-align:center;"> grade </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:center;"> 67/13 </td>
   <td style="text-align:center;"> 94 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 56/2 </td>
   <td style="text-align:center;"> 90 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 68/14 </td>
   <td style="text-align:center;"> 84 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 63/9 </td>
   <td style="text-align:center;"> 100 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 55/1 </td>
   <td style="text-align:center;"> 89 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 62/8 </td>
   <td style="text-align:center;"> 97 </td>
  </tr>
</tbody>
</table>

<table class="table" style="width: auto !important; margin-right: 0; margin-left: auto">
 <thead>
  <tr>
   <th style="text-align:center;"> id </th>
   <th style="text-align:center;"> participated </th>
   <th style="text-align:center;"> number_for_sorting </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:center;"> 1/1 </td>
   <td style="text-align:center;"> V </td>
   <td style="text-align:center;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 2/2 </td>
   <td style="text-align:center;"> V </td>
   <td style="text-align:center;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 3/3 </td>
   <td style="text-align:center;"> V </td>
   <td style="text-align:center;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 4/4 </td>
   <td style="text-align:center;"> NA </td>
   <td style="text-align:center;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 5/5 </td>
   <td style="text-align:center;"> NA </td>
   <td style="text-align:center;"> 5 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 6/6 </td>
   <td style="text-align:center;"> V </td>
   <td style="text-align:center;"> 6 </td>
  </tr>
</tbody>
</table>

<br>
So we now have several options:

1.  Join between the two tables, save the clean table as a new xlsx and upload it to the University's exam system.
2.  Join between the two tables, clip the column with the organized grades and paste it into the university's sorted excel file.

### Option 1 - Merge and write to a new excel file

So the first option will be to merge the two tables into the clean one and save that as a new excel file using the `{xlsx}` package:

``` r
joined_tables <- messy %>% 
    right_join(clean)

writexl::write_xlsx(joined_tables, "010210078-29012020C.xlsx")
```

Below is a screen shot of our new table:

![](xl.png)

However, going with this approach I encountered that the new .xlsx file is saved with a new column of id numbers that we see in the screenshot. We can just delete that column and have our file all ready to go.

### Option 2 - Clip the sorted column into the excel file

This time around I'll write a function for what we'll be doing: I want to join the tables but this time around I want to clip the column I need and then manually paste it in the original template excel file:

``` r
clip_grades <- function(messy, clean){
  messy %>% 
    right_join(clean) %>% 
    pull(grade) %>% 
    clipr::write_clip()
}

clip_grades(messy, clean)
```

which gives us the following:

![](clipgif.gif)

That's it!

Well, more or less. We need to delete the 'NA' that are copied from the function. Unfortunately I wasn't able to delete them from within `R`, so I manually delete them.

As to which option is better, I think the first option is more efficient as we only need to delete the id column. However, using the `{xlsx}` package is dependent on `{rJava}`and having java installed on the computer from what I encountered. Option two can be a little messy and possibly yield mistakes if we copy and paste the new grades and then manually delete the `NA` - your call.

#### So what did I learn here?

-   How to read and write an excel file.
-   Using the `write_clip` function which is amazingly easy.
-   How to make updating exams easier :muscle:

</br>

[^1]: For confidentiality and other reasons I only left columns with information that can't be linked to students (I also changed the grades altogether for this demonstration).
