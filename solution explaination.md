### Data Type Decision

There are two solution for store large object into postgresql database.
Oid and bytea,

if I directly usng bytea, it may not need store procedure to store pictures, so I use Oid to store picture.


The store procedure is inside public.sql. 