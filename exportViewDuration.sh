
\COPY (select * from items_buyeritem where view_duration !=42) TO '/tmp/products_199.csv' DELIMITER ',' CSV HEADER;

