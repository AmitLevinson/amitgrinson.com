---
title: Mapping bomb shelters in Be'er-Sheva, IL
layout: single-sidebar
author: Amit Grinson
date: '2020-01-14'
slug: bomb-shelters
categories:
  - R
  - maps
tags: [ggmap, rvest]
subtitle: ''
summary: 'While rockets were fired towards Israel I decided to take the opportunity and plot  bomb shelters in Beer-Sheva.'
format: hugo
---



<script src="index_files/libs/htmlwidgets-1.5.4/htmlwidgets.js"></script>
<script src="index_files/libs/jquery-1.12.4/jquery.min.js"></script>
<link href="index_files/libs/leaflet-1.3.1/leaflet.css" rel="stylesheet" />
<script src="index_files/libs/leaflet-1.3.1/leaflet.js"></script>
<link href="index_files/libs/leafletfix-1.0.0/leafletfix.css" rel="stylesheet" />
<script src="index_files/libs/proj4-2.6.2/proj4.min.js"></script>
<script src="index_files/libs/Proj4Leaflet-1.0.1/proj4leaflet.js"></script>
<link href="index_files/libs/rstudio_leaflet-1.3.1/rstudio_leaflet.css" rel="stylesheet" />
<script src="index_files/libs/leaflet-binding-2.1.1/leaflet.js"></script>


#### <a id="update"></a>**Update from March 21, 2020**

I've been wanting to return to this post and make this map more interactive. As a matter of fact it was easier than I thought, I just never got around to doing it. I won't be going through the code for the leaflet map below but will leave it for whoever would like to review it:

``` r
library(leaflet)
library(magrittr)
readr::read_csv("shelters.csv") %>% 
leaflet() %>% 
  addTiles() %>% 
  setView(34.7913, 31.25181,zoom = 13) %>% 
  addCircles(radius = 4, color = "red", fill = TRUE)
```

<div id="htmlwidget-d5095e866122fb9782ce" style="width:768px;height:480px;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-d5095e866122fb9782ce">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"https://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"https://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"addCircles","args":[[31.259018768,31.2597950910001,31.2592493760001,31.2573049280001,31.2574797520001,31.258424086,31.254246294,31.255173057,31.2556456460001,31.253666206,31.2537330280001,31.2569812850001,31.2570752350001,31.257608025,31.2575462630001,31.2700855640001,31.2702905,31.2695012190001,31.2658482960001,31.259725431,31.2646111440001,31.266921333,31.2604320470001,31.2596058720001,31.262762868,31.263789048,31.261942934,31.2638102080001,31.2632644710001,31.263504445,31.262432614,31.2708580180001,31.2711996570001,31.270725645,31.2712747300001,31.2718630300001,31.2720855330001,31.2726126790001,31.272427384,31.2704051920001,31.266736774,31.2628119170001,31.2455927190001,31.248994151,31.250188747,31.2459192310001,31.24676858,31.2479923820001,31.2478412890001,31.249363784,31.250175772,31.248725547,31.248610904,31.251846362,31.2518736100001,31.250946067,31.253505949,31.257884104,31.2540270010001,31.2559118880001,31.2710156910001,31.271205497,31.270356722,31.269982842,31.2698227120001,31.269304209,31.269990116,31.2687801060001,31.2682527530001,31.2683451450001,31.270695158,31.27323147,31.2733343200001,31.2737922810001,31.2728741080001,31.274249592,31.2746572610001,31.272394175,31.2739432400001,31.2744760080001,31.2717045570001,31.2729638220001,31.2757156430001,31.2741278410001,31.2746324350001,31.274596902,31.271494137,31.2718457610001,31.275141078,31.275589424,31.2759297440001,31.2649303200001,31.270103943,31.2659409890001,31.2669887380001,31.2697833300001,31.2704315440001,31.266575474,31.266131746,31.221500807,31.224164194,31.223587228,31.2258336940001,31.222024801,31.2197570490001,31.221235918,31.224912993,31.224000586,31.2261810250001,31.223021734,31.2238066,31.2209769780001,31.222977471,31.2321786260001,31.2324369340001,31.2431229220001,31.235916617,31.238806793,31.237065128,31.248259068,31.251491909,31.2504392380001,31.2504933070001,31.2518083160001,31.246153377,31.250630739,31.25563615,31.256696517,31.254957205,31.257290099,31.25460144,31.256567933,31.255031301,31.2575173870001,31.2579245330001,31.2579056490001,31.2226565670001,31.224564345,31.2426843960001,31.240248009,31.2399610090001,31.267945217,31.2638298580001,31.270236595,31.269875347,31.265144816,31.2690648330001,31.2681699770001,31.269377084,31.265713315,31.270953035,31.2722040720001,31.2645033750001,31.271228369,31.2715811,31.256697924,31.257101161,31.269666226,31.275281239,31.274241079,31.269109099,31.272405753,31.2598086400001,31.250707328,31.251678113,31.2525321090001,31.2486613240001,31.2554510690001,31.2490194850001,31.2670087990001,31.2682888350001,31.269309503,31.250801417,31.268097267,31.2679672850001,31.267170004,31.261017135,31.2604871560001,31.261171405,31.260286697,31.260856463,31.258957008,31.2669088850001,31.264312395,31.2644250700001,31.262675503,31.262628384,31.266354108,31.2378694280001,31.237196182,31.2522976180001,31.2551276230001,31.2555366730001,31.271009238,31.2697859260001,31.248898803,31.250194783,31.250113594,31.248703956,31.2482595930001,31.247643195,31.252913957,31.2562439010001,31.250285107,31.2561600820001,31.2510416860001,31.249713179,31.258150351,31.2590159170001,31.2581197600001,31.25558649,31.2571552970001,31.254918092,31.2545320300001,31.2465726200001,31.2520725430001,31.261599754,31.2721663470001,31.270971611,31.2616581070001,31.264973377,31.2658491130001,31.2688886780001,31.2683040970001,31.2707125310001,31.271428288,31.254769068,31.257070663,31.2465921090001,31.2692059390001,31.2443915640001,31.2314304170001,31.269208157,31.269363072,31.270308577,31.2595743270001,31.2700607460001,31.2564875580001,31.2479156200001,31.2481547410001,31.254812955,31.266566502,31.2504635080001,31.2541823770001,31.2683791260001,31.271307544,31.2482951640001,31.2737507580001,31.272590789,31.2570404000001,31.252699315,31.2517972700001,31.2663416,31.2709878490001,31.2660293330001,31.25408293,31.2701366480001,31.2402113960001,31.2646567780001,31.2463304390001,31.2347788370001,31.252428283],[34.808214546,34.8078915740001,34.809368438,34.8093634950001,34.810975436,34.810334568,34.805622382,34.8026935250001,34.804473768,34.8095251010001,34.8075520780001,34.808555186,34.7651206140001,34.76364862,34.7628454490001,34.778674504,34.7777073990001,34.7762277100001,34.770138844,34.7869285290001,34.795184944,34.7997725760001,34.7940810010001,34.7916208840001,34.7906790590001,34.79068958,34.7927366010001,34.79231459,34.7927492380001,34.792743929,34.7905235110001,34.7883433920001,34.7867639080001,34.785602972,34.7852056130001,34.787070295,34.787588817,34.7939116200001,34.7924905290001,34.7941080740001,34.8014500780001,34.792161772,34.7956425140001,34.7970971840001,34.7970376860001,34.7936621440001,34.7914949660001,34.784890746,34.787583614,34.7873553950001,34.7857147330001,34.779422326,34.7796193240001,34.7841264850001,34.7828629210001,34.7779282610001,34.782604796,34.7832538050001,34.7900850610001,34.7963698560001,34.806238138,34.8089210210001,34.809585251,34.8086036290001,34.809357278,34.8091260510001,34.8067740120001,34.8089092710001,34.8086805990001,34.8079129270001,34.804323229,34.800439962,34.8088667390001,34.8085067230001,34.809244467,34.808135475,34.8077908650001,34.8096215740001,34.8069308010001,34.806502575,34.8037255140001,34.802776814,34.802732577,34.8024465140001,34.8025668970001,34.804125362,34.802364975,34.8055181280001,34.8074389120001,34.8070149960001,34.8064910510001,34.7604294980001,34.7639117040001,34.765621094,34.7664207510001,34.7608955090001,34.7630732060001,34.7598450790001,34.7611068100001,34.775540274,34.7789006310001,34.7774103090001,34.778600274,34.7726666250001,34.773724196,34.7718155210001,34.775669044,34.780235401,34.780269586,34.7763314490001,34.775308716,34.7743583120001,34.7736159990001,34.7923748970001,34.78033953,34.779738781,34.784380764,34.7847258240001,34.7817552400001,34.792498504,34.7868126540001,34.789983894,34.789128825,34.787953332,34.7942136410001,34.7945532960001,34.7903546790001,34.7959888820001,34.7941725480001,34.795403445,34.7891443610001,34.793907173,34.7965042000001,34.7892947980001,34.781547866,34.783656121,34.7751580730001,34.780917947,34.781822312,34.781617833,34.783344335,34.7623511370001,34.762642929,34.771785949,34.7709577200001,34.7636153930001,34.7619093160001,34.7644633370001,34.764872847,34.7577812160001,34.770979358,34.765673103,34.7643799360001,34.767547478,34.769529817,34.773305672,34.773415368,34.805293723,34.805267585,34.800891017,34.808306987,34.806721075,34.8088518340001,34.8019847370001,34.8065743970001,34.810013871,34.8081264090001,34.7780347280001,34.782620235,34.7707858410001,34.7723190740001,34.774894422,34.77918176,34.7948698500001,34.7970907800001,34.795007293,34.79702511,34.7965872190001,34.795338615,34.7935443280001,34.7929193080001,34.7929353970001,34.7939598030001,34.795247798,34.797073217,34.7944644400001,34.7974265890001,34.792997642,34.785492021,34.7889980750001,34.804945893,34.8100962180001,34.808716111,34.783396279,34.7850399330001,34.795998975,34.805139436,34.8028419560001,34.8061534390001,34.804344707,34.807264053,34.81146289,34.806185188,34.806567597,34.81037658,34.80369548,34.8085987040001,34.811233825,34.809843013,34.8094435680001,34.8080172910001,34.810334235,34.8070907060001,34.8035195030001,34.8086055260001,34.802861137,34.7937478430001,34.7956186760001,34.793586141,34.7919188430001,34.79992937,34.801187988,34.8012474810001,34.792345267,34.7969623870001,34.794766757,34.8086733960001,34.80687017,34.776587685,34.79294107,34.791070099,34.7935582580001,34.7954634880001,34.7948531970001,34.7868227160001,34.7857320460001,34.795653003,34.791395838,34.7796560830001,34.781008178,34.77898084,34.794873022,34.780569927,34.8023777060001,34.7968104340001,34.7835412000001,34.7892121180001,34.807038339,34.8080192800001,34.8085495820001,34.779316936,34.8025542940001,34.7698468990001,34.8072728060001,34.8008629990001,34.8116456560001,34.7842904080001,34.7950379800001,34.7961240610001,34.8083349930001,34.7825503890001,34.808149154],4,null,null,{"interactive":true,"className":"","stroke":true,"color":"red","weight":5,"opacity":0.5,"fill":true,"fillColor":"red","fillOpacity":0.2},null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null,null]}],"setView":[[31.25181,34.7913],13,[]],"limits":{"lat":[31.2197570490001,31.2759297440001],"lng":[34.7577812160001,34.8116456560001]}},"evals":[],"jsHooks":[]}</script>

### **Original post**

I've been wanting to learn how to use maps in R for a while before creating the map in this post. Seeing dataframes with longitude and latitude coordinates on various occasions on [\#Tidytuesday](https://github.com/rfordatascience/tidytuesday) encouraged me to do so.  
A day before this visualizaiton, I discovered our municupality's open access data [website](https://www.beer-sheva.muni.il/OpenData/Pages/default.aspx). In this website you can find various datasets like street light coordinates, bomb shelters spread out in the city and more. A day after discovering it Israel, the country I live in, was fired missiles at. I decided to take the opportunity and map some of the shelters around my house. You know, just in case.

Let's begin with the packages (:package:) we'll need:

``` r
#for data manipulation
library(tidyverse)
#for a nice map
library(ggmap)
#for reading and working with .geojson file
library(geojsonio)
library(sp)
#for integrating a nice font
library(extrafont)
```

## Loading and tidying the data

I initially tried using the `.csv` file they have on their webiste but I was having too much trouble with the Hebrew so I decided to try and work with the `geojsonio` package. I had no idea how to work with a `.geojson` file or frankly how to work with maps in general. To my save, i found this incredible blog by [John Johnson](https://randomjohn.github.io/r-geojson-srt/) to help me transform a 'geomjson' file to a dataframe you can work with.

Let's begin:

``` r
#read the .geojson file
my_geojson <- "shelters.geojson"
#convert the .geojson file to an sp object
data_json <- geojson_read(my_geojson, what = "sp")
#now we can convert it to a nice data frame
shelters <- as.data.frame(data_json)
#last tidying of the column names
names(shelters)[6:7] <- c("long", "lat")
```

What we did was load the geojson file, read it as an 'sp' object and then turn it into to a dataframe. I changed the names so that it'll be easier to read the columns. we could also use `dplyr::rename` but I liked the base R function Johnson used in his blog so I'll stick with that.  
let's look at the top 3 observations of our new data frame:

          long      lat name קוד_ס elc group_ F_צוות
    1 34.80821 31.25902  ג/2    17  יש      0       
    2 34.80789 31.25980  ג/1    17  יש      0       
    3 34.80937 31.25925 ג/25    17  יש      0       

Ugh, well the names weren't read well into `R`. While this isn't a big issue to resolve, I don't find it necessary for the final piece. the names of the shelters are anyway in Hebrew and only represnt a letter and some sort of number (for e.g, A/23, only in Hebrew). Therefore we'll leave it as is since what I'm interested in is the longitude and latitude coordinations and for that we don't need the character column.

## Retrieving the map

So we have our data frame with long and lat points, let's get our map. I want a map that can be readable in terms of streets and roads, therefore I'll give the `ggmap` package a try[^1]. Google requires you to register in order to recieve an API key to pull maps to plot. Unfortunately I won't cover how to regiser in this blog post but I'm sure you can find plenty of tutorials addressing it online.  
Let's get Be'er-Sheva's map:

``` r
b7_map <- get_map(location = c(34.7913 , 31.25181), 
              zoom = 13, scale = 2, maptype = "roadmap")
```

What we did here was use the `get_map` function to pull the map according to the long and lat coordinates I gave it of Be'er-Sheva. You should first pass the longitude and then the latitude in the `location` argument. In addition you can change other features such as the zoom level, the maptype and more as we saw here (See `?get_map` for more info).

## Plot

Now that we have our data set ready and the map as an object we can go on to plot it. ggmap extends ggplot features so we can run the data frame smoothly into the `ggmap` function:

``` r
ggmap(b7_map)+
  geom_point(shelters, mapping = aes(long,lat),
            color = "red", size = 0.3, shape = 15)
```

<img src="index_files/figure-gfm/unnamed-chunk-6-1.png" width="768" />

What we did was pass the b7_map as an object into the `ggmap` function and add a geom, in this case `geom_point` representing our shelter coordinates. However, this map doesn't really help me in a time of need since it doesn't show *my address* clearly.

Let's try zooming in so that we can see what we're looking at:

``` r
#retreiving a new map with a greater `zoom`
b7_map_zoom <- get_map(location = c(34.7913 , 31.25181), 
                    zoom = 16, scale = 2, maptype = "roadmap")

p <- ggmap(b7_map_zoom)+
geom_point(shelters, mapping = aes(long,lat), color = "red",
           size = 3, shape = 15)
p
```

<img src="index_files/figure-gfm/unnamed-chunk-7-1.png" width="768" />

Much nicer and clearer. Using the zoom option in `get_map` enables to center more on where I want. Great, this shows me some bomb shetlers I have around me in a time of need. Let's add some fine tuning for our theme:

``` r
p+  
#for the title, caption and removing the X and Y axis
  labs (title = "Neighborhood B, Beer-Sheva, Israel, bomb shelters",
        x = NULL, y = NULL,
        caption = "data: www.beer-sheva.muni.il | @Amit_Levinson")+
  theme_minimal()+
  theme(text = element_text(family = "Microsoft Tai Le"),
    #Changing the position of the title
    plot.title = element_text(hjust = 0.5, size = 20, face = "bold"),
    axis.text = element_blank(),
    plot.caption = element_text(size = 9, face = "italic", hjust = 0),
    panel.border = element_rect(color = "black", size=2, fill = NA)
  )
```

<img src="index_files/figure-gfm/unnamed-chunk-8-1.png" width="768" />

Perfect, I can now save the plot and distribute it if someone needs it.

``` r
ggsave("shelters_b_eng.png", width = 8, height = 8)
```

<center>
{{% tweet "1194274713759039488" %}}
</center>

[^1]: For a first map I decided to go with a static one, but an interactive one can defenitely be a 2.0 version of this blog (as you saw with the [March 21st update](#update). Hopefully we won't need it.
