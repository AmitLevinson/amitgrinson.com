---
title: My year in R
author: Amit Grinson
date: '2020-10-15'
layout: single-sidebar
slug: my-year-in-r
categories: [R]
tags: [learning]
subtitle: ''
summary: "Looking back at my year of learning R"
featured: yes
projects: []
format: hugo-md
---



<style type="text/css">
newcaption {
  font-size: 0.9em;
  text-align: center
}
</style>
<p align="center">
<img alt = 'A figure of an animated R Icon' src = '/img/year-in-r/r-img.png'>
<newcaption> Image by [Allison Horst](https://allisonhorst.github.io/)</newcaption>
</p>

Learning R for a little over a year now was and still is a great experience. But a year isn't a lot, so why make a blog post about it?

I believe that pausing what one is doing and periodically evaluating if this pursuit is the right direction *for him or her* - is a healthy process. Doing so can help you **acknowledge your accomplishments and think of where you're heading**. And I'm glad I have the opportunity to do it in the following post.

### The Journey

I was wondering how to summarize my past year: A list of resources? a story? a listicle? I decided to go with more of an item-list somewhat chronologically ordered that I believe captures my experience. Of course like a lot of many other things in life, the timeline discussed isn't completely rigid as some items I did concurrently or jumped back and forth.

## 1. Hearing about R

I first heard of R when it was used in a hierarchical linear models workshop I attended. The workshop focused more on the statistics part of the analysis so we didn't go in depth into the code. Subsequently I heard about R twice -- Once from a friend studying Psychology, Yarden Ashur, and from my sister, Maayan Levinson, a statistician with the CBS. I'll admit it took me some time to pick it up, but eventually I did.

## 2. First learning steps

My friend from Psychology also told me there's a recorded R course for psychology available on moodle (A platform for online course information) I could use freely. The course was led by [Yoav Kessler](https://kesslerlab.wordpress.com/) and proved to be a fantastic introduction. I followed along with the course and did the different assignments until we reached ggplot, a library for plotting in R.

## 3. Joining the TidyTuesday community

By the time we reached ggplot in the psychology course I was already somewhat familiar with Twitter where the [\#Tidytuesday](https://github.com/rfordatascience/tidytuesday) mostly takes place. [\#Tidytuesday](https://github.com/rfordatascience/tidytuesday) is an amazing project where every week a new dataset is published for the \#rstats community to analyze, visualize and post their results on Twitter. My excitement and motivation to participate were extremely high: So many professional and experienced R-users working on the same dataset, conjuring amazing visualizations and posting their code for others to explore (and all this for free)?! I was blown away. So I followed along on Twitter for a week or two until I said OK, let's give it a try.

It was [week 38](https://github.com/rfordatascience/tidytuesday/tree/master/data/2019/2019-09-17) in 2019 and we were working on visualizing national parks. I wasn't really sure what to do, so I did a minimal exploration of the data and noticed an interesting increase of visitors in national parks across years, which seemed intuitive and perfect for a first visualization. Following the basic area-graph I made I remembered a visualization a week earlier from [Ariane Aumaitre](https://twitter.com/ariamsita) using roller-coaster icons in her graph. Knowing nothing on how to integrate icons, I adapted her code into my visualization to create a nice scenery for the mountain the data displayed (see tweet below). I was pretty satisfied at the time and the feedback from the \#rstats community was incredible - I was hooked on the project.

<center>
{{% tweet "1174364639427272706" %}}
<newcaption>First visualization and participation in TidyTuesday</newcaption>
</center>

<br>

I believe the project was a fantastic introduction to continuously analyzing and visualizing data in R. **Participating in the project provides a safe, motivating and rich setting to practice and learn R**. Additionally, I didn't have anything that 'forced' me to learn R, so knowing that every week I had a new data set to analyze and visualize along with others provided me with a sense of **routine and commitment**.

## 4. Opening a GitHub account

Following the first visualization for [\#Tidytuesday](https://github.com/rfordatascience/tidytuesday) I wanted to share the code I wrote. At the time I was only using GitHub to read code written by others. Using the [Happy git with r](https://happygitwithr.com/) guide I was able to properly upload my code and synchronize future work. Since then, **using GitHub taught me so much: Reading others' code and discovering new functions; Organizing my own code so others can easily read it and thus 'forcing me' to clean it once I finished a project; and having a place to host all my efforts.** I sincerely believe that opening a GitHub account to share everything I did was an important and pivoting moment learning R. Although I still have so much more to learn when it comes to cleaning code and project management, a lot of what I know now is attributed to having GitHub repositories and code as accessible as possible for others to explore and learn.

## 5. Visualizing things I was interested in

As I was participating in \#Tidytuesday Eliud Kipchoge broke (unofficially) the two-hour marathon barrier. I found this amazing and wanted to visualize the comparison between the new record and older ones. I manually copied the marathon record values from Wikipedia and used that to plot running icons representing the different records. It wasn't an aesthetic plot but it was definitely rewarding. I've since improved the visualization by making it reproducible and eventually wrote a [blog post](https://amitlevinson.com/post/eliud-kichoge/) explaining the process of how I made it. Similarly, a month or two later I [plotted bomb shelter locations around my house](https://amitlevinson.com/post/bomb-shelters/) amidst missiles fired towards Israel, all in R while using Google maps. **I finally took an opportunity to make a visualization that related to my daily routine.**

## 6. Continuous learning

![](https://media.giphy.com/media/8dYmJ6Buo3lYY/giphy.gif)

Well, it's kind of redundant to say this, as we're always learning, but it is important: After I joined the \#Tidytuesday community, I started again to actively learn about visualizations and data wrangling in addition to solidifying my basic knowledge of R. For this I relied on the following sources:

-   **R & R4DS book** - I decided to start with the [R for data science online book](https://r4ds.had.co.nz/). Every morning I would spend 30-60 minutes either reading and learning something new or attempting to answer the book's questions. **I'd re-write the code into my R console while following along, exploring and trying to understand what was going on.** To validate my answers to the questions or understand those I didn't know I cross-checked them with the [Excercise solutions book](https://jrnold.github.io/r4ds-exercise-solutions/) by Jeffrey Arnold. I also bought [Data Visualizaiton, A practical introduction](https://socviz.co/) by Kieran Healy and [Text Mining with R, A tidy Approach](https://www.tidytextmining.com/) by Julia Silge and David Robinson, but I used them more on the go and less of a sit-down.

-   **Joining online courses** - While reading the R4DS book I decided to seek out some other courses at my university, mainly for recreational as I had no course credits left to take. The friend who introduced me to R told me about a workshop on 'algorithms and research in the intersection of Psychology and big data' by [Michael Gilead](https://t.co/3hLoUnYbPa?amp=1). Getting an approval to sit in on some classes I found it a great introduction to working with big data. While joining in I met [Almog Simchon](https://almogsi.com/) who led a fantastic 'text analysis in R' workshop the following semester. I'd also join [Mattan Ben-Shachar's](https://sites.google.com/view/mattansb) TA class and learn more about data wrangling and statistical methods. Additionally, a friend told me about [Jonathan Rosenblatt's](https://www.john-ros.com/) R course in the department of industrial engineering and management (recorded lectures in Hebrew are freely available). **Although I didn't understand some of what was going on in these courses, I was glad to expose myself to new things I could follow up on later.** If any of you are reading this, thank you very much for the opportunity.

-   **Other visualization books** - I found myself leaning towards books that are not related to the R ecosystem, but that I discovered during my R journey. That is, I found a strong liking towards visualizing data and bought books on that topic too. **These books immensely improved my visualizations and how I look at visualizing data**. I still have a lot more to learn - both theoretically and technically - but these books definitely inspired and opened my mind when it comes to visualizations. I highly recommend reading [Storytelling with data](http://www.storytellingwithdata.com/books) by Cole Nussbaumer Knaflic and [How Charts Lie](http://albertocairo.com/) by Alberto Cairo which I started with.

-   **Watch live webinars & videos; attended meetups** - An invaluable source of learning was participating in various online meetups and webinars. A good place I found many of them was on Twitter, but I'm sure you can also find them in Facebook groups, Rstudio news letter, etc. I Sometimes didn't understand what they were talking about but just exposing myself to it felt great (seems like a reoccurring theme). It motivated me to want to learn more in order to succeed in doing what was presented. I also highly recommend exploring the [Rstudio Videos](https://rstudio.com/resources/webinars/) page.
    <br>
    Luckily, I started learning R before the COVID-19 prevailed so I was able to join 2 Israeli R-meetups. This was a great experience and although being a novice when I attended them, the community was great, people were welcoming, there was great pizza and beer and the presentations were fantastic. It was a great source of inspiration of what was to come. **Plus, seeing so many people enthusiastically talking about R made me understand that I'm not alone in liking this world.**

## 7. Making my own website

A month or two into learning R I noticed people had their own websites they made in R. Again I was fascinated at how this was possible - Not only can I wrangle data and beautifully visualize it but I can also build my own website? and for 10\$ I can use my own domain? This was crazy!

<iframe height="500" width="95%" title="Intentionally blank" src="https://amitlevinson.com/">
</iframe>
<center>
<newcaption> Opening my own website - A motivation to learn and write</newcaption>
</center>

<br>

**Nearing mid January (4+- months into R) I decided it's time open my own website.** I had a few things I already made ([Eliud Kipchoge's record](https://amitlevinson.com/post/eliud-kichoge/) and the [bomb shelters around my house](https://amitlevinson.com/post/bomb-shelters/)) and also wanted a place for others to learn more about me. I scrolled and followed along the [blogdown book](https://bookdown.org/yihui/blogdown/) for creating websites with R, viewed some of [Allison Hill's blogdown workshops](https://alison.rbind.io/project/up-running-blogdown/) and other resources. Eventually, I was setup and had my website live, done in R, hosted for free on Netlify and GitHub with an elegant Hugo Academic theme, and my own domain for only 10\$! **I was amazed at how easy and rewarding this was.** I mean, I had no knowledge (and still don't) of HTML, CSS or anything else to build a website and here I conjured one, and pretty easily!

**I highly recommend creating a website.** Even if you're not an R user, I think a personal website is a great motivator for writing blogs; a platform for others to learn more about you and a not so difficult thing to do today. **Opening a website has definitely motivated me to learn much more by writing about it** (here's a great talk by David Robinson on [The unreasonable effectiveness of public work](https://rstudio.com/resources/rstudioconf-2019/the-unreasonable-effectiveness-of-public-work/)).

## 8. Giving a talk about R

During Passover (April) 2020, the [Israel-2050](https://israel2050.co.il/en/home/) fellows group sent out a call inviting individuals to talk about anything they wanted. I decided to take the opportunity and give a talk there, and following that to a group of friends of mine that meet periodically with someone presenting something. Although being only \~7 months into learning R, I wanted to share its amazing abilities for wrangling and visualizing data, the extreme difference of using it compared to SPSS I learned and how it helped me explore intriguing questions I had. So I sat down, wrote an outline, and made a presentation using the [{Xaringan}](https://github.com/yihui/xaringan) package. You can find the [slides here]().

The talk was great (I think) and some of the participants even followed up inquiring about resources to get started, how can they do this in R, etc. However, more importantly, **making and giving the talk forced me to think about what is it in R that I like.** Organizing these thoughts and communicating them in a way that is appealing to the audience was a fantastic opportunity to stop and think about exactly that: Why do I like working in R and why should they join it.

<center>
<iframe height="500" width="100%" src="https://amitlevinson.github.io/slides-israel-2050/index.html#1">
</iframe>
<newcaption>
[My first talk about R](https://amitlevinson.github.io/slides-israel-2050/index.html#1) (use your keyboard arrow to scroll through it).</newcaption>
</center>

<br>

## 9. Integrating R into my daily work

**Using R as a research assistant** - I was very fortunate that the researcher I work for, [Dr. Jennifer Oser](https://www.jenniferoser.com/), was (and still is) very supportive of integrating R into our daily work. I remember as we started analyzing our data and trying to make sense of it I was debating whether to open SPSS, Excel or R. Luckily, I knew how to do some of what we wanted to in R so I turned to use that. I believe we've greatly progressed since, so much that I find it absurd to use something else now. **If you can integrate R into your daily work it's definitely a bonus, I know I learned a lot (I mean a lot) about rmarkdown and version control once I started using R in my research assistant position.**

**Integrating R into my thesis** - The reason I initially started learning R was so that I could analyze my thesis' findings and finish my MA with a new skill. No one forced me to use R, and I'm sure I could have done OK with SPSS (or maybe not?), but I was keen on using R in my thesis; it was an exciting and challenging experience. **Prior to my thesis I've mostly done visualizations and descriptive reports so it was great working on regression models, reliability and other forms of reports.** I also learned more about version control, using the same functions I wrote for the pilot study and my main analysis and so forth. I couldn't imagine producing SPSS tables and integrating them every time in a separate text document; plus, it was very rewarding trying to automate the process as much as possible.

## 10. Blog, and then blog some more

I imagine you've heard this saying a lot, but I definitely agree with it: **If you like it then you should <s>put a ring on it</s> write about it. Don't write for others, write for yourself.** While I mentioned earlier that I wrote about my visualizations, I also wanted to learn about the statistical analyses I came across. **I would read about a topic and think of an example I can easily use to explain the concept. For myself, not for others.**

For example, to learn what was Term frequency inverse document frequency (tf-idf) I implemented it in [analyzing the tfidf of 4 books by political theorists'](https://amitlevinson.com/post/learning-tfidf-with-political-theorists/) I like. At one point I wanted to learn more about Bernoulli trials so I explored the [uncertainty in the Israeli lottery](https://amitlevinson.com/post/uncertainty-in-the-israeli-lottery/). **Alternatively, write about a challenge you faced and how you solved it.**In another example, I wrote about presenting a static summary of categorical variables from my thesis pilot survey ([found here](https://amitlevinson.com/post/printing-survey-table/)).

**Don't write for others to click on your website; rather, write for you to learn or communicate something you want to share with your future self and the world, no matter who reads it.**

## Summary & Main takeaways

So this was a not-so-short recap of my last year, which I hope was of value. A lot of the above is owed to the amazing R community - Any and every one who blogs, shares his code, interacts about R on social media and was forthcoming. **I'm very grateful to the many people I've reached out to with random questions, wanting to join their course or inquire about further reading.**

![](https://media.giphy.com/media/YRuFixSNWFVcXaxpmX/giphy.gif)

It's interesting to think back about something you've done and if and how would you have done it differently. As to the latter, I'm not sure, and I'm kind of glad that it happened the way it did.

I think my main takeaways are:

1.  Learn a bit from a course, website, blog, book, etc. Don't get too caught on in my opinion, rather try and implement it on examples that could be similar to those in a book, but aren't given on a silver platter (for example search for your own dataset from [Kaggle](https://www.kaggle.com/) and the like).

2.  Find a community and project that will keep you hooked. If you're interested in R, then join the [\#Tidytuesday](https://github.com/rfordatascience/tidytuesday) project!

3.  Share what you learn -- whether by uploading your code to GitHub, opening your own website or giving a talk. One of the main motivators I had to overcome of writing after using R for only 4 months ( an "imposter syndrome") was discovering that a Youtube video on [how to unzip a file](https://www.youtube.com/watch?v=r9hpiyzOOTY) had 650,000 views. That is, there's an audience for everything. Don't think "I'm not good enough to write about it". One of the best ways I learned something was understanding it in a way that I could then communicate it to others.

4.  **Have fun! The more -- The better!**

If you're looking for a place to start, [Oscar Baruffa](https://oscarbaruffa.com/) compiled a fantastic resouce aggregating [\~100 books about R](https://www.bigbookofr.com/) (most are free).

#### What's next for me

Great question! Honestly I don't know. I hope to finish my thesis soon and search for a job that'll require me to work with R and visualize data. In addition, I'll probably also try and learn some Tableau and improve my SQL skills as they are somewhat sought after in various jobs I looked at. As to R, I hope to learn some new concepts and statistical analyses; incorporate more \#Tidytuesdays into my weekly routine; and analyze some data I have waiting around for a blog post. Of course everything is flexible, and in that case I really don't know what's waiting but I'm definitely excited about it!
