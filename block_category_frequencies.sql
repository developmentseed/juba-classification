-- Extract the streets and use them to create city blocks
CREATE VIEW streets AS (
	SELECT (ST_Dump(ST_Union(streets.geom))).geom
	FROM (
		SELECT geom
		FROM all_lines
		WHERE highway IS NOT NULL
	) AS streets
);
CREATE TABLE blocks AS (
	SELECT ST_Transform((ST_Dump(ST_Polygonize(streets.geom))).geom, 32636) AS geom
	FROM streets
);
ALTER TABLE blocks
	ADD COLUMN gid SERIAL PRIMARY KEY;

-- Calculate pixel counts on the classified image by city block
CREATE VIEW imagery_blocks AS (
	SELECT blocks.gid,
		imagery.rast
	FROM blocks,
		imagery
	WHERE ST_Intersects(imagery.rast, blocks.geom)
);
CREATE VIEW histograms_tiled AS (
	SELECT gid,
		(histogram).min AS category,
		(histogram).count
	FROM (
		SELECT gid,
			ST_Histogram(imagery_blocks.rast, 1, 17, ARRAY[1]) AS histogram
		FROM imagery_blocks
	) AS histogram
);
CREATE TABLE histograms AS (
	SELECT gid,
		category,
		SUM(count) AS count
	FROM histograms_tiled
	GROUP BY gid,
		category
);
