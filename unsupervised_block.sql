# Create PostGIS database
CREATE DATABASE unsupervised_block;
\connect unsupervised_block
CREATE EXTENSION postgis;
CREATE EXTENSION kmeans;

# Convert the data to SQL format
raster2pgsql -I -C -t 1x1 -s 32636 \
	dg-juba/054805119010_01/054805119010_01_P001_MUL/15MAY08083356-M3DS-054805119010_01_P001.TIF \
	imagery \
	| psql -q -d unsupervised_block
shp2pgsql -I -s 4326 \
	juba_south-sudan.osm2pgsql-shapefiles/juba_south-sudan_osm_line.shp \
	all_lines \
	| psql -q -d unsupervised_block

# Extract the streets and use them to create city blocks
CREATE TABLE streets AS (
	SELECT (ST_Dump(ST_Union(streets.geom))).geom AS geom
	FROM (
		SELECT *
		FROM all_lines
		WHERE highway IS NOT NULL
	) AS streets
);
CREATE TABLE blocks AS (
	SELECT (ST_Dump(ST_Polygonize(streets.geom))).path[1] AS _id,
		(ST_Dump(ST_Polygonize(streets.geom))).geom AS geom
	FROM streets
);

# Load multi-band raster image, and clip it to the AOI
CREATE VIEW aoi_tiles AS (
	SELECT imagery.*
	FROM imagery,
		(SELECT ST_SetSRID(ST_Extent(streets.geom), 4326) AS geom FROM streets) AS aoi_bounds
	WHERE ST_Intersects(imagery.rast, ST_Transform(aoi_bounds.geom, ST_SRID(imagery.rast)))
);
CREATE TABLE aoi_imagery AS (
	SELECT ST_Union(aoi_tiles.rast) AS rast
	FROM aoi_tiles
);

# Perform unsupervised classification of the raster's pixels
CREATE TABLE categorized AS (
	SELECT kmeans(ARRAY[
		ST_Value(aoi_imagery.rast, 1, 10, 10),
		ST_Value(aoi_imagery.rast, 2, 10, 10),
		ST_Value(aoi_imagery.rast, 3, 10, 10)
		], 10) OVER () AS category
	FROM aoi_imagery
);

# Use the city blocks to partition the classified image
CREATE TABLE block_values AS (
	SELECT ST_ValueCount(aoi_imagery, 3) AS band_3
	FROM 
);

# Export block-level table for use in regression
COPY blocks TO 'foobar.csv' DELIMITER ',' CSV HEADER;
