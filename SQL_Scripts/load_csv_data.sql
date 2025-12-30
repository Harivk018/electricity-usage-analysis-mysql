-- Load Househol Information
LOAD DATA LOCAL INFILE 'household_info.csv'
INTO TABLE household_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Load Billing Information
LOAD DATA LOCAL INFILE 'billing_info.csv'
INTO TABLE billing_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Load Appliance usage Information
LOAD DATA LOCAL INFILE 'appliance_usage.csv'
INTO TABLE appliance_usage
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATEDATED BY '\n'
IGNORE 1 ROWS;

-- Load Calculated Metrics Dimension
LOAD DATA LOCAL INFILE 'calculated_metrics.csv'
INTO TABLE calculated_metrics
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Load Environmental Information
LOAD DATA LOCAL INFILE 'environmental_data.csv'
INTO TABLE environmental_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

