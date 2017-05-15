/*
This script creates the Northwest Atlantic Seabird Catalog Schema
and populates a few non-spatial tables

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
	(7,'this data is part of another dataset and while there was an independent name the data are not independent'),
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
GO
--

-- look up behaviors
CREATE TABLE lu_behaviors(
	behavior_id tinyint not null,
	behavior_ds nvarchar(20) not null
	PRIMARY KEY(behavior_id) 
);
GO

INSERT INTO lu_behaviors(behavior_id,behavior_ds)
	VALUES
	(1,'attacking/fighting'),-- 'harassing'
	(2,'basking/sunning'),
	(3,'blow'),
	(4,'bow riding'),
	(5,'breaching'),
	(6,'dead'),
	(7,'diving'), -- %in% c('dive','diving','dove')
	(8,'diving - plunge diving')
	(9,'feeding'), -- %in% c('feed','feeding')
	(10,'fishing/working'),
	(11,'floating'),
	(12,'flocking'),
	(13,'fluking') -- %in% c('fluke','fluking')
	(14,'flying'),
	(15,'flying - directional'),
	(16,'flying - non-directional'),
	(17,'flying - soaring')
	(18,'following/chasing'),
	(19,'following - ship'),
	(20,'foraging'),
	(21,'hauled out'), -- %in% c('beached','on beach','on shore') 
	(22,'jumping'), -- 'leaping'
	(23,'landing'),
	(24,'lobtailing')
	(25,'milling'),
	(26,'mating'),
	(27,'other'),	
	(28,'piracy'),
	(29,'porposing'),
	(30,'preening'),
	(31,'rafting'),
	(32,'resting'),
	(33,'resting - logging'),
	(34,'rolling'),
	(35,'scavenging'),
	(36,'slapping'), -- %in% c('slap','slapping','tailslap','flipperslap')
	(37,'sleeping'),
	(38,'splashing'),
	(39,'spyhopping'),
	(40,'sitting'),
	(41,'sitting - on object'),
	(42,'sitting - on water'),
	(43,'standing'),
	(44,'steaming'), 
	(45,'surfacing'),
	(46,'swimming'),
	(47,'taking off'),
	(48,'taking off - pattering'),
	(49,'traveling'),
	(50,'unknown');
	

--NEEDS WORK--
-- create coverage area table for easily querying areas
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

CREATE TABLE lu_parent_project(
	project_id tinyint not null,
	project_name nvarchar(55) not null,
	project_ds nvarchar(4000) null,
	project_url nvarchar(3000) null,
	PRIMARY KEY(project_id)
);
GO

INSERT INTO lu_parent_project(project_id, project_name, project_ds, project_url)
	VALUES
	(1, 'AMAPPS aerial',
		'The geographic area of operations includes near-shore and offshore waters of the U.S. Atlantic Coast from the Canada/Maine border to approximately Jacksonville, FL. Transects are located at 5'' (~ 5 nautical miles [nm]) intervals at every 1'' and 6'' minutes of latitude. Transect length depends on the location along coast. Some transects extend to 16 meter depth or out a distance of 8 nm , whichever is longer. In some cases, transects located near to where the coastline runs east-west have been extended to ensure that the survey covers areas that are at least 8 nm from land. Some transects extend as far as 30 nm off-shore to include important seabird foraging areas. In the past these annual surveys were conducted during the winter between January and February. However, when the survey expanded to include all marine bird species the surveys were flown multiple times throughout the year to better determine seabird distributions at different times of year. As a result the surveys are currently conducted in the fall (early October) and winter (early February).  Timing can also depend on available funding , data management needs, personnel shortages and availability, weather, and aircraft availability. Surveys are flown during daylight hours with no limits on the time of day. A survey can be initiated when the wind speed is < 15 knots (kts), and should be discontinued if the winds exceed 20 kts. Before starting each transect both the pilot and observers will record observation conditions on a 5-point Likert scale with 1 = Worst observation conditions, 3 = Average conditions, and 5 = Best observation conditions. Often times the pilot and observer conditions will be different as glare can affect one side of the aircraft more than the other depending on the direction of flight. Each crew area consists of east-west oriented  strip-transects. Each transect has a unique ID that uses the latitude degrees concatenated with the latitude minutes and then with the segment number [00, 01, etc.]. Typically there will just be one line segment “00”, but when more than one segment occurs on the same latitude you might also have segment “01."( e.g. 444600 or 444601).The transects are flown at a height of 200 feet above ground level and at a speed of 110 knots. Altitude is maintained  with the help of a radar altimeter in most cases. Transects extend 30 nautical miles (nm) offshore and can be flown from east to west or west to east.  Each transect is 400 meters (m) in width with 200 m observation bands on each side of the aircraft. Each observer counts outward to a the predefined 200 m width on their side of the aircraft (left-front (lf) or right-front(rf)).  The pilot serves as the left-front observer (lf) while the observer traditionally sits in the right-front (rf) or co-pilot seat of the aircraft. However, there have been times when a third backseat observer is present (e.g. a new observer being trained). The transect boundary is marked either on the strut with black tape  or the windshield (with dry erase marker) of the plane for reference using a clinometer. The survey targets the fifteen species of sea ducks and all species of marine birds wintering along the Atlantic coast.  Identification of birds to the lowest taxonomic level is ideal (e.g.species), however several generalized  groups have been created for the survey understanding that species identification can be difficult during aerial survey conditions. Such groupings are provided for other species as well including gulls, shearwaters, alcids, and scoters. Observers are also asked to  record all marine mammals, sharks and rays, and sea turtles within the transect. Finally, observers will also record any boats, including those outside of the transect , with an estimated distance in nautical miles. Balloons (both inflated and deflated) should be recording within the transect. [summary snippets copied from internal confluence site]',
		'http://www.nefsc.noaa.gov/psb/AMAPPS/'),
	(2, 'AMAPPS boat',
		NULL,
		'http://www.nefsc.noaa.gov/psb/AMAPPS/'),
	(3,'Audubon CBC (Christmas Bird Count)',NULL,NULL),
	(4,'Bar Harbor Whale Watching Cruises',NULL,NULL),
	(5,'BOEM HighDef NC 2011',NULL,NULL),
	(6,'CDAS Mid-Atlantic',NULL,NULL),
	(7,'CASP (Cetacean and Seabird Assessment Program)',NULL,NULL),
	(8,'DOE BRI aerial',NULL,NULL),
	(9,'DOE BRI boat',NULL,NULL),
	(10,'EcoMon (NEFSC Ecosystem Monitoring) Cruises',
		'Shelf-wide Research Vessel Surveys are conducted 6-7 times per year over the continental shelf from Cape Hatteras, North Carolina to Cape Sable, Nova Scotia, using NOAA research ships or charter vessels. Three surveys are performed jointly with the bottom trawl surveys in the winter, spring and autumn. An additional four cruises, conducted in winter, late spring, late summer and late autumn, are dedicated to plankton and hydrographic data collection. The Cape Hatteras to Cape Sable area is divided into four regions, and 30 randomly selected stations are targeted for sampling from each region.',
		'https://www.nefsc.noaa.gov/HydroAtlas/'),
	(11,'Florida Light and Power, Long Island',NULL,NULL),
	(12,'Herring Acoustic',NULL,NULL),
	(13,'Massachusetts CEC',NULL,NULL),
	(14,'PIROP',NULL,NULL),
	(15,'ECSAS',NULL,NULL),
	(16,'BOEM NanoTag Massachusetts 2013',NULL,NULL),
	(17,'BOEM Terns 2013',NULL,'https://www.boem.gov/2014-665/');
--
 
------------------------
-- create main tables --
------------------------

-- create dataset table
CREATE TABLE dataset (
	dataset_id smallint not null,
	dataset_name nvarchar(50) not null,
	survey_type_cd nchar(1) null,
	survey_method_cd nchar(3) null,
	dataset_type_cd nchar(2) null, 
	whole_survey_width_m smallint null,
	individual_observer_survey_width_m smallint null,
	share_level_id tinyint not null, 
	sponsors nvarchar(50) null,
	planned_speed_knots numeric null,
	pooled_observations nchar(3) null, --yes/no
	responsible_party smallint null, 
	in_database nchar(3) not null, --yes/no
	metadata nvarchar(3000) null,
	parent_project tinyint null, 
	dataset_summary nvarchar(4000) null, 
	dataset_quality nvarchar(3000) null, 
	dataset_processing nvarchar(3000) null,
	version_nb tinyint null, 
	additional_info nvarchar(1000) null,
	PRIMARY KEY(dataset_id),
	FOREIGN KEY(survey_method_cd) REFERENCES lu_survey_method(survey_method_cd),
	FOREIGN KEY(dataset_type_cd) REFERENCES lu_dataset_type(dataset_type_cd),
	FOREIGN KEY(survey_type_cd) REFERENCES lu_survey_type(survey_type_cd),
	FOREIGN KEY(share_level_id) REFERENCES lu_share_level(share_level_id),
	FOREIGN KEY(dataset_id, version_nb) REFERENCES lu_revision_details(dataset_id, revision_nb),
	FOREIGN KEY(responsible_party) REFERENCES lu_people([user_id]),
	FOREIGN KEY(parent_project) REFERENCES lu_parent_project(project_id)
);
GO
--

--select * from dataset
INSERT INTO dataset(
dataset_id, 
parent_project, 
dataset_name, 
survey_type_cd, 
survey_method_cd,
dataset_type_cd, 
whole_survey_width_m, 
individual_observer_survey_width_m,
share_level_id, 
in_database, 
pooled_observations, 
responsible_party)--,
--dataset_summary, dataset_quality, dataset_processing)
	VALUES
	(141,1,'AMAPPS_FWS_Aerial_Fall2012','a','cts','ot',400,200,5,'yes','no',50),
	(142,1,'AMAPPS_FWS_Aerial_Fall2013','a','cts','ot',400,200,5,'yes','no',64),
	(164,1,'AMAPPS_FWS_Aerial_Fall2014','a','cts','ot',400,200,5,'yes','no',64),
	(118,1,'AMAPPS_FWS_Aerial_Preliminary_Summer2010','a','cts','ot',400,200,5,'yes','no',50),
	(140,1,'AMAPPS_FWS_Aerial_Spring2012','a','cts','ot',400,200,5,'yes','no',50),
	(138,1,'AMAPPS_FWS_Aerial_Summer2011','a','cts','ot',400,200,5,'yes','no',50),
	(137,1,'AMAPPS_FWS_Aerial_Winter2010-2011','a','cts','ot',400,200,5,'yes','no',50),
	(139,1,'AMAPPS_FWS_Aerial_Winter2014','a','cts','ot',400,200,5,'yes','no',64),
	(117,2,'AMAPPS_NOAA/NMFS_NEFSCBoat2011','b','cts','ot',300,300,5,'yes','yes',55),
	(116,2,'AMAPPS_NOAA/NMFS_NEFSCBoat2013','b','cts','ot',300,300,5,'yes','yes',55),
	(149,2,'AMAPPS_NOAA/NMFS_NEFSCBoat2014','b','cts','ot',300,300,5,'yes','yes',55),
	(160,2,'AMAPPS_NOAA/NMFS_NEFSCBoat2015','b','cts','ot',300,300,5,'yes','yes',52),
	(174,2,'AMAPPS_NOAA/NMFS_NEFSCBoat2016','b','cts','ot',300,300,9,'no','yes',52),
	(122,2,'AMAPPS_NOAA/NMFS_SEFSCBoat2011','b','cts','ot',300,300,5,'yes','yes',55),
	(123,2,'AMAPPS_NOAA/NMFS_SEFSCBoat2013','b','cts','ot',300,300,5,'yes','yes',55),
	(100,NULL,'AtlanticFlywaySeaducks1991',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,NULL),				
	(43,3,'AudubonCBC_MA2Z','g','cbc','og',NULL,NULL,5,'yes',NULL,8),        		
	(46,3,'AudubonCBC_MASB','g','cbc','og',NULL,NULL,5,'yes',NULL,8),         		
	(47,3,'AudubonCBC_MD15','g','cbc','og',NULL,NULL,5,'yes',NULL,8),         		
	(48,3,'AudubonCBC_MD19','g','cbc','og',NULL,NULL,5,'yes',NULL,8),         		
	(49,3,'AudubonCBC_MDBH','g','cbc','og',NULL,NULL,5,'yes',NULL,8),         		
	(50,3,'AudubonCBC_MDJB','g','cbc','og',NULL,NULL,5,'yes',NULL,8),         		
	(51,3,'AudubonCBC_ME08','g','cbc','og',NULL,NULL,5,'yes',NULL,8),         		
	(52,3,'AudubonCBC_ME0A','g','cbc','og',NULL,NULL,5,'yes',NULL,8),         		
	(53,3,'AudubonCBC_ME0B','g','cbc','og',NULL,NULL,5,'yes',NULL,8),         		
	(54,3,'AudubonCBC_MEBF','g','cbc','og',NULL,NULL,5,'yes',NULL,8),         		
	(55,3,'AudubonCBC_MEMB','g','cbc','og',NULL,NULL,5,'yes',NULL,8),         		
	(56,3,'AudubonCBC_NJ0A','g','cbc','og',NULL,NULL,5,'yes',NULL,8),         		
	(57,3,'AudubonCBC_NJ0R','g','cbc','og',NULL,NULL,5,'yes',NULL,8),         		
	(58,3,'AudubonCBC_NJ0S','g','cbc','og',NULL,NULL,5,'yes',NULL,8),         		
	(59,3,'AudubonCBC_NJAO','g','cbc','og',NULL,NULL,5,'yes',NULL,8),         		
	(60,3,'AudubonCBC_NJNJ','g','cbc','og',NULL,NULL,5,'yes',NULL,8),         		
	(61,3,'AudubonCBC_NY1Q','g','cbc','og',NULL,NULL,5,'yes',NULL,7),         		
	(62,3,'AudubonCBC_NY1R','g','cbc','og',NULL,NULL,5,'yes',NULL,8),         		
	(63,3,'AudubonCBC_NY1S','g','cbc','og',NULL,NULL,5,'yes',NULL,8),         		
	(64,3,'AudubonCBC_NY1W','g','cbc','og',NULL,NULL,5,'yes',NULL,8),         		
	(65,3,'AudubonCBC_NY1X','g','cbc','og',NULL,NULL,5,'yes',NULL,8),         		
	(66,3,'AudubonCBC_NY21','g','cbc','og',NULL,NULL,5,'yes',NULL,8),         		
	(67,3,'AudubonCBC_NY39','g','cbc','og',NULL,NULL,5,'yes',NULL,8),         		
	(68,3,'AudubonCBC_VACB','g','cbc','og',NULL,NULL,5,'yes',NULL,8),         		
	(107,NULL,'AvalonSeawatch1993',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,21), 					
	(5,4,'BarHarborWW05','b','cts','ot',NULL,NULL,5,'yes','yes',33),         		
	(6,4,'BarHarborWW06','b','cts','ot',NULL,NULL,5,'yes','yes',33),         		
	(166,4,'BarHarborWW09','b','cts','ot',NULL,NULL,0,'no',NULL,33), 		
	(167,4,'BarHarborWW10','b','cts','ot',NULL,NULL,0,'no',NULL,33), 		
	(103,NULL,'BluewaterWindDE',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,40), 					
	(102,NULL,'BluewaterWindNJ',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,40), 					
	(144,5,'BOEMHighDef_NC2011Aerial','a','cts','ot',500,250,5,'yes','no',61), 
	(143,5,'BOEMHighDef_NC2011Boat','b','cts','ot',1000,1000,5,'yes','no',61), 
	(169,5,'BOEMHighDef_NC2011Camera','c','cts','ot',NULL,NULL,99,'no','yes',61), 		
	(145,NULL,'BOEMNanoTag_Mass_Aug2013','a','tss',NULL,NULL,NULL,99,'no',NULL,60), 			
	(172,NULL,'BRIMaine2016','b','cts','ot',NULL,NULL,9,'no',NULL,66), 		
	(7,NULL,'CapeHatteras0405','b','cts','ot',NULL,NULL,5,'yes',NULL,23),         		
	(8,NULL,'CapeWindAerial','a','cts','ot',NULL,NULL,2,'yes','yes',13),       		
	(9,NULL,'CapeWindBoat','b','cts','ot',NULL,NULL,2,'yes','yes',13),         		
	(10,6,'CDASMidAtlantic','a','cts','ot',120,60,5,'yes','yes',15),
	(21,7,'CSAP','b','dts','ot',300,300,5,'yes','yes',31),
	(97,NULL,'DEandChesBaysUSFWS1990',NULL,NULL,NULL,NULL,NULL,6,'no',NULL,15), 					
	(175,NULL,'DeepwaterWindBlockIsland0910',NULL,NULL,NULL,NULL,NULL,9,'no',NULL,65), 					
	(115,8,'DOEBRIAerial2012','c','cts','ot',200,50,1,'yes','yes',3),--check on share levels
	(148,8,'DOEBRIAerial2013','c','cts','ot ',200,50,1,'yes','yes',3),--check on share levels
	(168,8,'DOEBRIAerial2014','c','cts','ot',200,50,1,'yes','yes',3),--check on share levels
	(157,9,'DOEBRIBoatApr2014','b','cts','ot',300,300,1,'yes','yes',3),
	(114,9,'DOEBRIBoatApril2012','b','cts','ot',300,300,1,'yes','yes',3),
	(124,9,'DOEBRIBoatAug2012','b','cts','ot',300,300,1,'yes','yes',3),
	(152,9,'DOEBRIBoatAug2013','b','cts','ot',300,300,1,'yes','yes',3),
	(125,9,'DOEBRIBoatDec2012','b','cts','ot',300,300,1,'yes','yes',3),
	(155,9,'DOEBRIBoatDec2013','b','cts','ot',300,300,1,'yes','yes',3),
	(126,9,'DOEBRIBoatJan2013','b','cts','ot',300,300,1,'yes','yes',3),
	(156,9,'DOEBRIBoatJan2014','b','cts','ot',300,300,1,'yes','yes',3),
	(127,9,'DOEBRIBoatJune2012','b','cts','ot',300,300,1,'yes','yes',3),
	(151,9,'DOEBRIBoatJune2013','b','cts','ot',300,300,1,'yes','yes',3),
	(128,9,'DOEBRIBoatMar2013','b','cts','ot',300,300,1,'yes','yes',3),
	(150,9,'DOEBRIBoatMay2013','b','cts','ot',300,300,1,'yes','yes',3),
	(130,9,'DOEBRIBoatNov2012','b','cts','ot',300,300,1,'yes','yes',3),
	(154,9,'DOEBRIBoatOct2013','b','cts','ot',300,300,1,'yes','yes',3),
	(129,9,'DOEBRIBoatSep2012','b','cts','ot',300,300,1,'yes','yes',3),
	(153,9,'DOEBRIBoatSep2013','b','cts','ot',300,300,1,'yes','yes',3),
	(134,NULL,'DominionVirginia_VOWTAP','b','cts','ot',300,300,5,'yes','yes',65),
	(101,NULL,'DUMLOnslowBay2007',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,36),					
	(77,10,'EcoMonAug08','b','cts','ot',300,300,5,'yes','yes',11),
	(42,10,'EcoMonAug09','b','cts','ot',300,300,5,'yes','yes',11),
	(82,10,'EcoMonAug10','b','cts','ot',300,300,5,'yes','yes',11),
	(112,10,'EcoMonAug2012','b','cts','ot',300,300,5,'yes','yes',11),
	(79,10,'EcoMonFeb10','b','cts','ot',300,300,5,'yes','yes',11),
	(131,10,'EcoMonFeb2012','b','cts','ot',300,300,5,'yes','yes',11),
	(171,10,'EcoMonFeb2013','b','cts','ot',300,300,5,'yes','yes',62),
	(38,10,'EcoMonJan09','b','cts','ot',300,300,5,'yes','yes',11),
	(158,10,'EcoMonJun2012','b','cts','ot',300,300,5,'yes','yes',11),
	(33,10,'EcoMonMay07','b','cts','ot',300,300,5,'yes','yes',11),
	(39,10,'EcoMonMay09','b','cts','ot',300,300,5,'yes','yes',11),
	(80,10,'EcoMonMay10','b','cts','ot',300,300,5,'yes','yes',11),
	(76,10,'EcoMonNov09','b','cts','ot',300,300,5,'yes','yes',11),
	(81,10,'EcoMonNov10','b','cts','ot',300,300,5,'yes','yes',11),
	(83,10,'EcoMonNov2011','b','cts','ot',300,300,5,'yes','yes',11),
	(159,10,'EcoMonOct2012','b','cts','ot',300,300,5,'yes','yes',11),
	(170,10,'EcoMonSep2012',NULL,NULL,NULL,NULL,NULL,6,'no',NULL,NULL),
	(119,NULL,'ECSAS','b','cts','ot',300,300,0,'no',NULL,16),
	(99,11,'FLPowerLongIsland_Aerial','a','cts','ot',400,200,5,'yes','yes',65),
	(165,11,'FLPowerLongIsland_Boat','b','cts','ot',300,300,5,'yes','yes',65),
	(147,NULL,'FWS_MidAtlanticDetection_Spring2012','a','cts','ot',400,200,5,'yes','no',59),
	(146,NULL,'FWS_SouthernBLSC_Winter2012','a','cts','ot',400,200,5,'yes','no',59),
	(113,NULL,'FWSAtlanticWinterSeaduck2008','a','cts','ot',400,200,5,'yes','no',58),
	(12,NULL,'GeorgiaPelagic','b','dts','ot',NULL,NULL,5,'yes',NULL,20),        		
	(110,NULL,'GulfOfMaineBluenose1965',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,NULL),   					
	(73,NULL,'HassNC','b','tss','ot',NULL,NULL,5,'yes',NULL,42),         		
	(15,NULL,'HatterasEddyCruise2004','b','cts','ot',NULL,NULL,5,'yes',NULL,27),         		
	(78,12,'HerringAcoustic06','b','cts','ot',300,300,5,'yes','yes',11),
	(34,12,'HerringAcoustic07','b','cts','ot',300,300,5,'yes','yes',11),
	(35,12,'HerringAcoustic08','b','cts','ot',300,300,5,'yes','yes',11),
	(69,12,'HerringAcoustic09Leg1','b','cts','ot',300,300,5,'yes','yes',11),
	(70,12,'HerringAcoustic09Leg2','b','cts','ot',300,300,5,'yes','yes',11),
	(71,12,'HerringAcoustic09Leg3','b','cts','ot',300,300,5,'yes','yes',11),
	(84,12,'HerringAcoustic2010','b','cts','ot',300,300,5,'yes','yes',11),
	(85,12,'HerringAcoustic2011','b','cts','ot',300,300,5,'yes','yes',11),
	(111,12,'HerringAcoustic2012','b','cts','ot',300,300,5,'yes','yes',62),
	(22,NULL,'MassAudNanAerial','a','cts','ot',182,91,5,'yes','yes',10),
	(135,13,'MassCEC2011-2012','a','cts','ot',400,200,5,'yes','no',62),
	(161,13,'MassCEC2013','a','cts','ot',400,200,5,'yes','no',62),
	(162,13,'MassCEC2014','a','cts','ot',400,200,5,'yes','no',62),
	(74,NULL,'Mayr1938TransAtlantic','b','go','og',NULL,NULL,5,'yes',NULL,NULL),--check        		
	(136,13,'NantucketAerial2013','a','cts','ot',NULL,NULL,7,'yes',NULL,62),		
	(96,NULL,'NantucketShoalsLTDU1998',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,NULL),					
	(105,NULL,'NCInletsDavidLee1976',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,22),					
	(109,NULL,'NewEnglandBlueDolphin1953',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,25),					
	(25,NULL,'NewEnglandSeamount06','b','dts','ot',NULL,NULL,5,'yes',NULL,16),        		
	(91,NULL,'NJDEP2009','b','cts','de',300,300,5,'yes','yes',56),
	(121,NULL,'NOAA/NMFS_NEFSCBoat2004','b','cts','ot',300,300,5,'yes','yes',52),
	(120,NULL,'NOAA/NMFS_NEFSCBoat2007','b','cts','ot',300,300,5,'yes','yes',52),
	(32,NULL,'NOAABycatch','b','byc','og',NULL,NULL,5,'yes',NULL,19),        		
	(20,NULL,'NOAAMBO7880','b','dts','ot',300,300,5,'yes','yes',15),   
	(173,NULL,'NYSERDA_APEM',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,NULL),					
	(23,NULL,'Patteson','b','go','og',NULL,NULL,5,'yes',NULL,32),        		
	(92,NULL,'PIROP','b',NULL,NULL,NULL,NULL,7,'yes',NULL,16),				
	(75,NULL,'PlattsBankAerial','a','cts','ot',NULL,NULL,5,'yes',NULL,39),        		
	(98,NULL,'RHWiley1957',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,26),					
	(89,NULL,'RISAMPAerial','a','cts','ot',300,300,5,'yes','yes',41),
	(90,NULL,'RISAMPBoat','b','cts','ot',300,300,5,'yes','yes',41),
	(104,NULL,'RockportSeawatch',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,NULL),					
	(108,NULL,'RowlettMaryland1971',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,24),					
	(163,NULL,'RoyalSociety',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,NULL),					
	(24,NULL,'SargassoSea04','b','go','og',NULL,NULL,5,'yes',NULL,28),	       		
	(28,NULL,'SargassoSea06','b','go','og',NULL,NULL,5,'yes',NULL,34),	        		
	(93,NULL,'SEANET',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,43),					
	(29,NULL,'SEFSC1992','b','cts','ot',300,300,5,'yes','yes',30),
	(30,NULL,'SEFSC1998','b','cts','ot',300,300,5,'yes','yes',30),
	(31,NULL,'SEFSC1999','b','cts','ot',300,300,5,'yes','yes',30),
	(133,NULL,'StatoilMaine','b','cts','ot',300,300,5,'yes','yes',65),
	(95,NULL,'StellwagenBankNMS',NULL,NULL,NULL,NULL,NULL,99,'no',NULL,9),					
	(106,NULL,'WaterfowlUSFWS2001',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,14),					
	(94,NULL,'WHOIJuly2010','b','cts','ot',300,300,1,'yes',NULL,11),
	(132,NULL,'WHOISept2010','b','cts','ot',300,300,1,'yes',NULL,11),
	(176,10,'EcoMonMar2014','b','cts','ot',300,300,0,'no',NULL,16),
	(177,10,'EcoMonOct2015','b','cts','ot',300,300,0,'no',NULL,16),
	(178,10,'EcoMonMay2015','b','cts','ot',300,300,0,'no',NULL,16),
	(179,10,'EcoMonOct2016','b','cts','ot',300,300,0,'no',NULL,16),
	(180,10,'EcoMonMay2016','b','cts','ot',300,300,0,'no',NULL,16),
	(181,10,'EcoMonAug2016','b','cts','ot',300,300,0,'no',NULL,16),
	(182,10,'EcoMonFeb2017','b','cts','ot',300,300,0,'no',NULL,16),
	(183,10,'EcoMonJun2013','b','cts','ot',300,300,0,'no',NULL,16),
	(184,10,'EcoMonNov2013','b','cts','ot',300,300,0,'no',NULL,16),
	(185,10,'EcoMonFeb2011','b','cts','ot',300,300,0,'no',NULL,NULL),
	(186,10,'EcoMonJun2011','b','cts','ot',300,300,0,'no',NULL,NULL),
	(187,16,'BOEMNanoTag_Mass_Sept2013','a','tss',NULL,NULL,NULL,99,'no',NULL,60),
	(188,17,'BOEM_terns_July2013','a','tss',NULL,NULL,NULL,0,'no',NULL,NULL);
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
	behavior_id tinyint null,
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
	FOREIGN KEY(transect_id) REFERENCES transect(transect_id),
	FOREIGN KEY(behavior_id) REFERENCES lu_behaviors(behavior_id)
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

--create url, citations, and reports table
CREATE TABLE links_and_literature (
	id smallint not null,
	dataset_id smallint not null,
	data_url nvarchar(2083) null,
	report nvarchar(2083) null,
	citation nvarchar(2000) null,
	publications nvarchar(2000) null,
	PRIMARY KEY(id),
	FOREIGN KEY(dataset_id) REFERENCES dataset(dataset_id)
);

INSERT INTO links_and_literature(id,dataset_id,data_url,report,citation)
	VALUES
	(1,15,'http://seamap.env.duke.edu/datasets/detail/322',NULL,'Hyrenbach, D. 2011. Hatteras Eddy Cruise 2004. Data downloaded from OBIS-SEAMAP (http://seamap.env.duke.edu/dataset/322) on yyyy-mm-dd.'),
	(2,24,'http://seamap.env.duke.edu/datasets/detail/310',NULL,'Hyrenbach, D. and H. Whitehead. 2008. Sargasso 2004 - Seabirds . Data downloaded from OBIS-SEAMAP (http://seamap.env.duke.edu/dataset/310) on yyyy-mm-dd'),
	(3,115,NULL,'http://www.briloon.org/uploads/BRI_Documents/Wildlife_and_Renewable_Energy/MABS%20Project%20Chapter%203%20-%20Connelly%20et%20al%202015.pdf',NULL),
	(4,148,NULL,'http://www.briloon.org/uploads/BRI_Documents/Wildlife_and_Renewable_Energy/MABS%20Project%20Chapter%203%20-%20Connelly%20et%20al%202015.pdf',NULL),
	(5,168,NULL,'http://www.briloon.org/uploads/BRI_Documents/Wildlife_and_Renewable_Energy/MABS%20Project%20Chapter%203%20-%20Connelly%20et%20al%202015.pdf',NULL),
	(6,117,NULL,'http://www.nefsc.noaa.gov/psb/AMAPPS/docs/NMFS_AMAPPS_2011_annual_report_final_BOEM.pdf',NULL),
	(7,143,NULL,'https://www.boem.gov/ESPIS/5/5272.pdf',NULL),
	(8,144,NULL,'https://www.boem.gov/ESPIS/5/5272.pdf',NULL),
	(9,169,NULL,'https://www.boem.gov/ESPIS/5/5272.pdf',NULL),
	(10,91,NULL,'http://www.nj.gov/dep/dsr/ocean-wind/report.htm'' AND ''http://www.nj.gov/dep/dsr/ocean-wind/final-volume-1.pdf',NULL),
	(11,113,NULL,'http://seaduckjv.org/pdf/studies/pr109.pdf',NULL),
	(19,29,'http://seamap.env.duke.edu/dataset/3','Southeast Fisheries Science Center, Marine Fisheries Service, NOAA. 1992. OREGON II Cruise. Cruise report. 92-01 (198).','Garrison, L. 2013. SEFSC Atlantic surveys 1992. Data downloaded from OBIS-SEAMAP (http://seamap.env.duke.edu/dataset/3) on yyyy-mm-dd.'),
	(20,30,'http://seamap.env.duke.edu/dataset/1','Southeast Fisheries Science Center, Marine Fisheries Service, NOAA. 1998. Cruise Results: Summer Atlantic Ocean Marine Mammal Survey: NOAA Ship Relentless Cruise. Cruise report. RS 98-01 (3)','Garrison, L. 2013. SEFSC Atlantic surveys, 1998 (3). Data downloaded from OBIS-SEAMAP (http://seamap.env.duke.edu/dataset/1) on yyyy-mm-dd.'),
	(21,31,'http://seamap.env.duke.edu/dataset/5 ; https://gcmd.nasa.gov/KeywordSearch/Metadata.do?Portal=idn_ceos&KeywordPath=%5BKeyword%3D%27shore+birds%27%5D&OrigMetadataNode=GCMD&EntryId=seamap5&MetadataView=Full&MetadataType=0&lbnode=mdlb2','Southeast Fisheries Science Center, Marine Fisheries Service, NOAA. 1999. Cruise Results; Summer Atlantic Ocean Marine Mammal Survey; NOAA Ship Oregon II Cruise. Cruise report. OT 99-05 (236)','Garrison, L. 2013. SEFSC Atlantic surveys 1999. Data downloaded from OBIS-SEAMAP (http://seamap.env.duke.edu/dataset/5) on yyyy-mm-dd.'),
	(22,92,'http://seamap.env.duke.edu/datasets/detail/280',NULL,'Hyrenbach, D., F. Huettmann and J. Chardine. 2012. PIROP Northwest Atlantic 1965-1992. Data downloaded from OBIS-SEAMAP (http://seamap.env.duke.edu/dataset/280) on yyyy-mm-dd.'),
	(23,7,'http://seamap.env.duke.edu/datasets/detail/280','http://www.whoi.edu/science/PO/hatterasfronts/marinemammal.html','Hyrenbach, D., F. Huettmann and J. Chardine. 2012. PIROP Northwest Atlantic 1965-1992. Data downloaded from OBIS-SEAMAP (http://seamap.env.duke.edu/dataset/280) on yyyy-mm-dd.'),
	(24,24,'http://seamap.env.duke.edu/datasets/detail/280',NULL,'Hyrenbach, D., F. Huettmann and J. Chardine. 2012. PIROP Northwest Atlantic 1965-1992. Data downloaded from OBIS-SEAMAP (http://seamap.env.duke.edu/dataset/280) on yyyy-mm-dd.'),
	(25,80,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2010/MAY_ECOMON_DEL1004/CRUISE_REPORT_2010004DE.pdf',NULL),
	(26,81,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2010/NOV_ECOMON_DEL1012/CRUISE_REPORT_2010012DE.pdf',NULL),
	(27,42,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2009/AUG_ECOMON_DEL0909/CRUISE_REPORT_2009009DE.pdf',NULL),
	(28,38,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2009/JAN_ECOMON_DEL0902/CRUISE_REPORT_2009002DEL.pdf',NULL),
	(29,39,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2009/MAY_ECOMON_DEL0905/CRUISE_REPORT_2009005DE.pdf',NULL),
	(30,76,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2010/NOV_ECOMON_DEL1012/CRUISE_REPORT_2010012DE.pdf',NULL),
	(31,77,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2008/AUG_ECOMON_DEL0808/CRUISE_REPORT_2008008DE.pdf',NULL),
	(32,171,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2013/FEB_ECOMON_PC1301/CRUISE_REPORT_2013001PC.pdf',NULL),
	(33,131,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2012/FEB_ECOMON_DEL1202/CRUISE_REPORT_2012002DE.pdf',NULL),
	(34,82,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2010/AUG_ECOMON_DEL1009/CRUISE_REPORT_2010009DE.pdf',NULL),
	(35,79,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2010/JAN_ECOMON_DEL1001/CRUISE_REPORT_2010001DE.pdf',NULL),
	(36,181,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2016/AUG_ECOMON_PC1607/CRUISE_REPORT_2016007PC.pdf',NULL),
	(37,180,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2016/MAY_ECOMON_GU1608/CRUISE_REPORT_2016008GU.pdf',NULL),
	(38,178,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2015/MAY_ECOMON_HB1502/CRUISE_REPORT_2015002HB.pdf',NULL),
	(39,177,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2015/OCT_ECOMON_GU1506/CRUISE_REPORT_2015006GU.pdf',NULL),
	(40,176,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2014/MAR_ECOMON_GU1401/CRUISE_REPORT_2014001GU.pdf',NULL),
	(41,33,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2007/MAY_ECOMON_DEL0706/CRUISE_REPORT_2007006DE.pdf',NULL),
	(42,183,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2013/JUN_ECOMON_GU1302/CRUISE_REPORT_2013002GU.pdf',NULL),
	(43,184,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2013/NOV_ECOMON_GU1305/CRUISE_REPORT_2013005GU.pdf',NULL),
	(44,185,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2011/FEB_ECOMON_DEL1102/CRUISE_REPORT_2011002DE.pdf',NULL),
	(45,186,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2011/JUN_ECOMON_DEL1105/CRUISE_REPORT_2011005DE.pdf',NULL);


--ECOMON Nov 2014 no birds in report? combined with Herring Acoustic https://www.nefsc.noaa.gov/HydroAtlas/2014/NOV_ECOMON_PC1405/CRUISE_REPORT_2014005PC.pdf
--ECOMON Dec 2011 we might have this data listed as Nov? Tim White on boat. Not the same as Nov 2011, finish stations not hit in Nov https://www.nefsc.noaa.gov/HydroAtlas/2011/DEC_ECOMON_DEL1110/CRUISE_REPORT_2011010DE.pdf


--create and populate progress_table table
CREATE TABLE progress_table (
	dataset_id smallint not null,
	dataset_name nvarchar(35) not null,
	share_level_id tinyint not null,
	priority_ranking tinyint null, --1:3 used for NOAA ranking but could rank another way
	action_required_or_taken nvarchar(50) not null,
	date_of_action date null,
	who_will_act nvarchar(50) not null,
	data_acquired bit not null,
	metadata_acquired bit not null,
	report_acquired bit not null,
	additional_info nvarchar(500) null,
	PRIMARY KEY(dataset_id),
	FOREIGN KEY(dataset_id) REFERENCES dataset(dataset_id)
);
GO

INSERT INTO progress_table(dataset_id,dataset_name,action_required_or_taken,date_of_action,who_will_act,data_acquired,metadata_acquired,report_acquired,additional_info)
	VALUES
	(92,7,'PIROP','need to investigate',NULL,'KC',0,0,0,'Apparently already in database but across several other surveys, need to figure out which'),
	(93,0,'SEANET','need to investigate',NULL,'KC',0,0,0,'Not sure that we actually want this in here'),
	(95,99,'StellwagenBankNMS','started QA/QC with Arliss',NULL,'KC',1,0,0,'See Arliss''s email. In contact with provider about data edits'),
	(96,0,'NantucketShoals1998','need to investigate',NULL,'TW',0,0,0,NULL),
	(97,0,'DEandChesBaysUSFWS1190','need to investigate',NULL,'MTJ/KC',0,0,0,NULL),
	(100,0,'AtlanticFlywaySeaducks','need to investigate',NULL,'MTJ/KC',0,0,0,NULL),
	(101,0,'DUMLOnslowBay2007','need to investigate',NULL,'AW',0,0,0,NULL),
	(106,0,'WaterfowlUSFWS2001','need to investigate',NULL,'MTJ/KC',0,0,0,NULL),
	(119,0,'ECSAS','Arliss has, on hold for now',NULL,'KC',0,0,0,'waiting until data is published'),
	(145,99,'BOEMNanoTag_Mass_July2013','needs QA/QC',NULL,'KC',1,0,0,'In contact with Pam about this'),
	(163,0,'RoyalSociety','need to investigate',NULL,'TW',0,0,0,NULL),
	(166,0,'BarHarborWW09','requested multiple times',CAST('2017-04-27' AS DATE),'KC',0,0,0,NULL),
	(167,0,'BarHarborWW010','requested multiple times',CAST('2017-04-27' AS DATE),'KC',0,0,0,NULL),
	(169,99,'BOEMHighDef_NC2011Camera','need to finish QA/QC',NULL,'KC',1,0,1,'There were issues with the gps and time'),
	(172,9,'BRIMaine2016','looked at data, needs QA/QC',NULL,'KC',1,0,0,NULL),
	(173,0,'NYSERDA_APEM','need to invevstigate',NULL,'KC',0,0,0,'Was in contact with provider about submission guidelines, need to check back'),
	(174,99,'AMAPPS_NOAA/NMFS_NEFSCBoat2016','started QA/QC',NULL,'KC',1,0,0,NULL),
	(175,9,'DeepwaterWindBlockIsland0910','needs QA/QC',NULL,'KC',1,0,0,NULL),
	(176,0,'EcoMonMar2014','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(177,0,'EcoMonOct2015','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(178,0,'EcoMonMay2015','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(179,0,'EcoMonOct2016','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(180,0,'EcoMonMay2016','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(181,0,'EcoMonAug2016','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(182,0,'EcoMonFeb2017','need to request',NULL,'TW/KC',0,0,0,'In contact with TW and AW about this'),
	(183,0,'EcoMonJun2013','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(184,0,'EcoMonNov2013','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(185,0,'EcoMonFeb2011','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(186,0,'EcoMonJun2011','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(187,99,'BOEMNanoTag_Mass_Aug2013','needs QA/QC',NULL,'KC',1,0,1,'In contact with Pam about this'),
	(188,99,'BOEMNanoTag_Mass_Sept2013','needs QA/QC',NULL,'KC',1,0,1,'In contact with Pam about this');
	
--

--create boem lease block table
CREATE TABLE boem_lease_blocks (
	prot_nb nvarchar(20) not null,
 	block_nb nvarchar(20) not null,
	geom_line nvarchar(MAX) not null,
	Primary Key (prot_nb,block_nb)
);
--
