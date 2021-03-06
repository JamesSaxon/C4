-- SIMPLIFIED CENSUS GEOMETRY IN POSTGIS
-- COPIED FROM https://strk.kbt.io/blog/2012/04/13/simplifying-a-map-layer-using-postgis-topology/

CREATE OR REPLACE FUNCTION SimplifyEdgeGeom(atopo varchar, anedge int, maxtolerance float8)
RETURNS float8 AS $$
DECLARE
  tol float8;
  sql varchar;
BEGIN
  tol := maxtolerance;
  LOOP
    sql := 'SELECT topology.ST_ChangeEdgeGeom(' || quote_literal(atopo) || ', ' || anedge
      || ', ST_Simplify(geom, ' || tol || ')) FROM '
      || quote_ident(atopo) || '.edge WHERE edge_id = ' || anedge;
    BEGIN
      -- RAISE NOTICE 'Running %', sql;
      EXECUTE sql;
      RETURN tol;
    EXCEPTION
     WHEN OTHERS THEN
      RAISE WARNING 'Simplification of edge % with tolerance % failed: %', anedge, tol, SQLERRM;
      tol := round( (tol/2.0) * 1e8 ) / 1e8; -- round to get to zero quicker
      IF tol = 0 THEN 
        RAISE NOTICE 'Tolerance reached 0.  Exception: %', SQLERRM; 
        RETURN 0;
      END IF;
    END;
  END LOOP;
END
$$ LANGUAGE 'plpgsql' STABLE STRICT;

-- Simplified geometries can ultimately live here.
-- ALTER TABLE census_tracts_2015 ADD geomsimp GEOMETRY;


