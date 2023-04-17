

-- DATABASE CREATION - new database containg data regarding "Best Metro Company"  --------------------------------------------------------------------------------------------------


CREATE DATABASE IF NOT EXISTS best_metro;

-----SCHEMA CREATION ----------------------------------------------------------------------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS metro_basic;

-- TABLE CREATION   -----------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Name: District; Type: TABLE; Schema: metro_basic;

CREATE TABLE IF NOT EXISTS metro_basic.District
    (
    district_id SERIAL4 PRIMARY KEY,
    district_name VARCHAR 
    );


-- Name: Street; Type: TABLE; Schema: metro_basic;

CREATE TABLE IF NOT EXISTS metro_basic.Street
    (
    street_id SERIAL4  PRIMARY KEY,
    street_name VARCHAR 
    );


-- Name: Area; Type: TABLE; Schema: metro_basic;

CREATE TABLE IF NOT EXISTS metro_basic.Area
    (
    area_id SERIAL4  PRIMARY KEY,
    area_district_id INTEGER NOT NULL REFERENCES metro_basic.District(district_id),
    area_street_id INTEGER NOT NULL REFERENCES metro_basic.Street(street_id)
    );


-- Name: Station; Type: TABLE; Schema: metro_basic;

CREATE TABLE IF NOT EXISTS metro_basic.Station
    (
    station_id SERIAL4  PRIMARY KEY,
    station_name VARCHAR UNIQUE NOT NULL,
    station_latitude DECIMAL NOT NULL CHECK (station_latitude BETWEEN -90.0 AND 90.0),                                -- checing if the number is within a proper range  
    station_longitude DECIMAL NOT NULL CHECK (station_longitude BETWEEN -180.0 AND 180.0),                            -- checing if the number is within a proper range  
    station_area_id INTEGER NOT NULL REFERENCES metro_basic.Area(area_id),
    station_ticket_machine BOOLEAN NOT NULL                                                                           -- TRUE when there is a ticket machine, FALSE where there's not
    );


-- Name: Line; Type: TABLE; Schema: metro_basic;

CREATE TABLE IF NOT EXISTS metro_basic.Line
    (
    line_id SERIAL4 PRIMARY KEY,
    line_color VARCHAR UNIQUE NOT NULL CHECK(line_color IN ('blue','red','green','grey','pink','yellow')),            -- specified the colors OF lines
    line_start_station_id INTEGER NOT NULL REFERENCES metro_basic.Station(station_id),
    line_end_station_id INTEGER NOT NULL REFERENCES metro_basic.Station(station_id)
    );


-- Name: Section; Type: TABLE; Schema: metro_basic;

CREATE TABLE IF NOT EXISTS metro_basic.Section
    (
    section_id SERIAL4 PRIMARY KEY,
    section_start_station_id INTEGER NOT NULL REFERENCES metro_basic.Station(station_id),
    section_end_station_id INTEGER NOT NULL REFERENCES metro_basic.Station(station_id),
    section_length_km DECIMAL NOT NULL CHECK (section_length_km < 20),                                                 -- The EACH SECTION cannot be longer than 20 km.
    section_line_id  INTEGER NOT NULL REFERENCES metro_basic.Line(line_id)
    );


-- Name: Unit_Level; Type: TABLE; Schema: metro_basic;

CREATE TABLE IF NOT EXISTS metro_basic.Unit_Level
    (
    unit_level SERIAL4 PRIMARY KEY,
    unit_level_description VARCHAR NOT NULL CHECK (unit_level_description IN ('City', 'Region', 'Country'))
    );


-- Name: Unit; Type: TABLE; Schema: metro_basic;

CREATE TABLE IF NOT EXISTS metro_basic.Unit 
    (
    unit_id SERIAL4 PRIMARY KEY,
    unit_name VARCHAR NOT NULL,
    unit_level INTEGER NOT NULL REFERENCES metro_basic.Unit_Level(unit_level),
    unit_parent_unit_id INTEGER REFERENCES metro_basic.Unit(unit_id)
    );


-- Name: Passenger; Type: TABLE; Schema: metro_basic;

CREATE TABLE metro_basic.Passenger
    (
    passenger_id BIGSERIAL PRIMARY KEY,
    passenger_name VARCHAR NOT NULL,
    passenger_date_of_birth DATE NOT NULL,
    passenger_gender CHAR(1) CHECK (passenger_gender IN ('F', 'M', 'D')),                                           -- F - female, M - male, D - diverse
    passenger_address_unit_id INTEGER NOT NULL REFERENCES metro_basic.Unit(unit_id),
    passenger_house_number INTEGER
    );


-- Name: Incident; Type: TABLE; Schema: metro_basic;

CREATE TABLE IF NOT EXISTS metro_basic.Incident 
    (
    incident_id BIGSERIAL PRIMARY KEY,
    incident_date_time TIMESTAMP NOT NULL DEFAULT now(),
    incident_section_id INTEGER NOT NULL REFERENCES metro_basic.Section(section_id),
    incident_passenger_id INTEGER NOT NULL REFERENCES metro_basic.Passenger(passenger_id),
    incident_fine_amount DECIMAL 
    );


-- Name: Inspector; Type: TABLE; Schema: metro_basic;

CREATE TABLE IF NOT EXISTS metro_basic.Inspector
    (
    inspector_id SERIAL4 PRIMARY KEY,
    inspector_name VARCHAR NOT NULL,
    inspector_date_of_birth DATE NOT NULL,
    inspector_gender CHAR(1) NOT NULL CHECK (inspector_gender IN ('F', 'M', 'D')),                                -- F - female, M - male, D - diverse
    inspector_date_of_hire DATE NOT NULL DEFAULT current_date                                                     -- If not filled in, the cell will be populated with current date 
    );


-- Name: Assigment; Type: TABLE; Schema: metro_basic;

CREATE TABLE IF NOT EXISTS metro_basic.Assigment
    (
    assigment_order_number SERIAL4 PRIMARY KEY,
    assigment_incident_id INTEGER NOT NULL REFERENCES metro_basic.Incident(incident_id),
    assigment_inspector_id INTEGER NOT NULL REFERENCES metro_basic.Inspector(inspector_id)
    );


-- MORE CONSTRAINTS CREATION -------------------------------------------------------------------------------------------------------------------------------------------

-- 1. Adding CHECK and NOT NULL constraints to Incident table 

ALTER TABLE metro_basic.Incident                                                                                     -- Since it was a HW requirement, I added two MORE constraints , although mostly they were defined during table creation 
ALTER COLUMN incident_fine_amount SET NOT NULL,
ADD CONSTRAINT incident_fine_amount_check CHECK (incident_fine_amount > 0);

-- 2. Adding CHECK  constraint to Inspector table - age confirmation 

ALTER TABLE metro_basic.Inspector 
ADD CONSTRAINT inspector_age CHECK ( EXTRACT(YEAR FROM current_date)-EXTRACT(YEAR FROM inspector_date_of_birth) > 18);

-- INSERTIN DATA ------------------------------------------------------------------------------------------------------------------------------------------------------
-- SELECT * FROM metro_basic.district d 
WITH new_district AS(
    SELECT 'Miechowice' AS district_name 
    UNION ALL
    SELECT 'Stroszek'
    UNION ALL
    SELECT 'Centrum'
    UNION ALL
    SELECT 'Arki Bozka'
    UNION ALL
    SELECT 'Rozbark')
     
INSERT INTO metro_basic.District (district_name)
SELECT * 
FROM new_district 
WHERE NOT EXISTS (SELECT  district_name  FROM metro_basic.district WHERE district_name IN ('Miechowice', 'Stroszek', 'Centrm', 'Arki Bozka', 'Rozbark'));

-- SELECT * FROM metro_basic.street d  
WITH new_street AS (
    SELECT  'Wolna' AS street_name 
    UNION ALL
    SELECT 'Mila'
    UNION ALL
    SELECT 'Zielona'
    UNION ALL
    SELECT 'Wesola'
    UNION ALL
    SELECT 'Wspolna')

INSERT INTO metro_basic.Street (street_name)
SELECT * 
FROM new_street
WHERE NOT EXISTS (SELECT street_name FROM metro_basic.street WHERE street_name IN ('Wolna','Mila','Zielona','Wesola','Wspolna'));
    
-- SELECT * FROM metro_basic.area a 
WITH new_area AS (
    SELECT (SELECT district_id FROM metro_basic.district d  WHERE district_name = 'Centrum') AS area_district_id, (SELECT street_id FROM metro_basic.street s WHERE street_name ='Wolna')  AS  area_street_id
    UNION ALL
    SELECT (SELECT district_id FROM metro_basic.district d  WHERE district_name ='Centrum'), (SELECT street_id FROM metro_basic.street s WHERE street_name ='Mila')
    UNION ALL
    SELECT (SELECT district_id FROM metro_basic.district d  WHERE district_name ='Centrum') , (SELECT street_id FROM metro_basic.street s WHERE street_name ='Zielona')
    UNION ALL
    SELECT (SELECT district_id FROM metro_basic.district d  WHERE district_name ='Centrum') , (SELECT street_id FROM metro_basic.street s WHERE street_name ='Wesola')
    UNION ALL
    SELECT (SELECT district_id FROM metro_basic.district d  WHERE district_name ='Centrum') , (SELECT street_id FROM metro_basic.street s WHERE street_name ='Wspolna')
    UNION ALL
    SELECT (SELECT district_id FROM metro_basic.district d  WHERE district_name ='Stroszek'), (SELECT street_id FROM metro_basic.street s WHERE street_name ='Mila')
    UNION ALL
    SELECT (SELECT district_id FROM metro_basic.district d  WHERE district_name ='Stroszek'), (SELECT street_id FROM metro_basic.street s WHERE street_name ='Zielona')
    UNION ALL
    SELECT (SELECT district_id FROM metro_basic.district d  WHERE district_name ='Stroszek'), (SELECT street_id FROM metro_basic.street s WHERE street_name ='Wesola'))
    
INSERT INTO metro_basic."area" (area_district_id, area_street_id)
    SELECT area_district_id, area_street_id 
    FROM new_area 
    WHERE NOT EXISTS (SELECT area_district_id, area_street_id 
                      FROM metro_basic."area"
                      WHERE  (area_district_id = (SELECT district_id FROM metro_basic.district WHERE district_name ='Centrum')  AND area_street_id = (SELECT street_id FROM metro_basic.street WHERE street_name = 'Wolna'))    OR
                             (area_district_id = (SELECT district_id FROM metro_basic.district WHERE district_name ='Centrum')  AND area_street_id = (SELECT street_id FROM metro_basic.street WHERE street_name = 'Mila' ))    OR 
                             (area_district_id = (SELECT district_id FROM metro_basic.district WHERE district_name ='Centrum')  AND area_street_id = (SELECT street_id FROM metro_basic.street WHERE street_name = 'Zielona'))  OR 
                             (area_district_id = (SELECT district_id FROM metro_basic.district WHERE district_name ='Centrum')  AND area_street_id = (SELECT street_id FROM metro_basic.street WHERE street_name = 'Wspolna'))  OR 
                             (area_district_id = (SELECT district_id FROM metro_basic.district WHERE district_name ='Stroszek') AND area_street_id = (SELECT street_id FROM metro_basic.street WHERE street_name = 'Mila'))    OR 
                             (area_district_id = (SELECT district_id FROM metro_basic.district WHERE district_name ='Stroszek') AND area_street_id = (SELECT street_id FROM metro_basic.street WHERE street_name = 'Zielona')) OR
                             (area_district_id = (SELECT district_id FROM metro_basic.district WHERE district_name ='Stroszek') AND area_street_id = (SELECT street_id FROM metro_basic.street WHERE street_name = 'Wesola')));
    


-- SELECT * FROM metro_basic.station   
WITH new_station AS (
    SELECT 'Miechowice Kosciol'     AS station_name, 
            50.359250203237806      AS station_latitude, 
            18.903176140416452      AS station_longitude, 
            ( SELECT area_id FROM metro_basic.area a WHERE area_district_id = (SELECT district_id FROM metro_basic.district WHERE district_name ='Centrum')  AND 
                                                            area_street_id   = (SELECT street_id FROM metro_basic.street WHERE street_name = 'Wolna')) AS station_area_id,
            TRUE AS station_ticket_machine
    
    UNION ALL 
    SELECT 'Miechowice Skrzyzowanie', 
            50.34824265755492, 
            18.934203931780647,
            ( SELECT area_id FROM metro_basic.area a WHERE area_district_id = (SELECT district_id FROM metro_basic.district WHERE district_name ='Centrum')  AND 
                                                            area_street_id   = (SELECT street_id FROM metro_basic.street WHERE street_name = 'Mila')) AS station_area_id,
            TRUE 
    
    UNION ALL 
    SELECT 'Miechowice Zajezdnia', 
            50.38946023678092, 
            18.911399548990985,
            ( SELECT area_id FROM metro_basic.area a WHERE area_district_id = (SELECT district_id FROM metro_basic.district WHERE district_name ='Centrum')  AND 
                                                            area_street_id   = (SELECT street_id FROM metro_basic.street WHERE street_name = 'Zielona')) AS station_area_id,
            TRUE
    
    UNION ALL 
    SELECT 'Stroszek Wiadukt', 
            50.220565936973244, 
            18.899137489604094,
            ( SELECT area_id FROM metro_basic.area a WHERE area_district_id = (SELECT district_id FROM metro_basic.district WHERE district_name ='Centrum')  AND 
                                                            area_street_id   = (SELECT street_id FROM metro_basic.street WHERE street_name = 'Wspolna')) AS station_area_id,
            FALSE 
            
    UNION ALL   
    SELECT 'Stroszek Szkola',
    50.224959125041394, 18.6519451370813,
    (SELECT area_id FROM metro_basic.area a WHERE area_district_id = (SELECT district_id FROM metro_basic.district WHERE district_name ='Centrum')  AND 
                                                  area_street_id   = (SELECT street_id FROM metro_basic.street WHERE street_name = 'Wolna')) AS station_area_id, 
    TRUE)
    
INSERT INTO metro_basic.Station ( station_name, station_latitude, station_longitude, station_area_id, station_ticket_machine)
SELECT *
FROM new_station
WHERE NOT EXISTS (SELECT s.station_name  FROM metro_basic.station s WHERE station_name IN ('Miechowice Kosciol','Miechowice Skrzyzowanie','Miechowice Zajezdnia','Stroszek Wiadukt', 'Stroszek Szkola')) ;


    
-- SELECT * FROM metro_basic.line 
WITH new_line AS (
    SELECT  'blue' AS line_color, 
            (SELECT station_id FROM metro_basic.station s WHERE station_name = 'Stroszek Wiadukt')     AS line_start_station_id, 
            (SELECT station_id FROM metro_basic.station s WHERE station_name = 'Miechowice Kosciol')   AS line_end_station_id
    UNION ALL 
    SELECT  'red' ,
            (SELECT station_id FROM metro_basic.station s WHERE station_name = 'Miechowice Skrzyzowanie') ,
            (SELECT station_id FROM metro_basic.station s WHERE station_name = 'Stroszek Szkola')) 
        
INSERT INTO metro_basic.Line ( line_color, line_start_station_id, line_end_station_id)
SELECT *
FROM new_line
WHERE NOT EXISTS (SELECT line_color FROM metro_basic.line WHERE line_color IN ('blue', 'red'));



-- SELECT * FROM metro_basic."section" s 
WITH new_section AS (
    SELECT  (SELECT station_id FROM metro_basic.station s WHERE station_name = 'Miechowice Kosciol' )      AS section_start_station_id,
            (SELECT station_id FROM metro_basic.station s WHERE station_name = 'Miechowice Skrzyzowanie' ) AS section_end_station_id,
            1.2 AS section_length_km,
            (SELECT line_id FROM metro_basic.line WHERE line_color = 'blue' )   AS section_line_id
    UNION ALL
    SELECT (SELECT station_id FROM metro_basic.station s WHERE station_name = 'Stroszek Wiadukt' ),
           (SELECT station_id FROM metro_basic.station s WHERE station_name = 'Stroszek Szkola' ),
           3.2,
           (SELECT line_id FROM metro_basic.line WHERE line_color = 'red' ))                    
                        
INSERT INTO metro_basic.Section (section_start_station_id, section_end_station_id, section_length_km, section_line_id)
SELECT *
FROM new_section
WHERE NOT EXISTS (SELECT section_start_station_id, section_end_station_id 
                  FROM metro_basic."section" 
                  WHERE (section_start_station_id = (SELECT station_id FROM metro_basic.station s WHERE station_name = 'Miechowice Kosciol' ) AND
                         section_end_station_id   = (SELECT station_id FROM metro_basic.station s WHERE station_name = 'Miechowice Skrzyzowanie'))
                         OR 
                        (section_start_station_id = (SELECT station_id FROM metro_basic.station s WHERE station_name = 'Stroszek Wiadukt' ) AND 
                         section_end_station_id   = (SELECT station_id FROM metro_basic.station s WHERE station_name = 'Stroszek Szkola' )));
    


-- SELECT * FROM metro_basic.unit_level ul 
WITH new_unit_level AS(
    SELECT 'Country' AS unit_level_description
    UNION ALL 
    SELECT 'Region'
    UNION ALL 
    SELECT 'City')

INSERT INTO metro_basic.Unit_Level (unit_level_description)
SELECT *
FROM new_unit_level
WHERE NOT EXISTS ( SELECT unit_level_description FROM metro_basic.unit_level WHERE unit_level_description IN ('Country', 'City', 'Region'));




-- SELECT * FROM metro_basic.unit u
WITH new_unit   AS (
    SELECT 'Poland' AS unit_name, 
            (SELECT unit_level FROM metro_basic.unit_level ul WHERE unit_level_description = 'Country' ) AS unit_level,
            NULL AS unit_parent_unit_id
    UNION ALL
    SELECT 'Silesia', 
            (SELECT unit_level FROM metro_basic.unit_level ul WHERE unit_level_description = 'Region' ),
            (SELECT unit_id FROM metro_basic.Unit WHERE unit_name = 'Poland')
    UNION ALL
    SELECT 'Bytom', 
            (SELECT unit_level FROM metro_basic.unit_level ul WHERE unit_level_description = 'City'),
            (SELECT unit_id FROM metro_basic.unit WHERE unit_name = 'Silesia' )
    UNION ALL
    SELECT 'Katowice', 
            (SELECT unit_level FROM metro_basic.unit_level ul WHERE unit_level_description = 'City' ),
            (SELECT unit_id FROM metro_basic.unit WHERE unit_name = 'Silesia' ))           
            
INSERT INTO metro_basic.Unit (unit_name, unit_level, unit_parent_unit_id)
SELECT * 
FROM new_unit
WHERE NOT EXISTS ( SELECT unit_name, unit_parent_unit_id 
                   FROM metro_basic.unit
                   WHERE (unit_name = 'Poland'  AND unit_parent_unit_id IS NULL)
                         OR 
                         (unit_name = 'Silesia' AND unit_parent_unit_id  = (SELECT unit_id FROM metro_basic.unit WHERE unit_name = 'Poland' ))
                         OR  
                         (unit_name = 'Bytom' AND unit_parent_unit_id  = (SELECT unit_id FROM metro_basic.unit WHERE unit_name = 'Silesia' ))
                         OR 
                         (unit_name = 'Katowice' AND unit_parent_unit_id  = (SELECT unit_id FROM metro_basic.unit WHERE unit_name = 'Silesia' )));

  
-- SELECT * FROM metro_basic.passenger p 
  
WITH new_passenger AS(
    SELECT  'Jan Kowalski'         AS passenger_name, 
            '1989-02-15':: DATE    AS passenger_date_of_birth, 
            'M'                    AS passenger_gender, 
            (SELECT unit_id FROM metro_basic.unit u WHERE unit_name = 'Bytom') AS passenger_address_unit_id, 
            30                     AS   passenger_house_number
    UNION ALL 
    SELECT  'Anna Nowak',     
            '1975-12-01':: DATE, 
            'F', 
            (SELECT unit_id FROM metro_basic.unit u WHERE unit_name = 'Bytom'),  
            12     
    UNION ALL 
    SELECT  'Piotr Krawczyk', 
            '2001-03-12':: DATE, 
            'M', 
            (SELECT unit_id FROM metro_basic.unit u WHERE unit_name = 'Katowice'),  
            4         
    UNION ALL 
    SELECT  'Aleksandra Maj', 
            '2003-10-29':: DATE, 
            'F', 
            (SELECT unit_id FROM metro_basic.unit u WHERE unit_name = 'Katowice'),  
            25 )    
                  
INSERT INTO metro_basic.Passenger ( passenger_name, passenger_date_of_birth, passenger_gender, passenger_address_unit_id, passenger_house_number)
SELECT *
FROM new_passenger
WHERE NOT EXISTS (SELECT passenger_name, passenger_date_of_birth 
                  FROM metro_basic.passenger  
                  WHERE (passenger_name =  'Anna Nowak'     AND  passenger_date_of_birth  = '1975-12-01':: DATE)    OR 
                        (passenger_name =  'Jan Kowalski'   AND  passenger_date_of_birth  = '1989-02-15':: DATE)    OR 
                        (passenger_name =  'Piotr Krawczyk' AND  passenger_date_of_birth  = '2001-03-12':: DATE)    OR 
                        (passenger_name =  'Aleksandra Maj' AND  passenger_date_of_birth  = '2003-10-29':: DATE));


                    
 -- SELECT * FROM metro_basic.incident                  

WITH new_incident AS(
    SELECT (SELECT section_id 
            FROM metro_basic."section" s 
            WHERE section_start_station_id = (SELECT station_id 
                                              FROM metro_basic.station s 
                                              WHERE station_name = 'Miechowice Kosciol' ) AND
                  section_end_station_id   = (SELECT station_id 
                                              FROM metro_basic.station s 
                                              WHERE station_name = 'Miechowice Skrzyzowanie')) AS incident_section_id,
            (SELECT passenger_id 
             FROM metro_basic.passenger p
             WHERE passenger_name =  'Anna Nowak'     AND  passenger_date_of_birth  = '1975-12-01') AS incident_passenger_i,
             120 AS incident_fine_amount
   
    UNION  ALL
    SELECT (SELECT section_id 
            FROM metro_basic."section" s 
            WHERE section_start_station_id = (SELECT station_id 
                                              FROM metro_basic.station s 
                                              WHERE station_name = 'Miechowice Kosciol' ) AND
                  section_end_station_id   = (SELECT station_id 
                                              FROM metro_basic.station s 
                                              WHERE station_name = 'Miechowice Skrzyzowanie')) AS incident_section_id,
            (SELECT passenger_id 
             FROM metro_basic.passenger p
             WHERE passenger_name =  'Jan Kowalski'   AND  passenger_date_of_birth  = '1989-02-15') AS incident_passenger_i,
             80 AS incident_fine_amount )

                    
INSERT INTO metro_basic.Incident (incident_section_id, incident_passenger_id, incident_fine_amount)
SELECT *
FROM new_incident
WHERE NOT EXISTS (SELECT * 
                  FROM metro_basic.incident
                  WHERE incident_date_time      != current_date 
                  AND   (
                        (incident_passenger_id   = (SELECT passenger_id  FROM metro_basic.passenger p   WHERE passenger_name =  'Anna Nowak' AND  passenger_date_of_birth  = '1975-12-01')   AND 
                         incident_section_id     = (SELECT section_id    FROM metro_basic."section" s   WHERE section_start_station_id = ( SELECT station_id 
                                                                                                                                          FROM metro_basic.station s 
                                                                                                                                          WHERE station_name = 'Miechowice Kosciol' ) AND
                                                                                                             section_end_station_id   = ( SELECT station_id 
                                                                                                                                          FROM metro_basic.station s 
                                                                                                                                          WHERE station_name = 'Miechowice Skrzyzowanie')))
                     OR (incident_passenger_id   = (SELECT passenger_id  FROM metro_basic.passenger p   WHERE passenger_name =  'Jan Kowalski'   AND  passenger_date_of_birth  = '1989-02-15')   AND 
                         incident_section_id     = (SELECT section_id    FROM metro_basic."section" s   WHERE section_start_station_id = ( SELECT station_id 
                                                                                                                                          FROM metro_basic.station s 
                                                                                                                                          WHERE station_name = 'Miechowice Kosciol' ) AND
                                                                                                             section_end_station_id   = ( SELECT station_id 
                                                                                                                                          FROM metro_basic.station s 
                                                                                                                                          WHERE station_name = 'Miechowice Skrzyzowanie')))));

                                                                                                                                      
-- SELECT * FROM metro_basic.inspector       
WITH new_inspector AS (
    SELECT 'Karol Krawczyk' AS inspector_name,  '1988-07-17' ::DATE  AS inspector_date_of_birth,  'M' AS inspector_gender, '2022-12-01' ::DATE  AS inspector_date_of_hire
    UNION ALL 
    SELECT 'Tadeusz Norek'  , '1965-11-05'::DATE, 'M', '2023-10-01'::DATE)

INSERT INTO metro_basic.Inspector (inspector_name, inspector_date_of_birth, inspector_gender, inspector_date_of_hire)
SELECT *
FROM new_inspector 
WHERE NOT EXISTS (SELECT inspector_name, inspector_date_of_birth FROM metro_basic.inspector WHERE (inspector_name = 'Karol Krawczyk' AND inspector_date_of_birth = '1988-07-17') OR 
                                                                                                  (inspector_name =  'Tadeusz Norek' AND inspector_date_of_birth = '1965-11-05'));
       
    
-- SELECT * FROM metro_basic.assigment
                                                                                              
WITH new_assigment AS (
    SELECT (SELECT incident_id FROM metro_basic.incident i WHERE date_trunc('day', incident_date_time) = '2023-04-05' AND 
                                                                 incident_passenger_id = (SELECT passenger_id FROM metro_basic.passenger p WHERE passenger_name =  'Anna Nowak'AND  passenger_date_of_birth  = '1975-12-01') AND
                                                                 incident_section_id = (SELECT section_id FROM metro_basic."section" s WHERE section_start_station_id = (SELECT station_id FROM metro_basic.station s WHERE station_name = 'Miechowice Kosciol' ) AND 
                                                                                                                                             section_end_station_id   = (SELECT station_id FROM metro_basic.station s WHERE station_name = 'Miechowice Skrzyzowanie'))) AS assigment_incident_id,
            (SELECT inspector_id FROM metro_basic.inspector i2 WHERE inspector_name = 'Karol Krawczyk' AND inspector_date_of_birth = '1988-07-17')

    UNION ALL 
    SELECT (SELECT incident_id FROM metro_basic.incident i WHERE date_trunc('day', incident_date_time) = '2023-04-05' AND 
                                                                 incident_passenger_id = (SELECT passenger_id FROM metro_basic.passenger p WHERE passenger_name =  'Anna Nowak'AND  passenger_date_of_birth  = '1975-12-01') AND
                                                                 incident_section_id = (SELECT section_id FROM metro_basic."section" s WHERE section_start_station_id = (SELECT station_id FROM metro_basic.station s WHERE station_name = 'Miechowice Kosciol' ) AND 
                                                                                                                                             section_end_station_id   = (SELECT station_id FROM metro_basic.station s WHERE station_name = 'Miechowice Skrzyzowanie'))) AS assigment_incident_id,
    (SELECT inspector_id FROM metro_basic.inspector i2 WHERE inspector_name =  'Tadeusz Norek' AND inspector_date_of_birth = '1965-11-05'))
    
INSERT INTO metro_basic.Assigment (assigment_incident_id, assigment_inspector_id)
SELECT *
FROM new_assigment 
WHERE NOT EXISTS (SELECT assigment_incident_id, assigment_inspector_id 
                  FROM metro_basic.assigment 
                  WHERE (assigment_incident_id = (SELECT incident_id 
                                                  FROM metro_basic.incident i 
                                                  WHERE date_trunc('day', incident_date_time) = '2023-04-05' 
                                                      AND  incident_passenger_id = (SELECT passenger_id 
                                                                                    FROM metro_basic.passenger p 
                                                                                    WHERE passenger_name =  'Anna Nowak' AND  passenger_date_of_birth  = '1975-12-01') 
                                                      AND incident_section_id = (SELECT section_id 
                                                                                 FROM metro_basic."section" s 
                                                                                 WHERE section_start_station_id = (SELECT station_id FROM metro_basic.station s WHERE station_name = 'Miechowice Kosciol' ) AND 
                                                                                       section_end_station_id   = (SELECT station_id FROM metro_basic.station s WHERE station_name = 'Miechowice Skrzyzowanie')))
                        AND                                                                                                                                                                                    
                        assigment_inspector_id =  (SELECT inspector_id FROM metro_basic.inspector i2 WHERE inspector_name = 'Karol Krawczyk' AND inspector_date_of_birth = '1988-07-17'))
                        OR 
                        (assigment_incident_id = (SELECT incident_id 
                                                  FROM metro_basic.incident i 
                                                  WHERE date_trunc('day', incident_date_time) = '2023-04-05' 
                                                      AND  incident_passenger_id = (SELECT passenger_id 
                                                                                    FROM metro_basic.passenger p 
                                                                                    WHERE passenger_name =  'Anna Nowak' AND  passenger_date_of_birth  = '1975-12-01') 
                                                      AND incident_section_id = (SELECT section_id 
                                                                                 FROM metro_basic."section" s 
                                                                                 WHERE section_start_station_id = (SELECT station_id FROM metro_basic.station s WHERE station_name = 'Miechowice Kosciol' ) AND 
                                                                                       section_end_station_id   = (SELECT station_id FROM metro_basic.station s WHERE station_name = 'Miechowice Skrzyzowanie')))
                        AND                                                                                                                                                                                    
                        assigment_inspector_id =  (SELECT inspector_id FROM metro_basic.inspector i2 WHERE inspector_name =  'Tadeusz Norek' AND inspector_date_of_birth = '1965-11-05')));
                        
-- ALTERING THE TABLES- adding 'record_ts' (settings: not null, default value current_date)--------------------------------------------------------------------------------

ALTER TABLE metro_basic.District   ADD COLUMN record_ts DATE NOT NULL DEFAULT current_date;
ALTER TABLE metro_basic.Street     ADD COLUMN record_ts DATE NOT NULL DEFAULT current_date;
ALTER TABLE metro_basic.Area       ADD COLUMN record_ts DATE NOT NULL DEFAULT current_date;
ALTER TABLE metro_basic.Station    ADD COLUMN record_ts DATE NOT NULL DEFAULT current_date;
ALTER TABLE metro_basic.Line       ADD COLUMN record_ts DATE NOT NULL DEFAULT current_date;
ALTER TABLE metro_basic.Section    ADD COLUMN record_ts DATE NOT NULL DEFAULT current_date;
ALTER TABLE metro_basic.Unit_Level ADD COLUMN record_ts DATE NOT NULL DEFAULT current_date;
ALTER TABLE metro_basic.Unit       ADD COLUMN record_ts DATE NOT NULL DEFAULT current_date;
ALTER TABLE metro_basic.Passenger  ADD COLUMN record_ts DATE NOT NULL DEFAULT current_date;
ALTER TABLE metro_basic.Incident   ADD COLUMN record_ts DATE NOT NULL DEFAULT current_date;
ALTER TABLE metro_basic.Inspector  ADD COLUMN record_ts DATE NOT NULL DEFAULT current_date;
ALTER TABLE metro_basic.Assigment  ADD COLUMN record_ts DATE NOT NULL DEFAULT current_date;

