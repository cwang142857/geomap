# Location based competition visualization - NYC
This program retrieves store level geo data from Google Maps API and visualizes metrics to help understand location based competition between two brand names
## Metrics
  * `percentage of competitor stores within x mile radius`: for each store, count number of competitor stores within the specified miles radius and divided by total number of competitor stores
  * `average miles radius of competitor stores`: for each store, compute average miles radius of all competitor stores within the specified miles radius
## Scripts
  * `extract_gm.py`: extract geo spatial data from Google Maps API. (extract geo spatial data of all Shake Shack in NYC)
  * `compute_df.R`: mung raw data extracted from Google, compute and store datasets with haversine distance of every pair of stores and total number of store per brand name
  * `app.R`: Shiny app to generate interactive table and maps with % of competitor stores with specified miles radius per base store
    * input example: ```base brand name = 'Shake Shack', competitor brand name = 'Chipotle Mexican Grill', maximum radius <= 1 mile```
## datasets
  * `sample_data.csv`: geo data extracted from Google Maps API
  * `data_p.csv`: dataset with distance of all store pairs computed and filtered for NYC
  * `data_t.csv`: dataset with total number of stores per brand name computed
