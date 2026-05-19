select  * from projects;
SELECT FROM_UNIXTIME(CAST(created_at AS UNSIGNED)) AS local_created_at
FROM projects;
describe projects;
SELECT 
  FROM_UNIXTIME(CAST(deadline AS UNSIGNED)) AS local_deadline,
  FROM_UNIXTIME(CAST(updated_at AS UNSIGNED)) AS local_updated_at,
  FROM_UNIXTIME(CAST(state_changed_at AS UNSIGNED)) AS local_state_changed_at,
  FROM_UNIXTIME(CAST(successful_at AS UNSIGNED)) AS local_successful_at,
  FROM_UNIXTIME(CAST(launched_at AS UNSIGNED)) AS local_launched_at
FROM projects;
create table calender_tabe ( date_value date primary key,
year int, monthno int, monthfull_name varchar(20), quarter int, yearmonth int, 
weekday_no int, weekday_name varchar(20), financial_month char(4), financial_quarter char(3));
alter table calendar_table modify column yearmonth varchar(20);
 insert into calendar_table (date_value) SELECT date(FROM_UNIXTIME(CAST(created_at AS UNSIGNED)))
FROM projects;
rename table  calender_table to calendar_table;
ALTER TABLE calendar_table DROP PRIMARY KEY;
select*from calendar_table;
UPDATE calendar_table
SET
  year = YEAR(date_value),
  monthno = MONTH(date_value),
  monthfull_name = monthname(date_value),
  quarter = QUARTER(date_value),
  yearmonth = date_format(date_value, "%Y-%b"),
  weekday_no = weekday(date_value),
  weekday_name = DAYNAME(date_value),
  financial_month = concat('FM' ,case when month(date_value)>= 4 then month(date_value) - 3 else month(date_value) + 9 end),
  financial_quarter = concat('FQ', case when month(date_value) between 4 and 6 then 1 when month(date_value) between 7 and 9 then 2 
  when month(date_value) between 10 and 12 then 3 else 4 end);
  update calendar_table set weekday_no= day(date_value);

describe creator;
SELECT ProjectID, COUNT(*) FROM projects
GROUP BY ProjectID
HAVING COUNT(*) > 1;
alter TABLE location
MODIFY COLUMN location_id INT;


SELECT DISTINCT creator_id  FROM projects
WHERE creator_id NOT IN (SELECT creator_id FROM creator);
SELECT DISTINCT location_id
FROM projects
WHERE location_id NOT IN (
  SELECT location_id FROM location
);
SELECT DISTINCT category_id
FROM projects
WHERE category_id NOT IN (
  SELECT category_id FROM category
);

  
  SHOW COLUMNS FROM projects LIKE 'creator_id';
SHOW COLUMNS FROM creator LIKE 'creator_id';
ALTER TABLE projects MODIFY creator_id INT;

ALTER TABLE projects
ADD CONSTRAINT fk_creator_id
FOREIGN KEY (creator_id) REFERENCES creator(creator_id)
ON DELETE NO ACTION ON UPDATE CASCADE;

SELECT DISTINCT creator_id 
FROM projects 
WHERE creator_id NOT IN (SELECT creator_id FROM creator);

INSERT INTO creator (creator_id, name, chosen_currency)
VALUES (123, 'Unknown Creator', 'USD');

DELETE FROM projects
WHERE creator_id NOT IN (
    SELECT creator_id FROM creator
);


DELETE FROM projects
WHERE location_id NOT IN (
    SELECT location_id FROM location
);

DELETE FROM projects
WHERE category_id NOT IN (
    SELECT category_id FROM category
);
SHOW COLUMNS FROM projects LIKE 'location_id';
SHOW COLUMNS FROM location LIKE 'location_id';
ALTER TABLE projects 
MODIFY COLUMN location_id INT  NOT NULL;

ALTER TABLE projects
ADD CONSTRAINT fk_location_id
FOREIGN KEY (location_id) REFERENCES location(location_id)
ON DELETE NO ACTION ON UPDATE CASCADE;

SHOW COLUMNS FROM projects LIKE 'category_id';
SHOW COLUMNS FROM category LIKE 'category_id';
ALTER TABLE projects 
MODIFY COLUMN category_id INT  NOT NULL;

ALTER TABLE projects
ADD CONSTRAINT fk_category_id
FOREIGN KEY (category_id) REFERENCES category(category_id)
ON DELETE NO ACTION ON UPDATE CASCADE;
show create table projects;

//Convert the Goal amount into USD using the Static USD Rate.//

SELECT 
  ProjectID,
  goal,
  static_usd_rate,
  (goal * static_usd_rate) AS goal_in_usd
FROM 
  projects;
  
  //Total Number of Projects based on outcome //

  select 
  state AS outcome,
  COUNT(*) AS total_projects
FROM 
  projects
GROUP BY 
  state;
  
  
   SELECT 
  location_id,
  COUNT(*) AS total_projects
FROM 
  projects
GROUP BY 
  location_id;
  
  SELECT 
  category_id,
  COUNT(*) AS total_projects
FROM 
  projects
GROUP BY 
  category_id;
  
  
  describe calendar_table;
  SELECT 
  c.year,
  COUNT(*) AS total_projects
FROM 
  projects p
JOIN 
  calendar_table c ON DATE(FROM_UNIXTIME(p.created_at)) = c.date_value
GROUP BY 
  c.year
ORDER BY 
  c.year;
  
  
  
  SELECT 
    SUM(usd_pledged) AS total_amount_raised
FROM 
    projects
WHERE 
    state = 'successful';
    
    
    
    SELECT 
    SUM(backers_count) AS total_backers
FROM 
    projects
WHERE 
    state = 'successful';
    
    
    
    SELECT 
    AVG(DATEDIFF(FROM_UNIXTIME(deadline), FROM_UNIXTIME(launched_at))) AS avg_duration_days
FROM 
    projects
WHERE 
    state = 'successful';
    
    
    
    SELECT 
    name AS project_name,
    backers_count,
    usd_pledged
FROM 
    projects
WHERE 
    state = 'successful'
ORDER BY 
    backers_count DESC
LIMIT 10;


SELECT 
    name AS project_name,
    usd_pledged,
    backers_count
FROM 
    projects
WHERE 
    state = 'successful'
ORDER BY 
    usd_pledged DESC
LIMIT 10;


SELECT 
  ROUND(
    (SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 
    2
  ) AS success_percentage
FROM 
  projects;
  
  
  
  SELECT 
  c.category_name,
  COUNT(p.projectID) AS total_projects,
  SUM(CASE WHEN p.state = 'successful' THEN 1 ELSE 0 END) AS successful_projects,
  ROUND(
    (SUM(CASE WHEN p.state = 'successful' THEN 1 ELSE 0 END) * 100.0) / COUNT(p.projectID), 
    2
  ) AS success_percentage
FROM 
  projects p
JOIN 
  category c ON p.category_id = c.category_id
GROUP BY 
  c.category_name
ORDER BY 
  success_percentage DESC;



SELECT 
  cal.year,
  COUNT(p.projectID) AS total_projects,
  SUM(CASE WHEN p.state = 'successful' THEN 1 ELSE 0 END) AS successful_projects,
  ROUND(
    (SUM(CASE WHEN p.state = 'successful' THEN 1 ELSE 0 END) * 100.0) / COUNT(p.projectID), 
    2
  ) AS success_percentage
FROM 
  projects p
JOIN 
  calendar_table cal ON DATE(FROM_UNIXTIME(p.created_at)) = cal.date_value
GROUP BY 
  cal.year
ORDER BY 
  cal.year;
  
  
  
  SELECT 
  goal_range,
  COUNT(*) AS total_projects,
  SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) AS successful_projects,
  ROUND(
    (SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) * 100.0) / COUNT(*),
    2
  ) AS success_percentage
FROM (
  SELECT *,
    CASE 
      WHEN goal < 1000 THEN 'Low (<1K)'
      WHEN goal < 10000 THEN 'Medium (1K-10K)'
      WHEN goal < 50000 THEN 'High (10K-50K)'
      ELSE 'Very High (50K+)'
    END AS goal_range
  FROM projects
) sub
GROUP BY 
  goal_range
ORDER BY 
  success_percentage DESC;


  

  