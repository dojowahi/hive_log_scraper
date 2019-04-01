# Hive Log Scraper

#### get_hs2_table.sh
When we have a huge amount of tables in a Hive warehouse, we want to know what tables are queried most often by users.
By getting a list of most used tables, we can focus more time on these tables than others. The code in this repository is based on a shell 
script which copies hive logs to a tmp location and then the logs are parsed by a Python script to get a list of all tables.

#### get_hive_query.sh
If you want to review all the queries executed in Hive and execution time, then this script will capture all the succesful queries executed along with their time taken.

### Prerequisites

It is assumed that property.hive.log.level is set to INFO in hive-log4j2.properties.

You will need to create directories to store the scripts, logs and a location where the hive logs will be copied. The copied logs are deleted
at the end of the process. Once you have the directories created, go to the global_var.sh and update the parameters accordingly and you 
should be all set.

All tests were done on Hive 2.3.3
GNU parallel needs to be installed on machine

