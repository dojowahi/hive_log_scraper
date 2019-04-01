# Hive Log Scraper

When we have a huge amount of tables in a Hive warehouse, we want to know what tables are queried most often by users.
By getting a list of most used tables, we can focus more time on these tables than others. The code in this repository is based on a shell 
script which copies hive logs to a tmp location and then the logs are parsed by a Python script to get a list of all tables.

### Prerequisites

You will need to create a directories to store the scripts, logs and a location where the logs will be copied. The copied logs are deleted
at the end of the process. Once you have the directories created, go to the global_var.sh and update the parameters accordingly and you 
should be all set

