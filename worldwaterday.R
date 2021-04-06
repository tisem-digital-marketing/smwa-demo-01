#' Demo 1: Visualize Tweet Network
#' 
#' author: @lachlandeer

# --- Part 1: Extracting Data from Twitter API --- #
library(rtweet)

tweets <- search_tweets(
    "#worldwaterday",
    n = 500,
    include_rts = TRUE
)

## tweets from inside NL?

nl_geo <- lookup_coords("Netherlands")

tweets_nl <- search_tweets(
    "#worldwaterday",
    include_rts = TRUE,
    retryonratelimit = TRUE,
    geocode = nl_geo
)

## save the #worldwaterday data set
library(readr)

## csv won't work due to list column
write_csv(tweets_nl, "worldwaterday_tweets.csv")
## save instead as rds 
write_rds(tweets_nl, "worldwaterday_tweets.rds")
## Can import rds file as `df <- read_rds(your_filepath)`
## from readr library

# --- Part 2  - Plotting the Retweet Network --- #

## i'm going to use the data from above,
## if you want to follow along, load the saved data
## tweets_nl <- read_rds('worldwaterday_tweets.rds')

## Filter rows that are retweets
library(dplyr)

rt <-
    tweets_nl %>%
    filter(is_retweet == TRUE)

## create a edgelist 
rt_edge <-
    rt %>%
    select(screen_name, retweet_screen_name) %>%
    # keep only unique pairs 
    distinct()

## take the edgelist and turn into a graph
library(tidygraph)

rt_grph <- as_tbl_graph(rt_edge)

## plot the data
library(ggraph)

## basic plot
rt_grph %>%
    ggraph(layout = "kk") + 
    geom_edge_link(alpha = 0.2) +
    geom_node_point() +
    theme_graph()

## build it up plot some more
rt_grph %>%
    ggraph(layout = "linear", circular = TRUE) +
    geom_node_point() +
    geom_edge_link(alpha = 0.2) +
    theme_graph() +
    ggtitle('#worldwaterday', 
            subtitle = "Retweet Network in the Netherlands"
            )

ggsave('retweet_graph.pdf')

# --- Part 3: Mentions Graph --- #
library(tidyr)

## get mentions as tidy data frame, result is edgelist
mnt <-
    tweets_nl %>%
    select(screen_name, mentions_screen_name) %>%
    filter(mentions_screen_name != "NA") %>%
    # separate multiple mentions in one tweet into 'many' rows
    unnest_longer(mentions_screen_name) %>%
    distinct()

## as graph data rather than edgelist
mnt_grph <- as_tbl_graph(mnt)

## let's draw a plot of this data

mnt_grph %>%
    ggraph(layout = "linear", circular = TRUE) +
    geom_node_point() +
    geom_edge_link(alpha = 0.2) +
    theme_graph() +
    ggtitle('#worldwaterday',
          subtitle = 'Mentions Network in the Netherlands')

ggsave("mentions_graph.pdf")













