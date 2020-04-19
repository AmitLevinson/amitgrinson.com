
### Words before and After the Elections

The last thing I'd like to look at is the frequency of words *before* and *after* the closing of polls. The elections were held on March 2nd, 2020, and the polls closed at 10:00 PM. Until 10 o'clock voting day it is prohibited to report and publicize any survey or media polls. Therefore, I imagine that at 10 PM (+- 30 seconds) when the media posts its first polls the discussion might vary a little. To check that we'll give each observation a value of before or after, break it up into words and plot their frequency. Let's have a look:
  
  ```{r warning = TRUE}
election_freq <- elections %>% 
  mutate(tweet_time = ifelse(created_at < "2020-03-02 22:00:30", "before", "after")) %>% 
  select(text, created_at, tweet_time) %>% 
  unnest_tokens(word, text) %>% 
  filter(!grepl("([a-z])|בחירות", word),
         !word %in% he_stopwords$word) %>%
  count(tweet_time,word) %>% 
  group_by(tweet_time) %>% 
  mutate(proportion = n/sum(n)) %>% 
  select(-n) %>%
  pivot_wider(names_from = tweet_time, values_from = proportion)

ggplot(election_freq, aes(x = before, y = after, color = abs(before-after)))+
  geom_abline(color = "gray40", lty = 2)+
  geom_text(aes(label = word), check_overlap = TRUE, vjust = 1.5)+
  adjust_axis()+
  scale_x_log10(labels = percent_format(), limits = c(NA, 0.01))+
  scale_y_log10(labels = percent_format())+
  scale_color_gradient(limits = c(0, 0.001), low = "gray100", high = "gray25")+
  labs(title = "Frequency of words before and after the election",
       x = "Before", y = "After")+
  theme(text = element_text(size = rel(4),family = "Calibri"),
        plot.title = element_text(family = "Roboto Condensed", size = 18),
        legend.position = "none",
        panel.grid = element_blank())
```
<br>
  
  #### So what are we looking at?
  
  For every word we see here, they Y axis represents its proportion out of all words used **after** the election polls closed - 10:00 PM. The X axis represents the frequency of that word out of all words used in tweets **before** the election polls closed. The diagonal dotted line represents equal usage of a given word both before and after the elections. 


All in all words seem extremely similar, let's run a correlation test to see how it looks:
```{r}
cor.test(election_freq$after, election_freq$before)
```

That's a pretty high correlation, in our case meaning that there are no extreme anomalies in using words. In other words, there isn't much of a difference in terms of words used before and after elections. We could run a term frequency inverse document frequency (tf-idf) instead of the above, but I'll leave that for another post altogether where I'll learn the algorithm.


##### wordcloud

Let's review that for a minute:  
  1. I first read in a file containing 500 Hebrew stopwords. As to the file's validity, you can look at them for yourself [here](https://github.com/gidim/HebrewStopWords/blob/master/heb_stopwords.txt). We'll see later on an interesting problem I had with it.  
2. I then used the unnest_tokens to break up the 'text' column in our dataframe into single words. We could, as we will do later, break it up into 2 words. Its default is one words which is adequate in this case.    
3. I then `select` the only column we need - our new one.  
4. I use the `anti_join` to filter out *words that match* words in the stopwords dataset.  
5. Using `count` I count how many times each word occurs and sort it.  
6. I `filter` any words that occur less than 150 times, the word 'elections' in Hebrew (Reminder: that's the word we searched tweets by so it'll be in all tweets) and any words in English. As to the latter, before I did it it left me with many Twitter usernames which didn't seem valuable.

