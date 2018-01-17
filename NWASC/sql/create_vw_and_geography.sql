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
-- add geography column
alter table transect 
add [geography] geography;

-- create geography column from geometry
--Update transect 
update transect
	set [geography] = GEOGRAPHY::STGeomFromText(Geometry.MakeValid().STAsText(),4269)
	where transect_id = 7159
	
	select [geometry].STNumPoints() from transect where transect_id = 7159
--where transect_id between 24827 and 24840 
--where Geometry.STGeometryType() = 'Point'
/* having issues with invalid geography, need MakeValid to work */ --select top 10 * from transect

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

