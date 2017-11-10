
-- Tabellen
CREATE TABLE gn.namedplace (
    id text,
    beginlifespanversion timestamp,
    beginlifespanversion_nilreason text,
    beginlifespanversion_nil boolean,
    endlifespanversion timestamp,
    endlifespanversion_nilreason text,
    endlifespanversion_nil boolean,
    geometry_nilreason text,
    geometry_remoteschema text,
    geometry_owns boolean,
    inspireid_localid text,
    leastviewres_nil boolean,
    leastviewres_nilreason text,
    leastviewres_denominator_nilreason text,
    leastviewres_denominator integer,
    mostviewres_nil boolean,
    mostviewres_nilreason text,
    mostviewres_denominator_nilreason text,
    mostviewres_denominator integer,
    CONSTRAINT namedplace_pkey PRIMARY KEY (id)
);
SELECT ADDGEOMETRYCOLUMN('gn', 'namedplace','geometry','4258','GEOMETRY', 2);

CREATE TABLE gn.localtype (
    id serial PRIMARY KEY,
    parentfk text NOT NULL REFERENCES gn.namedplace ON DELETE CASCADE,
    href text,
    nilreason text,
    localisedcharacterstring text,
    localisedcharacterstring_id text,
    localisedcharacterstring_locale text
);

CREATE TABLE gn.name (
    id serial PRIMARY KEY,
    parentfk text NOT NULL REFERENCES gn.namedplace ON DELETE CASCADE,
    language text,
    language_nilreason text,
    nativeness_nil boolean,
    nativeness_nilreason text,
    nativeness_href text,
    namestatus_nil boolean,
    namestatus_nilreason text,
    namestatus_href text,
    sourceofname text,
    sourceofname_nilreason text,
    sourceofname_nil boolean,
    pronunciation_nilreason text,
    pronunciation_nil boolean,
    pronunciationsoundlink text,
    pronunciationsoundlink_nilreason text,
    pronunciationsoundlink_nil boolean,
    pronunciationipa text,
    pronunciationipa_nilreason text,
    pronunciationipa_nil boolean,
    grammaticalgender_nil boolean,
    grammaticalgender_nilreason text,
    grammaticalgender_href text,
    grammaticalnumber_nil boolean,
    grammaticalnumber_nilreason text,
    grammaticalnumber_href text
);

CREATE TABLE gn.spelling (
    id serial PRIMARY KEY,
    parentfk integer NOT NULL REFERENCES gn.name ON DELETE CASCADE,
    text text,
    script text,
    script_nilreason text,
    script_nil boolean,
    transliterationscheme text,
    transliterationscheme_nilreason text,
    transliterationscheme_nil boolean
);

CREATE TABLE gn.relatedspatialobject (
    id serial PRIMARY KEY,
    parentfk text NOT NULL REFERENCES gn.namedplace ON DELETE CASCADE,
    nilreason text,
    nil boolean,
    identifier_localid text,
    identifier_namespace text,
    identifier_versionid text,
    identifier_versionid_nilreason text,
    identifier_versionid_nil boolean
);

CREATE TABLE gn.namedplace_type (
    id serial PRIMARY KEY,
    parentfk text NOT NULL REFERENCES gn.namedplace ON DELETE CASCADE,
    href text,
    nil boolean
);


-- == Create indizes ==========================

CREATE INDEX named_place_id_idx ON gn.namedplace (id);
CREATE INDEX named_place_geometry_idx ON gn.namedplace USING GIST (geometry);

CREATE INDEX name_id_idx ON gn.name (id);
CREATE INDEX name_parentfk_idx ON gn.name (parentfk);

CREATE INDEX localtype_id_idx ON gn.localtype (id);
CREATE INDEX localtype_parentfk_idx ON gn.localtype (parentfk);

CREATE INDEX namedplace_type_id_idx ON gn.namedplace_type (id);
CREATE INDEX namedplace_type_parentfk_idx ON gn.namedplace_type (parentfk);

CREATE INDEX relatedspatialobject_id_idx ON gn.relatedspatialobject (id);
CREATE INDEX relatedspatialobject_parentfk_idx ON gn.relatedspatialobject (parentfk);

CREATE INDEX spelling_id_idx ON gn.spelling (id);
CREATE INDEX spelling_parentfk_idx ON gn.spelling (parentfk);
CREATE INDEX spelling_text_idx ON gn.spelling (text);

-- == post processing ==========================
-- ALTER TABLE gn.namedplace ADD COLUMN inspire_id text;
-- UPDATE gn.namedplace 
-- SET inspire_id = 'http://sg.geodatenzentrum.de/wfs_geonames?service=WFS&request=GetFeature&VERSION=2.0.0&STOREDQUERY_ID=urn:ogc:def:query:OGC-WFS::GetFeatureById&ID=GN_NAMEDPLACE_' || id;

-- determine 1:n relations
-- SELECT * FROM 
--   (SELECT np.id, np.inspireid_localid, (SELECT COUNT(*) FROM gn.localtype lt WHERE lt.parentfk = np.id) AS tot FROM gn.namedplace np) as a
-- WHERE a.tot > 1;
--
-- SELECT * FROM 
--  (SELECT n.id, (SELECT COUNT(*) FROM gn.spelling s WHERE s.parentfk = n.id) AS tot FROM gn.name n) as a
-- WHERE a.tot = 1