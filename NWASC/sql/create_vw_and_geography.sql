/*
-----------------------------------------------------
The purpose of this script is to 
1) create a geography column 
2) create views separating point and lines in the transect table

Created by N. Zimpher, altered by K. Coleman
Jan. 2018
-----------------------------------------------------
*/

Use SeabirdCatalog;

/*
-----------------------------------------------------
exploratory
-----------------------------------------------------
*/
--select count(*) from transect
--select geometry.STGeometryType() from transect

--select transect_id, geometry.STAsText(), Geometry.STSrid
--from Transect 
--where Geometry.STGeometryType() = 'Point'

-- select distinct geometry.STSrid from transect 
/* all the same SRID=4269 which is NAD83 (+proj=longlat +ellps=GRS80 +datum=NAD83 +no_defs) */


/*
-----------------------------------------------------
create geography column in table
using the geometry column and the SRID
-----------------------------------------------------
*/
-- change type to point for Linestrings where number of points = 2 but both points are the same
alter table transect 
add newGeometry Geometry;
--
--
Update transect 
set newGeometry = [Geometry];
--
--
create view geographyTest as
select 
transect_id,
dataset_id,
Geometry,
Geometry.STGeometryType() as pointType,
Geometry.STStartPoint() as point1a,
Geometry.STEndPoint() as point2a,
Geometry.STStartPoint().STAsText() as point1b,
Geometry.STEndPoint().STAsText() as point2b,
Geometry.STNumPoints() as numpoints
from transect;
--
--
Update transect
set newGeometry = Geometry.STStartPoint()
where transect_id in (select 
transect_id
from geographyTest
where Geometry.STLength() = 0 and numpoints in (2,3) and pointType <> 'Point');

-- add geography column
alter table transect 
add [geography] geography;
GO;

-- create geography column from geometry
update transect
	set [geography] = GEOGRAPHY::STGeomFromText(newGeometry.MakeValid().STAsText(),4269)
	where transect_id between 70192 and 70194;
/*	where dataset_id in (5,6,7,12,15,20,21,22,23,24,25,28,29,30,31,32,33,34,35,39,42,57,
 69,70,71,75,77,78,80,82,84,85,89,90,91,112,113,116,117,118,120,121,122,123,
 137,138,140,141,146,147,158) --tern request*/
--

-- select * from geographyTest
-- drop view geographyTest
select dataset_id,geometry.STSrid, [geometry].STAsText() from transect where transect_id in (70194)

select * from transect where transect_id in (70194)

select * from transect where dataset_id in (8)
/*
Points with known errors for linestrings with only two points which are the same
(7159,7330,7543,7800,7801,7806,8752,8983,
9277,9278,9279,9281,9282,9283,9482,9483,
9484,9487,9489,9493,9499,9550,9553,9554,
9555,9556,9557,9558,9560,9561,9562,9564,
9566,9567,9568,9569,9570,9571,9573,9574)

Points with known errors for linestrings with only 3 points which are the same
(63754)

Points with known errors for linestrings with the same longitude but different latitudes
(62487,62488,62489,62490,62491) -- skipped to 63472 to test for other errors
*/

/* having issues with invalid geography, need MakeValid to work */ 

/*
-----------------------------------------------------
create views for points and lines to pull up in ArcGIS
ArcMap will not open transects with more than one type
-----------------------------------------------------
*/
drop view transect_points;
GO

create view transect_points as
select * from transect 
where Geometry.STGeometryType() = 'Point';
GO
-- select top 10 * from transect_points
	
drop view transect_lines; 
GO

create view transect_lines as
select * from transect 
where Geometry.STGeometryType() <> 'Point';
GO
-- select top 10 * from transect_lines

