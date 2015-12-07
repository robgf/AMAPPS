# AMAPPS

[id]: http://www.nefsc.noaa.gov/psb/AMAPPS/  
This repository contains the scripts to QA/QC the USFWS Atlantic Marine Assessment Program for Protected Species ([AMAPPS][id]) aerial data and prepare it for import into the USFWS AMAPPS access database and the USFWS maintained Northwest Atlantic Seabird Catalog (NWASC) 

Read Me for AMAPPS data management
========================================================
Written by: Kaycee Coleman   
Creadted: Nov. 2015     

For USFWS MB personel, all documentation is housed in M:/seabird_database folder and for now all working code is in the SeaDuck/NewCodeFromJeff_20150720 folder. This repository and QA/QC scripts are a work in progress, not a finished product  

1) Understanding the data
--------------------------------------------------------
**For USFWS MB personel, in seabird_database/documentation Read:**
- SeabirdSurvey_SOP.doc
- seabirds key tables structure Aug2013
- Final and progress reports
- StepsForOutput.doc
- Final Seabird Database Report.doc
- Seabird Database Quality Checking and Editing_Jan26 2012.doc
- Data Proofing.doc
- Editing\_Database\_File_Registry.doc
[id2]: https://my.usgs.gov/confluence/display/mbmdl/Data+lifecycle+development+for+Migratory+Bird+surveys+Home
- In addition it might help to look at the Data lifecycle development for Migratory Birds surveys [website][id2]. You will need premission to log onto this site. 


**References:**    
- O'Connell, A., Gardner, B., Gilbert, A., and Laurent, K. 2009. Compendium of Avian Occurrence Information for the Continental Shelf Waters along the Atlantic Coast of the United States. Final Report to USFWS. USGS, Patuxent Wildlife Research Center.
- Zipkin, Elise F., Leirness, Jeffery B., Kinlan, Brian P., O'Connell, Allan F., and Emily D. Silverman. 2012. Fitting statistical distributions to sea duck count data: implications for survey design and abundance estimation


2) Where to obtain survey data for processing
--------------------------------------------------------
[id3]: https://connect.doi.gov/fws/Portal/acjv/seabird/SitePages/Home.aspx
- AMAPPS data can be found on the SharePoint [site][id3]. You will need premission to log onto this site. 


3) Quality Control / Data Processing in R and GIS
--------------------------------------------------------
Process:  
- This section describes how to QA/QC the data using R, ArcMap, and Python within ArcMap. You will run "part1", check the shapefiles in ArcMap, save those files, then run "part2" of the scripts. 

Scripts needed:  
- run_processSurveyData_part1.R (loads packages and functions, this is the file you should alter)
    - processSurveyData_part1.R (function used by run_processSurveyData_part1.R, do not change this)
    - RProfile.R loads neccessary librarys and runs the following functions: 
        - addBegEnd\_GISeditObsTrack.R 
        - addBegEnd\_Obs.R 
        - addCoch.R (Adds a condition change (COCH) row when one was not reported with condition value "0" and count "0")
        - checkBEGCNTandENDCNTnumbers.R (Reports transects with errors in BEGCNT and ENDCNT rows)
        - checkConditionChange.R 
        - combineByName.R 
        - combineObsTrack.R (when running *combineObsTrack.R*, if you see **"Error in BEG/END"** then there is an error in how the begin count and end count rows line up, this needs to be fixed, do not continue.)
        - conditionCodeErrorChecks.R 
        - getDatabase.R 
        - getObsFiles.R (reads in the crew#_mmddyyy_birds.txt or .asc files and turns them into the "obs" and "Obs.Crew#" tables)
        - getTrackFiles.R 
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
    - GISeditObsTrack (python file used in ArcMap)
- processSurveyData_part2.R
 

Files Needed:  
- AMAPPS observation files (downloaded from SharePoint)
- AMAPPS transect files (downloaded from SharePoint)
- NWASC_codes.xlsx (list of all of the species codes used)
- Creating yearlab\_ObsFilesFix.R: The *AMAPPS\_yearlab\_AOUErrors.xlsx* and *AMAPPS\_yearlab\_ObsFileErrors.xlsx* generated in the *DataProcessing -> Surveys -> AMAPPS -> AMAPPS\_yearlab* folder will help inform you of which errors to fix in the yearlab\_ObsFilesFix.R script. These are often typos. You may need to listen to the corresponding WAV file to find out what the observer was trying to enter. Common errors should be included in the yearlab\_ObsFilesFix.R script prior if you need to look them up for reference (e\.g\. changing TOWER to code TOWR).  Also if there are corrections in the pilot/observer notes these corrections should be included in the yearlab\_ObsFilesFix.R script.  


4) Entering the data in the Access "Atlantic_Coast_Surveys" database
--------------------------------------------------------
Process:  
- The "Atlantic_Coast_Surveys" database houses all of the AMAPPS data but excludes nonbirds. Nonbird and offline data are saved seperately.

Scripts needed:  
- Add2Database.R
- Add2Database2.R
- ArcGISCalc4Database.R (these are in Jeff's "old" folder so might reconsider this process)
    - TrackFileSort.R
    - TrackFileSEGCNTChange.R
    - CreateID4DistFlownCalc.R
    - AvgCondition.R
- RunArcGISpy function
    - CalcDistFlown.py
    - CalcObsCovariates.py
    - UpdateGeoDatabase.py

    
5) Reformating and entering the data for the NWASC Database
--------------------------------------------------------
Process:  
- All offline, bird, and nonbird data are entered into the NWASC. Segmentation of the data for NOAA also happens at this stage, once it is in the NWASC.

Scripts needed:  


6) Archiving the data
--------------------------------------------------------
Process:  
[id4]: http://www.nodc.noaa.gov/cgi-bin/OAS/prd/accession/0115356
- Once the data has been entered into the NWASC database, the data are sent to the NOAA National Oceanographic Data Center (NODC) to be archived. A past submission can be seen [here][id4] (accessions_id: 0115356). Datasets that are already in the NODC can be found in the DataSets\_in_\NODC.xlsx file.

[id5]: https://www.nodc.noaa.gov/s2n/
The data should be submitted using the submission [website][id5]. 


