setwd("C:/Users/rober/OneDrive/Desktop/reproducible reserach")

library("usethis")
library("bookdown")
library("crosstalk")
library("DT")
library("kableExtra")
library("leaflet")
library("plotly")
library("rmarkdown")
library("tinytex")

usethis::use_git()
# set your credentials if you must
gitcreds::gitcreds_set()
# if you dont have a pat you can use
#usethis::create_github_token()
# if you need add your PAT
usethis::edit_r_environ()
# generate your readme
usethis::use_readme_rmd()
# Edit and upload to git
usethis::use_github()


---
title: "Explore relationships"
author: "Derek Corcoran"
date: "`r format(Sys.time(), '%d/%m, %Y')`"
output: html_document
---
  
  ```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = FALSE, warning = FALSE, error = FALSE)
library(tidyverse)
library(DT)
library(leaflet)
library(crosstalk)
library(plotly)

library(readr)
Species <- read_csv("https://raw.githubusercontent.com/derek-corcoran-barrios/OikosRepoducibleResearch/master/Species.csv")

Species2 <- Species %>% 
  pivot_longer(cols = abund_sp1:abund_sp4, names_to = "Species", values_to = "Abundance") %>% mutate(Species = str_remove_all(Species, "abund_"), Species =str_replace_all(Species, "sp", "Spp "))
```

```{r crosstalk, echo = F}
sd <- SharedData$new(Species2)
crosstalk::filter_checkbox("Species", "Species", sd, ~Species)
crosstalk::filter_slider("Abundance", "Abundance", sd, ~Abundance, step = 10, round = T, min = min(Species2$Abundance), max = max(Species2$Abundance))

Numpal <- colorNumeric("viridis", sort(unique(Species2$Abundance)))


leaflet(sd) %>%
  addTiles() %>% 
  leaflet::addCircles(lng = ~lon, lat = ~lat, color = ~Numpal(Abundance), popup = ~paste("Abundance:", prettyNum(Abundance, big.mark = ",")), label = ~paste("Abundance:", prettyNum(Abundance, big.mark = ","))) %>%  addLegend("bottomright", pal = Numpal, values = ~Abundance,
                                                                                                                                                                                                                                 title = "Abundance",
                                                                                                                                                                                                                                 labFormat = labelFormat(big.mark =","),
                                                                                                                                                                                                                                 opacity = 1
  )

G <- ggplot(sd, aes(x = bio_12, y = Abundance)) + geom_point(aes(color = Species)) + theme_bw()

ggplotly(G)

DT::datatable(sd, extensions = c('Buttons', 'ColReorder'),
              caption = 'Species abundances and explaining variables.',
              filter = "top",
              options = list(dom = 'Blfrtip',
                             colReorder = TRUE,
                             scrollX='400px',
                             scrollY='200px',
                             buttons = c('copy', 'csv', 'excel', I('colvis')),
                             lengthMenu = list(c(10,25,50,-1),
                                               c(10,25,50,"All")))) %>%
  formatRound(columns=c("lon", "lat", "bio_1", "bio_2", "bio_3", "bio_4", "bio_5", 
                        "bio_6", "bio_7", "bio_8", "bio_9", "bio_10", "bio_11", "bio_12", 
                        "bio_13", "bio_14", "bio_15", "bio_16", "bio_17", "bio_18", "bio_19"), digits=3)


```

