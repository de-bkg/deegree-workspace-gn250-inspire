-- ======================================================================
-- This is the  DB schema for the final service. To optimize performance 
-- all relations are flattened as far as possible to reduce the number of
-- joints, that are required for Feature retrieval. For the Geographical
-- Names all tables except name can be modelled inline.
-- ======================================================================

-- Schema: gn_prod

-- DROP SCHEMA gn_prod;

CREATE SCHEMA gn_prod AUTHORIZATION gn_inspire;
COMMENT ON SCHEMA gn_prod IS 'Schemata für optimierte Geonames Struktur';
  
-- == Tabellen =====

-- Tabellen
CREATE TABLE gn_prod.namedplace (
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
    localtype_href text,
    localtype_nilreason text,
    localtype_text text,
    localtype_id text,
    localtype_locale text,
    type_href text,
    type_nil boolean,    
    CONSTRAINT namedplace_pkey PRIMARY KEY (id)
);
ALTER TABLE gn_prod.namedplace OWNER TO gn_inspire;
SELECT ADDGEOMETRYCOLUMN('gn_prod', 'namedplace','geometry','4258','GEOMETRY', 2);

CREATE INDEX namedplace_id_idx ON gn_prod.namedplace (id);
CREATE INDEX namedplace_geometry_idx ON gn_prod.namedplace USING GIST (geometry);

CREATE TABLE gn_prod.name (
    -- original gn.name
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
    grammaticalnumber_href text,
    -- inline gn.spelling
    spelling_text text,
    spelling_script text,
    spelling_script_nilreason text,
    spelling_script_nil boolean,
    spelling_transliterationscheme text,
    spelling_transliterationscheme_nilreason text,
    spelling_transliterationscheme_nil boolean    
);
ALTER TABLE gn_prod.name OWNER TO gn_inspire;

CREATE INDEX name_id_idx ON gn_prod.name (id);
CREATE INDEX name_parentfk_idx ON gn_prod.name (parentfk);
CREATE INDEX name_spelling_text_idx ON gn_prod.name (spelling_text);

-- == post processing ==========================

INSERT INTO gn_prod.namedplace 
    SELECT 
        n.id as id, 
        n.beginlifespanversion as beginlifespanversion, n.beginlifespanversion_nilreason as beginlifespanversion_nilreason, n.beginlifespanversion_nil as beginlifespanversion_nil, 
        n.endlifespanversion as endlifespanversion, n.endlifespanversion_nilreason as endlifespanversion_nilreason, n.endlifespanversion_nil as endlifespanversion_nil, 
        n.geometry_nilreason as geometry_nilreason, n.geometry_remoteschema as geometry_remoteschema, n.geometry_owns as geometry_owns, 
        n.inspireid_localid as inspireid_localid, 
        n.leastviewres_nil as leastviewres_nil, n.leastviewres_nilreason as leastviewres_nilreason, n.leastviewres_denominator_nilreason as leastviewres_denominator_nilreason, n.leastviewres_denominator as leastviewres_denominator, 
        n.mostviewres_nil as mostviewres_nil, n.mostviewres_nilreason as mostviewres_nilreason, n.mostviewres_denominator_nilreason as mostviewres_denominator_nilreason, n.mostviewres_denominator as mostviewres_denominator, 
        l.href as localtype_href, l.nilreason as localtype_nilreason, l.localisedcharacterstring as localtype_text, l.localisedcharacterstring_id as localtype_id, l.localisedcharacterstring_locale as localtype_locale, 
        t.href as type_href, t.nil as type_nil,
        n.geometry as geometry
    FROM gn.namedplace AS n
        LEFT JOIN gn.localtype AS l ON n.id = l.parentfk
        LEFT JOIN gn.namedplace_type AS t ON n.id = t.parentfk;

INSERT INTO gn_prod.name 
    SELECT 
        n.id AS id, n.parentfk AS parentfk, 
        n.language AS language, n.language_nilreason AS language_nilreason,
        n.nativeness_nil AS nativeness_nil, n.nativeness_nilreason AS nativeness_nilreason, n.nativeness_href AS nativeness_href,
        n.namestatus_nil AS namestatus_nil, n.namestatus_nilreason AS namestatus_nilreason, n.namestatus_href AS namestatus_href,
        n.sourceofname AS sourceofname, n.sourceofname_nilreason AS sourceofname_nilreason, n.sourceofname_nil AS sourceofname_nil,
        n.pronunciation_nilreason AS pronunciation_nilreason, n.pronunciation_nil AS pronunciation_nil,
        n.pronunciationsoundlink AS pronunciationsoundlink, n.pronunciationsoundlink_nilreason AS pronunciationsoundlink_nilreason, n.pronunciationsoundlink_nil AS pronunciationsoundlink_nil,
        n.pronunciationipa AS pronunciationipa, n.pronunciationipa_nilreason AS pronunciationipa_nilreason, n.pronunciationipa_nil AS pronunciationipa_nil,
        n.grammaticalgender_nil AS grammaticalgender_nil, n.grammaticalgender_nilreason AS grammaticalgender_nilreason, n.grammaticalgender_href AS grammaticalgender_href,
        n.grammaticalnumber_nil AS grammaticalnumber_nil, n.grammaticalnumber_nilreason AS grammaticalnumber_nilreason, n.grammaticalnumber_href AS grammaticalnumber_href,
        s.text AS spelling_text, s.script AS spelling_script, s.script_nilreason AS spelling_script_nilreason, s.script_nil AS spelling_script_nil,
        s.transliterationscheme AS spelling_transliterationscheme, s.transliterationscheme_nilreason AS spelling_transliterationscheme_nilreason, 
        s.transliterationscheme_nil AS spelling_transliterationscheme_nil    
    FROM gn.name AS n
        LEFT JOIN gn.spelling AS s ON n.id = s.parentfk;

-- deegree doesn't use LIMIT, OFFSET or SORT BY which results in unpredictable order between same requests.
-- To provide a consistent response behaviour, a view with default sorting has to be created.
CREATE VIEW gn_prod.vnamedplace AS SELECT * FROM gn_prod.namedplace ORDER BY id ASC;
ALTER TABLE gn_prod.vnamedplace OWNER TO gn_inspire;