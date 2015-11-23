# AMAPPS
This repository contains the scripts to QA/QC the USFWS AMAPPS aerial data and prepare it for import into the NWASC database   

Read Me for AMAPPS data management
========================================================
Written by: Kaycee Coleman   
Creadted: Nov. 2015     

All documentation is housed in M:/seabird_database folder and for now all working code is in the SeaDuck/NewCodeFromJeff_20150720 folder. This repository and QA/QC scripts are a work in progress, not a finished product  

*The majority of this README was written off of the old scripts and needs to be altered for the new scripts*

1) Understanding the data
--------------------------------------------------------
**Read:**
- SeabirdSurvey_SOP.doc
- seabirds key tables structure Aug2013
- Final and progress reports
- StepsForOutput.doc
- Final Seabird Database Report.doc
- Seabird Database Quality Checking and Editing_Jan26 2012.doc
- Data Proofing.doc
- Editing\_Database\_File_Registry.doc

**Types of Surveys within the NWASC**
[id]: http://www.nefsc.noaa.gov/psb/AMAPPS/
- **AMAPPS**: Altantic Marine Assessment Program for Protected Species (check out their [website][id])

**References:**    
- O'Connell, A., Gardner, B., Gilbert, A., and Laurent, K. 2009. Compendium of Avian Occurrence Information for the Continental Shelf Waters along the Atlantic Coast of the United States. Final Report to USFWS. USGS, Patuxent Wildlife Research Center.
- Zipkin, Elise F., Leirness, Jeffery B., Kinlan, Brian P., O'Connell, Allan F., and Emily D. Silverman. 2012. Fitting statistical distributions to sea duck count data: implications for survey design and abundance estimation

[id2]: https://my.usgs.gov/confluence/display/mbmdl/Data+lifecycle+development+for+Migratory+Bird+surveys+Home
In addition it might help to look at the Data lifecycle development for Migratory Birds surveys [website][id2] that Emily Silverman and Nathan Zimpfer have created. You will need premission to log onto this site from Nate. 

2) Where to obtain survey data for processing
--------------------------------------------------------
[id3]: https://connect.doi.gov/fws/Portal/acjv/seabird/SitePages/Home.aspx
- **AMAPPS** data can be found on the SharePoint [site][id3]
- Other data may need to be obtained via email, email the person listed in the data table as the main point of contact

3) Quality Control / Data Processing in GIS
--------------------------------------------------------
- This creates "TrackFileEdit2013_GISedits.csv" used in step 10 of "yearlab\_ObsTrackEdit.R"

4) Quality Control / Data Processing in R
--------------------------------------------------------
Processing scripts for **AMAPPS**:
- yearlab\_ObsTrackEdit\.R or ObsTrackEdit\_year\.R in older scripts (*edits Track files*)      
  creates OfflineObs\_yearlab\_Final.csv   
***make sure the ObsTrackEdit file is pointing to the directory you are working in***   

```{r}
# load necessary functions (generic for all surveys)
# CHECK WHICH COMPUTER: LAPTOP OR FWS DESKTOP
cpu = if (file.exists("M:/")) "work" else "home"

# SET PATH TO DATA DIRECTORY
dir = if (cpu == "work") file.path("M:/seabird_database/Kaycee_Working_Folder") else 
  file.path("C:/Users/KColeman/Documents/seabird_database/Kaycee_Working_Folder")
setwd(dir)
rm(cpu)

source(file.path(dir, "RProfile.R"))
```

- RProfile.R loads neccessary librarys and runs the following functions: 
  - AddBegEnd\_GISeditObsTrack.R 
  - AddBegEnd\_Obs.R 
  - AddCoch.R 
      - Adds a condition change (COCH) row when one was not reported with condition value "0" and count "0"
  - CheckBEGCNTandENDCNTnumbers.R
      - Reports transects with errors in BEGCNT and ENDCNT rows, these must be visually inspected and changed in the ObsFilesFix\_yearlab.R
  - CheckConditionChange.R 
  - CombineByName.R 
  - CombineObsTrack.R 
  - ConditionCodeErrorChecks.R 
  - GetDatabase.R 
  - GetObsFiles.R 
      - reads in the crew#_mmddyyy_birds.txt or .asc files and turns them into the "obs" and "Obs.Crew#" tables
  - GetTrackFiles.R 
  - GPSFix.R 
  - ObsFilesErrorChecks.R 
  - RunArcGISpy.R 
  - SECFix.R 
  - SourceDir.R 
  - and loads packages 'RODBC' and 'foreign'

- make sure path and inpath are pointing to the right directories  
```{r}
# SET PATH TO DATA DIRECTORY
survey = 14
yearlab = "AMAPPS_2014_10"
path = file.path(dir, "DataProcessing/Surveys/AMAPPS", yearlab)
inpath = file.path(gsub("DataProcessing/Surveys", 
                        "SurveyData", path))
```

- Creating yearlab\_ObsFilesFix.R:  
This will change for each survey folder defined by yearlab. The *AMAPPS\_yearlab\_AOUErrors.xlsx* and *AMAPPS\_yearlab\_ObsFileErrors.xlsx* generated in the *DataProcessing -> Surveys -> AMAPPS -> AMAPPS\_yearlab* folder will help inform you of which errors to fix in the yearlab\_ObsFilesFix.R script. These are commonly typos. You may need to listen to the corresponding WAV file to find out what the observer was trying to enter. Common errors should be included in the yearlab\_ObsFilesFix.R script prior if you need to look them up for reference (e\.g\. changing TOWER to code TOWR and how to split mixed observations coded MIXD).  Also if there are corrections in the pilot/observer notes these corrections should be included in the yearlab\_ObsFilesFix.R script.  

- In Step 3: pay attention to what you define _yearlab_ as (e.g. 2014 vs. 2014\_10) and if you use it in the naming of ObsTrackEdit\_ and ObsFilesFix\_ (could need to change the source line)  
```{r}
# ------------------------------------------------------------------------- #
# STEP 3: FIX OBSERVATION FILE BEGSEG/ENDSEG ERRORS
# ------------------------------------------------------------------------- #
source(file.path(path, paste("ObsFilesFix_", yearlab, ".R", sep = "")))
```
- In Step 4: make sure the track file folder name is correct (e.g. "TrackFiles" vs. "Track Files" depending on how you name folders)

- when running *CombineObsTrack.R*, if you see **"Error in BEG/END"** then there is an error in how the begin count and end count rows line up, this needs to be fixed, do not continue. 

ObsTrackEdit\_yearlabel.R uses ObsFilesFix\_yearlabel.R 
- Do not simply run this script, it will require editing
- This script is unique to each input year/season file and fixes errors in the observation files:  
           a) Flags offine/useless information  
           b) Fixes incorrect type codings  
           c) Fix condition change errors
           d) Breaks apart mixed flock records

** NOT ALL OF THE DATA WILL BE IN AMAPPS FORMAT**  
For these other files it is important to check species code and location of the sightings, then put it into a useful format for import. E.g. look at the BOEM HiDef Study in Access format.

5) Reformating the data for the Database
--------------------------------------------------------
-R and Python scripts needed (in Database folder)
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

6) Entering Data into the Access Database
--------------------------------------------------------
- Add2Database2.R
- DatabaseRedesign.R

7) Archiving the data
--------------------------------------------------------
*Sending the data to NOAA, National Oceanographic Data Center (NODC)*
[id4]: http://www.nodc.noaa.gov/cgi-bin/OAS/prd/accession/0115356
Aside from being entered into the database, the data is also stored with the NODC on their [website][id4]   
- Datasets that are already in the NODC can be found on the DataSets\_in_\NODC.xlsx file 
- accessions_id: 0115356


