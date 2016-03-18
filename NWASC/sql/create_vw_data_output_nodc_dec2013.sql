-- View: working."vw_data_output_NODC"
-- 
DROP 
VIEW "working.vw_data_output_NODC";

CREATE
OR REPLACE 
VIEW working."vw_data_output_NODC" 
AS 
SELECT
	o.source_dataset_id 
AS dataset,
	d.title,
	M .survey_method_ds 
AS survey_method,
	dt.dataset_type_ds 
AS dataset_type,
	P .survey_platform_ds 
AS survey_type,
	ds.survey_width_m 
AS survey_width,
	o.observation_id 
AS observation_id,
	o.obs_dt 
AS observation_date,
	o.obs_start_tm 
AS observation_start_time,
	o.obs_end_tm 
AS observation_end_time,
	o.observers_tx 
AS observation_observers,
	s.common_nm,
	o.obs_count_intrans_nb 
AS observation_count,
	o.obs_count_general_nb 
AS observation_off_transect_count,
	st_x (o.location_gs) 
AS observation_longitude,
	st_y (o.location_gs) 
AS observation_latitude,
	o.animal_age_tx 
AS observation_animal_age,
	o.plumage_tx 
AS observation_plumage,
	o.behavior_tx 
AS observation_behavior,
	o.animal_sex_tx 
AS observation_animal_sex,
	o.association_tx 
AS observation_association,
	o.travel_direction_tx 
AS observation_travel_direction,
	o.flight_height_tx 
AS observation_flight_height,
	o.distance_to_animal_tx 
AS observation_distance_to_animal,
	o.angle_from_observer_nb 
AS observation_angle_from_observer,
	o.visibility_tx 
AS observation_visibility,
	o.weather_tx AS observation_weather,
	o.seastate_beaufort_nb 
AS observation_seastate_beaufort,
	o.wind_speed_tx 
AS observation_wind_speed,
	o.wind_dir_tx AS observation_wind_direction,
	o.seasurface_tempc_nb 
AS observation_seasurface_temp,
	o.salinity_ppt_nb 
AS observation_salinity,
	o.platform_tx 
AS observation_platform,
	o.station_tx 
AS observation_station,
	o.comments_tx 
AS observation_comments,
	r.transect_id as transect_id,
	r.source_transect_id 
AS transect,
	r.start_dt 
AS transect_start_date,
	r.start_tm 
AS transect_start_time,
	r.end_dt 
AS transect_end_date,
	r.end_tm 
AS transect_end_time,
	r.transect_time_min_nb 
AS tranect_time_minutes,
	r.transect_distance_nb 
AS transect_distance,
	r.traversal_speed_nb 
AS transect_traversal_speed,
	r.observers_tx 
AS transect_observers,
	r.visibility_tx AS transect_visibility,
	r.weather_tx 
AS transect_weather,
	r.seastate_beaufort_nb 
AS transect_seastate_beaufort,
	r.wind_speed_tx 
AS transect_wind_speed,
	r.wind_dir_tx 
AS transect_wind_direction,
	r.seasurface_tempc_nb 
AS transect_seasurface_temp,
	r.heading_tx 
AS transect_heading,
	r.conveyance_name_tx 
AS conveyance_name,
	r.wave_height_tx 
AS wave_height,
	r.comments_tx 
AS transect_comments

FROM
	seabird.observation o

LEFT JOIN seabird.transect r ON o.source_transect_id :: TEXT = r.source_transect_id :: TEXT

JOIN seabird.species s ON o.spp_cd :: TEXT = s.spp_cd :: TEXT
JOIN seabird.datacat d ON o.dataset_id = d.dataset_id
JOIN seabird.dataset ds ON o.dataset_id = ds.dataset_id

JOIN seabird.survey_method M ON ds.survey_method_cd :: TEXT = M .survey_method_cd :: TEXT

JOIN seabird.dataset_type dt ON ds.dataset_type_cd = dt.dataset_type_cd

JOIN seabird.survey_platform P ON ds.survey_type_cd = P .survey_platform_cd


WHERE
	(
		o.dataset_id <> ALL (ARRAY [ 7, 8, 117, 120 ])
	)

AND o.source_dataset_id :: TEXT !~~ '%Audubon%' :: TEXT;



ALTER TABLE working."vw_data_output_NODC" OWNER TO asussman;

COMMENT ON VIEW working."vw_data_output_NODC" IS 'data output for archive at NODC- mainly joins Observations and Transects and gets any necessary lookup fields.
ALS December 2013.';


COMMENT ON COLUMN working."vw_data_output_NODC".dataset IS 'Unique text-based id given to each original dataset.';

COMMENT ON COLUMN working."vw_data_output_NODC".title IS 'Title of the data set. May be abbreviated.';

COMMENT ON COLUMN working."vw_data_output_NODC".survey_method IS 'Description of the survey method code.';

COMMENT ON COLUMN working."vw_data_output_NODC".dataset_type IS 'Description of the dataset type.';

COMMENT ON COLUMN working."vw_data_output_NODC".survey_type IS 'Description of the type of survey, such as boat or aerial.';

COMMENT ON COLUMN working."vw_data_output_NODC".survey_width IS 'Survey width in meters, if a fixed survey width.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_id IS 'Automatically generated integer field unique to each observation.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_date IS 'Date of observation.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_start_time IS 'The observation time or start of the observation period.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_end_time IS 'The observation time at the end of the observation period.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_observers IS 'Observer(s) initials or name(s) during the observation period, for the individual observation.';

COMMENT ON COLUMN working."vw_data_output_NODC".common_nm IS 'Species common name.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_count IS 'Number of animals observed in the transect zone.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_off_transect_count IS 'Number of animals observed outside the survey width, off the transect zone, or when the survey width and/or transect zone is not specified.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_longitude IS 'Longitudinal (X) location of the observation in decimal degrees.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_latitude IS 'Latitudinal (Y) location of the observation in decimal degrees.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_animal_age IS 'Age of the observed animal or group if known.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_plumage IS 'Plumage of the observed animal or group if known.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_behavior IS 'Behavior observed, if any.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_animal_sex IS 'Sex of the observed animal or group if known.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_association IS 'Association of the observed animal or group to another observation, if noted.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_travel_direction IS 'Direction of travel of the observed animal or group, given in degrees or cardinal directions.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_flight_height IS 'Height of the observed animal or group (birds only), sometimes as a range in feet.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_distance_to_animal IS 'Distance from the observer to the observed animal or group.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_angle_from_observer IS 'Angle from the observer to the observed animal or group.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_visibility IS 'Visibility at the time of observation, either a description or code.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_weather IS 'Weather at the time of observation, either a description or code.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_seastate_beaufort IS 'Seastate on the Beaufort scale at the time of observation.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_wind_speed IS 'Average wind speed at the time of observation, in mph or knots.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_wind_direction IS 'Wind direction at the time of observation.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_seasurface_temp IS 'Measured seasurface temperature in degrees celcius at the time of observation.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_salinity IS 'Salinity in parts per thousand at the time of observation.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_platform IS 'Overlaps with station, usually, the name of the vessel or aircraft, but may also be the position of the observer on the platform.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_station IS 'Overlaps with platform; usually the position of the observer on the platform, but may also be the name of the vessel or aircraft.';

COMMENT ON COLUMN working."vw_data_output_NODC".observation_comments IS 'Comments made by the observer at the time of observation.';

COMMENT ON COLUMN working."vw_data_output_NODC".transect_id IS 'Automatically generated integer field unique to each transect.';

COMMENT ON COLUMN working."vw_data_output_NODC".transect IS 'Unique text-based id given to each distinct transect in the original datasets.';

COMMENT ON COLUMN working."vw_data_output_NODC".transect_start_date IS 'Date the traversal of the transect began.';

COMMENT ON COLUMN working."vw_data_output_NODC".transect_start_time IS 'Time the traversal of the transect began.';

COMMENT ON COLUMN working."vw_data_output_NODC".transect_end_date IS 'Date the traversal of the transect ended.';

COMMENT ON COLUMN working."vw_data_output_NODC".transect_end_time IS 'Time the traversal of the transect ended.';

COMMENT ON COLUMN working."vw_data_output_NODC".transect_time_minutes IS 'Length of time covered by the traversal of the transect, in minutes.';

COMMENT ON COLUMN working."vw_data_output_NODC".transect_distance IS 'Distance traveled during the traversal of the transect.';

COMMENT ON COLUMN working."vw_data_output_NODC".transect_traversal_speed IS 'Speed maintained by the boat or plane during the traversal of the transect, in nautical miles per hour.';

COMMENT ON COLUMN working."vw_data_output_NODC".transect_observers IS 'Observer(s) initials or name(s) during the observation period, for the entire transect.';

COMMENT ON COLUMN working."vw_data_output_NODC".transect_visibility IS 'Visibility during the traversal of the transect, either a description or code.';

COMMENT ON COLUMN working."vw_data_output_NODC".transect_weather IS 'Weather during the traversal of the transect, either a description or code.';

COMMENT ON COLUMN working."vw_data_output_NODC".transect_seastate_beaufort IS 'Seastate on the Beaufort scale during the traversal of the transect.';

COMMENT ON COLUMN working."vw_data_output_NODC".transect_wind_speed IS 'Average wind speed during the traversal of the transect in mph or knots.';

COMMENT ON COLUMN working."vw_data_output_NODC".transect_wind_direction IS 'Wind direction during the traversal of the transect.';

COMMENT ON COLUMN working."vw_data_output_NODC".transect_seasurface_temp IS 'Measured seasurface temperature in degrees celcius during the traversal of the transect.';

COMMENT ON COLUMN working."vw_data_output_NODC".transect_heading IS 'Heading during the traversal of the transect.';

COMMENT ON COLUMN working."vw_data_output_NODC".conveyance_name IS 'Name of the vessel or aircraft.';

COMMENT ON COLUMN working."vw_data_output_NODC".wave_height IS 'Wave height during the traversal of the transect.';

COMMENT ON COLUMN working."vw_data_output_NODC".transect_comments IS 'Comments made by the observer or data manager regarding the transect.';

--

SELECT * FROM working."vw_data_output_NODC"
