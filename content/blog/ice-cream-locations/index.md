---
title: Distances to Golda Ice-Cream Locations in Israel
author: Amit Grinson
date: '2021-02-10'
layout: single
slug: exploring-ice-cream-locations
categories: [R]
tags: [maps, rvest, interactive]
subtitle: ''
summary: 'Exploring maps and distances to various Golda ice-cream locations throughout Israel'
authors: []
featured: yes
projects: []
format:
  hugo:
    html-math-method: webtex
---



<script src="index_files/libs/core-js-2.5.3/shim.min.js"></script>
<script src="index_files/libs/react-17.0.0/react.min.js"></script>
<script src="index_files/libs/react-17.0.0/react-dom.min.js"></script>
<script src="index_files/libs/reactwidget-1.0.0/react-tools.js"></script>
<script src="index_files/libs/htmlwidgets-1.5.4/htmlwidgets.js"></script>
<script src="index_files/libs/reactable-binding-0.3.0/reactable.js"></script>


<style type="text/css">
newcaption {
  font-size: 0.9em;
  text-align: center;
}
</style>

### What's this all about

This past November I participated several times in the [\#30DaysMapChallenge](https://github.com/tjukanovt/30DayMapChallenge), a daily mapping visualization challenge. While I was satisfied with [what I came up with](https://amitlevinson.com/blog/thirty-day-map-challenge/), my main outcome was that I have no idea how to work with maps. Well, to say it differently, I was able to fiddle around and hit home eventually, but my knowledge of Coordinate Referencing Systems (CRS) and other important features was limited. For that purpose, I knew I'll be back to explore some additional geographic data, leading to the following blog post.

**In this blog post I'll explore [Golda Ice-cream](https://www.goldaglida.co.il/) locations throughout Israel.** My wife and I came across Golda one day and were happily surprised when first tasting it: the ice-cream was fantastic, especially compared to other ice-cream shops we previously visited. Golda has a plethora of ice-cream flavors including fantastic Sorbets, chocolate pretzel, salted cashew, vanilla chocolate pistachio and more. Also, they have this really amazing pretzel sauce you can drizzle on top, what a treat!

<center>
<newcaption>
<img width ="95%" src="imgs/ice-cream.jpg"></img>
Golda's delicious ice-cream flavors. Source: [Golda Facebook page](https://www.facebook.com/GLIDAGOLDAISRAEL)</newcaption>
</center>

<br>

To follow through with my motivation to learn more about maps and as a tribute to their great ice-cream I decided to explore Golda's ice-cream locations. More specifically, we'll be looking at distances from various points in the country to the *nearest* ice-cream location. Following a short overview of the data collection and ice-cream locations throughout Israel I will address the utmost important question pertaining distances and Golda locations:

> **Where do you *not* want to be if you want an ice-cream now**?

I will say that I have no affiliation nor received any compensation for this post. I'm genuinely writing this as a means to learn about maps by exploring ice-cream locations. **Stick with me if you want to learn about the nearest ice-cream shop to you.**

Before we begin, a big thank you goes to Dominic Roye's blog post on [distances from the shore in Iceland](https://dominicroye.github.io/en/2019/calculating-the-distance-to-the-sea-in-r/) for inspiration and practical help with the code. On a more theoretical level, I enjoyed and learned from Michael Dorman's ['Using R for Spatial Data Analysis'](https://michaeldorman.github.io/R-Spatial-Workshop-at-CBS-2021/main.html) materials from a workshop he gave. I highly recommend exploring both.

In contrast to previous blog posts of mine this one will not display code or raw data. However, I invite you to explore the [full source code](https://github.com/AmitLevinson/amitlevinson.com/blob/master/content/post/ice-cream-locations/index.Rmd) to learn what's done under the hood.

### Golda location information

I web-scraped [Golda's website]((https://www.goldaglida.co.il/%d7%a1%d7%a0%d7%99%d7%a4%d7%99%d7%9d/)) to extract relevant information such as street addresses in Hebrew. To get exact locations I geocoded those street addresses using the [{ggmap}](https://github.com/dkahle/ggmap) R package, extracting corresponding latitude & longitude coordinates for each scraped address. I then queried the received longitude and latitude for Golda's addresses in English to validate the information initially extracted.

Essentially, I geocoded the data twice. Any addresses in English that didn't match the Hebrew ones I manually checked for the correct location. I identified about 2-3 locations that the extracted information was 250 meters off. Some locations might still not be exact, but overall I think we're good to go. You can explore the [scraping script and complete dataset with English locations](https://github.com/AmitLevinson/Datasets/tree/master/golda) for further info.

**Our Golda ice-cream dataset looks as follows:**

<div id="htmlwidget-049aa9dbf880bcb88df9" class="reactable html-widget" style="width:auto;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-049aa9dbf880bcb88df9">{"x":{"tag":{"name":"Reactable","attribs":{"data":{"id":[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79],"city":["אור יהודה","אור עקיבא","אילת","אשדוד","אשקלון","באר יעקב","באר שבע","ביתן אהרון","בת ים","גבעת שמואל","גבעתיים","גבעתיים","גדרה","גן יבנה","הוד השרון","הרצליה","הרצליה","הרצליה","חדרה","חדרה","חולון","חיפה","חריש","טירת הכרמל","יבנה","יוקנעם","יפו","יפו","ירושלים","ירושלים","ירושלים","ירושלים","כרמיאל","כפר סבא","מודיעין","מודיעין","מעלה אדומים","מצפה רמון","נס ציונה","נתיבות","נצרת","נהריה","נתניה","נתניה","סביון","צומת גלילות","עפולה","פרדס חנה","פתח תקווה","קניון הקריון","קריית גת","קריית מוצקין","קרית אונו","ראש העין","ראש פינה","רמלה","רמת גן","רעננה","רעננה","ראשון לציון","ראשון לציון","ראשון לציון","רחובות","רחובות","שוהם","שפיים","תל אביב","תל אביב","תל אביב","תל אביב","תל אביב","תל אביב","תל אביב","תל אביב","תל אביב","תל אביב","תל אביב","תל אביב","תל אביב"],"street":["אריק איינשטיין 1","השקמים 8","מתחם הספירל","אריק איינשטיין 4","שדרות אפריקה 65","יהלום 3","החיטה 1","מתחם ביתנ'ס","בן גוריון 85","הערבה 1","בורכוב 54","דרך השלום 53","מנחם בגין 12","המגינים 56","דרך רמתיים 24","השונית 2- קניון ארנה","חבצלת השרון 37","בן גוריון 22","אקו פארק","צומת חדרה כביש 4","פנחס איילון 13","דוברין 3","גפן 4","ששת הימים 1","הדוגית 16","שדרות יצחק רבין 9","עולי ציון 9","רציף העלייה השנייה 101, נמל יפו","שדרת אלרוב ממילא","אביזוהר 8","המעיין 25","אגריפס 72","מעלה כמון 2","מתחם G","עמק זבולון 24 – קייזר סנטר","קניון מודיעין","הרכס 31","שדרות בן גוריון 2","ויצמן 12","בעלי המלאכה 13","ביג פאשן נצרת","בלפור 1","סינמה סיטי המחקר 3","יכין סנטר","נתיב היובל 1","סינמה סיטי","שדרות יצחק רבין 20","גלעד 1","השחם 30","דרך עכו 192","דרך הדרום 20","שדרות ירושלים 1","המייסדים 3","רחוב שבזי 10","התפוח 1","משה אדרת 4","שדרות ירושלים 3","רחוב ויצמן 273","אחוזה 71, רעננה","הטיילת 14","סחרוב 26","גבעתי 1","מוטי קינד 10","חיים פקריס 3","עמק איילון 30","חוצות שפיים","מקווה ישראל 22","בן יהודה 110","מאיר יערי 19","ז'בוטינסקי 110","שמואל רודנסקי 5","מנחם בגין 144","קניון עזריאלי","חוף גורדון-הירקון 163","משה דיין 2","יחיאלי 9, סוזן דלל","דיזינגוף 245","ישכון 22","דיזנגוף 107"],"number":["03-7797577","04-646-0705","08-9428989","08-9775157","08-6869144","08-9555764","08-6445959","09-9661614","03-9441070","03-7775169","03-9441580","03-5090394","08-6565999","08-6913335","09-9775251","09-9601630","09-9799320","09-7921477","04-8692622","04-8801493","03-7792477","077-7060373","04-8164606","04-612-6444","08-6846192","04-6298822","03-6036275","03-6241041","02-5644496","02-9665661","02-6449253","02-5444077","052-7247441","09-8912336","08-6578945","052-8264820","02-5455570","08-9120806","08-9955289","08-6733343","04-6704343","04-6835333","09-8802035","09-9777555","03-7787088","03-9447269","04-7749599","04-8233660",null,"04-8885555","08-658-9026","04-641-2662","03-7786447","03-9024405","04-6190555","08-9711909","03-5367330","09-7882233","09-9591000","03-5080550","03-7745102","03-6099949","08-9447717","08-6875060","03-559-7967","09-9697969","03-6327766","03-9743322","03-6885836","03-6968581","03-6992770","03-5297797","03-6960405","03-5780170","03-5614016","03-5105545","03-5164014","03-5377887","03-6350409"],"lon":[34.8600193,34.91794008,34.9596765,34.6365283,34.570097,34.8261351,34.7994617,34.8680834,34.7389925,34.8556056,34.8096975,34.803277,34.7835822,34.704494,34.8940276,34.7968935,34.8048763,34.8420226,34.9340366,34.91021,34.7783752,34.9999173,35.0395,34.9729581,34.735896,35.0940528,34.7569213,34.7506434,35.2252087,35.1867225,35.161224,35.21137479,35.3208182,34.9284373,34.9982069,35.0076632,35.3113066,34.8027322,34.7982235,34.5952321,35.30125526,35.0910873,34.8616661,34.86202,34.877472,34.8044874,35.2998605,34.9743126,34.8587367,35.0903414,34.7772321,35.0652399,34.8579994,34.9418992,35.5503387,34.8891982,34.81934893,34.8450306,34.8806584,34.7325432,34.7741726,34.8170841,34.7894096,34.8045454,34.94685,34.8283333,34.7762768,34.7717,34.7877215,34.7866453,34.79277609,34.79484,34.7922028,34.7689540001264,34.799156,34.7642438,34.7761066,34.7674684,34.7736884],"lat":[32.0205064,32.50435742,29.5495247,31.7911936,31.680045,31.9362388,31.2341222,32.3615628,32.018181,32.084025,32.078906,32.066902,31.80029,31.7952815,32.1600277,32.1636494,32.1789864,32.1630141,32.4285114,32.437704,32.0087448,32.8181047,32.471,32.7596281,31.866917,32.6460421,32.0529073,32.0542555,31.7773657,31.7749335,31.764778,31.78468998,32.9271943,32.1720743,31.907639,31.8996612,31.7824447,30.6125647,31.9269473,31.4184847,32.69674366,33.0067673,32.2908142,32.2812249,32.0446395,32.1463675,32.6146772,32.4727894,32.0873026,32.8420813,31.6057407,32.8352351,32.0561635,32.0985708,32.970075,31.9298811,32.07502139,32.191239,32.1789452,31.9988297,31.9895843,31.9671292,31.8946742,31.9119146,31.9990278,32.2208333,32.0627021,32.0831387,32.0999275,32.0871902,32.12071803,32.079904,32.0740769,32.0848266319339,32.047187,32.0607159,32.0921838,32.0688802,32.0800888]},"columns":[{"accessor":"id","name":"id","type":"numeric"},{"accessor":"city","name":"city","type":"character"},{"accessor":"street","name":"street","type":"character"},{"accessor":"number","name":"number","type":"character"},{"accessor":"lon","name":"lon","type":"numeric"},{"accessor":"lat","name":"lat","type":"numeric"}],"defaultPageSize":6,"paginationType":"numbers","showPageInfo":true,"minRows":1,"dataKey":"2426b7b046f077a64c1b8f702dbe0f5e"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}</script>

<br>

We have a total of 79 locations throughout Israel. Each row represents a store, the city and street it's located in, their phone number and a corresponding longitude and latitude point. A few stores on the website were noted as currently closed, but for the sake of this post will treat them like all others.

Let's see where they are across Israel:

<center>
<iframe width="95%" height="525px" name="iframe" src="widgets/simple_map.html">
</iframe>
<newcaption>Golda Ice-cream locations. Hover over a location for more info</newcaption>
</center>

<br>

A quick overview of our map shows that **majority of Golda locations are in the Tel-Aviv metropolitan area (center of Israel). Other locations are scattered across the country with several in the north and a few down south.** You can also hover over a location to learn where exactly is it located.

### Measuring distances

We (well, I) want to calculate the distances to each Ice-cream location from various points on the map. Doing so requires us to project our map to a different coordinate reference system than the current. That is, our current CRS uses geographic coordinates that account for earth's curvature, when we want a flat surface to measure distances. Think of it as cutting open a basketball, flattening it and then measuring a distance from two points.

Furthermore, We want to measure distances from various locations on the map to the nearest Golda ice-cream location. However, **distance from 'various locations' is somewhat abstract; we want the distance from something a little more specific.** To tackle that query, we'll divide the geographical area of Israel into grids.

Grids... What? Let's have a look:

``` r
theme_set(theme_void()+
            theme(text = element_text("IBM Plex Sans"),
                  plot.title = element_text(color = "#0C0C44", face = "bold")))

p1 <- ggplot(isr_map_sf)+
  geom_sf()

p2 <- ggplot(grid)+
  geom_sf()
  
p1+p2+
  plot_annotation(
    title = "Map of Isreal (left) and map cut into 2km<sup>2</sup> areas (right)",
    theme = theme(plot.title = element_markdown(size = 12)))
```

<img src="index_files/figure-gfm/unnamed-chunk-7-1.png" width="768" />

On the left we have our map of Israel, and on the right the same map after we 'cut' it horizontally and vertically. Each grid represents a square polygon (except those on the borders) with specific geographic references to plot it, creating a 2 squared kilometers area (2km![^2](https://latex.codecogs.com/svg.latex?%5E2 "^2")). **We can measure the distance from the center of each 2km![^2](https://latex.codecogs.com/svg.latex?%5E2 "^2") grid to the nearest ice-cream location.**

In practical terms, here's an example of distances from one random grid to a few random Golda locations:

``` r
# Create a sampled dataframe
dataum <- data.frame(
  geometry = st_geometry(golda_projected[3:9,]),
  location_grid = st_centroid(rep(grid_wgs[350],7)))


# Our data points projected to a 
data_lines <- map_dfc(dataum, ~ st_transform(.x, crs = 2039)) 

sample_data <- data_lines %>% 
  map_dfc(~ st_transform(.x, crs = 4326) %>% st_coordinates(.x)) %>% 
  map_dfc(as.data.frame) %>% 
  set_names(c("golda.x","golda.y", "us.x" ,"us.y")) %>% 
  cbind(distance = map2_dbl(data_lines$geometry, data_lines$geometry.1,  st_distance),
        location_polygon = st_transform(data_lines$geometry.1, crs = 4326)) %>% 
  mutate(relevant = ifelse(distance == min(distance), "yes", "no"),
         distance = ifelse(relevant == "yes", paste0(round(distance/1000, 0), "km"), round(distance/1000, 0)))

point_labels <- data.frame(x = c(34.802,34.95968, 34.79946),
                           y = c(30.04696, 29.54952, 31.23412),
                           label = c("Example grid", "Nearest Golda", "Golda locations"))

ggplot(isr_map_sf)+
  geom_sf()+
  geom_point(data = sample_data,mapping= aes(x = golda.x, y = golda.y, color = relevant), size = 1.2)+
  geom_sf(data = grid_wgs[350], aes(geometry = geometry), fill = "red", color = "red")+
  geom_spatial_segment(data = sample_data, mapping = aes(x = us.x, xend = golda.x, y = us.y, yend = golda.y, linetype = relevant, color = relevant), show.legend = FALSE)+
  geom_spatial_text_repel(data = sample_data, mapping = aes(x = golda.x,  y = golda.y, label = distance, color = relevant), crs = 4326, hjust = 0.5, size = 3.5)+
  geom_text_repel(data = point_labels, mapping = aes(x = x, y = y, label = label), xlim = c(35.5,36), point.padding = 0.1,  arrow = arrow(length = unit(0.015, "npc"), type = "closed"), segment.linetype = 8, color = "gray55", segment.color = "gray80", size = 3)+
  scale_color_manual(values = c("yes" = "red", "no" = "gray60"))+
  scale_linetype_manual(values = c("dashed","solid"))+
  xlim(34,36)+
  coord_sf(clip = "off")+
  guides(color = "none")+
  labs(title = "Finding the nearest Golda location for each grid")+
  theme(plot.title = element_text(size = 13, hjust = 0.5))
```

<img src="index_files/figure-gfm/unnamed-chunk-8-1.png" width="768" />

Our small square represents a 2km![^2](https://latex.codecogs.com/svg.latex?%5E2 "^2") area somewhere in southern Israel. **The lines and corresponding values indicate the distance to each ice-cream location from our example grid.** To be specific, I measure the air distance from the *center* of a grid cell to the various locations. In the above graph our sampled grid is connected with a red line to the nearest ice-cream location located in Eilat, 57km away.

{{% alert note %}}
We divide Israel into grids and measure the distance between each grid cell to all 79 Golda locations. To extract the distance to the nearest Golda location we find the minimum distance value for each grid, i.e. the distance to the nearest Golda ice-cream location.
{{% /alert %}}

![](https://media.giphy.com/media/AGGz7y0rCYxdS/giphy.gif)

### Where's Our Ice-cream

Once we understand how each grid's nearest ice-cream location distance is found we can measure accordingly for all grids. Following that we can create a map of our grid cells filled with color indicating the distance to the nearest Golda ice-cream location:

``` r
# Commented out and loaded as an rds instead. Calculate distances:
# distances <- st_distance(golda_meters, st_centroid(grid)) %>% 
# as_tibble()

# Loaded as rds for faster rendering
distances <- read_rds("rds/distances.rds")

golda_distances <- data.frame(
  # We want grids in a WGS 84 CRS:
  us = st_transform(grid, crs = 4326),
  # Extract minimum distance for each grid
  distance_km = map_dbl(distances, min)/1000,
  # Extract the value's index for joining with the ice-cream location info
  location_id = map_dbl(distances, function(x) match(min(x), x))) %>% 
  # Join with the ice-cream table
  left_join(golda_projected, by = c("location_id" = "id"))


# We don't evaluate this as I saved it as a widget instead.
# ice_cream_icon <-  makeIcon("ice-cream.png", iconWidth = 6, iconHeight = 8)

# Decrease size of ice-cream icons
ice_cream_icon <- makeIcon("https://upload.wikimedia.org/wikipedia/commons/2/2c/Ice-cream-solid.svg", iconWidth = 6, iconHeight = 10)

# Bin ranges for a nicer color scale
bins <- c(0,5,15,30,50,70)
# Create a binned color palette
pal <- colorBin(c("#FF1554", "#FF3C70", "#FF7096", "#FFA4BC", "#FFE5EC"), domain = golda_distances$distance_km, bins = bins, reverse = TRUE)

#Pink colors more variance:
# c("#FF1554", "#FF3C70", "#FF7096", "#FFA4BC", "#FFE5EC")

    #ff084a
# Function to create the labels indicating distances
make_label_distances <- function(km, street, city){
  glue("
  <div style='text-align:left;'>
  You are <span style='font-size:13px;'><b>{round(km, 1)}</b></span> km from the nearest location at:</div>
  <div style='text-align:right;'>
       {street}, {city}</div>") %>% 
    HTML()}
# Create the labels
ice_cream_labels <- pmap(list(golda_distances$distance_km, golda_distances$street,golda_distances$city), make_label_distances)

full_map <- leaflet() %>% 
  addTiles() %>% 
  addMarkers(data = golda_projected, icon = ~ice_cream_icon, group = "Ice-cream locations") %>% 
  addPolygons(data = golda_distances[[1]], fillColor = pal(golda_distances$distance_km), fillOpacity = 0.8, weight =0,
              opacity =1, color = "transparent", group = "Distances", popup = ice_cream_labels, 
              highlight = highlightOptions(weight = 2.5, color = "#666", bringToFront = TRUE, opacity= 1),
              popupOptions = popupOptions(autoPan = FALSE,closeOnClick = TRUE, textOnly = T)) %>% 
   addLegend(pal = pal, values = (golda_distances$distance_km), opacity = 0.8, 
                         title = "Distance (Km)", position= "bottomright") %>% 
  addLayersControl(overlayGroups = c("Ice-cream locations", "Distances"),
                   options = layersControlOptions(collapsed = FALSE))

# Save the widget to use as an iframe:
# htmlwidgets::saveWidget(full_map, "widgets/full_map.html")
```

<p align="center">
<iframe width="95%" height="550px" name="iframe" src="widgets/full_map.html">
</iframe>
<newcaption>Distance to the nearest Golda ice-cream location from the center of a 2km![^2](https://latex.codecogs.com/svg.latex?%5E2 "^2") grid cell. Zoom in and click on a grid for more info on the nearest ice-cream location</newcaption>
</p>

**Beautiful! Well, mainly for those living near ice-cream locations.**

The main conclusion is you don't want to be stuck somewhere in southern Israel or south of the dead sea with a sudden craving for ice-cream. We also see that similar to before, those living in the Tel-Aviv metropolitan area are safe with a Golda location near by.

I've added a twist to the map in which you can click on a grid cell to see how far is the nearest ice cream location. The distance is measured from the center of a grid so we'll treat the grid cell as one unit.

We could also level up the map and have the distance measured from a specific location the user clicks on, not a whole grid cell. For that we'll need something reactable such as an interactive web app (e.g. R Shiny) providing exact distances from a point clicked on the map. It seems pretty straight forward but for the purpose of the post I found the above appropriate and a great learning experience.

### Static maps

#### Version 1

We can visualize it on a static map enabling us to easily share it as an image:

``` r
# Using the interactive original object we can create a
# static map:
golda_distances <- data.frame(
  us = st_transform(grid, crs = 4326),
  # Extract minimum distance for each grid
  distance_km = map_dbl(distances, min)/1000,
  # Extract the value's index for joining with the ice-cream loc info
  location_id = map_dbl(distances, function(x) match(min(x), x))) %>% 
  left_join(golda_projected, by = c("location_id" = "id")) %>% 
  mutate(binned_colors = cut(distance_km, breaks = c(70,50,25,10,5,0)))

pink_palette <- c("#FF1554", "#FF3C70", "#FF7096", "#FFA4BC", "#FFE5EC")


ggplot(golda_distances, color = "gray55")+
  geom_sf(data = isr_map_sf, aes(geometry = geometry))+
  geom_sf(aes(geometry = geometry.x, fill =  binned_colors), color = NA)+
  geom_point(golda_locations, mapping = aes(x = lon, y= lat), size = .3)+
  scale_fill_manual(name = "Distance (km)", values = rev(pink_palette),
                    labels = c("0-5", "5-10", "10-25", "25-50", "50-70"))+
  xlim(33.7,36)+
  labs(title = "Distance from Golda Ice-cream locations", subtitle = "Black dots represent Golda ice-cream locations, and the filled<br>color indicates distances from the center of a 2km<sup>2</sup> area")+
  # labs(caption = "Data: Golda | @Amit_Levinson")+
  theme_void()+
  theme(plot.title = element_text(color = "#0C0C44", face = "bold", size = 13),
        plot.title.position = "plot",
        plot.subtitle = element_markdown(color = "gray35", size = 10),
        # plot.caption = element_text(color = "gray55", hjust = 1, size = 6, face = "italic"),
        # plot.margin = margin(3,4,0,4,"mm"),
        legend.title = element_text(size = 8),
        legend.text = element_text(size = 7),
        legend.key.size = unit(3,"mm"))
```

<img src="index_files/figure-gfm/unnamed-chunk-10-1.png" data-fig-align="center" width="768" />

<center>
<newcaption>Static map of distances to Golda ice-cream locations
<a download href="imgs/Golda.png"><i class="fa fa-download" aria-hidden="true" style="color:black"></i></a></newcaption>
</center>

#### Version 2

Considering the geo-political issues in Israel, which I won't elaborate here, I'll share another map with different borders. These borders better reflect the feasibility of individuals to access these locations since people living in, say, Gaza (plotted in previous maps), cannot access any of the locations.

``` r
# Israel map
isr_map_rds_raw <- readRDS("maps/00_Israel_0_sf.rds")
# write_rds(grid_rds, "rds/grid_green.rds")
grid_rds <- read_rds("rds/grid_green.rds")
# write_rds(distances_rds, "rds/distances_green.rds")
distances_rds <- read_rds("rds/distances_green.rds")

golda_distances_rds <- data.frame(
  us = st_transform(grid_rds, crs = 4326),
  # Extract minimum distance for each grid
  distance_km = map_dbl(distances_rds, min)/1000,
  # Extract the value's index for joining with the ice-cream loc info
  location_id = map_dbl(distances_rds, function(x) match(min(x), x))) %>% 
  left_join(golda_projected, by = c("location_id" = "id")) %>% 
  mutate(binned_colors = cut(distance_km, breaks = c(70,50,25,10,5,0)))

ggplot(golda_distances_rds)+
  geom_sf(data = isr_map_rds_raw, color = "gray55")+
  geom_sf(aes(geometry = geometry.x, fill =  binned_colors, color = "black"), color = "transparent")+
  geom_point(golda_locations, mapping = aes(x = lon, y= lat), size = .3)+
  scale_fill_manual(name = "Distance (km)", values = rev(pink_palette), labels = c("0-5", "5-10", "10-25", "25-50", "50-70"))+
  xlim(33.7,36)+
  labs(title = "Distance from Golda Ice-cream locations", subtitle = "Black dots represent Golda ice-cream locations, and the filled<br>color indicates distances from the center of a 2km<sup>2</sup> area")+
  # labs(caption = "Data: Golda | @Amit_Levinson")+
  theme_void()+
  theme(plot.title = element_text(color = "#0C0C44", face = "bold", size = 13),
        plot.title.position = "plot",
        plot.subtitle = element_markdown(color = "gray35", size = 10),
        # plot.caption = element_text(color = "gray55", hjust = 1, size = 6, face = "italic"),
        # plot.margin = margin(3,4,0,4,"mm"),
        legend.title = element_text(size = 8),
        legend.text = element_text(size = 7),
        legend.key.size = unit(3,"mm"))
```

<img src="index_files/figure-gfm/unnamed-chunk-13-1.png" width="768" />

<center>
<newcaption>Static map of distances to Golda ice-cream locations within Israel's pre-67 borders <a download href="imgs/Golda_wo.png"><i class="fa fa-download" aria-hidden="true" style="color:black"></i></a></newcaption>
</center>

### Conclusion

All this talk about ice-cream sure got me craving for some. I hope I didn't instill too much ice-cream craving in you following this post, but at least now you know where to find the nearest location. I also invite you to explore the [full source code](https://github.com/AmitLevinson/amitlevinson.com/blob/master/content/post/ice-cream-locations/index.Rmd) or play with the [data](https://github.com/AmitLevinson/Datasets/tree/master/golda) yourself.

Although a short post, I've learned a plenty on using maps, distances and reference systems. From a technical level it required learning about transitioning from various reference systems, calculating distances, understanding what occurs under the hood and learning how to interactively display the final result. **While I definitely still don't know enough about working with spatial data in R, I feel like I don't know a little less after completing this blog post.**

I hope you enjoyed this post and it helps you find the nearest ice-cream location next time you're subject to an ice-cream frenzy!
