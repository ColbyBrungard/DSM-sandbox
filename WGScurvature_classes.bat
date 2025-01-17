@echo off



REM start time 
set startTime=%date%:%time%

REM The water gathering surface input for the valley feaver interpretations requires input of plan and profile curvature classes that have been grouped into more general classes. Because I have USA-wide covariates of plan and profile curvature I decided that the easiest way to make the water gathering surface variable was to reclassify the plan and profile curvatures into concave, linear, and convex classes and then to reclassify these classes into the general water gathering classes needed. This was convienet because I already had the code to this. The two key decisions in this proceedure was 1) what neighborhood size to use and 2) what cutoff values to use. I decided on plan and profile curvature calculated over a 16-cell radius because I felt that it smoothed out much of the noise in the plan/profile values in the western USA where Valley Feaver will occur. I did observe greater fideility of plan and profile curvatures calculated over a 2 cell neighborhood to the landforms, but felt that there was just too much noise in the 30m DEM of the western USA. 

REM I chose to use cutoff thresholds of -0.0001 and 0.0001. Values were consisdred concave if they were < = -0.0001 and convex if there were > 0.0001. Values between these two threholds were considered linear. I chose these from a visual review of the values over a hillshade and in comparision with topolines. I also tried values of 0.0005 (and -0.0005) but this only changed +- 1 cell on the edges of the class so I felt that 0.0001 was relatively robust. 

REM Clip each plan and profile curvature to the western USA as this is the only data that I need. Boundaries for the western USA were obtained from: https://catalog.data.gov/dataset/tiger-line-shapefile-2017-nation-u-s-current-state-and-equivalent-national  I then selected the states that were west of ~ 100th parallel (e.g., KS westward) and saved this as a clipping layer. Then I used this to clip the DEM. 

REM REM clip to western USA. Make sure to save this as a .tif or the gdal calc will not work
REM echo now clipping to western USA
REM gdalwarp -t_srs EPSG:5070 -tr 30.0 30.0 -cutline tl_2017_us_state_west.gpkg -crop_to_cutline -multi -wo NUM_THREADS planc_16.tif planc_16_west.tif
REM gdalwarp -t_srs EPSG:5070 -tr 30.0 30.0 -cutline tl_2017_us_state_west.gpkg -crop_to_cutline -multi -wo NUM_THREADS profc_16.tif profc_16_west.tif


REM echo *************************
REM REM plan cuvature classes
REM echo now calculating plan curvature classes 
REM call gdal_calc -A planc_16_west.tif --outfile=plan_classes.tif --calc="3*(A<=-0.0001)+2*((A>-0.0001)*(A<=0.0001))+1*(A>0.0001)" --NoDataValue=255 --type Byte --creation-option COMPRESS=DEFLATE --creation-option BIGTIFF=YES

REM echo *************************
REM rem profile curvature classes. Note that the values for convex/concave are inverse of the plan classes
REM echo now calculating profile curvature classes
REM call gdal_calc -A profc_16_west.tif --outfile=prof_classes.tif --calc="1*(A<=-0.0001)+2*((A>-0.0001)*(A<=0.0001))+3*(A>0.0001)" --NoDataValue=255 --type Byte --creation-option COMPRESS=DEFLATE --creation-option BIGTIFF=YES


REM echo *************************
REM rem water gathering surface classes
REM echo now calculating water gathering surface curvature classes
REM call gdal_calc -A prof_classes.tif -B plan_classes.tif --outfile=WGSslopeshape_classes.tif --calc="1*((A==2)*(B==2))+0*((A==2)*(B==3))+2*((A==2)*(B==1))+0*((A==3)*(B==2))+0*((A==3)*(B==3))+1*((A==3)*(B==1))+2*((A==1)*(B==2))+1*((A==1)*(B==3))+3*((A==1)*(B==1))" --NoDataValue=255 --type Byte --creation-option COMPRESS=DEFLATE --creation-option BIGTIFF=YES

REM echo *************************
REM rem nine curvature classes 
REM echo now calculating 9 slope shape classes
REM call gdal_calc -A prof_classes.tif -B plan_classes.tif --outfile=slopeshape_9classes.tif --calc="1*((A==2)*(B==2))+2*((A==2)*(B==3))+3*((A==2)*(B==1))+4*((A==3)*(B==2))+5*((A==3)*(B==3))+6*((A==3)*(B==1))+7*((A==1)*(B==2))+8*((A==1)*(B==3))+9*((A==1)*(B==1))" --NoDataValue=255 --type Byte --creation-option COMPRESS=DEFLATE --creation-option BIGTIFF=YES

echo *************************
rem 4 simplified curvature classes 
echo now calculating 4 simplified slope shape classes. 
REM this is not quite right it does not produce class4 right.... need to test on smaller area. 
call gdal_calc -A prof_classes.tif -B plan_classes.tif --outfile=slopeshape_4classes.tif --calc="2*((A==2)*(B==2))+4*((A==2)*(B==3))+4*((A==2)*(B==1))+4*((A==3)*(B==2))+3*((A==3)*(B==3))+4*((A==3)*(B==1))+4*((A==1)*(B==2))+4*((A==1)*(B==3))+1*((A==1)*(B==1))" --NoDataValue=255 --type Byte --creation-option COMPRESS=DEFLATE --creation-option BIGTIFF=YES

echo Start Time: %startTime%
echo Finish Time: %date%:%time%

REM end ######################

REM THIS ALMOST WORKS EXCEPT THAT IT converts everything to a 3band image with values of the RGB colors, not the right classes. This is cool though. 
REM rem add colors and convert to geotif format. For some reason doing this for the 9 classes makes it a 3 band image
REM echo now adding colors and converting
REM gdaldem color-relief -of GTiff plan_classes.sdat color.txt plan_classes_color.tif  
REM gdaldem color-relief -of GTiff prof_classes.sdat color.txt prof_classes.tif  
REM rem made 3 band tif
REM gdaldem color-relief -of GTiff WGSslopeshape_classes.sdat color4.txt WGSslopeshape_classes_color.tif  
REM gdaldem color-relief -of GTiff slopeshape_9classes.sdat color9.txt slopeshape_9classes_color.tif


REM rem THIS ALMOST WORKS EXCEPT THAT I CAN'T GET THE FILES TO BE TAB DELIMITED AND IF THEY ARE NOT TAB DELIMITED IT WILL FAIL. THE BEST WAY TO MAKE THESE LOOK UP TABLES IS TO GENERATE ONE IN SAGA GIS, SAVE IT AS A TEMPLATE, AND MODIFY THE VALUES AS NEEDED.

REM REM -----------------------------------
REM set PATH=%PATH%;C:\saga-6.2.0_x64
REM set SAGA_MLB=C:\saga-6.2.0_x64\tools
REM rem make the reclassification tables 
REM echo now making reclassifiction look up tables. 

REM rem Binning curvatures into concave, linear, and convex classes requiest a look up table with relevant values defining the bins. The table should be a tab delimited text file and have minimum, maximum, and new columns. A tab delimited file can be made by putting spaces (not tabs) between values. 'Minimum' column = minimum values that will be reclassified into the value in the 'new' column. 'Maximum' column = maximum values that will be reclassified into the value in the 'new' column. 'New' column, the resulting values from the reclassification. Selecting these values should be done by someone familiar with the area. One note, curvature often ranges between -1 and 1, however; there are some cells which have very large (positive and negative values). Setting the smallest minimum and the largest maximum to be large values (-1000 and 1000 in this case) just makes sure that all the pixels are classified.

REM rem profile curvature
REM (
REM echo minimum maximum new
REM echo -1000.0000 -0.0001 1.0000
REM echo -0.0001 0.0001 2.0000
REM echo 0.0001 1000.0000 3.0000
REM ) > "lut_profc.txt"

REM rem plan curvature. plan curvature is negative for convex and positive for concave.
REM (
REM echo minimum maximum new
REM echo -100000.0000 -0.0001 3.0000
REM echo -0.0001 0.0001 2.0000
REM echo 0.0001 100000.0000 1.0000
REM ) > "lut_planc.txt"


REM rem the reclassfication table for the Water Gathering Surface classes. A 3 column matrix where the columns are: 1 the values of downslope classes, 2 the values of across slope classes, 3 the resulting classes. The downslope classes are listed first because I call the downslope raster as grid1 in the reclassification function. The resulting numerical values are mapped to classes as: 
REM rem 1 = Linear-Linear 
REM rem 0 = linear - Convex
REM rem 2 = Linear - Concave
REM rem 0 = Convex - Linear
REM rem 0 = Convex - Convex
REM rem 1 = Convex - Concave
REM rem 2 = Concave - Linear
REM rem 1 = Concave - Convex
REM rem 3 = Concave - Concave

REM (
rem echo Value in Grid 1 Value in Grid 2 Resulting Value
REM echo 2.000000	2.000000	1.000000
REM echo 2.000000	3.000000	0.000000
REM echo 2.000000	1.000000	2.000000
REM echo 3.000000	2.000000	0.000000
REM echo 3.000000	3.000000	0.000000
REM echo 3.000000	1.000000	1.000000
REM echo 1.000000	2.000000	2.000000
REM echo 1.000000	3.000000	1.000000
REM echo 1.000000	1.000000	3.000000
REM ) > "lut_WGSclasses.txt"


REM rem The 9 slope shape classes. A 3 column matrix where the columns are: 1 the values of downslope classes, 2 the values of across slope classes, 3 the resulting classes. The downslope classes are listed first because I call the downslope raster as grid1 in the reclassification function. The resulting numerical values are mapped to classes as: 
REM rem 1 = Linear-Linear 
REM rem 2 = linear - Convex
REM rem 3 = Linear - Concave
REM rem 4 = Convex - Linear
REM rem 5 = Convex - Convex
REM rem 6 = Convex - Concave
REM rem 7 = Concave - Linear
REM rem 8 = Concave - Convex
REM rem 9 = Concave - Concave

REM REM (
REM rem echo Value in Grid 1 Value in Grid 2 Resulting Value
REM REM echo 2.000000	2.000000	1.000000
REM REM echo 2.000000	3.000000	2.000000
REM REM echo 2.000000	1.000000	3.000000
REM REM echo 3.000000	2.000000	4.000000
REM REM echo 3.000000	3.000000	5.000000
REM REM echo 3.000000	1.000000	6.000000
REM REM echo 1.000000	2.000000	7.000000
REM REM echo 1.000000	3.000000	8.000000
REM REM echo 1.000000	1.000000	9.000000
REM REM ) > "lut_9classes.txt"

REM REM rem The 9 slope shape classes are a bit much. Simplify these to only 4 classes (Fred Young's SGI ideas)
REM REM rem 1 = Concave - Concave
REM REM rem 2 = Linear - Linear
REM REM rem 3 = Convex - Convex
REM REM rem 4 = Mixed

REM REM (
REM REM echo Value in Grid 1 Value in Grid 2 Resulting Value
REM REM echo 2.000000 2.000000 2.000000
REM REM echo 2.000000 3.000000 4.000000
REM REM echo 2.000000 1.000000 4.000000
REM REM echo 3.000000 2.000000 4.000000
REM REM echo 3.000000 3.000000 3.000000
REM REM echo 3.000000 1.000000 4.000000
REM REM echo 1.000000 2.000000 4.000000
REM REM echo 1.000000 3.000000 4.000000
REM REM echo 1.000000 1.000000 1.000000
REM REM ) > "lut_4classes.txt"


REM REM even with clipping the files were too large
REM REM Multiply the curvature values by 1000000 then convert to integer
REM echo now converting to integer to reduce size
REM call gdal_calc -A planc_16_west.tif --outfile=planc_16_west_int.tif --calc="A*100000" --type Int16 --creation-option COMPRESS=DEFLATE --creation-option PREDICTOR=2 --creation-option BIGTIFF=YES

REM call gdal_calc -A profc_16_west.tif --outfile=profc_16_west_int.tif --calc="A*100000" --type Int16 --creation-option COMPRESS=DEFLATE --creation-option PREDICTOR=2 --creation-option BIGTIFF=YES


REM rem convert to saga format (happens in RAM)
REM echo now converting to saga format
REM gdalwarp -of SAGA planc_16_west_int.tif planc_16_west_int.sdat
REM gdalwarp -of SAGA profc_16_west_int.tif profc_16_west_int.sdat


REM SAGA GIS format
REM echo *************************
REM REM Cuvature classes 

REM REM This fails because of memory issues because the raster it too large as SAGA tries to load these files into RAM. 
REM REM profile curvature classes
REM echo now calculating plan curvature classes
REM saga_cmd grid_tools 15 -INPUT=planc_16_west_int.sgrd -RESULT=plan_classes.sgrd -METHOD=2 -RETAB=lut_planc_int.txt -TOPERATOR=3


REM echo *************************
REM rem plan curvature classes
REM echo now calculating profile curvature classes
REM saga_cmd grid_tools 15 -INPUT=profc_16_west_int.sgrd -RESULT=prof_classes.sgrd -METHOD=2 -RETAB=lut_profc_int.txt -TOPERATOR=3

REM echo *************************
REM rem water gathering surface classes
REM echo now calculating water gathering surface curvature classes
REM saga_cmd grid_tools 20 -GRID1=prof_classes.sgrd -GRID2=plan_classes.sgrd -RESULT=WGSslopeshape_classes.sgrd -LOOKUP=lut_WGSclasses.txt

REM echo *************************
REM rem nine curvature classes 
REM echo now calculating 9 slope shape classes
REM saga_cmd grid_tools 20 -GRID1=prof_classes.sgrd -GRID2=plan_classes.sgrd -RESULT=slopeshape_9classes.sgrd -LOOKUP=lut_9classes.txt

REM echo *************************
REM rem 4 simplified curvature classes 
REM echo now calculating 4 simplified slope shape classes
REM saga_cmd grid_tools 20 -GRID1=prof_classes.sgrd -GRID2=plan_classes.sgrd -RESULT=slopeshape_4classes.sgrd -LOOKUP=lut_4classes.txt

REM echo *************************
REM rem compress
REM echo now compressing
REM gdal_translate -ot Byte -co COMPRESS=DEFLATE -co PREDICTOR=2 plan_classes.sdat plan_classes.tif
REM gdal_translate -ot Byte -co COMPRESS=DEFLATE -co PREDICTOR=2 prof_classes.sdat prof_classes.tif
REM gdal_translate -ot Byte -co COMPRESS=DEFLATE -co PREDICTOR=2 WGSslopeshape_classes.sdat WGSslopeshape_classes.tif
REM gdal_translate -ot Byte -co COMPRESS=DEFLATE -co PREDICTOR=2 slopeshape_9classes.sdat slopeshape_9classes.tif
REM gdal_translate -ot Byte -co COMPRESS=DEFLATE -co PREDICTOR=2 slopeshape_4classes.sdat slopeshape_4classes.tif
