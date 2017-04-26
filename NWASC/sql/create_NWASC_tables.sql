/*
This script creates the Northwest Atlantic Seabird Catalog Schema
and populates a few look up tables

created April 2017
by K. Coleman
*/

---------------------
-- define database --
---------------------
USE NWASC;
GO
--


---------------------------
-- create look up tables --
---------------------------

--create and populate dataset type table
CREATE TABLE lu_dataset_type (
	dataset_type_cd nchar(2) not null, 
	dataset_type_ds nvarchar(30) not null,
	Primary Key (dataset_type_cd)
);
GO

INSERT INTO lu_dataset_type (dataset_type_cd,dataset_type_ds)
	VALUES
	('de','derived effort'),
	('og','original general observation'),
	('ot','original transect');


--create and populate people table
CREATE TABLE lu_people (
	[user_id] smallint not null,
	name nvarchar(50) null,
	affiliation nvarchar(50) null,
	active_status nchar(10) null,
	Primary Key ([user_id])
);

--INSERT INTO lu_people([user_id], name, affiliation, active_status)
--	VALUES
	
--

--create and populate share level table
CREATE TABLE lu_share_level (
	share_level_id tinyint not null,
	share_level_ds nvarchar(250) not null,
	PRIMARY KEY(share_level_id)
);
GO 

INSERT INTO lu_share_level(share_level_id, share_level_ds)
	VALUES
	(0,'we do not have the data, need to request or request in progress'),
	(1,'not shared: Due to sensitivity concerns. dataset is restricted temporarily; remove in near future or share at some level. Do not share, do not send data to external repositories. NOTE: we cannot legally deny valid data requests.'),
	(2,'limited use: Allow use in summaries and visualizations (maps, graphs) without specific information. Allow same general use by AKN. (AKN Level 2)'),
	(3,'limited use (AKN+): Same as level 2, except allow others to request the dataset through AKN.  (AKN Level 3)'),
	(4,'limited use (AKN++): Same as level 3, except the AKN will display more info (all "Darwin Core" elements) and share with several bioinformatic efforts.  (AKN Level 4)'),
	(5,'full data available: Allow use of all data except observer names and contact information. AKN will also receive all data elements (see list).  (AKN Level 5)'),
	(6,'unobtainable or nonexistant'),
	(9,'acquired but not in the database and quality control not started'),
	(99,'in progress');
--

-- create and populate species type table
CREATE TABLE lu_species_type(
	species_type_id tinyint not null, 
	species_type_ds nvarchar(15) not null,
	PRIMARY KEY(species_type_id)
);
GO 
--

INSERT INTO lu_species_type(species_type_id, species_type_ds)
	VALUES
	(1,'birds'),
	(2,'cetaceans'),
	(3,'sea turtles'),
	(4,'fish'),
	(5,'other');
--

-- create species table
CREATE TABLE lu_species(
	spp_cd nchar(5) not null,
	species_type_id tinyint not null,
	common_name nvarchar(50) not null,
	scientific_name nvarchar(50) null,
	ITIS_id int null,
	PRIMARY KEY(spp_cd),
	FOREIGN KEY(species_type_id) REFERENCES lu_species_type(species_type_id)
);
--

-- create and populate survey type table
CREATE TABLE lu_survey_type(
	survey_type_cd nchar(1) not null,
	survey_type_ds nvarchar(50) not null,
	PRIMARY KEY (survey_type_cd)
);
GO 

INSERT INTO lu_survey_type(survey_type_cd,survey_type_ds)
	VALUES
	('a','airplane'),
	('b','boat'),
	('c','camera'),
	('f','fixed ground survey'),
	('g','area-wide ground survey');
--

-- create and populate survey method table
CREATE TABLE lu_survey_method(
	survey_method_cd nchar(3) not null,
	survey_method_ds nchar(50) not null,
	PRIMARY KEY (survey_method_cd)
);
GO 

INSERT INTO lu_survey_method(survey_method_cd,survey_method_ds)
	VALUES
	('byc','bycatch'),
	('cbc','Christmas Bird count'),
	('cts','continuous time strip'),
	('dth','discrete time horizon'),
	('dts','discrete time strip'),
	('go','general observation'),
	('tss','targeted species survey');
--

--create and populate beaufort table
CREATE TABLE lu_beaufort(
	beaufort_id tinyint not null,
	wind_speed_knots nchar(5) not null,
	WMO_classification nvarchar(50) not null,
	water_ds nvarchar(150) not null,
	PRIMARY KEY(beaufort_id)
);
GO 

INSERT INTO lu_beaufort(beaufort_id,wind_speed_knots,WMO_classification,water_ds)
	VALUES
	(0,'<1','Calm','Sea surface smooth and mirror-like'),
	(1,'1-3','Light Air','Scaly ripples, no foam crests'),
	(2,'4-6','Light Breeze','Small wavelets, crests glassy, no breaking'),
	(3,'7-10','Gentle Breeze','Large wavelets, crests begin to break, scattered whitecaps'),
	(4,'11-16','Moderate Breeze','Small waves 1-4 ft. becoming longer, numerous whitecaps'),
	(5,'17-21','Fresh Breeze','Moderate waves 4-8 ft taking longer form, many whitecaps, some spray'),
	(6,'22-27','Strong Breeze','Larger waves 8-13 ft, whitecaps common, more spray'),
	(7,'28-33','Near Gale','Sea heaps up, waves 13-19 ft, white foam streaks off breakers'),
	(8,'34-40','Gale','Moderately high (18-25 ft) waves of greater length, edges of crests begin to break into spindrift, foam blown in streaks'),
	(9,'41-47','Strong Gale','High waves (23-32 ft), sea begins to roll, dense streaks of foam, spray may reduce visibility'),
	(10,'48-55','Storm','Very high waves (29-41 ft) with overhanging crests, sea white with densely blown foam, heavy rolling, lowered visibility'),
	(11,'56-63','Violent Storm','Exceptionally high (37-52 ft) waves, foam patches cover sea, visibility more reduced'),
	(12,'64+','Hurricane','Air filled with foam, waves over 45 ft, sea completely white with driving spray, visibility greatly reduced');
--

--create revisions table
CREATE TABLE lu_revision_details (
	dataset_id smallint not null,
	revision_nb tinyint not null,
	revision_date date not null,
	revision_details nvarchar(1000) not null,
	Primary Key (dataset_id, revision_nb)
);
--

--NEEDS WORK--
-- create coverage area table
--CREATE TABLE lu_coverage(
--	dataset_id smallint not null,
--	Maine bit not null,
--	Massachusetts bit not null,
--	Rhode_Island bit not null,
--	Connecticut bit not null,
--	New_York bit not null,
--	New_Jersey bit not null,
--	Delaware bit not null,
--	Maryland bit not null,
--	Virginia bit not null,
--	North_Carolina bit not null,
--	South_Carolina bit not null,
--	Georgia bit not null,
--	Florida bit not null,

--	Nantucket_sound bit not null,
--  Long_Island_sound bit not null, 
--  Delaware_Bay bit not null,
--	Chesapeake_Bay bit not null,
--	Hudson_Bay bit not null,

--	Gulf_of_Mexico bit not null,
--	Gulf_of_Maine bit not null,
--	Mid_Atlantic_Bight bit not null,
--	South_Atlantic_Bight bit not null,
--	Northeast_US_within_EEZ bit not null,
--	Northeast_US_outside_EEZ bit not null,
--	Canada bit not null,
--);
--

------------------------
-- create main tables --
------------------------

-- create dataset table
CREATE TABLE dataset (
	dataset_id smallint not null,
	dataset_name nvarchar(50) not null,
	survey_type_cd nchar(1) not null,
	survey_method_cd nchar(3) not null,
	dataset_type_cd nchar(2) not null, 
	whole_survey_width_m smallint null,
	partial_survey_width_m smallint null,
	share_level_id tinyint not null, 
	sponsors nvarchar(50) null,
	planned_speed_knots numeric null,
	metadata nvarchar(MAX) null,
	version_nb tinyint not null, 
	pooled_observations nchar(3) not null,
	responsible_party smallint null, 
	in_database bit not null, 
	quality_ds nvarchar(1000) null,
	additional_info nvarchar(1000) null,
	PRIMARY KEY(dataset_id),
	FOREIGN KEY(survey_method_cd) REFERENCES lu_survey_method(survey_method_cd),
	FOREIGN KEY(dataset_type_cd) REFERENCES lu_dataset_type(dataset_type_cd),
	FOREIGN KEY(survey_type_cd) REFERENCES lu_survey_type(survey_type_cd),
	FOREIGN KEY(share_level_id) REFERENCES lu_share_level(share_level_id),
	FOREIGN KEY(dataset_id, version_nb) REFERENCES lu_revision_details(dataset_id, revision_nb),
	FOREIGN KEY(responsible_party) REFERENCES lu_people([user_id])
);
--

-- create transect table
CREATE TABLE transect (
	transect_id int not null,
	dataset_id smallint not null,
	source_transect_id nvarchar(50) null,
	start_dt date null,
	start_tm time null,
	--start_lat numeric null,
	--start_lon numeric null, 
	end_dt date null,
	end_tm time null,
	--end_lat numeric null,
	--end_lon numeric null,
	start_seconds_from_midnight numeric null,
	end_seconds_from_midnight numeric null,
	observer_tx nvarchar(20) null,
	observer_position nvarchar(20) null,
	visibility_tx nvarchar(50) null,
	weather_tx nvarchar(50) null,
	seastate_beaufort_nb tinyint null,
	wind_dir_tx nvarchar(50) null,
	seasurface_tempc_nb numeric null,
	heading_tx nvarchar(20) null,
	altitude_m smallint null,
	vehicle_name nvarchar(50) null, 
	geom_line nvarchar(MAX) null,
	comments nvarchar(1000) null,
	PRIMARY KEY(transect_id),
	FOREIGN KEY(dataset_id) REFERENCES dataset(dataset_id),
	FOREIGN KEY(seastate_beaufort_nb) REFERENCES lu_beaufort(beaufort_id)
);
--

-- create observation table
CREATE TABLE observation (
	observation_id int not null,
	dataset_id smallint not null,
	transect_id int null, 
	obs_dt date null,
	obs_tm time null,
	--obs_lat numeric null,
	--obs_lon numeric null,
	original_species_tx nvarchar(50) null,
	spp_cd nchar(5) not null,
	obs_count_intrans_nb smallint null,
	obs_count_general_nb smallint not null, --should be not null, need to check 
	observer_tx nvarchar(20) null,
	observer_position nvarchar(20) null,
	seconds_from_midnight numeric null,
	animial_age_tx nvarchar(50) null,
	plumage_tx nvarchar(50) null,
	behavior_tx nvarchar(50) null,
	animal_sex_tx nvarchar(50) null,
	travel_direction_tx nvarchar(50) null,
	heading_tx nvarchar(50) null,
	flight_height_tx nvarchar(50) null,
	distance_to_animal_tx nvarchar(50) null,
	angle_from_observer_nb tinyint null,
	associations_tx nvarchar(50) null,
	visibility_tx nvarchar(50) null,
	seastate_beaufort_nb tinyint null,
	wind_speed_tx nvarchar(50) null,
	wind_dir_tx nvarchar(50) null,
	--seasurface_tempc_nb numeric null,
	cloud_cover_tx nvarchar(50) null,
	--salinity_ppt_nb numeric null,
	wave_height_tx nvarchar(50) null,
	camera_reel nvarchar(50) null,
	observer_confidence nvarchar(50) null,
	--boem_lease_block_id smallint null,
	observer_comments nvarchar(250) null,
	geom_line nvarchar(MAX) null,
	admin_notes nvarchar(250) null,
	PRIMARY KEY(observation_id),
	FOREIGN KEY(dataset_id) REFERENCES dataset(dataset_id),
	FOREIGN KEY(seastate_beaufort_nb) REFERENCES lu_beaufort(beaufort_id),
	FOREIGN KEY(spp_cd) REFERENCES lu_species(spp_cd),
	FOREIGN KEY(transect_id) REFERENCES transect(transect_id)
	--FOREIGN KEY(boem_lease_block_id) REFERENCES lu_boem_lease_blocks(boem_lease_block_id)
);
--

-- create track table
CREATE TABLE track (
	track_id int not null,
	dataset_id smallint not null,
	transect_id int null, 
	track_dt date null,
	track_tm time null,
	--track_lat numeric null,
	--track_lon numeric null,
	point_type nchar(10) null,
	source_track_id nvarchar(50) null,
	seconds_from_midnight_nb numeric null,
	geom_line nvarchar(MAX) null,
	comments nvarchar(50) null,
	PRIMARY KEY(track_id),
	FOREIGN KEY(transect_id) REFERENCES transect(transect_id),
	FOREIGN KEY(dataset_id) REFERENCES dataset(dataset_id)
);
--

------------------------------
-- create extra info tables --
------------------------------

--create citations table
CREATE TABLE citations (
	dataset_id smallint not null,
	citation nvarchar(1000) not null,
	PRIMARY KEY (dataset_id),
	FOREIGN KEY (dataset_id) REFERENCES dataset(dataset_id)
);
--

--create reports table
CREATE TABLE reports (
	dataset_id smallint not null,
	report nvarchar(1000) not null,
	PRIMARY KEY (dataset_id),
	FOREIGN KEY (dataset_id) REFERENCES dataset(dataset_id)
);
--

--create urls table
CREATE TABLE urls (
	dataset_id smallint not null,
	url nvarchar(1000) not null,
	PRIMARY KEY (dataset_id),
	FOREIGN KEY (dataset_id) REFERENCES dataset(dataset_id)
);
--

--create progress_table table
CREATE TABLE progress_table (
	dataset_id smallint not null,
	priority_ranking tinyint null, --1:3 used for NOAA ranking but could rank another way
	action_required_or_taken nvarchar(20) not null,
	date_of_action date null,
	who_will_act nvarchar(50) not null,
	data_acquired bit not null,
	metadata_acquired bit not null,
	report_acquired bit not null,
	additional_info nvarchar(500) null,
	PRIMARY KEY (dataset_id),
	FOREIGN KEY (dataset_id) REFERENCES dataset(dataset_id)
);
--

--create boem lease block table
CREATE TABLE boem_lease_blocks (
	prot_nb nvarchar(20) not null,
 	block_nb nvarchar(20) not null,
	geom_line nvarchar(MAX) not null,
	Primary Key (prot_nb,block_nb)
);
--
