/*
This script creates the Northwest Atlantic Seabird Catalog Schema
and populates a few non-spatial tables

created April 2017
by K. Coleman

This script will continue to be updated when adding new datasets to the dataset table
or for most other additions or changes made to tables other than observations, transect, or track
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
	work_email_only nvarchar(50) null,
	active_status nchar(10) null,
	Primary Key ([user_id])
);
GO

INSERT INTO lu_people([user_id], name, affiliation, active_status,work_email_only)
	VALUES
	(1,'Mark Wimer','USGS','active','mwimer@usgs.gov'),
	(2,'Allison Sussman','USGS','not active',NULL),
	(3,'Andrew Gilbert','BRILOON','active','andrew.gilbert@briloon.org'),
	(4,'Tim Pascoe',NULL,NULL,NULL),
	(5,'Thomas de Lange Wenneck', NULL,NULL,NULL),
	(6,'Henrik Skov',NULL,NULL,NULL),
	(7,'David Divins','NOAA',NULL,NULL),
	(8,'Geoffrey LeBaron','Audubon',NULL,NULL),
	(9,'David Wiley','NOAA',NULL,'david.wiley@noaa.gov'),
	(10,'Becky Harris','MA Audubon',NULL,NULL),	
	(11,'Richard Veit','CUNY','active','Richard.Veit@csi.cuny.edu'),
	(12,'Larry Poppe','USGS',NULL,NULL),	
	(13,'Terry Orr',NULL,NULL,NULL),
	(14,'Mark Koneff','USFWS','active','mark_koneff@fws.gov'),
	(15,'Doug Forsell','USFWS','not active',NULL),
	(16,'Carina	Gjerdrum',NULL,'active',NULL),
	(17,'Todd O''Brien','NOAA',NULL,NULL),	
	(18,'Bruce Peterjohn','USGS',NULL,NULL),
	(19,'David Potter','NOAA',NULL,NULL),	
	(20,'J. Christopher	Haney','Defenders', NULL,NULL),	
	(21,'David Mizrahi','NJ Audubon', NULL,NULL),	
	(22,'David Lee',NULL,NULL,NULL),			
	(23,'Erin LaBrecque','Duke',NULL,NULL),	
	(24,'R. A. Rowlett',NULL,NULL,NULL),			
	(25,'Malcolm Gordon','UCLA',NULL,NULL),	
	(26,'R. Haven Wiley','UNC', NULL,NULL),	
	(27,'David Hyrenbach','U Washington',NULL,NULL),
	(28,'Hal Whitehead','DAL',NULL,NULL),	
	(29,'Kevin Powers', NULL,NULL,NULL),			
	(30,'Lance Garrison','NOAA',NULL,NULL),	
	(31,'Stephanie Schmidt','Manomet',NULL,NULL),
	(32,'Brian Patteson',NULL,NULL,NULL),			
	(33,'Linda Welch','USFWS','active','Linda_Welch@fws.gov'),
	(34,'Sarah Wong','DAL',NULL,NULL),
	(35,'Bob Raftovich','USFWS','active','robert_raftovich@fws.gov'),
	(36,'Kim Urian','EC RR',NULL,NULL),	
	(37,'Odd Aksel Bergstad','IMR',NULL,NULL),
	(38,'Peter Stevick',NULL,NULL,NULL),		
	(39,'Nicholas Wolff','U Maine',NULL,NULL),	
	(40,'Douglas Pfeister', NULL,NULL,NULL),	
	(41,'Kristopher	Winiarski', NULL,NULL,NULL),	
	(42,'Todd Hass','ECY WA',NULL,NULL),	
	(43,'Julie Ellis','Tufts',NULL,NULL),
	(44,'Allan O''Connell','USGS','active','aoconnell@usgs.gov'),
	(45,'Brian Kinlan','NOAA','not active',NULL),
	(46,'Beth Gardner',NULL,'active',NULL),
	(47,'Elise Zipkin',NULL,'active',NULL),
	(48,'Nick Flanders','NCSU',NULL,NULL),	
	--no 49, need to check and see if I can reassign 
	(50,'M. Tim	Jones','USFWS','active','tim_jones@fws.gov'),
	(51,'Melanie Steinkamp','USFWS','active','melanie_steinkamp@fws.gov'),
	(52,'Elizabeth Josephson','NOAA','active','elizabeth.josephson@noaa.gov'),
	(53,'Debra Palka','NOAA',NULL,NULL),	
	(54,'Holly Goyert','UMASS','active','hgoyert@umass.edu'),
	(55,'Mike Simpkins','NOAA',NULL,NULL),	
	(56,'Gary Buchanan', NULL,NULL,NULL),	
	(57,'Shannon Beliew','USGS', 'active','sbeliew@usgs.gov'),
	(58,'Emily Silverman','USFWS', 'active','emily_silverman@fws.gov'),
	(59,'Jeff Leirness','NOAA', 'active','jeffery.leirness@noaa.gov'),
	(60,'Pam Loring','USFWS','active','pamela_loring@fws.gov'),
	(61,'Julia Willmot','Normandeu', 'active','jwillmott@normandeau.com'),
	(62,'Tim White','BOEM', 'active','timothy.white@boem.gov'),
	(63,'Aaron Svedlow','Tetratech', 'not active',NULL),
	(64,'Kaycee Coleman','USFWS', 'active','kaycee_coleman@fws.gov'),
	(65,'David Bigger','BOEM','active','david.bigger@boem.gov'),
	(66,'Matt Nixon','Maine.gov','active','Matthew.E.Nixon@maine.gov'),
	(67,'Scott Anderson','NC Wildlife','active','scott.anderson@ncwildlife.org'),
	(68,'Arliss Winship','NOAA','active','Arliss.Winship@noaa.gov'),
	(69,'Fayvor Love','Point Blue','active','flove@pointblue.org'),
	(70,'Jim Paruk','BRILOON','active','jim.paruk@briloon.org'),
	(71,'Tony Diamond','University of New Brunswick','active',NULL),
	(72,'Tom White','USFWS','active','thomas_white@fws.gov'),
	(73,'Rob Serafini','Point Blue','active','rserafini@pointblue.org'),
	(74,'Caleb Spiegel','USFWS','active','caleb_spiegel@fws.gov'),
	(75,'Meghan Sadlowski','USFWS','active','meghan_sadlowski@fws.gov'),
	(76, 'Scott Johnston','USFWS','active','scott_johnston@fws.gov');
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
	species_type_ds nvarchar(60) not null,
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
	(5,'other (bats, polar bears, plants, man made objects, etc.)'),
	(6,'bugs'),
	(7,'boats'),
	(8,'non-seabirds');
/*
update lu_species_type
set species_type_ds = 'landbirds'
where species_type_id = 8

select * from lu_species_type
*/
--

-- create species table
CREATE TABLE lu_species (
	spp_cd nvarchar(4) not null,
	species_type_id tinyint not null,
	common_name nvarchar(200) not null,
	[group] nvarchar(100) null,
	genus nvarchar(100) null,
	species nvarchar(100) null,
	ITIS_id int null,
	PRIMARY KEY(spp_cd),
	FOREIGN KEY(species_type_id) REFERENCES lu_species_type(species_type_id)
);
GO

INSERT INTO lu_species(
	species_type_id,spp_cd,	common_name, [group], genus, species, ITIS_id)
	VALUES
	(1,'ABDH','American Black Duck X Mallard Hybrid','Anas rubripes x platy.',NULL, NULL, NULL),
	(1,'ABDU','American Black Duck', NULL,'Anas','rubripes',175068),
	(1,'AMBI','American Bittern',NULL,'Botaurus','lentiginosus',174856),
	(1,'AMCO','American Coot',NULL,'Fulica','americana',176292),
	(1,'AMGP','American Golden Plover',NULL,'Pluvialis','dominica',176564),
	(1,'AMKE','American Kestrel',NULL,'Falco','sparverius',175622),
	(1,'AMOY','American Oystercatcher',NULL,'Haematopus','palliatus',176472),
	(1,'AMPI','American Pipit',NULL,'Anthus','rubescens',554127),
	(1,'AMWI','American Wigeon',NULL,'Anas','americana',175094),
	(1,'AMWO','American Woodcock',NULL,'Scolopax','minor',176580),
	(1,'ANHI','Anhinga anhinga',NULL,'Anhinga','anhinga',174755),
	(1,'APLO','Arctic Loon/Pacific Loon','Gavia arctica/pacifica',NULL,NULL,NULL),
	(1,'ARLO','Arctic Loon',NULL,'Gavia','arctica',174471),
	(1,'ARTE','Arctic Tern',NULL,'Sterna','paradisaea',176890),
	(1,'ATPU','Atlantic Puffin',NULL,'Fratercula','arctica',177025),
	(1,'AUSH','Audubon''s Shearwater',NULL,'Puffinus','iherminieri',174561),
	(1,'AWPE','American White Pelican',NULL,'Pelecanus','erythrorhynchos',174684),
	(1,'BAGO','Barrow''s Goldeneye',NULL,'Bucephala','islandica',175144),
	(1,'BASA','Baird''s Sandpiper',NULL,'Calidris','bairdii',176655),
	(1,'BARO','Barolo Shearwater',NULL,'Puffinus','baroli',824117),
	(1,'BBCU','Black-billed Cuckoo',NULL,'Coccyzus','erythropthalmus',177834),
	(1,'BBPL','Black-bellied Plover',NULL,'Pluvialis','squatarola',176567),
	(1,'BBSP','Black-bellied Storm-petrel',NULL,'Fregetta','tropica',174655),
	(1,'BCNH','Black-crowned Night-Heron',NULL,'Nycticorax','nycticorax',174832),
	(1,'BCPE','Black-capped Petrel',NULL,'Pterodroma','hasitata',174567),
	(1,'BEKI','Belted Kingfisher',NULL,'Megaceryle','alcyon',178106),
	(1,'BEPE','Bermuda Petrel',NULL,'Pterodroma','cahow',174568),
	(1,'BFAL','Black-footed Albatross',NULL,'Diomedea','nigripes',174516),
	(1,'BHGU','Common Black-headed Gull',NULL,'Larus','ridibundus',176835),
	(1,'BLGU','Black Guillemot',NULL,'Cepphus','grylle',176985),
	(1,'BLKI','Black-legged Kittiwake',NULL,'Rissa','tridactyla',176875),
	(1,'BLNO','Black Noddy',NULL,'Anous','minutus',176944),
	(1,'BLOY','Black Oystercatcher',NULL,'Haematopus','bachmani',176475),
	(1,'BLSC','Black Scoter',NULL,'Melanitta','nigra',175171),
	(1,'BLSK','Black Skimmer',NULL,'Rynchops','niger',554447),
	(1,'BLSP','Black Storm-petrel',NULL,'Oceanodroma','melania',174640),
	(1,'BLTE','Black Tern',NULL,'Chlidonias','niger',176959),
	(1,'BNST','Black-necked Stilt',NULL,'Himantopus','mexicanus',176726),
	(1,'BOBO','Bobolink',NULL,'Dolichonyx','oryzivorus',179032),
	(1,'BOGU','Bonaparte''s Gull',NULL,'Larus','philadelphia',176839),
	(1,'BOWA','Bohemian Waxwing',NULL,'Bombycilla','garrulus',178529),
	(1,'BRAN','Brant',NULL,'Branta','bernicla',175011),
	(1,'BRBL','Brewer''s Blackbird',NULL,'Euphagus','cyanocephalus',179094),
	(1,'BRBO','Brown Booby',NULL,'Sula','leucogaster',174704),
	(1,'BRCR','Brown Creeper',NULL,'Certhia','americana',178803),
	(1,'BRNO','Brown Noddy',NULL,'Anous','stolidus',176941),
	(1,'BRPE','Brown Pelican',NULL,'Pelecanus','occidentalis',174685),
	(1,'BRSP','Band-rumped Storm-petrel',NULL,'Oceanodroma','castro',174636),
	(1,'BRTE','Bridled Tern',NULL,'Sterna','anaethetus',176897),
	(1,'BRTH','Brown Thrasher',NULL,'Toxostoma','rufum',178627),
	(1,'BTGU','Black-tailed Gull',NULL,'Larus','crassirostris',176831),
	(1,'BTNW','Black-throated Green Warbler',NULL,'Dendroica','virens',178898),
	(1,'BUFF','Bufflehead',NULL,'Bucephala','albeola',175145),
	(1,'BUPE','Bulwer''s Petrel',NULL,'Bulweria','bulweria',554144),
	(1,'BUTE','Unidentified Buteo','Buteo',NULL,NULL,175349),
	(1,'BVSH','Black-vented Shearwater',NULL,'Puffinus','opisthomelas',554396),
	(1,'BWTE','Blue-winged Teal',NULL,'Anas','discors',175086),
	(1,'CAAU','Cassin''s Auklet',NULL,'Ptychoramphus','aleuticus',177013),
	(1,'CACH','Carolina Chickadee',NULL,'Poecile','carolinensis',554383),
	(1,'CAEG','Cattle Egret',NULL,'Bubulcus','ibis',174803),
	(1,'CAGU','California Gull',NULL,'Larus','californicus',176829),
	(1,'CANG','Canada Goose',NULL,'Branta','canadensis',174999),
	(1,'CANV','Canvasback',NULL,'Aythya','valisineria',175129),
	(1,'CATE','Caspian Tern',NULL,'Sterna','caspia',176924),
	(1,'CHAR','Unidentified Charadriiform','Charadriiformes',NULL,NULL,176445),
	(1,'CHSW','Chimney Swift',NULL,'Chaetura','pelagica',178001),
	(1,'CLRA','Clapper Rail',NULL,'Rallus','longirostris',176209),
	(1,'CLSW','Cliff Swallow',NULL,'Petrochelidon','pyrrhonota',178455),
	(1,'COEI','Common Eider',NULL,'Somateria','mollissima',175155),
	(1,'COGA','Common Gallinule',NULL,'Gallinula','galeata',708108),
	(1,'COGO','Common Goldeneye',NULL,'Bucephala','clangula',175141),
	(1,'COLO','Common Loon',NULL,'Gavia','immer',174469),
	(1,'COME','Common Merganser',NULL,'Mergus','merganser',175185),
	(1,'COMO','Common Moorhen',NULL,'Gallinula','chloropus',176284),
	(1,'COMU','Common Murre',NULL,'Uria','aalge',176974),
	(1,'COPE','Cook''s Petrel',NULL,'Pterodroma','cookii',554395),
	(1,'COSH','Cory''s Shearwater',NULL,'Calonectris','diomedea',203446),
	(1,'COSN','Common Snipe',NULL,'Gallinago','gallinago',176700),
	(1,'COTE','Common Tern',NULL,'Sterna','hirundo',176888),
	(1,'COYE','Common Yellowthroat',NULL,'Geothlypis','trichas',178944),
	(1,'CVSH','Cape Verde Shearwater',NULL,'Calonectris','edwardsii',723253),
	(1,'DASC','Unidentified Dark scoter - black or surf',NULL,NULL,NULL,NULL),
	(1,'DCCO','Double-crested Cormorant',NULL,'Phalacrocorax','auritus',174717),
	(1,'DEJU','Dark-eyed Junco',NULL,'Junco','hyemalis',179410),
	(1,'DOVE','Dovekie',NULL,'Alle alle',176982),
	(1,'DOWI','Unidentified Dowitcher spp.','Limnodromus griseus or L. scolopaceus','Limnodromus',NULL,176674),
	(1,'DUNL','Dunlin',NULL,'Calidris','alpina',176661),
	(1,'EAKI','Eastern Kingbird',NULL,'Tyrannus','tyrannus',178279),
	(1,'EAME','Eastern Meadowlark',NULL,'Sturnella','magna',179034),
	(1,'EAPH','Eastern Phoebe',NULL,'Sayornis','phoebe',178329),
	(1,'EASO','Eastern Screech-Owl',NULL,'Megascops','asio',686658),
	(1,'EATO','Eastern Towhee',NULL,'Pipilo','erythrophthalmus',179276),
	(1,'EISC','Unidentified Eider/Scoter spp.','Melanitta/Somateria spp.',NULL,NULL,NULL),
	(1,'EUCD','Eurasian Collared-Dove',NULL,'Streptopelia','decaocto',177139),
	(1,'EUOY','Eurasian Oystercatcher',NULL,'Haematopus','ostralegus',176469),
	(1,'EUSP','European Storm-petrel',NULL,'Hydrobates','pelagicus',174663),
	(1,'EUWI','Eurasian Wigeon',NULL,'Anas','penelope',175092),
	(1,'EVGR','Evening Grosbeak',NULL,'Coccothraustes','vespertinus',179173),
	(1,'FEPE','Fea''s Petrel',NULL,'Pterodroma','feae',562557),
	(1,'FFSH','Flesh-footed Shearwater',NULL,'Puffinus','carneipes',174548),
	(1,'FICR','Fish Crow',NULL,'Corvus','ossifragus',179737),
	(1,'FOTE','Forster''s Tern',NULL,'Sterna','forsteri',176887),
	(1,'FRGU','Franklin''s Gull',NULL,'Larus','pipixcan',176838),
	(1,'FTSP','Fork-tailed Storm-petrel',NULL,'Oceanodroma','furcata',174625),
	(1,'GADW','Gadwall',NULL,'Anas','strepera',175073),
	(1,'GBBG','Great Black-backed Gull',NULL,'Larus','marinus',176815),
	(1,'GBHE','Great Blue Heron',NULL,'Ardea','herodias',174773),
	(1,'GBHG','Unidentified Great Black-backed/Herring Gull','Larus marinus/argentatus',NULL,NULL,NULL),
	(1,'GBTE','Gull-billed Tern',NULL,'Sterna','nilotica',176926),
	(1,'GCKI','Golden-crowned Kinglet',NULL,'Regulus','satrapa',179865),
	(1,'GHGH','Glaucous Gull X Herring Gull (hybrid)','Larus hyperboreus X argentatus',NULL,NULL,NULL),
	(1,'GLGU','Glaucous Gull',NULL,'Larus','hyperboreus',176808),
	(1,'GLIB','Glossy Ibis',NULL,'Plegadis','falcinellus',174924),
	(1,'GOME','Unidentified Goldeneye or Merganser',NULL,NULL,NULL,NULL),
	(1,'GRAJ','Gray Jay',NULL,'Perisoreus','canadensis',179667),
	(1,'GRAK','Gray Kingbird',NULL,'Tyrannus','dominicensis',178280),
	(1,'GRCO','Great Cormorant',NULL,'Phalacrocorax','carbo',174715),
	(1,'GREG','Great Egret',NULL,'Ardea','alba',554135),
	(1,'GRFR','Great Frigatebird',NULL,'Fregata','minor',174766),
	(1,'GRHE','Green Heron',NULL,'Butorides','virescens',174793),
	(1,'GRSC','Greater Scaup',NULL,'Aythya','marila',175130),
	(1,'GRSH','Greater Shearwater',NULL,'Puffinus','gravis',174549),
	(1,'GRSK','Great Skua',NULL,'Stercorarius','skua',660059),
	(1,'GRYE','Greater Yellowlegs',NULL,'Tringa','melanoleuca',176619),
	(1,'GUTE','Unidentified Small Gull/Tern',NULL,NULL,NULL,NULL),
	(1,'GWFG','Greater White-fronted Goose',NULL,'Anser','albifrons',175020),
	(1,'GWGU','Glaucous-winged Gull',NULL,'Larus','glaucescens',176814),
	(1,'GWTE','Green-winged Teal',NULL,'Anas','crecca',175081),
	(1,'HADU','Harlequin Duck',NULL,'Histrionicus','histrionicus',175149),
	(1,'HAPE','Hawaiian Petrel',NULL,'Pterodroma','sandwichensis',562561),
	(1,'HEPE','Herald Petrel',NULL,'Pterodroma','arminjoniana',174570),
	(1,'HERG','Herring Gull',NULL,'Larus','argentatus',176824),
	(1,'HOGR','Horned Grebe',NULL,'Podiceps','auritus',174482),
	(1,'HOME','Hooded Merganser',NULL,'Lophodytes','cucullatus',175183),
	(1,'HUGO','Hudsonian Godwit',NULL,'Limosa','haemastica',176690),
	(1,'ICGU','Iceland Gull',NULL,'Larus','glaucoides',176811),
	(1,'INBU','Indigo Bunting',NULL,'Passerina','cyanea',179150),
	(1,'IVGU','Ivory Gull',NULL,'Pagophila','eburnea',176851),
	(1,'JFPE','Juan Fernandez Petrel',NULL,'Pterodroma','externa externa',174575),
	(1,'JUNC','Unidentified junco',NULL,NULL,NULL,179409),
	(1,'KIEI','King Eider',NULL,'Somateria','spectabilis',175160),
	(1,'KILL','Killdeer',NULL,'Charadrius','vociferus',176520),
	(1,'KIRA','King Rail',NULL,'Rallus','elegans',176207),
	(1,'KUGU','Kumlien''s Gull',NULL,'Larus','glaucoides kumlieni',176813),
	(1,'LAGU','Laughing Gull',NULL,'Larus','atricilla',176837),
	(1,'LALO','Lapland Longspur',NULL,'Calcarius','lapponicus',179526),
	(1,'LBBG','Lesser Black-backed Gull',NULL,'Larus','fuscus',176821),
	(1,'LBDO','Long-billed Dowitcher',NULL,'Limnodromus','scolopaceus',176679),
	(1,'LBHE','Little Blue Heron',NULL,'Egretta','caerulea',174827),
	(1,'LEAS','Least Storm-petrel',NULL,'Oceanodroma','microsoma',174646),
	(1,'LENO','Lesser Noddy',NULL,'Anous','tenuirostris',176943),
	(1,'LESA','Least Sandpiper',NULL,'Calidris','minutilla',176656),
	(1,'LESC','Lesser Scaup',NULL,'Aythya','affinis',175134),
	(1,'LESP','Leach''s Storm-petrel',NULL,'Oceanodroma','leucorhoa',174628),
	(1,'LETE','Least Tern',NULL,'Sterna','antillarum',176923),
	(1,'LEYE','Lesser Yellowlegs',NULL,'Tringa','flavipes',176620),
	(1,'LIGU','Little Gull',NULL,'Larus','minutus',176840),
	(1,'LISH','Little Shearwater',NULL,'Puffinus','assimilis',174559),
	(1,'LISP','Lincoln''s Sparrow',NULL,'Melospiza','lincolnii',179484),
	(1,'LITE','Little Tern',NULL,'Sternula','albifrons',824124),
	(1,'LONG','Unidentified Longspur','Calcarius spp.','Calcarius',NULL,179524),
	(1,'LOSH','Loggerhead Shrike',NULL,'Lanius','ludovicianus',178515),
	(1,'LSGB','Lesser Snow Goose', 'Blue Phase','Chen','caerulescens',175038),
	(1,'LSGW','Lesser Snow Goose', 'White phase','Chen','caerulescens',175038),
	(1,'LTDU','Long-tailed Duck',NULL,'Clangula','hyemalis',175147),
	(1,'LTJA','Long-tailed Jaeger',NULL,'Stercorarius','longicaudus',176794),
	(1,'MABO','Masked Booby',NULL,'Sula','dactylatra',174699),
	(1,'MAFR','Magnificent Frigatebird',NULL,'Fregata','magnificens',174763),
	(1,'MAGO','Marbled Godwit',NULL,'Limosa','fedoa',176686),
	(1,'MALL','Mallard',NULL,'Anas','platyrhynchos',175063),
	(1,'MASH','Manx Shearwater',NULL,'Puffinus','puffinus',174555),
	(1,'MEAD','Unidentified Meadowlark','Sturnella spp.','Sturnella',NULL,179033),
	(1,'MEGU','Mew Gull',NULL,'Larus','canus',176832),
	(1,'MERL','Merlin',NULL,'Falco','columbarius',175613),
	(1,'MOPL','Mountain Plover',NULL,'Charadrius','montanus',176522),
	(1,'NOBO','Northern Bobwhite',NULL,'Colinus','virginianus',175863),
	(1,'NOFL','Northern Flicker',NULL,'Colaptes','auratus',178154),
	(1,'NOFU','Northern Fulmar',NULL,'Fulmarus','glacialis',174536),
	(1,'NOGA','Northern Gannet',NULL,'Morus','bassanus',174712),
	(1,'NOPI','Northern Pintail',NULL,'Anas','acuta',175074),
	(1,'NOTE','Unidentified Noddy Tern',NULL,NULL,NULL,NULL),
	(1,'NSHO','Northern Shoveler',NULL,'Anas','clypeata',175096),
	(1,'OSPR','Osprey',NULL,'Pandion','haliaetus',175590),
	(1,'PAJA','Parasitic Jaeger',NULL,'Stercorarius','parasiticus',176793),
	(1,'PALO','Pacific Loon',NULL,'Gavia','pacifica',174475),
	(1,'PBGR','Pied-billed Grebe',NULL,'Podilymbus','podiceps',174505),
	(1,'PECO','Pelagic Cormorant',NULL,'Phalacrocorax','pelagicus',174725),
	(1,'PELI','Unidentified Pelican','Pelecanus spp.','Pelecanus',NULL,NULL),
	(1,'PESA','Pectoral Sandpiper',NULL,'Calidris','melanotos',176653),
	(1,'PFSH','Pink-footed Shearwater',NULL,'Puffinus','creatopus',174547),
	(1,'PIPL','Piping Plover',NULL,'Charadrius','melodus',NULL),
	(1,'POJA','Pomarine Jaeger',NULL,'Stercorarius','pomarinus',176792),
	(1,'POSP','Polynesian Storm-petrel',NULL,'Nesofregetta','fuliginosa',174661),
	(1,'PUSA','Purple Sandpiper',NULL,'Calidris','maritima',176646),
	(1,'RAZO','Razorbill',NULL,'Alca','torda',176971),
	(1,'RBGU','Ring-billed Gull',NULL,'Larus','delawarensis',176830),
	(1,'RBME','Red-breasted Merganser',NULL,'Mergus','serrator',175187),
	(1,'RBTR','Red-billed Tropicbird',NULL,'Phaethon','aethereus',174673),
	(1,'RCKI','Ruby-crowned Kinglet',NULL,'Regulus','calendula',179870),
	(1,'RECR','Red Crossbill',NULL,'Loxia','curvirostra',179259),
	(1,'REDH','Redhead',NULL,'Aythya','americana',175125),
	(1,'REDP','Common or Hoary Redpoll','Carduelis flammea/hornemanni',NULL,NULL,NULL),
	(1,'REEG','Reddish Egret',NULL,'Egretta','rufescens',174824),
	(1,'REKN','Red Knot',NULL,'Calidris','canutus',176642),
	(1,'REPH','Red Phalarope',NULL,'Phalaropus','fulicaria',554376),
	(1,'RFBO','Red-footed Booby',NULL,'Sula','sula',174707),
	(1,'RHAU','Rhinoceros Auklet',NULL,'Cerorhinca','monocerata',177023),
	(1,'RNDU','Ring-necked Duck',NULL,'Aythya','collaris',175128),
	(1,'RNGR','Red-necked Grebe',NULL,'Podiceps','grisegena',174479),
	(1,'RNPH','Red-necked Phalarope',NULL,'Phalaropus','lobatus',176735),
	(1,'ROSP','Roseate Spoonbill',NULL,'Platalea','ajaja',174941),
	(1,'ROST','Roseate Tern',NULL,'Sterna','dougallii',176891),
	(1,'ROSW','Rough-Winged Swallow',NULL,'Stelgidopteryx',NULL,178439),
	(1,'ROYT','Royal Tern',NULL,'Sterna','maxima',176922),
	(1,'RTLO','Red-throated Loon',NULL,'Gavia','stellata',174474),
	(1,'RTTR','Red-tailed Tropicbird',NULL,'Phaethon','rubricauda',174679),
	(1,'RUBL','Rusty Blackbird',NULL,'Euphagus','carolinus',179091),
	(1,'RUDU','Ruddy Duck',NULL,'Oxyura','jamaicensis',175175),
	(1,'RUTU','Ruddy Turnstone',NULL,'Arenaria','interpres',176571),
	(1,'RWBL','Red-winged Blackbird',NULL,'Agelaius','phoeniceus',179045),
	(1,'SACR','Sandhill Crane',NULL,'Grus','canadensis',176177),
	(1,'SAGU','Sabine''s Gull',NULL,'Xema','sabini',176866),
	(1,'SAND','Sanderling',NULL,'Calidris','alba',176669),
	(1,'SATE','Sandwich Tern',NULL,'Sterna','sandvicensis',176927),
	(1,'SBDO','Short-billed Dowitcher',NULL,'Limnodromus','griseus',176675),
	(1,'SBGU','Slaty-backed Gull',NULL,'Larus','schistisagus',176816),
	(1,'SCAU','Unidentified Scaup','Aythya marila or A. affinis',NULL,NULL,NULL),
	(1,'SEOW','Short-eared Owl',NULL,'Asio','flammeus',177935),
	(1,'SEPL','Semipalmated Plover',NULL,'Charadrius','semipalmatus',176506),
	(1,'SESA','Semipalmated Sandpiper',NULL,'Calidris','pusilla',176667),
	(1,'SHAG','Shag',NULL,'Phalacrocorax','aristotelis',174733),
	(1,'SHOR','Unidentified shorebird',NULL,NULL,NULL,NULL),
	(1,'SNBU','Snow Bunting',NULL,'Plectrophenax','nivalis',179532),
	(1,'SNEG','Snowy Egret',NULL,'Egretta','thula',174813),
	(1,'SNGO','Snow Goose',NULL,'Chen','caerulescens',175038),
	(1,'SNOW','Snowy Owl',NULL,'Bubo','scandiacus',686683),
	(1,'SOGU','Sooty Gull',NULL,'Larus','hemprichii',176854),
	(1,'SORA','Sora',NULL,'Porzana','carolina',176242),
	(1,'SOSA','Solitary Sandpiper',NULL,'Tringa','solitaria',176615),
	(1,'SOSH','Sooty Shearwater',NULL,'Puffinus','griseus',174553),
	(1,'SOTE','Sooty Tern',NULL,'Sterna','fuscata',176894),
	(1,'SPEI','Spectacled Eider',NULL,'Somateria','fischeri',175161),
	(1,'SPGR','Spruce Grouse',NULL,'Falcipennis','canadensis',553896),
	(1,'SPGU','Spectacled Guillemot',NULL,'Cepphus','carbo',176994),
	(1,'SPPI','Sprague''s Pipit',NULL,'Anthus','spragueii',178499),
	(1,'SPSA','Spotted Sandpiper',NULL,'Actitis','macularia',176612),
	(1,'SPSK','South Polar Skua',NULL,'Stercorarius','maccormicki',660062),
	(1,'STEI','Steller''s Eider',NULL,'Polysticta','stelleri',175153),
	(1,'STSA','Stilt Sandpiper',NULL,'Calidris','himantopus',554145),
	(1,'STSH','Short-tailed Shearwater',NULL,'Puffinus','tenuirostris',174554),
	(1,'SUSC','Surf Scoter',NULL,'Melanitta','perspicillata',175170),
	(1,'SWAN','Unidentified Swan','Olor spp.','Olor',NULL,174993),
	(1,'SWIS','Swinhoe''s Storm-petrel',NULL,'Oceanodroma','monorhis',174642),
	(1,'TAPE','Tahiti Petrel',NULL,'Pseudobulweria','rostrata',562522),
	(1,'TBMU','Thick-billed Murre',NULL,'Uria','lomvia',176978),
	(1,'THGU','Thayer''s Gull',NULL,'Larus','thayeri',176828),
	(1,'TOSH','Townsend''s Shearwater',NULL,'Puffinus','auricularis',174558),
	(1,'TRHE','Tricolored (Louisiana) Heron',NULL,'Egretta','tricolor',NULL),
	(1,'TRSP','Tristram''s Storm-Petrel',NULL,'Oceanodroma','tristrami',174641),
	(1,'TUPU','Tufted Puffin',NULL,'Fratercula','cirrhata',177032),
	(1,'TUSW','Tundra Swan',NULL,'Cygnus','columbianus',174987),
	(1,'UALB','Unidentified Albatross','Diomedeidae spp.','Diomedeidae',NULL,174513),
	(1,'UBBG','Unidentified Great or Lesser Black-backed Gull','Larus marinus/fuscus',NULL,NULL,NULL),
	(1,'UBST','Bridled or Sooty Tern','Sterna anaethetus/fuscata',NULL,NULL,NULL),
	(1,'UCAT','Common or Arctic Tern','Sterna hirundo/paradisaea',NULL,NULL,NULL),
	(1,'UCRT','Unidentified Common or Roseate Tern','Sterna hirundo/dougallii',NULL,NULL,NULL,),--includes CRTE (same meaning) which was removed
	(1,'UDAB','Unidentified dabbling duck','Anas spp.','Anas',NULL,NULL),
	(1,'UDGS','Unidentified Duck, Goose, or Swan','Anseriformes spp.',NULL,NULL,174982),
	(1,'UGOO','Unidentified Goose',NULL,NULL,NULL,NULL),
	(1,'UGUI','Unidentified Guillemot','Cepphus spp.','Cepphus',NULL,176984),
	(1,'UHGP','Unidentified Hawaiian Petrel or Galapagos Petrel','Pterodroma sandwichensis/phaeopygia',NULL,NULL,NULL),
	(1,'ULSB','Unidentified large shorebird',NULL,NULL,NULL,NULL),
	(1,'UNAL','Unidentified Alcid','Alcidae spp.',NULL,NULL,176967),
	(1,'UNAM','Unidentified Seaside or Sharptailed Sparrow','Ammodramus spp.','Ammodramus',NULL,179332),
	(1,'UNBI','Unidentified Bird','Aves',NULL,NULL,174371),
	(1,'UNBL','Unidentified Blackbird','Icteridae spp.',NULL,NULL,179030),
	(1,'UNBO','Unidentified Booby','Sula spp.','Sula',NULL,174697),
	(1,'UNCA','Unidentified Calidris (Sandpiper, Sanderling, Dunlin, Red Knot)','Calidris spp.','Calidris',NULL,NULL),
	(1,'UNCO','Unidentified Cormorant','Phalacrocorax spp','Phalacrocorax',NULL,174714),
	(1,'UNDD','Unidentified Diving/Sea Duck','Aythya spp.','Aythya',NULL,175124),
	(1,'UNDU','Unidentified Duck','Anatidae',NULL,NULL,NULL),
	(1,'UNEG','Unidentified Egret',NULL,NULL,NULL,NULL),
	(1,'UNEI','Unidentified Eider','Somateria spp.','Somateria',NULL,175154),
	(1,'UNFI','Unidentified Finch','Carduelis spp.','Carduelis',NULL,179225),
	(1,'UNFR','Unidentified Frigatebird','Fregata spp.','Fregata',NULL,174762),
	(1,'UNGB','Unidentified Goldeneye/Bufflehead','Bucephala spp.','Bucephala',NULL,175140),
	(1,'UNGO','Unidentified Goldeneye','Bucephala spp.','Bucephala',NULL,175140),
	(1,'UNGR','Unidentified Grebe','Podiceps spp.','Podiceps',NULL,174478),
	(1,'UNGU','Unidentified Gull',NULL,NULL,NULL,NULL),
	(1,'UNHE','Unidentified Heron',NULL,NULL,NULL,NULL),
	(1,'UNJA','Unidentified Jaeger','Stercorarius spp.','Stercorarius',NULL,176791),
	(1,'UNLA','Unidentified large alcid (Razorbill or Murre)',NULL,NULL,NULL,NULL),
	(1,'UNLG','Unidentified Large Gull',NULL,NULL,NULL,NULL),
	(1,'UNLO','Unidentified Loon','Gavia spp.','Gavia',NULL,174468),
	(1,'UNLR','Unidentified large rail','Rallidae',NULL,NULL,176205),
	(1,'UNLS','Unidentified Large Shearwater',NULL,NULL,NULL,NULL),
	(1,'UNLT','Unidentified large Tern',NULL,NULL,NULL,NULL),
	(1,'UNME','Unidentified Merganser',NULL,NULL,NULL,NULL),
	(1,'UNMT','Unidentified medium tern',NULL,NULL,NULL,NULL),
	(1,'UNMU','Unidentified Murre','Uria spp.','Uria',NULL,176973),
	(1,'UNNH','Unidentified Night Heron',NULL,NULL,NULL,NULL),
	(1,'UNPA','Unidentified Passerine (perching birds, songbirds)',NULL,NULL,NULL,NULL),
	(1,'UNPE','Unidentified Petrel','Procellariidae',NULL,NULL,174532),
	(1,'UNPH','Unidentified Phalarope','Phalaropus spp.','Phalaropus',NULL,176733),
	(1,'UNPR','Unidentified tubenose','Procellariidae',NULL,NULL,174532),
	(1,'UNPT','Unidentified Pterodroma (petrels)','Pterodroma spp.','Pterodroma',NULL,174566),
	(1,'UNPU','Unidentified Puffin','Fratercula spp.','Fratercula',NULL,177024),
	(1,'UNRP','Unidentified Raptor/ bird of prey',NULL,NULL,NULL,NULL),
	(1,'UNSA','Unidentified small alcid (Puffin/Dovekie)','Alle alle/Fratercula arctica',NULL,NULL,NULL),
	(1,'UNSC','Unidentified Scoter','Melanitta spp.','Melanitta',NULL,175162),
	(1,'UNSG','Unidentified small gull',NULL,NULL,NULL,NULL),
	(1,'UNSH','Unidentified Shearwater','Procellariidae',NULL,NULL,174532),
	(1,'UNSK','Unidentified Skua','Stercorarius spp.','Stercorarius',NULL,176791),
	(1,'UNSP','Unidentified Storm-petrel',NULL,NULL,NULL,NULL),
	(1,'UNSS','Unidentified Small Shearwater (Audubon''s, Manx, or Little)','Puffinus lherminieri , P. puffinus, or P. assimilis','Puffinus',NULL,NULL),
	(1,'UNST','Unidentified small Tern',NULL,NULL,NULL,NULL),
	(1,'UNSU','Unidentified Sulid','Sulidae spp.',NULL,NULL,174696),
	(1,'UNTA','Unidentified Tanager',NULL,NULL,NULL,NULL),
	(1,'UNTB','Unidentified Tropicbird','Phaethon spp.','Phaethon',NULL,174672),
	(1,'UNTE','Unidentified Tern',NULL,NULL,NULL,NULL),
	(1,'UNTH','Unidentified Thrush','Turdidae spp.',NULL,NULL,179751),
	(1,'UNTL','Unidentified Teal',NULL,NULL,NULL,NULL),
	(1,'UNYE','Unidentified Yellowlegs','Tringa melanoleuca or T. flavipes','Tringa',NULL,NULL),
	(1,'USAC','Unidentified small Accipiter',NULL,NULL,NULL,NULL),
	(1,'USAN','Unidentified Sandpiper','Scolopacidae spp.',NULL,NULL,176568),
	(1,'USSB','Unidentified small shorebird',NULL,NULL,NULL,NULL),
	(1,'VIRA','Virginia Rail',NULL,'Rallus','limicola',176221),
	(1,'WBSP','White-bellied Storm-petrel',NULL,'Fregetta','grallaria',174656),
	(1,'WCTE','White-cheeked Tern',NULL,'Sterna','repressa',176914),
	(1,'WEGU','Western Gull',NULL,'Larus','occidentalis',176817),
	(1,'WESA','Western Sandpiper',NULL,'Calidris','mauri',176668),
	(1,'WFSP','White-faced Storm-petrel',NULL,'Pelagodroma','marina',174621),
	(1,'WHIB','White Ibis',NULL,'Eudocimus','albus',174930),
	(1,'WHIM','Whimbrel',NULL,'Numenius','phaeopus',176599),
	(1,'WHTE','White Tern',NULL,'Gygis','alba',176954),
	(1,'WILL','Willet',NULL,'Catoptrophorus','semipalmatus',176638),
	(1,'WIPH','Wilson''s phalarope',NULL,'Phalaropus','tricolor',176736),
	(1,'WIPL','Wilson''s Plover',NULL,'Charadrius','wilsonia',176517),
	(1,'WISN','Wilson''s Snipe',NULL,'Gallinago','delicata',726048),
	(1,'WISP','Wilson''s Storm-petrel',NULL,'Oceanites','oceanicus',174650),
	(1,'WIWA','Wilson''s Warbler',NULL,'Wilsonia','pusilla',178973),
	(1,'WIWR','Winter Wren',NULL,'Troglodytes','troglodytes',178547),
	(1,'WODU','Wood Duck',NULL,'Aix','sponsa',175122),
	(1,'WOTH','Wood Thrush',NULL,'Hylocichla','mustelina',179777),
	(1,'WRSA','White-rumped Sandpiper',NULL,'Calidris','fuscicollis',176654),
	(1,'WRSP','Wedge-rumped Storm-petrel',NULL,'Oceanodroma','tethys',174638),
	(1,'WTSH','Wedge-tailed Shearwater',NULL,'Puffinus','pacificus',174550),
	(1,'WTTR','White-tailed Tropicbird',NULL,'Phaethon','lepturus',174676),
	(1,'WWBT','White-winged Black Tern',NULL,'Chlidonias','leucopterus',176958),
	(1,'WWCR','White-winged Crossbill',NULL,'Loxia','leucoptera',179268),
	(1,'WWGU','Unidentified white winged gull (Ross''s Gull, Ivory Gull, Iceland Gull, Glaucous-winged Gull and Glaucous Gull)',NULL,'Larus',NULL,NULL),
	(1,'WWSC','White-winged Scoter',NULL,'Melanitta','fusca',175163),
	(1,'XAMU','Xantus'' Murrelet',NULL,'Synthliboramphus','hypoleucus',177011),
	(1,'YCNH','Yellow-crowned Night Heron',NULL,'Nyctanassa','violacea',174842),
	(1,'YESH','Yelkouan Shearwater',NULL,'Puffinus','yelkouan',562599),
	(1,'YHBL','Yellow-headed Blackbird',NULL,'Xanthocephalus','xanthocephalus',179043),
	(1,'YLGU','Yellow-legged Gull',NULL,'Larus','cachinnans',554270),
	(1,'YNAL','Yellow-nosed Albatross',NULL,'Thalassarche','chlororhynchos',554452),
	
	(2,'ASDO','Atlantic Spotted Dolphin',NULL,'Stenella','frontalis',552460),
	(2,'BBWH','Blainville''s Beaked Whale',NULL,'Mesoplodon','densirstris',NULL),
 	(2,'BESE','Bearded Seal',NULL,'Erignathus','barbatus',180655),
 	(2,'BLWH','Blue Whale',NULL,'Balaenoptera','musculus',180528),
 	(2,'BODO','Bottlenose Dolphin',NULL,'Tursiops','truncatus',180426),
 	(2,'BRDO','Bridled Dolphin','Stenella attenuata/ frontalis','Stenella',NULL,NULL),
 	(2,'CBWH','Cuvier''s Beaked Whale',NULL,'Ziphius','cavirostris',180498),
 	(2,'CLDO','Clymene Dolphin',NULL,'Stenella','clymene',180435),
 	(2,'CODO','Common Dolphin',NULL,'Delphinus','delphis',180438),
 	(2,'DPSW','Unidentified Dwarf/Pygmy Sperm Whale','Kogia simus or K. breviceps','Kogia',NULL,180490),
 	(2,'DSWH','Dwarf Sperm Whale',NULL,'Kogia','sima',180492),
 	(2,'FIWH','Fin Whale',NULL,'Balaenoptera','physalus',180527),
 	(2,'FKWH','False Killer Whale',NULL,'Pseudorca','crassidens',180463),
 	(2,'FRDO','Fraser''s Dolphin',NULL,'Lagenodelphis','hosei',180440),
 	(2,'GBWH','Gervais'' Beaked Whale',NULL,'Mesoplodon','europaeus',NULL),
 	(2,'GRSE','Gray Seal',NULL,'Halichoerus','grypus',180653),
 	(2,'HAPO','Harbor Porpoise',NULL,'Phocoena','phocoena',180473),
 	(2,'HASE','Harbor Seal',NULL,'Phoca','vitulina',180649),
 	(2,'HOSE','Hooded Seal',NULL,'Cystophora','cristata',180657),
 	(2,'HRPS','Harp Seal',NULL,'Pagophilus','groenlandicus',622022),
 	(2,'HUWH','Humpback Whale',NULL,'Megaptera','novaeangliae',180530),
 	(2,'KIWH','Killer Whale',NULL,'Orcinus','orca',180469),
 	(2,'LFPW','Long-finned Pilot Whale',NULL,'Globicephala','melas',552461),
 	(2,'LSSD','Long-snouted Spinner Dolphin',NULL,'Stenella','longirostris',180429),
 	(2,'MHDO','Melon-headed Whale',NULL,'Peponocephala','electra',180459),
 	(2,'MIWH','Minke Whale',NULL,'Balaenoptera','acutorostrata',180524),
 	(2,'NABW','North Atlantic Bottle-nosed whale',NULL,'Hyperoodon','ampullatus',180504),
 	(2,'PIWH','Pilot Whale',NULL,'Globicephala',NULL,180464),
 	(2,'PKWH','Pygmy Killer Whale',NULL,'Feresa','attenuata',180460),
 	(2,'PSDO','Pantropical Spotted Dolphin',NULL,'Stenella','attenuata',180430),
 	(2,'PSWH','Pygmy Sperm Whale',NULL,'Kogia','breviceps',180491),
 	(2,'RIDO','Risso''s dolphin',NULL,'Grampus','griseus',180457),
 	(2,'RISE','Ringed Seal',NULL,'Pusa','hispida',622018),
 	(2,'RIWH','Right Whale',NULL,'Eubalaena','glacialis',180537),
 	(2,'RTDO','Rough-toothed Dolphin',NULL,'Steno','bredanensis',180417),
 	(2,'SBWH','Sowerby''s Beaked Whale',NULL,'Mesoplodon','bidens',180515),
 	(2,'SEWH','Sei Whale',NULL,'Balaenoptera','borealis',180526),
 	(2,'SFWH','Short-finned Pilot Whale',NULL,'Globicephala macrorhynchus',180466),
 	(2,'SPDO','Unidentified Spotted Dolphins (Atlantic or Pantropical)','Stenella',NULL,180428),
 	(2,'SPWH','Sperm Whale',NULL,'Physeter','macrocephalus',180489),
 	(2,'STDO','Striped Dolphin',NULL,'Stenella','coeruleoalba',180434),
 	(2,'TBWH','True''s Beaked Whale',NULL,'Mesoplodon','mirus',NULL),
 	(2,'UBKW','Unidentified Beaked Whale','Mesoplodon spp.',NULL,NULL,180506),
 	(2,'UNBW','Unidentified Baleen Whale','Mysticeti spp.',NULL,NULL,552298),
 	(2,'UNCD','Unidentified Common Dolphins','Delphinus spp.',NULL,NULL,180437),
 	(2,'UNCE','Unidentified Cetacean','Cetacea spp.',NULL,NULL,180403),
 	(2,'UNDO','Unidentified Dolphin','Delphinidae',NULL,NULL,180415),
 	(2,'UNFS','Unidentified Fin/Sei whale','Balaenoptera physalus/B. borealis','Balaenoptera',NULL,NULL),
 	(2,'UNGD','Unidentified Spotted or Bottlenose Dolphin','Stenella or Tursiops',NULL,NULL,NULL),
 	(2,'UNLD','Unidentified Lagenorhynchus dolphin','Lagenorhynchus sp.',NULL,NULL,NULL),
 	(2,'UNLW','Unidentified large whale','Cetacea spp.',NULL,NULL,180403),
 	(2,'UNMM','Unidentified Marine Mammal','Mammalia',NULL,NULL,179913),
 	(2,'UNPO','Unidentified porpoise',NULL,NULL,NULL,NULL),
 	(2,'UNRO','Unidentified Rorqual','Balaenopteridae spp.',NULL,NULL,180522),
 	(2,'UNSE','Unidentified Seal','Phocidae',NULL,NULL,180640),-- includes UNI,UNPD for unidentified pinniped which was removed
 	(2,'UNSW','Unidentified small whale','Cetacea spp.',NULL,NULL,180403),
 	(2,'UNTW','Unidentified Toothed Whales','Odontoceti spp.',NULL,NULL,180404),
 	(2,'UNWH','Unidentified Whale','Cetacea spp.',NULL,NULL,180403),
 	(2,'UNZI','Unidentified Ziphiid (beaked whale)','Ziphiidae',NULL,NULL,180493),
 	(2,'UTSE','Unidentified True Seal','Phocidae spp.',NULL,NULL,180640),
 	(2,'WALR','Walrus',NULL,'Odobenus','rosmarus',180639),
 	(2,'WBDO','White-beaked Dolphin',NULL,'Lagenorhynchus','albirostris',180442),
	(2,'WIMA','West Indian Manatee',NULL,'Trichechus','manatus',180684),
	(2,'WSDO','Atlantic White-sided Dolphin',NULL,'Lagenorhynchus','acutus',180443),

	(3,'GRTU','Green Turtle',NULL,'Chelonia','mydas',173833),
	(3,'HATU','Hawksbill Turtle',NULL,'Eretmochelys','imbricata',173837),
	(3,'KRST','Kemp''s Ridley Sea Turtle',NULL,'Lepidochelys','kempii',551770),
	(3,'LETU','Leatherback Turtle',NULL,'Dermochelys','coriacea',173843),
	(3,'LOTU','Loggerhead Turtle',NULL,'Caretta','caretta',173830),
	(3,'SMTU','Unidentified Small turtle - Loggerhead, Green, Hawksbill, or Kemp''s Ridley',NULL,NULL,NULL,NULL),
	(3,'TURT','Unidentified Sea Turtle',NULL,NULL,NULL,NULL),
	(3,'UNCH','Unidentified Cheloniidae species (Green Sea Turtle, Hawksbill Sea Turtle, and Flatback Sea Turtle)','Cheloniidae spp.',NULL,NULL,NULL),

	(4,'ALTU','Albacore Tuna',NULL,'Thunnus','alalunga',172419),
	(4,'BASH','Basking Shark',NULL,'Cetorhinus','maximus',159907),
	(4,'BFTU','Atlantic Bluefin Tuna',NULL,'Thunnus','thynnus',172421),
	(4,'BIFI','Billfishes','Istiophoridae spp.',NULL,NULL,172486),
	(4,'BLAT','Blackfin Tuna',NULL,'Thunnus','atlanticus',172427),
	(4,'BLMA','Blue Marlin',NULL,'Makaira','nigricans',172491),
	(4,'BLSH','Blue Shark',NULL,'Prionace','glauca',160424),
	(4,'BLUE','Bluefish',NULL,'Pomatomus','saltatrix',168559),
	(4,'BONI','Bonito',NULL,'Scombridae','spp.',172398),
	(4,'CNRA','Cownose Ray',NULL,'Rhinoptera','bonasus',160985),
	(4,'FAAL','False Albacore',NULL,'Euthynnus','alletteratus',172402),
	(4,'FISH','Unidentified fish','Osteichthyes',NULL,NULL,161030),
	(4,'GOMR','Giant Oceanic Manta Ray',NULL,'Manta','birostris',160992),
	(4,'GWSH','Great White Shark',NULL,'Carcharodon','carcharias',159903),
	(4,'HASH','Hammerhead shark','Sphyrnidae spp.',NULL,NULL,160497),
	(4,'KIMA','King Mackerel',NULL,'Scomberomorus','cavalla',172435),
	(4,'MAKO','Unidentified Long-finned/Short-finned Mako Shark','Isurus spp.',NULL,NULL,159923),
	(4,'MAMA','Dolphin fish (Mahi-Mahi)',NULL,'Coryphaena','hippurus',168791),
	(4,'MARA','Unidentified Manta Ray','Mobulidae',NULL,NULL,160990),
	(4,'MOLA','Ocean Sunfish (Mola)',NULL,'Mola','mola',173414),
	(4,'OWTS','Oceanic Whitetip Shark (aka. Brown shark, brown Milbert''s sand bar shark, nigano shark, silvertip shark)','Carcharhinus','longimanus',160330),
	(4,'SAFI','Sargassumfish',NULL,'Histrio','histrio',164520),
	(4,'SAIL','Sailfish',NULL,'Istiophorus','platypterus',172488),
	(4,'SCHA','Scalloped Hammerhead Shark',NULL,'Sphyrna','lewini',160508),
	(4,'SHAR','Unidentified shark','Elasmobranchii spp.',NULL,NULL,159786),
	(4,'SKTU','Skipjack Tuna',NULL,'Katsuwonus','pelamis',172401),
	(4,'SPMA','Spanish mackerels','Scomberomorus spp.',NULL,NULL,172434),
	(4,'SWFI','Unidentified Swordfish spp.','Xiphiidae spp.',NULL,NULL,172480),
	(4,'THHE','Thread Herrings','Opisthonema spp.',NULL,NULL,161747),
	(4,'TUNA','Unidentified tuna','Scombridae',NULL,NULL,172398),
	(4,'UFFI','Unidentified flying fish','Exocoetidae spp.',NULL,NULL,165431),
	(4,'UNEL','Unidentified elasmobranch (Shark, Ray, Skate)','Elasmobranch',NULL,NULL,NULL),
	(4,'UNLF','Unidentified large fish','Osteichthyes spp.',NULL,NULL,161030),
	(4,'UNRA','Unidentified ray','Rajiformes spp.',NULL,NULL,160806),
	(4,'UNSF','Unidentified small fish','Osteichthyes spp.',NULL,NULL,161030),
	(4,'UNSR','Unidentified stringray','Dasyatidae spp.',NULL,NULL,NULL),
	(4,'UNTS','Unidentified thresher shark',NULL,NULL,NULL,NULL),
	(4,'WAHO','Wahoo',NULL,'Acanthocybium','solandri',172451),
	(4,'WHMA','White Marlin',NULL,'Kajikia','albida',768126),
	(4,'YETU','Yellowfin Tuna',NULL,'Thunnus','albacares',172423),
	(4,'BAIT','bait ball',NULL,NULL,NULL,NULL),
	(4,'CAJE','Cannonball Jelly',NULL,'Stomolophus','meleagris',51926),
	(4,'HOCR','Atlantic Horseshoe Crab',NULL,'Limulus','polyphemus',82703),
	(4,'MOON','Moon Jellyfish',NULL,'Aurelia','aurita',51701),
	(4,'PMOW','Portuguese Man o'' War',NULL,'Physalia','physalis',719181),
	(4,'UNJE','Unidentified jellyfish','Scyphozoa spp.',NULL,NULL,51483),

	(5,'ALGA','Algal bloom',NULL,NULL,NULL,NULL),
	(5,'ANTE','Antennae',NULL,NULL,NULL,NULL),
	(5,'BALN','balloon',NULL,NULL,NULL,NULL),
	(5,'BUOY','buoy',NULL,NULL,NULL,NULL),
	(5,'CHAN','Change in personnel, station, transect, etc.',NULL,NULL,NULL,NULL),
	(5,'CLSU','Cloudless Sulphur',NULL,'Phoebis','sennae',777750),
	(5,'ERRO','error',NULL,NULL,NULL,NULL),
	(5,'FGGI','fixed gear-gill net',NULL,NULL,NULL,NULL),
	(5,'FGLO','fixed gear-lobster',NULL,NULL,NULL,NULL),
	(5,'FGUN','fixed gear-unidentified',NULL,NULL,NULL,NULL),
	(5,'FIGE','fishing gear',NULL,NULL,NULL,NULL),
	(5,'FLJE','flotsam and jetsam',NULL,NULL,NULL,NULL),
	(5,'FUEL','oil/fuel',NULL,NULL,NULL,NULL),
	(5,'ICE','ice',NULL,NULL,NULL,NULL),
	--(5,'KRILL','Unidentified krill',NULL,NULL),--change to ZOOP
	(5,'LABA','Latex balloon',NULL,NULL,NULL,NULL),
	(5,'LINE','rope/line',NULL,NULL,NULL,NULL),
	(5,'MACR','macroalgae',NULL,NULL,NULL,NULL),
	(5,'MYBA','Mylar balloon',NULL,NULL,NULL,NULL),
	--(5,'NONE','none',NULL,NULL),--change to unkn
	(5,'OCFR','ocean front',NULL,NULL,NULL,NULL),
	(5,'ORSU','Orange Sulphur',NULL,'Colias','eurytheme',188528),
	(5,'PLAS','plastic',NULL,NULL,NULL,NULL),
	(5,'POBE','Polar Bear',NULL,'Ursus','maritimus',180542),
	(5,'PONY','Pony',NULL,NULL,NULL,NULL),
	(5,'RCKW','rockweed',NULL,'Pilea','microphylla',19133),
	(5,'REBA','Red Bat',NULL,'Lasiurus','borealis',180016),
	(5,'SARG','Sargassum',NULL,NULL,NULL,11389),
	(5,'SPEN','Salmon Pens',NULL,NULL,NULL,NULL),
	(5,'TOWR','Tower',NULL,NULL),
	--(5,'TRAN','transect point',NULL,NULL),--remove from observation table
	(5,'UBAT','Unidentified Bat',NULL,NULL,NULL,NULL),
	(5,'UFOB','Unidentified flying object (animal-origin)',NULL,NULL,NULL,NULL),
	--(5,'UNCT','??',NULL,NULL),--change to unkn
	(5,'UNKN','unknown',NULL,NULL,NULL,NULL),
	(5,'ZOOP','zooplankton',NULL,NULL,NULL,NULL),

	(6,'BDDR','Blue Dasher Dragonfly',NULL,'Pachydiplax','longipennis',101799),
	--(6,'BLST','Black Swallowtail','Papilio polyxenes ',188545),--change to BSTB
	(6,'BSTB','Black Swallowtail Butterfly',NULL,'Papilio','polyxenes',188543),
	(6,'BUMB','Unidentified Bee',NULL,NULL,NULL,NULL),
	(6,'DRAG','dragonfly spp.',NULL,NULL,NULL,NULL),
	(6,'GISW','Giant Swallowtail Butterfly',NULL,'Papilio','cresphontes',NULL),
	(6,'GRDA','Green Darner',NULL,'Anax','junius',101598),
	(6,'MONA','Monarch Butterfly',NULL,'Danaus','plexippus',117273),
	(6,'PLBU','Painted Lady Butterfly',NULL,'Vanessa','cardui',188601),
	(6,'SUBU','Sulfur Butterfly spp.','Coliadinae spp.',NULL,NULL,694016),
	(6,'SWDA','Swamp Darner',NULL,'Epiaeschna','heros',101638),
	(6,'UBUT','Unidentified butterfly',NULL,NULL,NULL,NULL),
	(6,'UNMO','Unidentified Moth',NULL,NULL,NULL,NULL),
	(6,'WAGL','Wandering Glider',NULL,'Pantala','flavescens',101801),

	(7,'BOAC','Boat-Aircraft carrier',NULL,NULL,NULL,NULL),
	(7,'BOAT','Boat-Unidentified',NULL,NULL,NULL,NULL),
	(7,'BOBA','Boat-Barge/barge and tug',NULL,NULL,NULL,NULL),
	(7,'BOCA','Boat-Cargo',NULL,NULL,NULL,NULL),
	(7,'BOCF','Boat-Commercial fishing',NULL,NULL),
	(7,'BOCG','Boat-Coast Guard',NULL,NULL,NULL,NULL),
	(7,'BOCR','Boat-Cruise',NULL,NULL,NULL,NULL),
	(7,'BOCS','Boat-Container ship',NULL,NULL,NULL,NULL),
	(7,'BOFE','Boat-Ferry',NULL,NULL,NULL,NULL),
	(7,'BOFI','Boat-Fishing',NULL,NULL,NULL,NULL),
	(7,'BOLO','Boat-Lobster',NULL,NULL,NULL,NULL),
	(7,'BOME','Boat-Merchant',NULL,NULL,NULL,NULL),
	(7,'BONA','Boat-Navy',NULL,NULL,NULL,NULL),
	(7,'BOPL','Boat-Pleasure',NULL,NULL,NULL,NULL),
	(7,'BOPS','Boat-Purseiner',NULL,NULL,NULL,NULL),
	(7,'BORF','Boat-Recreational fishing',NULL,NULL,NULL,NULL),
	(7,'BORV','Boat-Research vessel',NULL,NULL,NULL,NULL),
	(7,'BOSA','Boat-Sail',NULL,NULL,NULL,NULL),
	(7,'BOSU','Boat-Submarine',NULL,NULL,NULL,NULL),
	(7,'BOTA','Boat-Tanker',NULL,NULL,NULL,NULL),
	(7,'BOTD','Boat-Trawler/dragger',NULL,NULL,NULL,NULL),
	(7,'BOTU','Boat-Tug',NULL,NULL,NULL,NULL),
	(7,'BOWW','Boat-Whale watch',NULL,NULL,NULL,NULL),
	(7,'BOYA','Boat-Yacht',NULL,NULL,NULL,NULL),
	
	(8,'AMRE','American Redstart',NULL,'Setophaga','ruticilla',178979),
	(8,'AMGO','American Goldfinch',NULL,'Carduelis','tristis',179236),
	(8,'AMRO','American Robin',NULL,'Turdus','migratorius',179759),
	(8,'AMCR','American Crow',NULL,'Corvus','brachyrhynchos',179731),
	(8,'ATSP','American Tree Sparrow',NULL,'Spizella','arborea',179432),
	(8,'BAEA','Bald Eagle',NULL,'Haliaeetus','leucocephalus',175420),
	(8,'BANO','Barn Owl',NULL,'Tyto','alba',177851),
	(8,'BANS','Bank Swallow',NULL,'Riparia','riparia',178436),
	(8,'BAOR','Baltimore Oriole',NULL,'Icterus','galbula',179083),
	(8,'BAOW','Barred Owl',NULL,'Strix','varia',177921),
	(8,'BARS','Barn Swallow',NULL,'Hirundo','rustica',178448),
	(8,'BAWW','Black-and-white Warbler',NULL,'Mniotilta','varia',178844),
	(8,'BBWO','Black-backed Woodpecker',NULL,'Picoides','arcticus',178250),
	(8,'BCCH','Black-capped Chickadee',NULL,'Poecile','atricapillus',554382),
	(8,'BGGN','Blue-gray Gnatcatcher',NULL,'Polioptila','caerulea',179853),
	(8,'BHCO','Brown-headed Cowbird',NULL,'Molothrus','ater',179112),
	(8,'BLBW','Blackburnian Warbler',NULL,'Dendroica','fusca',178904),
	(8,'BLJA','Blue Jay',NULL,'Cyanocitta','cristata',179680),
	(8,'BLPW','Blackpoll Warbler',NULL,'Dendroica','striata',178913),
	(8,'BLVU','Black Vulture',NULL,'Coragyps','atratus',175272),
	(8,'BOCH','Boreal Chickadee',NULL,'Poecile','hudsonica',554386),
	(8,'BTBW','Black-throated Blue Warbler',NULL,'Dendroica','caerulescens',178888),
	(8,'BTGR','Boat-tailed Grackle',NULL,'Quiscalus','major',179108),
	(8,'BWWA','Blue-winged Warbler',NULL,'Vermivora','pinus',178853),
	(8,'CARW','Carolina Wren',NULL,'Thryothorus','ludovicianus',178581),
	(8,'CASW','Cave Swallow',NULL,'Petrochelidon','fulva',178460),
	(8,'CAWA','Canada Warbler',NULL,'Cardellina','canadensis',950079),
	(8,'CEDW','Cedar Waxwing',NULL,'Bombycilla','cedrorum',178532),
	(8,'CHIC','Unidentified Chickadee',NULL,NULL,NULL,NULL,NULL),
	(8,'CHSP','Chipping Sparrow',NULL,'Spizella','passerina',179435),
	(8,'CMWA','Cape May Warbler',NULL,'Dendroica','tigrina',178887),
	(8,'COGR','Common Grackle',NULL,'Quiscalus','quiscula',179104),
	(8,'COHA','Cooper''s Hawk',NULL,'Accipiter','cooperii',175309),
	(8,'CONI','Common Nighthawk',NULL,'Chordeiles','minor',177979),
	(8,'CORA','Common Raven',NULL,'Corvus','corax',179725),
	(8,'CORE','Common Redpoll',NULL,'Carduelis','flammea',179230),
	(8,'DOWO','Downy Woodpecker',NULL,'Picoides','pubescens',178259),
	(8,'EABL','Eastern Bluebird',NULL,'Sialia','sialis',179801),
	(8,'EUST','European Starling',NULL,'Sturnus','vulgaris',179637),
	(8,'FALC','Unidentified falcon','Falco spp.',NULL,NULL,175598),
	(8,'FISP','Field Sparrow',NULL,'Spizella','pusilla',179443),
	(8,'FOSP','Fox Sparrow',NULL,'Passerella','iliaca',179464),
	(8,'GCFC','Great Crested Flycatcher',NULL,'Myiarchus','crinitus',178309),
	(8,'GHOW','Great Horned Owl',NULL,'Bubo','virginianus',177884),
	(8,'GRCA','Gray Catbird',NULL,'Dumetella','carolinensis',178625),
	(8,'GRSP','Grasshopper Sparrow',NULL,'Ammodramus','savannarum',179333),
	(8,'HAWK','Unidentified hawk',NULL,NULL,NULL,NULL),
	(8,'HAWO','Hairy Woodpecker',NULL,'Picoides','villosus',178262),
	(8,'HETH','Hermit Thrush',NULL,'Catharus','guttatus',179779),
	(8,'HOFI','House Finch',NULL,'Carpodacus','mexicanus',179191),
	(8,'HOLA','Horned Lark',NULL,'Eremophila','alpestris',554256),
	(8,'HORE','Hoary Redpoll',NULL,'Carduelis','hornemanni',179231),
	(8,'HOSP','House Sparrow',NULL,'Passer','domesticus',179628),
	(8,'HOWA','Hooded Warbler',NULL,'Wilsonia','citrinis',178972),
	(8,'HOWR','House Wren',NULL,'Troglodytes','aedon',178541),
	(8,'LEOW','Long-eared Owl',NULL,'Asio','otus',177932),
	(8,'LOSH','Loggerhead Shrike',NULL,'Lanius','ludovicianus',178515),
	(8,'MAWA','Magnolia Warbler',NULL,'Dendroica','magnolia',178886),
	(8,'MAWR','Marsh Wren',NULL,'Cistothorus','palustris',178608),
	(8,'MODO','Mourning Dove',NULL,'Zenaida','macroura',177125),
	(8,'MOWA','Mourning Warbler',NULL,'Oporornis','philadelphia',178939),
	(8,'MUSW','Mute Swan',NULL,'Cygnus','Olor',174985),
	(8,'MYWA','Myrtle Warbler',NULL,'Dendroica','c. coronata',178892),
	(8,'NAWA','Nashville Warbler',NULL,'Vermivora','ruficapilla',178861),
	(8,'NHOW','Northern Hawk Owl',NULL,'Surnia','ulula',177898),
	(8,'NOCA','Northern Cardinal',NULL,'Cardinalis','cardinalis',179124),
	(8,'NOGO','Northern Goshawk',NULL,'Accipiter','gentilis',175300),
	(8,'NOHA','Northern Harrier',NULL,'Circus','cyaneus',175430),
	(8,'NOMO','Northern Mockingbird',NULL,'Mimus','polyglottos',178620),
	(8,'NOPA','Northern Parula',NULL,'Parula','americana',178868),
	(8,'NOWA','Northern Waterthrush',NULL,'Seiurus','noveboracensis',178931),
	(8,'NRWS','Northern Rough-winged Swallow',NULL,'Stelgidopteryx','serripennis',178443),
	(8,'NSHR','Northern Shrike',NULL,'Lanius','excubitor',178511),
	(8,'NSTS','Nelson''s Sharp-tailed Sparrow',NULL,'Ammodramus','nelsoni',554031),
	(8,'NSWO','Northern Saw-whet Owl',NULL,'Aegolius','acadicus',177942),
	(8,'OCWA','Orange-crowned Warbler',NULL,'Vermivora','celata',178856),
	(8,'OROR','Orchard Oriole',NULL,'Icterus','spurius',179064),
	(8,'OVEN','Ovenbird',NULL,'Seiurus','aurocapillus',178927),
	(8,'PEEP','Unidentified peep',NULL,NULL,NULL,NULL),
	(8,'PAWA','Palm Warbler',NULL,'Dendroica','palmarum',178921),
	(8,'PEFA','Peregrine Falcon',NULL,'Falco','peregrinus',175604),
	(8,'PHVI','Philadelphia Vireo',NULL,'Vireo','philadelphicus',NULL),
	(8,'PIGR','Pine Grosbeak',NULL,'Pinicola','enucleator',179205),
	(8,'PISI','Pine Siskin',NULL,'Carduelis','pinus',179233),
	(8,'PIWA','Pine Warbler',NULL,'Dendroica','pinus',178914),
	(8,'PIWO','Pileated Woodpecker',NULL,'Dryocopus','pileatus',178166),
	(8,'PRAW','Prairie Warbler',NULL,'Dendroica','discolor',178918),
	(8,'PROW','Prothonotary Warbler',NULL,'Protonotaria','citrea',178846),
	(8,'PUFI','Purple Finch',NULL,'Carpodacus','purpureus',179186),
	(8,'PUMA','Purple Martin',NULL,'Progne','subis',178464),
	(8,'RBGR','Rose-breasted Grosbeak',NULL,'Pheucticus','ludovicianus',179139),
	(8,'RBNU','Red-breasted Nuthatch',NULL,'Sitta','canadensis',178784),
	(8,'RBWO','Red-bellied Woodpecker',NULL,'Melanerpes','carolinus',178195),
	(8,'REVI','Red-eyed Vireo',NULL,'Vireo','olivaceous',179021),
	(8,'RHWO','Red-headed Woodpecker',NULL,'Melanerpes','erythrocephalus',178186),
	(8,'RITD','Ringed Turtle-Dove',NULL,'Streptopelia','risoria',177136),
	(8,'RLHA','Rough-legged Hawk',NULL,'Buteo','lagopus',175373),
	(8,'RNEP','Ring-necked Pheasant',NULL,'Phasianus','colchicus',175905),
	(8,'ROPI','Rock Pigeon',NULL,'Columba','livia',177071),
	(8,'RSHA','Red-shouldered Hawk',NULL,'Buteo','lineatus',175359),
	(8,'RTHA','Red-tailed Hawk',NULL,'Buteo','jamaicensis',175350),
	(8,'RTHU','Ruby-throated Hummingbird',NULL,'Archilochus','colubris',178032),
	(8,'RUGR','Ruffed Grouse',NULL,'Bonasa','umbellus',175790),
	(8,'SAVS','Savannah Sparrow',NULL,'Passerculus','sandwichensis',179314),
	(8,'SCRE','Eastern Screech Owl',NULL,'Megascops','asio',686658),
	(8,'SCTA','Scarlet Tanager',NULL,'Piranga','olivacea',179883),
	(8,'SEWR','Sedge Wren',NULL,'Cistothorus','platensis',178605),
	(8,'SOSP','Song Sparrow',NULL,'Melospiza','melodia',179492),
	(8,'SPAR','Unidentified sparrow','Emberizidae',NULL,NULL,178838),
	(8,'SSHA','Sharp-shinned Hawk',NULL,'Accipiter','striatus',175304),
	(8,'SWAL','Unidentified Swallow','Hirundinidae',NULL,NULL,178423),
	(8,'TEWA','Tennessee Warbler',NULL,'Vermivora','peregrina',178855),
	(8,'TRES','Tree Swallow',NULL,'Tachycineta','bicolor',178431),
	(8,'SWSP','Swamp Sparrow',NULL,'Melospiza','georgiana',179488),
	(8,'TUTI','Tufted Titmouse',NULL,'Baeolophus','bicolor',554138),
	(8,'TUVU','Turkey Vulture',NULL,'Cathartes','aura',175265),
	(8,'UAHA','Unidentified Accipiter Hawk','Accipiter spp.','Accipiter',NULL,175299),
	(8,'UNCR','Unidentified Crow','Corvus spp.','Corvus',NULL,179724),
	(8,'UNFL','Unidentified Flycatcher','Empidonax spp.','Empidonax',NULL,178337),
	(8,'UNHU','Unidentified Hummingbird','Trochilidae',NULL,NULL,NULL),
	(8,'UNNI','Unidentified Nighthawk',NULL,NULL,NULL,NULL),
	(8,'UNOR','Unidentified Oriole','Icterus spp.','Icterus',NULL,179063),
	(8,'UNOW','Unidentified Owl','Strigidae',NULL,NULL,177854),
	(8,'UNVI','Unidentified Vireo',NULL,NULL,NULL,NULL),
	(8,'UNWA','Unidentified Warbler',NULL,NULL,NULL,NULL),
	(8,'USOW','Unidentified small owl',NULL,NULL,NULL,NULL),
	(8,'VERM','Unidentified Vermivora','Vermivora',NULL,NULL,178851),
	(8,'VESP','Vesper Sparrow',NULL,'Pooecetes','gramineus',179366),
	(8,'WBNU','White-breasted Nuthatch',NULL,'Sitta','carolinensis',178775),
	(8,'WAPI','Water Pipit',NULL,'Anthus','spinoletta',178489),
	(8,'WCSP','White-crowned Sparrow',NULL,'Zonotrichia','leucophrys',179455),
	(8,'WEVI','White-eyed Vireo',NULL,'Vireo','griseus',178991),
	(8,'WITU','Wild Turkey',NULL,'Meleagris','gallopavo',176136),
	(8,'WTSP','White-throated Sparrow',NULL,'Zonotrichia','albicollis',179462),
	(8,'WWDO','White-winged Dove',NULL,'Zenaida','asiatica',177121),
	(8,'YBCH','Yellow-breasted Chat',NULL,'Icteria','virens',178964),
	(8,'YBCU','Yellow-billed Cuckoo',NULL,'Coccyzus','americanus',177831),
	(8,'YBFL','Yellow-bellied Flycatcher',NULL,'Empidonax','flaviventris',178338),
	(8,'YBSA','Yellow-bellied Sapsucker',NULL,'Sphyrapicus','varius',178202),
	(8,'YRWA','Yellow-rumped Warbler',NULL,'Dendroica','coronata',178891),
	(8,'YWAR','Yellow Warbler',NULL,'Dendroica','petechia',178878),

--select * from lu_species

/*
update lu_species
set species_type_id = 8
where spp_cd = 'AMRE'

select * from lu_species order by species_type_id, spp_cd

 update lu_species
 set
 ITIS_id = NULL,
 scientific_name = NULL
 where spp_cd in ('UNLT','UNMT','UNST','UNTE')
*/
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
	('byc','bycatch - the unwanted fish and other marine creatures caught during commercial fishing for a different species. These data estimate takes of protected species and discards of fishery resources'),
	('cbc','Christmas Bird count - The Christmas Bird Count (CBC) is a census of birds in the Western Hemisphere, performed annually in the early Northern-hemisphere winter by volunteer birdwatchers and administered by the National Audubon Society.  it''s an extract from Audubon, and thus it''s a copy of data actively maintained elsewhere. If it has been edited since import, we wouldn''t know.'),
	('cts','continuous time strip - ''continuous'' refers to time and the ''strip'' usually denotes a measure of distance from the observer (or platform) perpendicular to the projected path of the observation platform. This method is often along a transect and requires a start and end of the observation period. The observations are then recorded as they occur along the path with exact time and/or location of the observation.'),
	('dth','discrete time horizon - This would be when observations are occurring over a defined time at one single location'),
	('dts','discrete time strip - ''discrete'' refers to time and the ''strip'' usually denotes a measure of distance from the observer (or platform) perpendicular to the projected path of the observation platform. This method denotes all the observations in a defined time unit (e.g. one hour) along the path of observation, so the explicit time or location when that observation occurred along the path is not noted but binned to the center, start, or stop of that given time bin.'), 
	('go','general observation - These would be when an observation is supplied but it was not the primary mission of the event or survey where the species was observed or there are no defining protocols to monitor effort.'),
	('tss','targeted species survey - The defining aspect of this protocol is that only one or a limited few targeted species are observed and all other species that occur in the observation path are not recorded. The ''targeted species'' is a method modifier, where certain data are not recorded but it should still be a Discrete Time Strip or Continuous Time Strip.');
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
	version_nb tinyint not null,
	revision_date date not null,
	revision_details nvarchar(1000) not null,
	Primary Key (dataset_id, version_nb)
);
GO

INSERT INTO lu_revision_details(dataset_id,version_nb,revision_date,revision_details)
	VALUES(135,2,CAST('2017-07-12' AS DATE),'Changed date from 1/11/2011 to 1/11/2012 and transect id from 2011-01-11_NJM to 2012-01-11_NJM. This includes the observation table (records :), track table (records :) and tranesct table (record 122117).')
	--(,2,CAST('' AS DATE),'NEED TO CHANGE NOAA AMAPPS 2015 LEG TO TRANSECT IDS, in Email to Arliss')
-- 

-- look up age
CREATE TABLE lu_age(
	age_id tinyint not null,
	age_ds nvarchar(20) not null
	PRIMARY KEY(age_id) 
);
GO

INSERT INTO lu_age(age_id,age_ds)
	VALUES
	(1,'adult'),
	(2,'juvenile'),
	(3,'mixed'),
	(4,'other'),
	(5,'unknown'),
	(6,'immature'),
	(7,'subadult');
--

-- look up sex
CREATE TABLE lu_sex(
	sex_id tinyint not null,
	sex_ds nvarchar(20) not null
	PRIMARY KEY(sex_id) 
);
GO

INSERT INTO lu_sex(sex_id,sex_ds)
	VALUES
	(1,'female'),
	(2,'male'),
	(3,'mixed'),
	(4,'other'),
	(5,'unknown');
--
	
-- look up behaviors
CREATE TABLE lu_behaviors(
	behavior_id tinyint not null,
	behavior_ds nvarchar(50) not null
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
	(8,'diving - plunge diving'),
	(9,'feeding'), -- %in% c('feed','feeding')
	(10,'fishing/working'),
	(11,'flocking'),
	(12,'fluking'), -- %in% c('fluke','fluking')
	(13,'flying'), --directional, non-directional,soaring
	(14,'following/chasing'),
	(15,'following - ship'),
	(16,'foraging'),
	(17,'hauled out'), -- %in% c('beached','on beach','on shore') 
	(18,'jumping'), -- 'leaping'
	(19,'landing'),
	(20,'lobtailing'),
	(21,'milling'),
	(22,'mating'),
	(23,'other'),	
	(24,'piracy'),
	(25,'porposing'),
	(26,'preening'),
	(27,'rafting'),
	(28,'resting/floating'),-- logging
	(29,'rolling'),
	(30,'scavenging'),
	(31,'slapping'), -- %in% c('slap','slapping','tailslap','flipperslap')
	(32,'sleeping'),
	(33,'splashing'),
	(34,'spyhopping'),
	(35,'sitting'),
	(36,'sitting - on object'),
	(37,'sitting - on water'),
	(38,'standing'),
	(39,'steaming'), 
	(40,'surfacing'),
	(41,'swimming'),
	(42,'taking off/pattering'),
	(43,'traveling'),
	(44,'unknown');
--

--
CREATE TABLE lu_parent_project(
	project_id tinyint not null,
	project_name nvarchar(55) not null,
	project_ds nvarchar(4000) null,
	project_url nvarchar(3000) null,
	PRIMARY KEY(project_id)
);
GO

INSERT INTO lu_parent_project(
	project_id, project_name, project_ds, project_url)
	VALUES
	(1,'AMAPPS USFWS',
		'The geographic area of operations includes near-shore and offshore waters of the U.S. 
		Atlantic Coast from the Canada/Maine border to approximately Jacksonville, FL. Transects 
		are located at 5'' (~ 5 nautical miles [nm]) intervals at every 1'' and 6'' minutes of 
		latitude. Transect length depends on the location along coast. Some transects extend to 
		16 meter depth or out a distance of 8 nm , whichever is longer. In some cases, transects 
		located near to where the coastline runs east-west have been extended to ensure that the 
		survey covers areas that are at least 8 nm from land. Some transects extend as far as 30 
		nm off-shore to include important seabird foraging areas. In the past these annual surveys 
		were conducted during the winter between January and February. However, when the survey 
		expanded to include all marine bird species the surveys were flown multiple times throughout 
		the year to better determine seabird distributions at different times of year. As a result the 
		surveys are currently conducted in the fall (early October) and winter (early February).  
		Timing can also depend on available funding , data management needs, personnel shortages and 
		availability, weather, and aircraft availability. Surveys are flown during daylight hours 
		with no limits on the time of day. A survey can be initiated when the wind speed is < 15 
		knots (kts), and should be discontinued if the winds exceed 20 kts. Before starting each 
		transect both the pilot and observers will record observation conditions on a 5-point Likert 
		scale with 1 = Worst observation conditions, 3 = Average conditions, and 5 = Best observation 
		conditions. Often times the pilot and observer conditions will be different as glare can affect 
		one side of the aircraft more than the other depending on the direction of flight. Each crew area 
		consists of east-west oriented  strip-transects. Each transect has a unique ID that uses the latitude 
		degrees concatenated with the latitude minutes and then with the segment number [00, 01, etc.]. 
		Typically there will just be one line segment “00”, but when more than one segment occurs on the 
		same latitude you might also have segment “01."( e.g. 444600 or 444601).The transects are flown at 
		a height of 200 feet above ground level and at a speed of 110 knots. Altitude is maintained  
		with the help of a radar altimeter in most cases. Transects extend 30 nautical miles (nm) offshore 
		and can be flown from east to west or west to east.  Each transect is 400 meters (m) in width with 
		200 m observation bands on each side of the aircraft. Each observer counts outward to a the predefined 
		200 m width on their side of the aircraft (left-front (lf) or right-front(rf)).  The pilot serves as 
		the left-front observer (lf) while the observer traditionally sits in the right-front (rf) or co-pilot 
		seat of the aircraft. However, there have been times when a third backseat observer is present (e.g. a 
		new observer being trained). The transect boundary is marked either on the strut with black tape  or the 
		windshield (with dry erase marker) of the plane for reference using a clinometer. The survey targets the 
		fifteen species of sea ducks and all species of marine birds wintering along the Atlantic coast.  Identification 
		of birds to the lowest taxonomic level is ideal (e.g.species), however several generalized  groups have been 
		created for the survey understanding that species identification can be difficult during aerial survey conditions. 
		Such groupings are provided for other species as well including gulls, shearwaters, alcids, and scoters. 
		Observers are also asked to  record all marine mammals, sharks and rays, and sea turtles within the transect. 
		Finally, observers will also record any boats, including those outside of the transect , with an estimated 
		distance in nautical miles. Balloons (both inflated and deflated) should be recording within the transect. 
		[summary snippets copied from internal confluence site]',
		'http://www.nefsc.noaa.gov/psb/AMAPPS/'),
	(2,'AMAPPS NOAA',NULL,'http://www.nefsc.noaa.gov/psb/AMAPPS/'),
	(3,'Audubon CBC (Christmas Bird Count)',NULL,NULL),
	(4,'Bar Harbor Whale Watching Cruises',NULL,NULL),
	(5,'BOEM HighDef NC 2011',NULL,NULL),
	(6,'CDAS Mid-Atlantic',NULL,NULL),
	(7,'CASP (Cetacean and Seabird Assessment Program)',NULL,NULL),
	(8,'DOE BRI aerial',NULL,NULL),
	(9,'DOE BRI boat',NULL,NULL),
	(10,'EcoMon (NEFSC Ecosystem Monitoring) Cruises',
		'Shelf-wide Research Vessel Surveys are conducted 6-7 times per year over the 
		continental shelf from Cape Hatteras, North Carolina to Cape Sable, Nova Scotia, 
		using NOAA research ships or charter vessels. Three surveys are performed jointly 
		with the bottom trawl surveys in the winter, spring and autumn. An additional four 
		cruises, conducted in winter, late spring, late summer and late autumn, are dedicated 
		to plankton and hydrographic data collection. The Cape Hatteras to Cape Sable area is 
		divided into four regions, and 30 randomly selected stations are targeted for sampling from each region.',
		'https://www.nefsc.noaa.gov/HydroAtlas/'),
	(11,'Florida Light and Power, Long Island',NULL,NULL),
	(12,'Herring Acoustic',NULL,NULL),
	(13,'Massachusetts CEC',NULL,NULL),
	(14,'PIROP',NULL,NULL),
	(15,'ECSAS',NULL,NULL),
	(16,'BOEM NanoTag Massachusetts 2013',NULL,NULL),
	(17,'BOEM Terns 2013',NULL,'https://www.boem.gov/2014-665/'),
	(18,'EcoMon/HerringAcoutic combo',NULL,NULL),
	(19,'StellwagenBankNMS standardized transects',NULL,NULL),
	(20,'StellwagenBankNMS Whale Watch',NULL,NULL),
	(21,'Deepwater Wind BI Boat',NULL,NULL),
	(22,'StellwagenBankNMS second side transects',NULL,NULL),
	(23,'StellwagenBankNMS "other" protocol',NULL,NULL),
	(24,'NYSERDA','In preparation for offshore wind energy development, the New York State Energy and 
	Research Development Authority (NYSERDA) has initiated the largest offshore high resolution aerial 
	survey of marine and bird life in U.S. history. Normandeau Associates, Inc. and APEM Ltd (Normandeau-APEM team) 
	will gather 3 years of baseline surveys to assess the entire New York Offshore Planning Area (OPA) 
	with particular emphasis on the Wind Energy Area (WEA).  The surveys use ultra-high resolution 
	aerial digital imagery to assess use by birds, marine mammals, turtles, and fish. This proactive 
	study of potential impacts will facilitate a more efficient track to energy production offshore New 
	York by providing the necessary information to meet the U.S. Bureau of Ocean Energy Management''s (BOEM''s) 
	regulatory requirements for environmental review of WEAs.','https://remote.normandeau.com/nys_overview.php');

/*  update lu_parent_project table */
/*  update lu_parent_project
	set
	project_name = 'AMAPPS NOAA'
	where project_id = 2
*/

-- select * from lu_parent_project
 
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

--select * from dataset --order by share_level_id --order by in_database
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
	responsible_party,
	sponsors,
	planned_speed_knots,
	version_nb)--,
--dataset_summary, dataset_quality, dataset_processing)
	VALUES
	(141,1,'AMAPPS_FWS_Aerial_Fall2012','a','cts','ot',400,200,5,'yes','no',50,'BOEM,USFWS,NOAA,NAVY',110,1),
	(142,1,'AMAPPS_FWS_Aerial_Fall2013','a','cts','ot',400,200,5,'yes','no',64,'BOEM,USFWS,NOAA,NAVY',110,1),
	(164,1,'AMAPPS_FWS_Aerial_Fall2014','a','cts','ot',400,200,5,'yes','no',64,'BOEM,USFWS,NOAA,NAVY',110,1),
	(118,1,'AMAPPS_FWS_Aerial_Preliminary_Summer2010','a','cts','ot',400,200,5,'yes','no',50,'BOEM,USFWS,NOAA,NAVY',110,1),
	(140,1,'AMAPPS_FWS_Aerial_Spring2012','a','cts','ot',400,200,5,'yes','no',50,'BOEM,USFWS,NOAA,NAVY',110,1),
	(138,1,'AMAPPS_FWS_Aerial_Summer2011','a','cts','ot',400,200,5,'yes','no',50,'BOEM,USFWS,NOAA,NAVY',110,1),
	(137,1,'AMAPPS_FWS_Aerial_Winter2010-2011','a','cts','ot',400,200,5,'yes','no',50,'BOEM,USFWS,NOAA,NAVY',110,1),
	(139,1,'AMAPPS_FWS_Aerial_Winter2014','a','cts','ot',400,200,5,'yes','no',64,'BOEM,USFWS,NOAA,NAVY',110,1),
	(117,2,'AMAPPS_NOAA/NMFS_NEFSCBoat2011','b','cts','ot',300,300,5,'yes','yes',55,'BOEM,USFWS,NOAA,NAVY',NULL,1),
	(116,2,'AMAPPS_NOAA/NMFS_NEFSCBoat2013','b','cts','ot',300,300,5,'yes','yes',55,'BOEM,USFWS,NOAA,NAVY',NULL,1),
	(149,2,'AMAPPS_NOAA/NMFS_NEFSCBoat2014','b','cts','ot',300,300,5,'yes','yes',55,'BOEM,USFWS,NOAA,NAVY',NULL,1),
	(160,2,'AMAPPS_NOAA/NMFS_NEFSCBoat2015','b','cts','ot',300,300,5,'yes','yes',52,'BOEM,USFWS,NOAA,NAVY',NULL,1),
	(174,2,'AMAPPS_NOAA/NMFS_NEFSCBoat2016','b','cts','ot',300,300,9,'yes','yes',52,'BOEM,USFWS,NOAA,NAVY',NULL,1),
	(122,2,'AMAPPS_NOAA/NMFS_SEFSCBoat2011','b','cts','ot',300,300,5,'yes','yes',55,'BOEM,USFWS,NOAA,NAVY',NULL,1),
	(123,2,'AMAPPS_NOAA/NMFS_SEFSCBoat2013','b','cts','ot',300,300,5,'yes','yes',55,'BOEM,USFWS,NOAA,NAVY',NULL,1),
	(100,NULL,'AtlanticFlywaySeaducks1991',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,NULL,'USFWS',NULL,1),				
	(43,3,'AudubonCBC_MA2Z','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1),        		
	(46,3,'AudubonCBC_MASB','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1),         		
	(47,3,'AudubonCBC_MD15','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1),         		
	(48,3,'AudubonCBC_MD19','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1),         		
	(49,3,'AudubonCBC_MDBH','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1),         		
	(50,3,'AudubonCBC_MDJB','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1),         		
	(51,3,'AudubonCBC_ME08','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1),         		
	(52,3,'AudubonCBC_ME0A','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1),         		
	(53,3,'AudubonCBC_ME0B','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1),         		
	(54,3,'AudubonCBC_MEBF','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1),         		
	(55,3,'AudubonCBC_MEMB','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1),         		
	(56,3,'AudubonCBC_NJ0A','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1),         		
	(57,3,'AudubonCBC_NJ0R','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1),         		
	(58,3,'AudubonCBC_NJ0S','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1),         		
	(59,3,'AudubonCBC_NJAO','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1),         		
	(60,3,'AudubonCBC_NJNJ','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1),         		
	(61,3,'AudubonCBC_NY1Q','g','cbc','og',NULL,NULL,5,'yes','yes',7,NULL,NULL,1),         		
	(62,3,'AudubonCBC_NY1R','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1),         		
	(63,3,'AudubonCBC_NY1S','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1),         		
	(64,3,'AudubonCBC_NY1W','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1),         		
	(65,3,'AudubonCBC_NY1X','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1),         		
	(66,3,'AudubonCBC_NY21','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1),         		
	(67,3,'AudubonCBC_NY39','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1),         		
	(68,3,'AudubonCBC_VACB','g','cbc','og',NULL,NULL,5,'yes','yes',8,NULL,NULL,1),         		
	(107,NULL,'AvalonSeawatch1993',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,21,NULL,NULL,1), 					
	(5,4,'BarHarborWW05','b','cts','ot',NULL,NULL,5,'yes','yes',33,'USFWS',NULL,1),         		
	(6,4,'BarHarborWW06','b','cts','ot',NULL,NULL,5,'yes','yes',33,'USFWS',NULL,1),         		
	(166,4,'BarHarborWW09','b','cts','ot',NULL,NULL,0,'no',NULL,33,'USFWS',NULL,1), 		
	(167,4,'BarHarborWW10','b','cts','ot',NULL,NULL,0,'no',NULL,33,'USFWS',NULL,1), 		
	(103,NULL,'BluewaterWindDE',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,40,'BOEM',NULL,1), 					
	(102,NULL,'BluewaterWindNJ',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,40,'BOEM',NULL,1), 					
	(144,5,'BOEMHighDef_NC2011Aerial','a','cts','ot',500,250,5,'yes','no',61,'BOEM,Normandeau',NULL,1), 
	(143,5,'BOEMHighDef_NC2011Boat','b','cts','ot',1000,1000,5,'yes','no',61,'BOEM,Normandeau',NULL,1), 
	(169,5,'BOEMHighDef_NC2011Camera','c','cts','ot',NULL,NULL,99,'no','yes',61,'BOEM,Normandeau',NULL,1), 		 			
	(172,NULL,'BRIMaine2016','b','cts','ot',1500,1500,9,'no',NULL,66,'BRI,Maine gov',NULL,1), 		
	(7,NULL,'CapeHatteras0405','b','cts','ot',NULL,NULL,5,'yes',NULL,23,'Duke',NULL,1),         		
	(8,NULL,'CapeWindAerial','a','cts','ot',NULL,NULL,2,'yes','yes',13,'BOEM',NULL,1),       		
	(9,NULL,'CapeWindBoat','b','cts','ot',NULL,NULL,2,'yes','yes',13,'BOEM',NULL,1),         		
	(10,6,'CDASMidAtlantic','a','cts','ot',120,60,5,'yes','yes',15,NULL,NULL,1),
	(21,7,'CSAP','b','dts','ot',300,300,5,'yes','yes',31,'Manomet',NULL,1),
	(97,NULL,'DEandChesBaysUSFWS1990',NULL,NULL,NULL,NULL,NULL,6,'no',NULL,15,'USFWS',NULL,1), 		 					
	(115,8,'DOEBRIAerial2012','c','cts','ot',200,50,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1),--check on share levels
	(148,8,'DOEBRIAerial2013','c','cts','ot ',200,50,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1),--check on share levels
	(168,8,'DOEBRIAerial2014','c','cts','ot',200,50,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1),--check on share levels
	(157,9,'DOEBRIBoatApr2014','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1),
	(114,9,'DOEBRIBoatApril2012','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1),
	(124,9,'DOEBRIBoatAug2012','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1),
	(152,9,'DOEBRIBoatAug2013','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1),
	(125,9,'DOEBRIBoatDec2012','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1),
	(155,9,'DOEBRIBoatDec2013','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1),
	(126,9,'DOEBRIBoatJan2013','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1),
	(156,9,'DOEBRIBoatJan2014','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1),
	(127,9,'DOEBRIBoatJune2012','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1),
	(151,9,'DOEBRIBoatJune2013','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1),
	(128,9,'DOEBRIBoatMar2013','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1),
	(150,9,'DOEBRIBoatMay2013','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1),
	(130,9,'DOEBRIBoatNov2012','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1),
	(154,9,'DOEBRIBoatOct2013','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1),
	(129,9,'DOEBRIBoatSep2012','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1),
	(153,9,'DOEBRIBoatSep2013','b','cts','ot',300,300,1,'yes','yes',3,'DOE,BRI,BOEM',NULL,1),
	(134,NULL,'DominionVirginia_VOWTAP','b','cts','ot',300,300,5,'yes','yes',65,'BOEM,Dominion,TetraTech',NULL,1),
	(101,NULL,'DUMLOnslowBay2007',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,36,'Duke, University of NC',NULL,1),					
	(77,10,'EcoMonAug08','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1),
	(42,10,'EcoMonAug09','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1),
	(82,10,'EcoMonAug10','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1),
	(112,10,'EcoMonAug2012','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1),
	(79,10,'EcoMonFeb10','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1),
	(131,10,'EcoMonFeb2012','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1),
	(171,10,'EcoMonFeb2013','b','cts','ot',300,300,5,'yes','yes',62,'NOAA',NULL,1),
	(38,10,'EcoMonJan09','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1),
	(158,10,'EcoMonJun2012','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1),
	(33,10,'EcoMonMay07','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1),
	(39,10,'EcoMonMay09','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1),
	(80,10,'EcoMonMay10','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1),
	(76,10,'EcoMonNov09','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1),
	(81,10,'EcoMonNov10','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1),
	(83,10,'EcoMonNov2011','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1),
	(159,10,'EcoMonOct2012','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1),
	(170,10,'EcoMonSep2012',NULL,NULL,NULL,NULL,NULL,6,'no',NULL,NULL,NULL,NULL,1),
	(119,15,'ECSAS','b','cts','ot',300,300,0,'no',NULL,16,NULL,NULL,1),
	(99,11,'FLPowerLongIsland_Aerial','a','cts','ot',400,200,5,'yes','yes',65,'BOEM, Florida Light and Power',NULL,1),
	(165,11,'FLPowerLongIsland_Boat','b','cts','ot',300,300,5,'yes','yes',65,'BOEM, Florida Light and Power',NULL,1),
	(147,NULL,'FWS_MidAtlanticDetection_Spring2012','a','cts','ot',400,200,5,'yes','no',59,'USFWS',NULL,1),
	(146,NULL,'FWS_SouthernBLSC_Winter2012','a','cts','ot',400,200,5,'yes','no',59,'USFWS',NULL,1),
	(113,NULL,'FWSAtlanticWinterSeaduck2008','a','cts','ot',400,200,5,'yes','no',58,'USFWS',NULL,1),
	(12,NULL,'GeorgiaPelagic','b','dts','ot',NULL,NULL,5,'yes',NULL,20,NULL,NULL,1),        		
	(110,NULL,'GulfOfMaineBluenose1965',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,NULL,NULL,NULL,1),   					
	(73,NULL,'HassNC','b','tss','ot',NULL,NULL,5,'yes',NULL,42,NULL,NULL,1),         		
	(15,NULL,'HatterasEddyCruise2004','b','cts','ot',NULL,NULL,5,'yes',NULL,27,NULL,NULL,1),         		
	(78,12,'HerringAcoustic06','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1),
	(34,12,'HerringAcoustic07','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1),
	(35,12,'HerringAcoustic08','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1),
	(69,12,'HerringAcoustic09Leg1','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1),
	(70,12,'HerringAcoustic09Leg2','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1),
	(71,12,'HerringAcoustic09Leg3','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1),
	(84,12,'HerringAcoustic2010','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1),
	(85,12,'HerringAcoustic2011','b','cts','ot',300,300,5,'yes','yes',11,'NOAA',NULL,1),
	(111,12,'HerringAcoustic2012','b','cts','ot',300,300,5,'yes','yes',62,'NOAA',NULL,1),
	(22,NULL,'MassAudNanAerial','a','cts','ot',182,91,5,'yes','yes',10,NULL,NULL,1),
	(135,13,'MassCEC2011-2012','a','cts','ot',400,200,5,'yes','no',62,NULL,NULL,2),
	(161,13,'MassCEC2013','a','cts','ot',400,200,5,'yes','no',62,NULL,NULL,1),
	(162,13,'MassCEC2014','a','cts','ot',400,200,5,'yes','no',62,NULL,NULL,1),
	(74,NULL,'Mayr1938TransAtlantic','b','go','og',NULL,NULL,5,'yes',NULL,NULL,NULL,NULL,1),--check        		
	(136,13,'NantucketAerial2013','a','cts','ot',NULL,NULL,7,'yes',NULL,62,NULL,NULL,1),		
	(96,NULL,'NantucketShoalsLTDU1998',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,NULL,NULL,NULL,1),					
	(105,NULL,'NCInletsDavidLee1976',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,22,NULL,NULL,1),					
	(109,NULL,'NewEnglandBlueDolphin1953',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,25,NULL,NULL,1),					
	(25,NULL,'NewEnglandSeamount06','b','dts','ot',NULL,NULL,5,'yes',NULL,16,NULL,NULL,1),        		
	(91,NULL,'NJDEP2009','b','cts','de',300,300,5,'yes','yes',56,'NJDEP,BOEM',NULL,1),
	(121,NULL,'NOAA/NMFS_NEFSCBoat2004','b','cts','ot',300,300,5,'yes','yes',52,'NOAA',10,1),
	(120,NULL,'NOAA/NMFS_NEFSCBoat2007','b','cts','ot',300,300,5,'yes','yes',52,'NOAA',11,1),
	(32,NULL,'NOAABycatch','b','byc','og',NULL,NULL,5,'yes',NULL,19,'NOAA',NULL,1),        		
	(20,NULL,'NOAAMBO7880','b','dts','ot',300,300,5,'yes','yes',15,'NOAA',NULL,1),   					
	(23,NULL,'Patteson','b','go','og',NULL,NULL,5,'yes',NULL,32,NULL,NULL,1),        		
	(92,NULL,'PIROP','b',NULL,NULL,NULL,NULL,7,'yes',NULL,16,NULL,NULL,1),				
	(75,NULL,'PlattsBankAerial','a','cts','ot',340,170 ,5,'yes',NULL,39,NULL,99.892,1),        		
	(98,NULL,'RHWiley1957',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,26,NULL,NULL,1),					
	(89,NULL,'RISAMPAerial','a','cts','ot',300,300,5,'yes','yes',41,NULL,NULL,1),
	(90,NULL,'RISAMPBoat','b','cts','ot',300,300,5,'yes','yes',41,NULL,NULL,1),
	(104,NULL,'RockportSeawatch',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,NULL,NULL,NULL,1),					
	(108,NULL,'RowlettMaryland1971',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,24,NULL,NULL,1),					
	(163,NULL,'RoyalSociety',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,NULL,NULL,NULL,1),					
	(24,NULL,'SargassoSea04','b','go','og',NULL,NULL,5,'yes',NULL,28,'Duke',NULL,1),	       		
	(28,NULL,'SargassoSea06','b','go','og',NULL,NULL,5,'yes',NULL,34,'Duke',NULL,1),	        		
	(93,NULL,'SEANET','g',NULL,NULL,NULL,NULL,0,'no',NULL,43,'Tufts,Wildlife Clinic',NULL,1),					
	(29,NULL,'SEFSC1992','b','cts','ot',300,300,5,'yes','yes',30,'NOAA',NULL,1),
	(30,NULL,'SEFSC1998','b','cts','ot',300,300,5,'yes','yes',30,'NOAA',NULL,1),
	(31,NULL,'SEFSC1999','b','cts','ot',300,300,5,'yes','yes',30,'NOAA',NULL,1),
	(133,NULL,'StatoilMaine','b','cts','ot',300,300,5,'yes','yes',65,'BOEM,StatOil,TetraTech',10,1),				
	(106,NULL,'WaterfowlUSFWS2001',NULL,NULL,NULL,NULL,NULL,0,'no',NULL,14,'USFWS',NULL,1),					
	(94,NULL,'WHOIJuly2010','b','cts','ot',300,300,1,'yes',NULL,11,'WHOI',NULL,1),
	(132,NULL,'WHOISept2010','b','cts','ot',300,300,1,'yes',NULL,11,'WHOI',NULL,1),
	(145,16,'BOEMNanoTag_Mass_Aug2013','a','tss','ot',400,200,5,'yes','yes',60,'BOEM,USFWS',110,1),
	(176,16,'BOEMNanoTag_Mass_Sept2013a','a','tss','ot',400,200,5,'yes','yes',60,'BOEM,USFWS',110,1),
	(177,16,'BOEMNanoTag_Mass_Sept2013b','a','tss','ot',400,200,5,'yes','yes',60,'BOEM,USFWS',110,1),
	(178,17,'BOEM_terns_July2013','a','tss','ot',400,200,5,'yes','no',62,'BOEM',100,1),
	(179,17,'BOEM_terns_Aug2013','a','tss','ot',400,200,5,'yes','no',62,'BOEM',100,1),
	(180,17,'BOEM_terns_Sep2013a','a','tss','ot',400,200,5,'yes','no',62,'BOEM',100,1),
 	(181,17,'BOEM_terns_Sep2013b','a','tss','ot',400,200,5,'yes','no',62,'BOEM',100,1),
	(95,19,'StellwagenBankNMS_Jun2012','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),	
	(182,19,'StellwagenBankNMS_Aug2012','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),
	(183,19,'StellwagenBankNMS_Oct2012','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),
	(184,19,'StellwagenBankNMS_Jan2013','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),
	(185,19,'StellwagenBankNMS_Apr2013','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),
	(186,19,'StellwagenBankNMS_Jun2013','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),
	(187,19,'StellwagenBankNMS_Aug2013','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),
	(188,19,'StellwagenBankNMS_Oct2013','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),
	(189,19,'StellwagenBankNMS_Apr2014','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),
	(190,19,'StellwagenBankNMS_Jun2014','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),
	(191,19,'StellwagenBankNMS_Aug2014','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),
	(192,19,'StellwagenBankNMS_Sep2014','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),
	(193,19,'StellwagenBankNMS_Oct2014','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),
	(194,19,'StellwagenBankNMS_Dec2014','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),
	(195,19,'StellwagenBankNMS_Jun2015','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),
	(196,19,'StellwagenBankNMS_Aug2015','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),
	(197,19,'StellwagenBankNMS_Sep2015','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),
	(198,19,'StellwagenBankNMS_Oct2015','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),
	(199,19,'StellwagenBankNMS_Dec2015','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),
	(200,19,'StellwagenBankNMS_Aug2011','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),
	(201,19,'StellwagenBankNMS_Sep2011a','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),--two surveys in Sep.
	(202,19,'StellwagenBankNMS_Sep2011b','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),--two surveys in Sep.
	(203,19,'StellwagenBankNMS_Dec2011','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),
	(204,19,'StellwagenBankNMS_Oct2011','b','cts','ot',300,300,99,'no',NULL,9,'NOAA',NULL,1),
	(175,21,'DeepwaterWindBlockIsland_boat_Nov09a','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1),
	(205,21,'DeepwaterWindBlockIsland_boat_Nov09b','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1),
	(206,21,'DeepwaterWindBlockIsland_boat_Dec10a','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1),
	(207,21,'DeepwaterWindBlockIsland_boat_Dec10b','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1),
	(208,21,'DeepwaterWindBlockIsland_boat_Jan10a','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1),
	(209,21,'DeepwaterWindBlockIsland_boat_Jan10b','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1),
	(210,21,'DeepwaterWindBlockIsland_boat_Feb10a','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1),
	(211,21,'DeepwaterWindBlockIsland_boat_Feb10b','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1),
	(212,21,'DeepwaterWindBlockIsland_boat_Mar10a','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1),
	(213,21,'DeepwaterWindBlockIsland_boat_Mar10b','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1),
	(214,21,'DeepwaterWindBlockIsland_boat_Apr10a','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1),
	(215,21,'DeepwaterWindBlockIsland_boat_Apr10b','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1),
	(216,21,'DeepwaterWindBlockIsland_boat_May10a','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1),
	(217,21,'DeepwaterWindBlockIsland_boat_May10b','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1),
	(218,21,'DeepwaterWindBlockIsland_boat_Jun10a','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1),
 	(219,21,'DeepwaterWindBlockIsland_boat_Jun10b','b','cts','ot',300,300,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1),
 	(220,21,'DeepwaterWindBlockIsland_boat_Aug11a','b','cts','ot',300,300,0,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1),
 	(221,21,'DeepwaterWindBlockIsland_boat_Aug11b','b','cts','ot',300,300,0,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1),
 	(222,21,'DeepwaterWindBlockIsland_boat_Sep11a','b','cts','ot',300,300,0,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1),
	(223,21,'DeepwaterWindBlockIsland_boat_Sep11b','b','cts','ot',300,300,0,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',8,1),
	(224,22,'StellwagenBankNMS_SS_Jun2012','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1),
	(225,22,'StellwagenBankNMS_SS_Aug2012','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1),
	(226,22,'StellwagenBankNMS_SS_Oct2012','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1),
	(227,22,'StellwagenBankNMS_SS_Jan2013','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1),
	(228,22,'StellwagenBankNMS_SS_Apr2013','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1),
	(229,22,'StellwagenBankNMS_SS_Jun2013','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1),
	(230,22,'StellwagenBankNMS_SS_Aug2013','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1),
	(231,22,'StellwagenBankNMS_SS_Oct2013','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1),
	(232,22,'StellwagenBankNMS_SS_Apr2014','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1),
	(233,22,'StellwagenBankNMS_SS_Jun2014','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1),
	(234,22,'StellwagenBankNMS_SS_Aug2014','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1),
	(235,22,'StellwagenBankNMS_SS_Sep2014','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1),
	(236,22,'StellwagenBankNMS_SS_Oct2014','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1),
	(237,22,'StellwagenBankNMS_SS_Dec2014','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1),
	(238,22,'StellwagenBankNMS_SS_Jun2015','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1),
	(239,22,'StellwagenBankNMS_SS_Aug2015','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1),
	(240,22,'StellwagenBankNMS_SS_Sep2015','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1),
	(241,22,'StellwagenBankNMS_SS_Oct2015','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1),
	(242,22,'StellwagenBankNMS_SS_Dec2015','b','cts','ot',NULL,NULL,99,'no',NULL,9,'NOAA',NULL,1),
	(243,21,'DeepwaterWindBlockIsland0910_camera','c','cts','ot',NULL,NULL,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',53,1),
	(244,20,'StellwagenBankNMS_WW_2011-10-22','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(245,20,'StellwagenBankNMS_WW_2012-06-17','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(246,20,'StellwagenBankNMS_WW_2012-06-24','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(247,20,'StellwagenBankNMS_WW_2012-07-01','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(248,20,'StellwagenBankNMS_WW_2012-07-08','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(249,20,'StellwagenBankNMS_WW_2012-07-15','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(250,20,'StellwagenBankNMS_WW_2012-08-12','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(251,20,'StellwagenBankNMS_WW_2012-08-19','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(252,20,'StellwagenBankNMS_WW_2012-08-25','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(253,20,'StellwagenBankNMS_WW_2012-08-26','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(254,20,'StellwagenBankNMS_WW_2012-09-01','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(255,20,'StellwagenBankNMS_WW_2012-09-02','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(256,20,'StellwagenBankNMS_WW_2012-09-08','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(257,20,'StellwagenBankNMS_WW_2012-09-09','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(258,20,'StellwagenBankNMS_WW_2012-09-16','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(259,20,'StellwagenBankNMS_WW_2012-09-22','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(260,20,'StellwagenBankNMS_WW_2012-09-30','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(261,20,'StellwagenBankNMS_WW_2012-10-20','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(262,20,'StellwagenBankNMS_WW_2012-10-21','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(263,20,'StellwagenBankNMS_WW_2012-10-27','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(264,20,'StellwagenBankNMS_WW_2013-06-16','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(265,20,'StellwagenBankNMS_WW_2013-06-19','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(266,20,'StellwagenBankNMS_WW_2013-06-23','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(267,20,'StellwagenBankNMS_WW_2013-06-27','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(268,20,'StellwagenBankNMS_WW_2013-06-29','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(269,20,'StellwagenBankNMS_WW_2013-06-30','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(270,20,'StellwagenBankNMS_WW_2013-07-13','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(271,20,'StellwagenBankNMS_WW_2013-07-14','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(272,20,'StellwagenBankNMS_WW_2013-07-20','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(273,20,'StellwagenBankNMS_WW_2013-07-28','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(274,20,'StellwagenBankNMS_WW_2013-08-03','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(275,20,'StellwagenBankNMS_WW_2013-08-04','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(276,20,'StellwagenBankNMS_WW_2013-08-06','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(277,20,'StellwagenBankNMS_WW_2013-08-11','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(278,20,'StellwagenBankNMS_WW_2013-08-17','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(279,20,'StellwagenBankNMS_WW_2013-08-18','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(280,20,'StellwagenBankNMS_WW_2013-08-20','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(281,20,'StellwagenBankNMS_WW_2013-08-24','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(282,20,'StellwagenBankNMS_WW_2013-08-25','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(283,20,'StellwagenBankNMS_WW_2013-08-31','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(284,20,'StellwagenBankNMS_WW_2013-09-04','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(285,20,'StellwagenBankNMS_WW_2013-09-14','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(286,20,'StellwagenBankNMS_WW_2013-09-15','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(287,20,'StellwagenBankNMS_WW_2013-09-29','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(288,20,'StellwagenBankNMS_WW_2013-10-05','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(289,20,'StellwagenBankNMS_WW_2013-10-17','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(290,20,'StellwagenBankNMS_WW_2013-10-26','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(291,20,'StellwagenBankNMS_WW_2013-10-27','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(292,20,'StellwagenBankNMS_WW_2013-11-10','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(293,20,'StellwagenBankNMS_WW_2014-05-02','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(294,20,'StellwagenBankNMS_WW_2014-05-09','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(295,20,'StellwagenBankNMS_WW_2014-05-16','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(296,20,'StellwagenBankNMS_WW_2014-06-08','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(297,20,'StellwagenBankNMS_WW_2014-06-15','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(298,20,'StellwagenBankNMS_WW_2014-06-16','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(299,20,'StellwagenBankNMS_WW_2014-06-21','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(300,20,'StellwagenBankNMS_WW_2014-06-27','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(301,20,'StellwagenBankNMS_WW_2014-06-28','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(302,20,'StellwagenBankNMS_WW_2014-07-10','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(303,20,'StellwagenBankNMS_WW_2014-07-11','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(304,20,'StellwagenBankNMS_WW_2014-07-13','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(305,20,'StellwagenBankNMS_WW_2014-07-18','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(306,20,'StellwagenBankNMS_WW_2014-07-20','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(307,20,'StellwagenBankNMS_WW_2014-07-21','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(308,20,'StellwagenBankNMS_WW_2014-07-26','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(309,20,'StellwagenBankNMS_WW_2014-07-27','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(310,20,'StellwagenBankNMS_WW_2014-08-02','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(311,20,'StellwagenBankNMS_WW_2014-08-03','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(312,20,'StellwagenBankNMS_WW_2014-08-09','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(313,20,'StellwagenBankNMS_WW_2014-08-10','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(314,20,'StellwagenBankNMS_WW_2014-08-16','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(315,20,'StellwagenBankNMS_WW_2014-08-17','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(316,20,'StellwagenBankNMS_WW_2014-08-25','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(317,20,'StellwagenBankNMS_WW_2014-08-30','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(318,20,'StellwagenBankNMS_WW_2014-08-31','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(319,20,'StellwagenBankNMS_WW_2014-09-06','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(320,20,'StellwagenBankNMS_WW_2014-09-13','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(321,20,'StellwagenBankNMS_WW_2014-09-14','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(322,20,'StellwagenBankNMS_WW_2014-09-20','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(323,20,'StellwagenBankNMS_WW_2014-09-28','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(324,20,'StellwagenBankNMS_WW_2014-10-05','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(325,20,'StellwagenBankNMS_WW_2014-10-12','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(326,20,'StellwagenBankNMS_WW_2014-10-18','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(327,20,'StellwagenBankNMS_WW_2014-10-26','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(328,20,'StellwagenBankNMS_WW_2014-10-31','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(329,20,'StellwagenBankNMS_WW_2014-11-08','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(330,20,'StellwagenBankNMS_WW_2014-11-15','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(331,20,'StellwagenBankNMS_WW_2015-04-11','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(332,20,'StellwagenBankNMS_WW_2015-04-26','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(333,20,'StellwagenBankNMS_WW_2015-05-10','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(334,20,'StellwagenBankNMS_WW_2015-05-17','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(335,20,'StellwagenBankNMS_WW_2015-05-24','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(336,20,'StellwagenBankNMS_WW_2015-05-30','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(337,20,'StellwagenBankNMS_WW_2015-05-31','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(338,20,'StellwagenBankNMS_WW_2015-06-07','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(339,20,'StellwagenBankNMS_WW_2015-06-13','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(340,20,'StellwagenBankNMS_WW_2015-06-14','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(341,20,'StellwagenBankNMS_WW_2015-06-20','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(342,20,'StellwagenBankNMS_WW_2015-06-21','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(343,20,'StellwagenBankNMS_WW_2015-06-27','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(344,20,'StellwagenBankNMS_WW_2015-07-05','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(345,20,'StellwagenBankNMS_WW_2015-07-11','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(346,20,'StellwagenBankNMS_WW_2015-07-12','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(347,20,'StellwagenBankNMS_WW_2015-07-18','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(348,20,'StellwagenBankNMS_WW_2015-07-19','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(349,20,'StellwagenBankNMS_WW_2015-07-23','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(350,20,'StellwagenBankNMS_WW_2015-07-25','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(351,20,'StellwagenBankNMS_WW_2015-08-01','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(352,20,'StellwagenBankNMS_WW_2015-08-02','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(353,20,'StellwagenBankNMS_WW_2015-08-08','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(354,20,'StellwagenBankNMS_WW_2015-08-09','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(355,20,'StellwagenBankNMS_WW_2015-08-15','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(356,20,'StellwagenBankNMS_WW_2015-08-22','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(357,20,'StellwagenBankNMS_WW_2015-08-23','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(358,20,'StellwagenBankNMS_WW_2015-08-29','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(359,20,'StellwagenBankNMS_WW_2015-09-06','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(360,20,'StellwagenBankNMS_WW_2015-09-12','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(361,20,'StellwagenBankNMS_WW_2015-09-13','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(362,20,'StellwagenBankNMS_WW_2015-09-19','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(363,20,'StellwagenBankNMS_WW_2015-09-20','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(364,20,'StellwagenBankNMS_WW_2015-09-26','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(365,20,'StellwagenBankNMS_WW_2015-09-27','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(366,20,'StellwagenBankNMS_WW_2015-10-11','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(367,20,'StellwagenBankNMS_WW_2015-10-18','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(368,20,'StellwagenBankNMS_WW_2015-10-24','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(369,20,'StellwagenBankNMS_WW_2015-11-01','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(370,20,'StellwagenBankNMS_WW_2015-11-07','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(371,23,'StellwagenBankNMS_Other_Sept2013','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),--listed as standardized but is in question
	(372,23,'StellwagenBankNMS_Other_2011-08-02','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(373,23,'StellwagenBankNMS_Other_2011-09-15','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(374,23,'StellwagenBankNMS_Other_2011-09-21','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(375,23,'StellwagenBankNMS_Other_2011-10-18','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(376,23,'StellwagenBankNMS_Other_2011-12-30','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(377,23,'StellwagenBankNMS_Other_2012-04-17','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(378,23,'StellwagenBankNMS_Other_2013-07-28','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(379,23,'StellwagenBankNMS_Other_2013-09-04','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(380,23,'StellwagenBankNMS_Other_2014-07-25','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(381,23,'StellwagenBankNMS_Other_2014-07-26','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(382,23,'StellwagenBankNMS_Other_2014-08-09','b','dts','og',NULL,NULL,9,'no',NULL,9,'NOAA',NULL,1),
	(383,10,'EcoMonFeb2011','b','cts','ot',300,300,0,'no',NULL,NULL,'NOAA',NULL,1),--DEL 1102
	(384,10,'EcoMonJun2011','b','cts','ot',300,300,0,'no',NULL,NULL,'NOAA',NULL,1),--DEL 1105
	(385,10,'EcoMonJun2013','b','cts','ot',300,300,0,'no',NULL,16,'NOAA',NULL,1),--GU 1302
	(386,10,'EcoMonNov2013','b','cts','ot',300,300,0,'no',NULL,16,'NOAA',NULL,1),--GU 1305
	(387,10,'EcoMonMar2014','b','cts','ot',300,300,0,'no',NULL,16,'NOAA',NULL,1),--GU 1401
	(388,10,'EcoMonMay2015','b','cts','ot',300,300,0,'no',NULL,16,'NOAA',NULL,1),--HB 1502
	(389,10,'EcoMonOct2015','b','cts','ot',300,300,0,'no',NULL,16,'NOAA',NULL,1),--GU 1506 
	(390,10,'EcoMonAug2016','b','cts','ot',300,300,0,'no',NULL,16,'NOAA',NULL,1),--PC 1607
	(391,10,'EcoMonMay2016','b','cts','ot',300,300,0,'no',NULL,16,'NOAA',NULL,1),--GU 1608
	(392,10,'EcoMonOct2016','b','cts','ot',300,300,0,'no',NULL,16,'NOAA',NULL,1),--PC 1609 no bird observer 
	(393,10,'EcoMonFeb2017','b','cts','ot',300,300,0,'no',NULL,16,'NOAA',NULL,1),--HB 1701
	(394,10,'EcoMonJune2017','b','cts','ot',300,300,0,'no',NULL,16,'NOAA',NULL,1),--GU 1706
	(395,1,'AMAPPS_FWS_Aerial_Summer2017','a','cts','ot',400,200,5,'no','no',50,'BOEM,USFWS,NOAA,NAVY',110,1),
	(173,24,'NYSERDA_APEM_1','c','cts','ot',NULL,NULL,0,'no',NULL,61,'BOEM,APEM,Normandeau',NULL,1),
	(396,1,'AMAPPS_FWS_Aerial_2018','a','cts','ot',400,200,5,'no','no',50,'BOEM,USFWS,NOAA,NAVY',110,1),
	(397,1,'AMAPPS_FWS_Aerial_2019','a','cts','ot',400,200,5,'no','no',50,'BOEM,USFWS,NOAA,NAVY',110,1),
	(398,24,'NYSERDA_APEM_2','c','cts','ot',NULL,NULL,0,'no',NULL,61,'BOEM,APEM,Normandeau',NULL,1),
	(399,24,'NYSERDA_APEM_3','c','cts','ot',NULL,NULL,0,'no',NULL,61,'BOEM,APEM,Normandeau',NULL,1),
	(400,24,'NYSERDA_APEM_4','c','cts','ot',NULL,NULL,0,'no',NULL,61,'BOEM,APEM,Normandeau',NULL,1),
	(401,24,'NYSERDA_APEM_5','c','cts','ot',NULL,NULL,0,'no',NULL,61,'BOEM,APEM,Normandeau',NULL,1),
	(402,24,'NYSERDA_APEM_6','c','cts','ot',NULL,NULL,0,'no',NULL,61,'BOEM,APEM,Normandeau',NULL,1),
	(403,24,'NYSERDA_APEM_7','c','cts','ot',NULL,NULL,0,'no',NULL,61,'BOEM,APEM,Normandeau',NULL,1),
	(404,24,'NYSERDA_APEM_8','c','cts','ot',NULL,NULL,0,'no',NULL,61,'BOEM,APEM,Normandeau',NULL,1),
	(405,24,'NYSERDA_APEM_9','c','cts','ot',NULL,NULL,0,'no',NULL,61,'BOEM,APEM,Normandeau',NULL,1),
	(406,24,'NYSERDA_APEM_10','c','cts','ot',NULL,NULL,0,'no',NULL,61,'BOEM,APEM,Normandeau',NULL,1),
	(407,24,'NYSERDA_APEM_11','c','cts','ot',NULL,NULL,0,'no',NULL,61,'BOEM,APEM,Normandeau',NULL,1),
	(408,24,'NYSERDA_APEM_12','c','cts','ot',NULL,NULL,0,'no',NULL,61,'BOEM,APEM,Normandeau',NULL,1),
	(409,2,'AMAPPS_NOAA/NMFS_NEFSCAerial2010','a','cts','ot',NULL,NULL,0,'no',NULL,NULL,'BOEM,USFWS,NOAA,NAVY',NULL,NULL),
	(410,2,'AMAPPS_NOAA/NMFS_NEFSCAerial2012','a','cts','ot',NULL,NULL,0,'no',NULL,NULL,'BOEM,USFWS,NOAA,NAVY',NULL,NULL);

-- 	( ,2,'AMAPPS_NOAA/NMFS_NEFSCBoat2017','b','cts','ot',300,300,9,'yes','yes',52,'BOEM,USFWS,NOAA,NAVY',NULL,1),

-- 	(,21,'DeepwaterWindBlockIsland_bats',NULL,NULL,NULL,NULL,NULL,9,'no',NULL,65,'BOEM,TetraTech,Deepwater Wind RI',NULL,1),
--	(,2,'AMAPPS_NOAA/NMFS_NEFSCBoat2018','b','cts','ot',300,300,9,'yes','yes',52,'BOEM,USFWS,NOAA,NAVY',NULL,1),
--	(,2,'AMAPPS_NOAA/NMFS_NEFSCBoat2019','b','cts','ot',300,300,9,'yes','yes',52,'BOEM,USFWS,NOAA,NAVY',NULL,1),

/*  update dataset table */
/*    update dataset
	set
	parent_project = 2
	where dataset_id = 410
*/

-- select * from dataset


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
	source_obs_id int null, 
	dataset_id smallint not null,
	transect_id int null, 
	obs_dt date null,
	obs_tm time null,
	--obs_lat numeric null,
	--obs_lon numeric null,
	original_species_tx nvarchar(50) null,
	spp_cd nvarchar(4) not null,
	obs_count_intrans_nb smallint null,
	obs_count_general_nb smallint null, --should be not null, need to check 
	observer_tx nvarchar(20) null,
	observer_position nvarchar(20) null,
	seconds_from_midnight numeric null,
	original_age_tx nvarchar(50) null,
	age_id tinyint null,
	plumage_tx nvarchar(50) null,
	original_behavior_tx nvarchar(100) null,
	behavior_id tinyint null,
	original_sex_tx varchar(50) null,
	sex_id tinyint null,
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
	FOREIGN KEY(behavior_id) REFERENCES lu_behaviors(behavior_id),
	FOREIGN KEY(age_id) REFERENCES lu_age(age_id),
	FOREIGN KEY(sex_id) REFERENCES lu_sex(sex_id),
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
	data_citation nvarchar(2000) null,
	publications nvarchar(2000) null,
	publication_url nvarchar(2000) null,
	publication_DOI nvarchar(2000) null,
	PRIMARY KEY(id),
	FOREIGN KEY(dataset_id) REFERENCES dataset(dataset_id)
);

INSERT INTO links_and_literature(
	id, dataset_id, data_url, report, data_citation, publications, publication_url, publication_DOI)
	VALUES
	(1,15,'http://seamap.env.duke.edu/datasets/detail/322',NULL,'Hyrenbach, D. 2011. Hatteras Eddy Cruise 2004. Data downloaded from OBIS-SEAMAP (http://seamap.env.duke.edu/dataset/322) on yyyy-mm-dd.',NULL,NULL,NULL),
	(2,24,'http://seamap.env.duke.edu/datasets/detail/310',NULL,'Hyrenbach, D. and H. Whitehead. 2008. Sargasso 2004 - Seabirds . Data downloaded from OBIS-SEAMAP (http://seamap.env.duke.edu/dataset/310) on yyyy-mm-dd',NULL,NULL,NULL),
	(3,115,NULL,'http://www.briloon.org/uploads/BRI_Documents/Wildlife_and_Renewable_Energy/MABS%20Project%20Chapter%203%20-%20Connelly%20et%20al%202015.pdf',NULL,NULL,NULL,NULL),
	(4,148,NULL,'http://www.briloon.org/uploads/BRI_Documents/Wildlife_and_Renewable_Energy/MABS%20Project%20Chapter%203%20-%20Connelly%20et%20al%202015.pdf',NULL,NULL,NULL,NULL),
	(5,168,NULL,'http://www.briloon.org/uploads/BRI_Documents/Wildlife_and_Renewable_Energy/MABS%20Project%20Chapter%203%20-%20Connelly%20et%20al%202015.pdf',NULL,NULL,NULL,NULL),
	(6,117,NULL,'http://www.nefsc.noaa.gov/psb/AMAPPS/docs/NMFS_AMAPPS_2011_annual_report_final_BOEM.pdf',NULL,NULL,NULL,NULL),
	(7,143,NULL,'https://www.boem.gov/ESPIS/5/5272.pdf',NULL,NULL,NULL,NULL),
	(8,144,NULL,'https://www.boem.gov/ESPIS/5/5272.pdf',NULL,NULL,NULL,NULL),
	(9,169,NULL,'https://www.boem.gov/ESPIS/5/5272.pdf',NULL,NULL,NULL,NULL),
	(10,91,NULL,'http://www.nj.gov/dep/dsr/ocean-wind/report.htm'' AND ''http://www.nj.gov/dep/dsr/ocean-wind/final-volume-1.pdf',NULL,NULL,NULL,NULL),
	(11,113,NULL,'http://seaduckjv.org/pdf/studies/pr109.pdf',NULL,NULL,NULL,NULL),
	(12,29,'http://seamap.env.duke.edu/dataset/3','Southeast Fisheries Science Center, Marine Fisheries Service, NOAA. 1992. OREGON II Cruise. Cruise report. 92-01 (198).','Garrison, L. 2013. SEFSC Atlantic surveys 1992. Data downloaded from OBIS-SEAMAP (http://seamap.env.duke.edu/dataset/3) on yyyy-mm-dd.',NULL,NULL,NULL),
	(13,30,'http://seamap.env.duke.edu/dataset/1','Southeast Fisheries Science Center, Marine Fisheries Service, NOAA. 1998. Cruise Results: Summer Atlantic Ocean Marine Mammal Survey: NOAA Ship Relentless Cruise. Cruise report. RS 98-01 (3)','Garrison, L. 2013. SEFSC Atlantic surveys, 1998 (3). Data downloaded from OBIS-SEAMAP (http://seamap.env.duke.edu/dataset/1) on yyyy-mm-dd.',NULL,NULL,NULL),
	(14,31,'http://seamap.env.duke.edu/dataset/5 ; https://gcmd.nasa.gov/KeywordSearch/Metadata.do?Portal=idn_ceos&KeywordPath=%5BKeyword%3D%27shore+birds%27%5D&OrigMetadataNode=GCMD&EntryId=seamap5&MetadataView=Full&MetadataType=0&lbnode=mdlb2','Southeast Fisheries Science Center, Marine Fisheries Service, NOAA. 1999. Cruise Results; Summer Atlantic Ocean Marine Mammal Survey; NOAA Ship Oregon II Cruise. Cruise report. OT 99-05 (236)','Garrison, L. 2013. SEFSC Atlantic surveys 1999. Data downloaded from OBIS-SEAMAP (http://seamap.env.duke.edu/dataset/5) on yyyy-mm-dd.',NULL,NULL,NULL),
	(15,92,'http://seamap.env.duke.edu/datasets/detail/280',NULL,'Hyrenbach, D., F. Huettmann and J. Chardine. 2012. PIROP Northwest Atlantic 1965-1992. Data downloaded from OBIS-SEAMAP (http://seamap.env.duke.edu/dataset/280) on yyyy-mm-dd.',NULL,NULL,NULL),
	(16,7,'http://seamap.env.duke.edu/datasets/detail/280','http://www.whoi.edu/science/PO/hatterasfronts/marinemammal.html','Hyrenbach, D., F. Huettmann and J. Chardine. 2012. PIROP Northwest Atlantic 1965-1992. Data downloaded from OBIS-SEAMAP (http://seamap.env.duke.edu/dataset/280) on yyyy-mm-dd.',NULL,NULL,NULL),
	(17,80,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2010/MAY_ECOMON_DEL1004/CRUISE_REPORT_2010004DE.pdf',NULL,NULL,NULL,NULL),
	(18,81,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2010/NOV_ECOMON_DEL1012/CRUISE_REPORT_2010012DE.pdf',NULL,NULL,NULL,NULL),
	(19,42,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2009/AUG_ECOMON_DEL0909/CRUISE_REPORT_2009009DE.pdf',NULL,NULL,NULL,NULL),
	(20,38,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2009/JAN_ECOMON_DEL0902/CRUISE_REPORT_2009002DEL.pdf',NULL,NULL,NULL,NULL),
	(21,39,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2009/MAY_ECOMON_DEL0905/CRUISE_REPORT_2009005DE.pdf',NULL,NULL,NULL,NULL),
	(22,76,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2010/NOV_ECOMON_DEL1012/CRUISE_REPORT_2010012DE.pdf',NULL,NULL,NULL,NULL),
	(23,77,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2008/AUG_ECOMON_DEL0808/CRUISE_REPORT_2008008DE.pdf',NULL,NULL,NULL,NULL),
	(24,171,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2013/FEB_ECOMON_PC1301/CRUISE_REPORT_2013001PC.pdf',NULL,NULL,NULL,NULL),
	(25,131,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2012/FEB_ECOMON_DEL1202/CRUISE_REPORT_2012002DE.pdf',NULL,NULL,NULL,NULL),
	(26,82,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2010/AUG_ECOMON_DEL1009/CRUISE_REPORT_2010009DE.pdf',NULL,NULL,NULL,NULL),
	(27,79,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2010/JAN_ECOMON_DEL1001/CRUISE_REPORT_2010001DE.pdf',NULL,NULL,NULL,NULL),
	(28,33,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2007/MAY_ECOMON_DEL0706/CRUISE_REPORT_2007006DE.pdf',NULL,NULL,NULL,NULL),
	(29,74,NULL,'https://gcmd.gsfc.nasa.gov/search/Metadata.do?from=getdif&subset=GCMD&entry=%5BGCMD%5DGoMA-Platts_Bank_Aerial_Survey#metadata',NULL,NULL,NULL,NULL),
	(30,89,NULL,NULL,NULL,'Kristopher J. Winiarski, M. Louise Burt, Eric Rexstad, David L. Miller, Carol L. Trocki, Peter W. C.Paton, and Scott R. McWilliams. 2014. Integrating aerial and ship surveys of marine birds into a combineddensity surface model: A case study of wintering Common Loons. The Condor. 116(2):149-161','https://www.researchgate.net/publication/260553628_Integrating_aerial_and_ship_surveys_of_marine_birds_into_a_combined_density_surface_model_A_case_study_of_wintering_Common_Loons','10.1650/CONDOR-13-085.1'),
	(31,90,NULL,NULL,NULL,'Kristopher J. Winiarski, M. Louise Burt, Eric Rexstad, David L. Miller, Carol L. Trocki, Peter W. C.Paton, and Scott R. McWilliams. 2014. Integrating aerial and ship surveys of marine birds into a combineddensity surface model: A case study of wintering Common Loons. The Condor. 116(2):149-161','https://www.researchgate.net/publication/260553628_Integrating_aerial_and_ship_surveys_of_marine_birds_into_a_combined_density_surface_model_A_case_study_of_wintering_Common_Loons','10.1650/CONDOR-13-085.1'),
 	(32,390 ,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2016/AUG_ECOMON_PC1607/CRUISE_REPORT_2016007PC.pdf',NULL,NULL,NULL,NULL),
 	(33,391 ,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2016/MAY_ECOMON_GU1608/CRUISE_REPORT_2016008GU.pdf',NULL,NULL,NULL,NULL),
 	(34,388 ,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2015/MAY_ECOMON_HB1502/CRUISE_REPORT_2015002HB.pdf',NULL,NULL,NULL,NULL),
 	(35,389 ,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2015/OCT_ECOMON_GU1506/CRUISE_REPORT_2015006GU.pdf',NULL,NULL,NULL,NULL),
 	(36,387 ,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2014/MAR_ECOMON_GU1401/CRUISE_REPORT_2014001GU.pdf',NULL,NULL,NULL,NULL),
 	(37,385 ,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2013/JUN_ECOMON_GU1302/CRUISE_REPORT_2013002GU.pdf',NULL,NULL,NULL,NULL),
 	(38,386 ,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2013/NOV_ECOMON_GU1305/CRUISE_REPORT_2013005GU.pdf',NULL,NULL,NULL,NULL),
 	(39,383 ,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2011/FEB_ECOMON_DEL1102/CRUISE_REPORT_2011002DE.pdf',NULL,NULL,NULL,NULL),
 	(40,384 ,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2011/JUN_ECOMON_DEL1105/CRUISE_REPORT_2011005DE.pdf',NULL,NULL,NULL,NULL),
	(41,393 ,NULL,'https://www.nefsc.noaa.gov/HydroAtlas/2017/FEB_ECOMON_HB1701/CRUISE_REPORT_2017001HB.pdf',NULL,NULL,NULL,NULL),
	(42,173,'https://remote.normandeau.com/login.php','https://remote.normandeau.com/docs/Summary%20of%20Summer%202016%20Survey%201.pdf',NULL,NULL,NULL,NULL),
	(43,398,'https://remote.normandeau.com/login.php','https://remote.normandeau.com/docs/NYSERDA-Fall%202016%20Survey2_Summary.pdf',NULL,NULL,NULL,NULL),
	(44,399,'https://remote.normandeau.com/login.php','https://remote.normandeau.com/docs/NYSERDA%20Winter%202017%20-%20Survey%20Summary%20Report.pdf',NULL,NULL,NULL,NULL),
	(45,400,'https://remote.normandeau.com/login.php','https://remote.normandeau.com/docs/NYSERDA%20Spring%202017%20-%20Survey%20Summary%20Report.pdf',NULL,NULL,NULL,NULL),
	(46,401,'https://remote.normandeau.com/login.php','https://remote.normandeau.com/docs/NYSERDA%20Summer%202017%20-%20Survey%20Summary%20Report.pdf',NULL,NULL,NULL,NULL),
	(47,119,'http://iobis.org/explore/#/dataset/2656','http://ipt.iobis.org/obiscanada/resource?r=cws_eastcoastseabirdsatc',NULL,NULL,'http://iobis.org/explore/#/dataset/2656',NULL),
	(48,174,NULL,'https://www.nefsc.noaa.gov/psb/AMAPPS/docs/Annual%20Report%20of%202016%20AMAPPS_final.pdf',NULL,NULL,NULL,NULL),
	(49,160,NULL,'https://www.nefsc.noaa.gov/psb/AMAPPS/docs/NMFS_AMAPPS_2015_annual_report_Final.pdf',NULL,NULL,NULL,NULL),
	(50,149,NULL,'https://www.nefsc.noaa.gov/psb/AMAPPS/docs/NMFS_AMAPPS_2014_annual_report_Final.pdf',NULL,NULL,NULL,NULL),
	(51,116,NULL,'https://www.nefsc.noaa.gov/psb/AMAPPS/docs/NMFS_AMAPPS_2013_annual_report_FINAL3.pdf',NULL,NULL,NULL,NULL),
	(52,409,NULL,'https://www.nefsc.noaa.gov/psb/AMAPPS/docs/Final_2010AnnualReportAMAPPS_19Apr2011.pdf',NULL,NULL,NULL,NULL),
	(53,410,NULL,'https://www.nefsc.noaa.gov/psb/AMAPPS/docs/NMFS_AMAPPS_2012_annual_report_FINAL.pdf',NULL,NULL,NULL,NULL);

/*  update links_and_literature script template*/
/*  update links_and_literature
	set
	report = 'http://ipt.iobis.org/obiscanada/resource?r=cws_eastcoastseabirdsatc'
	publication_url = 'http://iobis.org/explore/#/dataset/2656'
	where dataset_id = 119
*/

-- select * from links_and_literature

/* notes
	-ECOMON Nov 2014 no birds in report? combined with Herring Acoustic https://www.nefsc.noaa.gov/HydroAtlas/2014/NOV_ECOMON_PC1405/CRUISE_REPORT_2014005PC.pdf
	-ECOMON Dec 2011 we might have this data listed as Nov? Tim White on boat. Not the same as Nov 2011, finish stations not hit in Nov https://www.nefsc.noaa.gov/HydroAtlas/2011/DEC_ECOMON_DEL1110/CRUISE_REPORT_2011010DE.pdf
*/

--create and populate progress_table table
CREATE TABLE progress_table (
	dataset_id smallint not null,
	dataset_name nvarchar(50) not null,
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

-- select * from progress_table
INSERT INTO progress_table(
	dataset_id, 
	share_level_id, 
	dataset_name, 
	action_required_or_taken,
	date_of_action, 
	who_will_act, 
	data_acquired,
	metadata_acquired, 
	report_acquired, 
	additional_info)
	VALUES
	(92,7,'PIROP','need to investigate',NULL,'KC',0,0,0,'Apparently already in database but across several other surveys, need to figure out which'),
	(93,0,'SEANET','need to investigate',NULL,'KC',0,0,0,'Not sure that we actually want this in here'),
	(96,0,'NantucketShoals1998','need to investigate',NULL,'TW',0,0,0,NULL),
	(97,0,'DEandChesBaysUSFWS1190','need to investigate',NULL,'MTJ/KC',0,0,0,NULL),
	(100,0,'AtlanticFlywaySeaducks','need to investigate',NULL,'MTJ/KC',0,0,0,NULL),
	(101,0,'DUMLOnslowBay2007','requested',CAST('2017-10-18' as date),'AW',0,0,0,'data provider on materinty leave, will contact again in a few months'),
	(106,0,'WaterfowlUSFWS2001','need to investigate',NULL,'MTJ/KC',0,0,0,NULL),
	(163,0,'RoyalSociety','need to investigate',NULL,'TW',0,0,0,NULL),
	(166,0,'BarHarborWW09','requested multiple times',CAST('2017-10-17' as date),'KC',0,0,0,NULL),
	(167,0,'BarHarborWW010','requested multiple times',CAST('2017-10-17' as date),'KC',0,0,0,NULL),
	(169,99,'BOEMHighDef_NC2011Camera','need to finish QA/QC',NULL,'KC',1,0,1,'There were issues with the gps and time'),
	(172,99,'BRIMaine2016','QA/QC in progress',NULL,'KC',1,0,0,NULL),
	(95,99,'StellwagenBankNMS_Jun2012','QA/QC in progress',NULL,'KC',1,1,0,'Script from Arliss as guide'),	
	(182,99,'StellwagenBankNMS_Aug2012','QA/QC in progress',NULL,'KC',1,1,0,'Script from Arliss as guide'),
	(183,99,'StellwagenBankNMS_Oct2012','QA/QC in progress',NULL,'KC',1,1,0,'Script from Arliss as guide'),
	(184,99,'StellwagenBankNMS_Jan2013','QA/QC in progress',NULL,'KC',1,1,0,'Script from Arliss as guide'),
	(185,99,'StellwagenBankNMS_Apr2013','QA/QC in progress',NULL,'KC',1,1,0,'Script from Arliss as guide'),
	(186,99,'StellwagenBankNMS_Jun2013','QA/QC in progress',NULL,'KC',1,1,0,'Script from Arliss as guide'),
	(187,99,'StellwagenBankNMS_Aug2013','QA/QC in progress',NULL,'KC',1,1,0,'Script from Arliss as guide'),
	(188,99,'StellwagenBankNMS_Oct2013','QA/QC in progress',NULL,'KC',1,1,0,'Script from Arliss as guide'),
	(189,99,'StellwagenBankNMS_Apr2014','QA/QC in progress',NULL,'KC',1,1,0,'Script from Arliss as guide'),
	(190,99,'StellwagenBankNMS_Jun2014','QA/QC in progress',NULL,'KC',1,1,0,'Script from Arliss as guide'),
	(191,99,'StellwagenBankNMS_Aug2014','QA/QC in progress',NULL,'KC',1,1,0,'Script from Arliss as guide'),
	(192,99,'StellwagenBankNMS_Sep2014','QA/QC in progress',NULL,'KC',1,1,0,'Script from Arliss as guide'),
	(193,99,'StellwagenBankNMS_Oct2014','QA/QC in progress',NULL,'KC',1,1,0,'Script from Arliss as guide'),
	(194,99,'StellwagenBankNMS_Dec2014','QA/QC in progress',NULL,'KC',1,1,0,'Script from Arliss as guide'),
	(195,99,'StellwagenBankNMS_Jun2015','QA/QC in progress',NULL,'KC',1,1,0,'Script from Arliss as guide'),
	(196,99,'StellwagenBankNMS_Aug2015','QA/QC in progress',NULL,'KC',1,1,0,'Script from Arliss as guide'),
	(197,99,'StellwagenBankNMS_Sep2015','QA/QC in progress',NULL,'KC',1,1,0,'Script from Arliss as guide'),
	(198,99,'StellwagenBankNMS_Oct2015','QA/QC in progress',NULL,'KC',1,1,0,'Script from Arliss as guide'),
	(199,99,'StellwagenBankNMS_Dec2015','QA/QC in progress',NULL,'KC',1,1,0,'Script from Arliss as guide'),
	(200,99,'StellwagenBankNMS_Aug2011','QA/QC in progress',NULL,'KC',1,1,0,'Script from Arliss as guide'),
	(201,99,'StellwagenBankNMS_Sep2011a','QA/QC in progress',NULL,'KC',1,1,0,'Script from Arliss as guide'),
	(202,99,'StellwagenBankNMS_Sep2011b','QA/QC in progress',NULL,'KC',1,1,0,'Script from Arliss as guide'),
	(203,99,'StellwagenBankNMS_Dec2011','QA/QC in progress',NULL,'KC',1,1,0,'Script from Arliss as guide'),
	(204,99,'StellwagenBankNMS_Oct2011','QA/QC in progress',NULL,'KC',1,1,0,'Script from Arliss as guide'),
	(175,9,'DeepwaterWindBlockIsland_boat_Nov09a','QA/QC started',NULL,'KC',1,0,0,NULL),
	(205,9,'DeepwaterWindBlockIsland_boat_Nov09b','QA/QC started',NULL,'KC',1,0,0,NULL),
	(206,9,'DeepwaterWindBlockIsland_boat_Dec10a','QA/QC started',NULL,'KC',1,0,0,NULL),
	(207,9,'DeepwaterWindBlockIsland_boat_Dec10b','QA/QC started',NULL,'KC',1,0,0,NULL),
	(208,9,'DeepwaterWindBlockIsland_boat_Jan10a','QA/QC started',NULL,'KC',1,0,0,NULL),
	(209,9,'DeepwaterWindBlockIsland_boat_Jan10b','QA/QC started',NULL,'KC',1,0,0,NULL),
	(210,9,'DeepwaterWindBlockIsland_boat_Feb10a','QA/QC started',NULL,'KC',1,0,0,NULL),
	(211,9,'DeepwaterWindBlockIsland_boat_Feb10b','QA/QC started',NULL,'KC',1,0,0,NULL),
	(212,9,'DeepwaterWindBlockIsland_boat_Mar10a','QA/QC started',NULL,'KC',1,0,0,NULL),
	(213,9,'DeepwaterWindBlockIsland_boat_Mar10b','QA/QC started',NULL,'KC',1,0,0,NULL),
	(214,9,'DeepwaterWindBlockIsland_boat_Apr10a','QA/QC started',NULL,'KC',1,0,0,NULL),
	(215,9,'DeepwaterWindBlockIsland_boat_Apr10b','QA/QC started',NULL,'KC',1,0,0,NULL),
	(216,9,'DeepwaterWindBlockIsland_boat_May10a','QA/QC started',NULL,'KC',1,0,0,NULL),
	(217,9,'DeepwaterWindBlockIsland_boat_May10b','QA/QC started',NULL,'KC',1,0,0,NULL),
	(218,9,'DeepwaterWindBlockIsland_boat_Jun10a','QA/QC started',NULL,'KC',1,0,0,NULL),
 	(219,9,'DeepwaterWindBlockIsland_boat_Jun10b','QA/QC started',NULL,'KC',1,0,0,NULL),
 	(220,9,'DeepwaterWindBlockIsland_boat_Aug11a','need to request',NULL,'KC',0,0,0,NULL),
 	(221,9,'DeepwaterWindBlockIsland_boat_Aug11b','need to request',NULL,'KC',0,0,0,NULL),
 	(222,9,'DeepwaterWindBlockIsland_boat_Sep11a','need to request',NULL,'KC',0,0,0,NULL),
	(223,9,'DeepwaterWindBlockIsland_boat_Sep11b','need to request',NULL,'KC',0,0,0,NULL),
	(224,99,'StellwagenBankNMS_SS_Jun2012','QA/QC in progress',NULL,'KC',1,1,0,NULL),
	(225,99,'StellwagenBankNMS_SS_Aug2012','QA/QC in progress',NULL,'KC',1,1,0,NULL),
	(226,99,'StellwagenBankNMS_SS_Oct2012','QA/QC in progress',NULL,'KC',1,1,0,NULL),
	(227,99,'StellwagenBankNMS_SS_Jan2013','QA/QC in progress',NULL,'KC',1,1,0,NULL),
	(228,99,'StellwagenBankNMS_SS_Apr2013','QA/QC in progress',NULL,'KC',1,1,0,NULL),
	(229,99,'StellwagenBankNMS_SS_Jun2013','QA/QC in progress',NULL,'KC',1,1,0,NULL),
	(230,99,'StellwagenBankNMS_SS_Aug2013','QA/QC in progress',NULL,'KC',1,1,0,NULL),
	(231,99,'StellwagenBankNMS_SS_Oct2013','QA/QC in progress',NULL,'KC',1,1,0,NULL),
	(232,99,'StellwagenBankNMS_SS_Apr2014','QA/QC in progress',NULL,'KC',1,1,0,NULL),
	(233,99,'StellwagenBankNMS_SS_Jun2014','QA/QC in progress',NULL,'KC',1,1,0,NULL),
	(234,99,'StellwagenBankNMS_SS_Aug2014','QA/QC in progress',NULL,'KC',1,1,0,NULL),
	(235,99,'StellwagenBankNMS_SS_Sep2014','QA/QC in progress',NULL,'KC',1,1,0,NULL),
	(236,99,'StellwagenBankNMS_SS_Oct2014','QA/QC in progress',NULL,'KC',1,1,0,NULL),
	(237,99,'StellwagenBankNMS_SS_Dec2014','QA/QC in progress',NULL,'KC',1,1,0,NULL),
	(238,99,'StellwagenBankNMS_SS_Jun2015','QA/QC in progress',NULL,'KC',1,1,0,NULL),
	(239,99,'StellwagenBankNMS_SS_Aug2015','QA/QC in progress',NULL,'KC',1,1,0,NULL),
	(240,99,'StellwagenBankNMS_SS_Sep2015','QA/QC in progress',NULL,'KC',1,1,0,NULL),
	(241,99,'StellwagenBankNMS_SS_Oct2015','QA/QC in progress',NULL,'KC',1,1,0,NULL),
	(242,99,'StellwagenBankNMS_SS_Dec2015','QA/QC in progress',NULL,'KC',1,1,0,NULL),
	(387,0,'EcoMonMar2014','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(389,0,'EcoMonOct2015','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(388,0,'EcoMonMay2015','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(391,0,'EcoMonMay2016','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(390,0,'EcoMonAug2016','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(393,0,'EcoMonFeb2017','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(385,0,'EcoMonJun2013','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(386,0,'EcoMonNov2013','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(383,0,'EcoMonFeb2011','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(384,0,'EcoMonJun2011','need to request',NULL,'TW/KC',0,0,1,'In contact with TW and AW about this'),
	(395,99,'FWS_AMAPPS_Aerial_Summer2017','QA/QC in progress',NULL,'KC',1,0,0,'In contact with the last three observers'),
	(173,0,'NYSERDA_APEM_1','requested',CAST('2017-10-18' as date),'KC',0,0,1,'working on details with provider'),
	(398,0,'NYSERDA_APEM_2','requested',CAST('2017-10-18' as date),'KC',0,0,1,'working on details with provider'),
	(399,0,'NYSERDA_APEM_3','requested',CAST('2017-10-18' as date),'KC',0,0,1,'working on details with provider'),
	(400,0,'NYSERDA_APEM_4','requested',CAST('2017-10-18' as date),'KC',0,0,1,'working on details with provider'),
	(401,0,'NYSERDA_APEM_5','requested',CAST('2017-10-18' as date),'KC',0,0,1,'working on details with provider'),
	(243,9,'DeepwaterWindBlockIsland0910_camera','needs QA/QC',NULL,'KC',1,0,0,'this will need reformating'),
	(119,9,'ECSAS','Data downloaded from OBIS, need to request effort data',NULL,'KC',1,1,0,'Arliss has full dataset');

/* update progress table script template */  	
/*	update progress_table
  	set 
 	date_of_action=CAST('2017-11-08' as date),
 	action_required_or_taken = 'downloaded from OBIS, need to request effort data',
 	additional_info='Arliss has full dataset',
 	data_acquired=1,
 	metadata_acquired=1,
    share_level_id = 9
 	where dataset_id = 119
*/

/* select progress table script template */ 
--  select * from progress_table

--create boem lease block table
CREATE TABLE boem_lease_blocks (
	prot_nb nvarchar(20) not null,
 	block_nb nvarchar(20) not null,
	geom_line nvarchar(MAX) not null,
	Primary Key (prot_nb,block_nb)
);
--

-- create data request table
CREATE TABLE requests (
	request_id smallint not null,
	request_type nvarchar(10) not null, 
	requester smallint not null,
	request_info nvarchar(1000) not null, 
	date_requested date not null,
	request_status nvarchar(20) not null, --"filled","not filled","partially filled"
	date_filled date null,
	additional_notes nvarchar(1000) null,
	PRIMARY KEY(request_id),
	FOREIGN KEY(requester) REFERENCES lu_people([user_id])
);
GO

INSERT INTO requests(
	request_id,request_type,requester,request_info,date_requested,
	request_status,date_filled,additional_notes)
	VALUES
	(1,'data',68,'Segmentation product of all datasets used in Phase 1 of NOAA modeling and additional data for phase 2, see share google spreadsheet for details',
		CAST('2014-01-01' AS DATE),'filled',CAST('2017-04-04' AS DATE),
		'NOAA will need additional datasets to quality control their model in late 2017'),
	(2,'data',67,'Double Crested Cormorants (DCCO) for all of the East Coast, but mostly interested in NC',
		CAST('2016-09-27' AS DATE),'partially filled',CAST('2017-01-25' AS DATE),
		'should requery and resend once all the datasets are in sql server, we only sent old data'),
	(3,'data',69,'all shareable data to go into AKN',CAST('2016-05-12' AS DATE),'partially filled',CAST('2016-10-28' AS DATE),
		'effort and observation information for the old data was sent. More discussion needs to happen with how these data go into AKN. They also need the transect table'),
	(4,'data',70,'Common Loon (COLO) between June 15-Aug 15, years 1910- present',CAST('2016-05-10' AS DATE),
		'not filled',NULL,NULL),
	(5,'data',71,'Razorbills (RAZO), looking for any counts from Maine to Florida at sea for winter 2012-13',
		CAST('2016-04-10' AS DATE),'not filled',NULL,NULL),
	(6,'data',3,'MassCEC',CAST('2017-06-29' AS DATE),'filled',CAST('2017-06-29' AS DATE),NULL),
	(7,'data',50,'All FWS AMAPPS and Seaduck data',CAST('2017-07-12' AS DATE),'filled',CAST('2017-07-17' AS DATE),'This is for an R5 GIS exercise'),
	(8,'data',62,'Segmented NOAA phase 2 product',CAST('2017-07-5' AS DATE),'filled',CAST('2017-07-5' AS DATE),NULL),
	(9,'data',3,'MassCEC',CAST('2017-06-29' AS DATE),'filled',CAST('2017-06-29' AS DATE),'requested an update for another project, version 2 of data'),
	(10,'service',62,'service request to segment EcoMon data not yet submitted to us',CAST('2017-09-14' AS DATE),'filled',CAST('2017-07-5' AS DATE),NULL),
	(11,'data',72, 'Ecological Services BCPE data', CAST('2017-8-15' AS DATE), 'filled', CAST('2017-8-25' AS DATE), NULL),
	(12,'service',72, 'Ecological Services analysis for BCPE data', CAST('2017-8-15' AS DATE), 'filled', CAST('2017-9-15' AS DATE), NULL),
	(13,'data',73, 'AKN request, data and information', CAST('2017-7-28' AS DATE), 'patially filled',NULL, 'back and forth with Rob on details and info'),
	(14,'data',59,'official survey name for each dataset listed in the source_dataset_id column', CAST('2017-09-8' AS DATE), 'filled', CAST('2017-09-11' AS DATE), NULL),
	(15,'service',74,'summary of species and surveys within the new seamount & canyon marine national monuments - request from refuges, Caleb relayed', CAST('2017-11-20' AS DATE), 'filled', CAST('2017-11-29' AS DATE), NULL),
	(16,'service',75,'NWASC boundaries', CAST('2017-11-20' AS DATE), 'filled', CAST('2017-11-29' AS DATE), 'Meghan is looking to create a polygon for pulling AKN data for ECOS for Atlantic birds'),
	(17,'service', 76 ,'Bug data summary for a RI reporter', CAST('2017-12-20' AS DATE),'not filled', NULL, NULL),
	(18,'data', 3 ,'all tern data', CAST('2017-12-04' AS DATE),'filled', CAST('2017-12-08' AS DATE), NULL);

-- example: (id, type, person, description, CAST('req. date' AS DATE), status, CAST('date filled' AS DATE), notes);
/*  update data_requests script template */  	
/*	update data_requests 
	set date_filled = CAST('2017-07-17' AS DATE), 
	request_status = 'filled'  
	where request_id = 7
*/

/*  look up people who need to be contacted for a project */ 
/*  select * from requests 
	join lu_people 
	on requester = user_id;
*/
