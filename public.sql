


-- ----------------------------
-- Type structure for picture_view
-- ----------------------------
DROP TYPE IF EXISTS "public"."picture_view";
CREATE TYPE "public"."picture_view" AS (
  "p_type" varchar(10) COLLATE "pg_catalog"."default",
  "p_data" bytea
);
ALTER TYPE "public"."picture_view" OWNER TO "postgres";

-- ----------------------------
-- Sequence structure for account_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."account_id_seq";
CREATE SEQUENCE "public"."account_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Table structure for account
-- ----------------------------
DROP TABLE IF EXISTS "public"."account";
CREATE TABLE "public"."account" (
  "id" int4 NOT NULL DEFAULT nextval('account_id_seq'::regclass),
  "first_name" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "last_name" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "email" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "gender" varchar(15) COLLATE "pg_catalog"."default" NOT NULL,
  "telephone" varchar(20) COLLATE "pg_catalog"."default" DEFAULT NULL::character varying
)
;




-- ----------------------------
-- Table structure for image
-- ----------------------------
DROP TABLE IF EXISTS "public"."image";
CREATE TABLE "public"."image" (
  "id" uuid NOT NULL,
  "filename" varchar(255) COLLATE "pg_catalog"."default",
  "ext" varchar(10) COLLATE "pg_catalog"."default",
  "picture" oid,
  "belong_to" int4,
  "target" varchar(20) COLLATE "pg_catalog"."default" DEFAULT 'profile'::character varying
)
;


-- ----------------------------
-- Function structure for addimage
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."addimage"("filedata" bytea, "fname" varchar, "extname" varchar, "uid" int4);
CREATE OR REPLACE FUNCTION "public"."addimage"("filedata" bytea, "fname" varchar, "extname" varchar, "uid" int4)
  RETURNS "pg_catalog"."varchar" AS $BODY$
	DECLARE
		newid "uuid" := uuid_generate_v4();
		picid oid := 0;
		retid varchar := '';
	BEGIN
		picid := lo_from_bytea(0, filedata);
		INSERT INTO image(id, filename, ext, picture, belong_to) VALUES(newid, fname, extname, picid, uid) RETURNING id into retid;
	RETURN retid;
END$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- ----------------------------
-- Function structure for deleteuser
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."deleteuser"("userid" int4);
CREATE OR REPLACE FUNCTION "public"."deleteuser"("userid" int4)
  RETURNS "pg_catalog"."int4" AS $BODY$
	DECLARE
		ret int;
	BEGIN
		select lo_unlink(i) into ret from (
			select picture i from image where belong_to = userid
		) t;
		
		Delete from image where belong_to = userid;
		Delete from account where id = userid;

	RETURN ret;
END$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- ----------------------------
-- Function structure for getimage
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."getimage"("uid" varchar);
CREATE OR REPLACE FUNCTION "public"."getimage"("uid" varchar)
  RETURNS "public"."picture_view" AS $BODY$
	DECLARE
		ret "picture_view";
		pid "oid" := 0;
	BEGIN
		select picture, ext into pid, ret.p_type from image where id::text=uid;
		ret.p_data := lo_get(pid);

	RETURN ret;
END$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- ----------------------------
-- Function structure for replaceimage
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."replaceimage"("filedata" bytea, "fname" varchar, "extname" varchar, "iid" varchar);
CREATE OR REPLACE FUNCTION "public"."replaceimage"("filedata" bytea, "fname" varchar, "extname" varchar, "iid" varchar)
  RETURNS "pg_catalog"."int4" AS $BODY$
	DECLARE
		picid "oid" = 0;
		ret int = 0;
	BEGIN
		select lo_unlink(i) into ret from (
			select picture i from image where id = iid::uuid
		) t;
		picid := lo_from_bytea(0, filedata);
		update image set filename=fname, ext=extname, picture=picid where id = iid::uuid;
		
	RETURN picid;
END$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;



-- ----------------------------
-- Function structure for uuid_generate_v1
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."uuid_generate_v1"();
CREATE OR REPLACE FUNCTION "public"."uuid_generate_v1"()
  RETURNS "pg_catalog"."uuid" AS '$libdir/uuid-ossp', 'uuid_generate_v1'
  LANGUAGE c VOLATILE STRICT
  COST 1;

-- ----------------------------
-- Function structure for uuid_generate_v1mc
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."uuid_generate_v1mc"();
CREATE OR REPLACE FUNCTION "public"."uuid_generate_v1mc"()
  RETURNS "pg_catalog"."uuid" AS '$libdir/uuid-ossp', 'uuid_generate_v1mc'
  LANGUAGE c VOLATILE STRICT
  COST 1;

-- ----------------------------
-- Function structure for uuid_generate_v3
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."uuid_generate_v3"("namespace" uuid, "name" text);
CREATE OR REPLACE FUNCTION "public"."uuid_generate_v3"("namespace" uuid, "name" text)
  RETURNS "pg_catalog"."uuid" AS '$libdir/uuid-ossp', 'uuid_generate_v3'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for uuid_generate_v4
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."uuid_generate_v4"();
CREATE OR REPLACE FUNCTION "public"."uuid_generate_v4"()
  RETURNS "pg_catalog"."uuid" AS '$libdir/uuid-ossp', 'uuid_generate_v4'
  LANGUAGE c VOLATILE STRICT
  COST 1;

-- ----------------------------
-- Function structure for uuid_generate_v5
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."uuid_generate_v5"("namespace" uuid, "name" text);
CREATE OR REPLACE FUNCTION "public"."uuid_generate_v5"("namespace" uuid, "name" text)
  RETURNS "pg_catalog"."uuid" AS '$libdir/uuid-ossp', 'uuid_generate_v5'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for uuid_nil
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."uuid_nil"();
CREATE OR REPLACE FUNCTION "public"."uuid_nil"()
  RETURNS "pg_catalog"."uuid" AS '$libdir/uuid-ossp', 'uuid_nil'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for uuid_ns_dns
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."uuid_ns_dns"();
CREATE OR REPLACE FUNCTION "public"."uuid_ns_dns"()
  RETURNS "pg_catalog"."uuid" AS '$libdir/uuid-ossp', 'uuid_ns_dns'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for uuid_ns_oid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."uuid_ns_oid"();
CREATE OR REPLACE FUNCTION "public"."uuid_ns_oid"()
  RETURNS "pg_catalog"."uuid" AS '$libdir/uuid-ossp', 'uuid_ns_oid'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for uuid_ns_url
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."uuid_ns_url"();
CREATE OR REPLACE FUNCTION "public"."uuid_ns_url"()
  RETURNS "pg_catalog"."uuid" AS '$libdir/uuid-ossp', 'uuid_ns_url'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Function structure for uuid_ns_x500
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."uuid_ns_x500"();
CREATE OR REPLACE FUNCTION "public"."uuid_ns_x500"()
  RETURNS "pg_catalog"."uuid" AS '$libdir/uuid-ossp', 'uuid_ns_x500'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."account_id_seq"
OWNED BY "public"."account"."id";
SELECT setval('"public"."account_id_seq"', 12, true);

-- ----------------------------
-- Uniques structure for table account
-- ----------------------------
ALTER TABLE "public"."account" ADD CONSTRAINT "account_email_key" UNIQUE ("email");

-- ----------------------------
-- Primary Key structure for table account
-- ----------------------------
ALTER TABLE "public"."account" ADD CONSTRAINT "account_pkey" PRIMARY KEY ("id");


-- ----------------------------
-- Primary Key structure for table image
-- ----------------------------
ALTER TABLE "public"."image" ADD CONSTRAINT "image_pkey1" PRIMARY KEY ("id");


-- ----------------------------
-- Foreign Keys structure for table image
-- ----------------------------
ALTER TABLE "public"."image" ADD CONSTRAINT "toaccount" FOREIGN KEY ("belong_to") REFERENCES "public"."account" ("id") ON DELETE CASCADE ON UPDATE CASCADE;


