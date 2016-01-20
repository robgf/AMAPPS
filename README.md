# AMAPPS

[id]: http://www.nefsc.noaa.gov/psb/AMAPPS/  
This repository contains the scripts to QA/QC the USFWS Atlantic Marine Assessment Program for Protected Species ([AMAPPS][id]) aerial data and prepare it for import into the USFWS AMAPPS access database and the USFWS maintained Northwest Atlantic Seabird Catalog (NWASC). 

Read Me for AMAPPS data management
========================================================
Written by: Kaycee Coleman   
Creadted: Nov. 2015     

For USFWS MB personel, all documentation is housed in M:/seabird_database folder and for now all working code is in the fs1/SeaDuck/NewCodeFromJeff_20150720 folder. This repository and QA/QC scripts are a work in progress, not a finished product  

1) Understanding the data
--------------------------------------------------------
[id2]: https://my.usgs.gov/confluence/display/mbmdl/Data+lifecycle+development+for+Migratory+Bird+surveys+Home  
**For USFWS MB personel, in seabird_database/documentation Read:**
- SeabirdSurvey_SOP.doc
- seabirds key tables structure Aug2013
- Final and progress reports (in Reports folder)
- StepsForOutput.doc
- Seabird Database Quality Checking and Editing_Jan26 2012.doc
- Data Proofing.doc
- Editing\_Database\_File_Registry.doc
- In addition it might help to look at the Data lifecycle development for Migratory Birds surveys [website][id2]. You will need premission to log onto this site. 

[id9]: https://www.researchgate.net/publication/281667883_Statistical_guidelines_for_assessing_marine_avian_hotspots_and_coldspots_A_case_study_on_wind_energy_development_in_the_US_Atlantic_Ocean
[id10]: https://www.researchgate.net/publication/259163159_Fitting_statistical_distributions_to_sea_duck_count_data_Implications_for_survey_design_and_abundance_estimation

**References:**    
- O'Connell, A., Gardner, B., Gilbert, A., and Laurent, K. 2009. Compendium of Avian Occurrence Information for the Continental Shelf Waters along the Atlantic Coast of the United States. Final Report to USFWS. USGS, Patuxent Wildlife Research Center.
- Zipkin, Elise F., Leirness, Jeffery B., Kinlan, Brian P., O'Connell, Allan F., and Emily D. Silverman. 2014. [Fitting statistical distributions to sea duck count data: Implications for survey design and abundance estimation][id10]. STATISTICAL METHODOLOGY 17:67–81.  DOI: 10.1016/j.stamet.2012.10.002
- Zipkin, Elise F., Kinlan, Brian P., Sussman, Allison, Rypkema, Diana, Wimer, Mark, and Allan F. O'Connell. 2015. [Statistical guidelines for assessing marine avian hotspots and coldspots: A case study on wind energy development in the U.S. Atlantic Ocean][id9]. BIOLOGICAL CONSERVATION 191:216-223. DOI: 10.1016/j.biocon.2015.06.035 



2) Where to obtain survey data for processing 
--------------------------------------------------------
[id3]: https://connect.doi.gov/fws/Portal/acjv/seabird/SitePages/Home.aspx
- AMAPPS data can be found on the SharePoint [site][id3]. You will need premission to log onto this site. Download all of the processed observation and track files and save them in the Survey_Data/AMAPPS/AMAPPS_year_mo folder.


3) Quality Control / Data Processing in R and GIS 
--------------------------------------------------------
**Process:**  
- This section describes how to QA/QC the data using R, ArcMap, and Python within ArcMap. You will run "part1", check the shapefiles in ArcMap, save those files, then run "part2" of the scripts. 

**Scripts needed:**  
- run_processSurveyData_part1.R (loads packages and functions, this is the file you should alter)
    - processSurveyData_part1.R (function used by run_processSurveyData_part1.R, do not change this)
    - RProfile.R loads neccessary librarys and runs the following functions: 
        - addBegEnd\_GISeditObsTrack.R (this is for after the GIS edits, if points were deleted and new BEG/END counts need to be added)
        - addBegEnd\_Obs.R (this adds BEG/END counts if needed)
        - addCoch.R (Adds a condition change (COCH) row when one was not reported with condition value "0" and count "0")
        - checkBEGCNTandENDCNTnumbers.R (Reports transects with errors in BEGCNT and ENDCNT rows)
        - checkConditionChange.R 
        - combineByName.R 
        - combineObsTrack.R (combines the observation and track files. When running *combineObsTrack.R*, if you see **"Error in BEG/END"** then there is an error in how the begin count and end count rows line up, this needs to be fixed, do not continue.)
        - conditionCodeErrorChecks.R 
        - getDatabase.R 
        - getObsFiles.R (reads in the crew#_mmddyyy_birds.txt or .asc files and turns them into the "obs" and "Obs.Crew#" tables)
        - getTrackFiles.R (reads in the track files)
        - GPSFix.R 
        - obsFilesErrorChecks.R 
        - runArcGISpy.R 
        - SECFix.R 
        - sourceDir.R 
    - ObsFilesFix\_yearlabel.R 
        - This script is unique to each input year/season file and fixes errors in the observation files:  
           a) Flags offine/useless information  
           b) Fixes incorrect type codings  
           c) Fix condition change errors
           d) Breaks apart mixed flock records
    - GISeditObsTrack (python file used in ArcMap to fix spatial errors in the data)
- processSurveyData_part2.R (after the GIS edits this rechecks the data for errors caused in manual editing and combines the files for entry into the Atlantic_Coast_Surveys and NWASC databases)
 

**Files Needed:**  
- AMAPPS observation files (downloaded from SharePoint)
- AMAPPS transect files (downloaded from SharePoint)
- NWASC_codes.xlsx (list of all of the species codes used, path defined as dbpath in the process scripts)
- ObsFilesFix\_yearlabel.R   
        - Creating yearlab\_ObsFilesFix.R: You will add to this script as you run through the error checks and find new errors. The *AMAPPS\_yearlab\_AOUErrors.xlsx* and *AMAPPS\_yearlab\_ObsFileErrors.xlsx* generated in the *DataProcessing -> Surveys -> AMAPPS -> AMAPPS\_yearlab* folder will help inform you of which errors to fix in the yearlab\_ObsFilesFix.R script. These are often typos. You may need to listen to the corresponding WAV file (on the SharePoint site) to find out what the observer was trying to enter. Common errors should be included in the yearlab\_ObsFilesFix.R script prior if you need to look them up for reference (e\.g\. changing TOWER to code TOWR).  Also if there are corrections in the pilot/observer notes these corrections should be included in the yearlab\_ObsFilesFix.R script.  
- GISeditObsTrack_template (ArcGIS ArcMap Document)  
        - used to create shapefiles for each crew/day
- atlanticCoastline_buffer_halfNM (shapefile)  
        - used to check if points are on land
- all_atlantic_flylines_wNE_extended (shapefile)   
        - used to check if transects are labeled incorrectly or if points are too far off a transect


**Manual editing in GIS (after run_processSurveyData_part1.R and before processSurveyData_part2.R):**  

  a) open the shapefiles created in part1    
  b) visually inspect each crew/day shapefile (check the points flagged that are on land, track points that aren't on a transect, points were the pilots are not flying a straight line where they could be looping back around, etc.)  

 
>   Flag color coding:  
>    0,0,0 = grey = no error  
>    0,0,1 = purple = bearing error  
>    0,1,0 = yellow = distance error  
>    1,0,0 = red = start or end point  
>    0,1,1 = green = start or end point and bearing error  
>    1,1,1 = green = start or end point, bearing, and distance  
>    1,1,0 = green = start or end point and distance error  
>    1,0,1 = purple = distance and bearing error   

  c) delete points you find unfit, they will be saved in a csv format in part2. These points should be track file points NOT observation points. You can tell this by checking the information when you click on that point. If you find an issue with an observation point be certain that it is an error before deleting it.   
 - Manually delete suspicious points
        - First use the information tool to check if it is an observation or a waypoint. If it is an observation it is most likely a true data point.  The land maps in ArcMap may not be accurate. 
        - As a rule of thumb, if there are less than 6 points crossing an Island most likely you can leave these. You are trying to target larger areas across land. The island topography could be off. 
        - Use the editor tool
        - Click on the suspicious point
        - Hit delete

  d) save each crew/day shapefile in an edited_shapefiles folder  
- Save each edited layer as a shapefile
        - Right click on layer
        - Click on data
        - Click on export data 
        - Click on the folder icon and 
        - Switch 'save type as' to shapefile


4) Entering the data in the Access "Atlantic_Coast_Surveys" database 
--------------------------------------------------------
**Process:**  
- The "Atlantic_Coast_Surveys" database houses all of the AMAPPS data but excludes nonbirds (except for boats). Nonbird and offline data are saved seperately or in the Misc_observations table of the "Atlantic_Coast_Surveys" database. The database includes tables for  "Crew_Information", "Observations", "Survey_Information", "Tracks", and "Transect_Information". 

**Scripts needed:**  
- Add2Database.R  
        - CalcDistFlown.py (calculates distance flown by the pilots on each transect)  
        - CalcObsCovariates.py (if you need bathymetry, shelf slope etc.)  
        - UpdateGeoDatabase.py   
- Add2Database2.R (formats the data to go into each table and adds the data to the access "Atlantic_Coast_Surveys" database)     
- ArcGISCalc4Database.R (these are in Jeff's "old" folder so might reconsider this process)  
        - TrackFileSort.R  
        - TrackFileSEGCNTChange.R  
        - CreateID4DistFlownCalc.R  
        - AvgCondition.R  
    

5) Reformating and entering the data in the NWASC Database 
--------------------------------------------------------
**Process:**  
- All offline, bird, and nonbird data are entered into the NWASC.   
- Segmentation of the data for NOAA happens once the data is in the NWASC on all of the NWASC data at the same time (not by dataset).

**Scripts needed:**  
- R script
- SQL script


6) Archiving the data 
--------------------------------------------------------
**Process:**  
[id4]: http://www.nodc.noaa.gov/cgi-bin/OAS/prd/accession/0115356
- Once the data has been entered into the NWASC database, the data are sent to the NOAA National Oceanographic Data Center (NODC) to be archived. A past submission can be seen [here][id4] (accessions_id: 0115356). Datasets that are already in the NODC can be found in the DataSets\_in_\NODC.xlsx file.

**Scripts needed:**
- create_vw_data_output_nodc_dec2013 (SQL file to create NODC view excluding some datasets that shouldn't be public or were not designed for bird counts)

[id5]:https://www.nodc.noaa.gov/s2n/
[id6]:http://www.nodc.noaa.gov/archive/arc0070/0115356/1.1/data/0-data/seabird_data_archive_NODC_30Dec2013.csv
[id7]:http://www.nodc.noaa.gov/archive/arc0070/0115356/1.1/data/0-data/seabird_data_structure_NODC_30Dec2013.csv
[id8]:http://www.nodc.noaa.gov/archive/arc0070/0115356/1.1/data/0-data/Atlantic%20Offshore%20Seabird%20Dataset%20Catalog_NODC%20Metadata_FGDC.xml

a) All data-object-tables from the database need to be extracted and combined in one flat 'csv' file, [see old][id6]  
b) Prepare a file with column descriptions, [see old][id7]  
c) Prepare a FGDC record metadata file, [see old][id8]  
d) Report needs to be in 'pdf' format.  
  
The data should be submitted using the submission [website][id5]. 


