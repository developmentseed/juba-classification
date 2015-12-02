#!/bin/bash

# Create the PostGIS database
dropdb block_category_frequencies
createdb block_category_frequencies
psql -d block_category_frequencies -c "CREATE EXTENSION postgis;"

# Convert the data to SQL format
raster2pgsql -I -C -t 100x100 -s 32636 \
	juba-data/juba_10category.tif \
	imagery \
	| psql -q -d block_category_frequencies
shp2pgsql -I -s 4326 \
	juba_south-sudan.osm2pgsql-shapefiles/juba_south-sudan_osm_line.shp \
	all_lines \
	| psql -q -d block_category_frequencies

# Count the number of pixels of each category by block
psql -d block_category_frequencies -f block_category_frequencies.sql
psql -d block_category_frequencies -c "\COPY histograms TO 'histograms.csv' DELIMITER ',' CSV HEADER;"

# Run the regression and output its summary
Rscript regression.r
