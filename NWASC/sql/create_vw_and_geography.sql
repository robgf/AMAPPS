/*
-----------------------------------------------------
The purpose of this script is to 
1) create a geography column 
2) create views separating point and lines in the transect table

Created by N. Zimpher, altered by K. Coleman
Jan. 2018
-----------------------------------------------------
*/


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
create view geographyTest 
as 
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
/*
select 
transect_id
from geographyTest 
where point1b = point2b  and numpoints = 2 and pointType <> 'Point'
or point1a.STAsText() = point2a.STAsText() and numpoints = 2 and pointType <> 'Point'
*/

Update transect
set newGeometry = Geometry.STStartPoint()
where transect_id in (select transect_id from geographyTest 
where point1a.STAsText() = point2a.STAsText() and numpoints = 2 and pointType <> 'Point'
or point1b = point2b  and numpoints = 2 and pointType <> 'Point');

-- add geography column
alter table transect 
add [geography] geography;
GO;

-- create geography column from geometry
update transect
	set [geography] = GEOGRAPHY::STGeomFromText(Geometry.MakeValid().STAsText(),4269)
	where transect_id between 9572 and 9573;
	GO;
--

-- select * from geographyTest
-- drop view geographyTest
-- select dataset_id,[geometry].STAsText() from transect where transect_id in (9574)

/*
Points with known errors for linestrings with only two points which are the same
(7159,7330,7543,7800,7801,7806,8752,8983,
9277,9278,9279,9281,9282,9283,9482,9483,
9484,9487,9489,9493,9499,9550,9553,9554,
9555,9556,9557,9558,9560,9561,9562,9564,
9566,9567,9568,9569,9570,9571,9573,9574)
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

