#!/bin/bash

#####################################################################################################
# Script Name: get_hive_tbl_list.sh
# Date of Creation: 8/3/2018
# Author: Ankur Wahi
#####################################################################################################


display_usage()

{

 echo >&2
 echo "Usage: Get list of hive tables queries by scraping hive logs " >&2
 echo "Syntax: `basename $0` HiveLogLocation" >&2
 echo "Ex:  sh `basename $0` /mnt/var/log/hive" >&2
 echo >&2
 exit 22

}

hive_log_loc=$1


if [ $# -ne 1 ]
then
  echo "Error: Wrong number of parameters"
  display_usage
fi

source global_var.sh
cp ${hive_log_loc}/hive*log* ${tmp_loc}/

gunzip ${tmp_loc}/hive-server2*.gz

for hive_log in `ls ${tmp_loc}/hive-server2*`
do
        grep -Pzo '(?s)(Executing command).*?(INFO|WARN|DEBUG|FATAL|ERROR)' ${hive_log} | sed 's/^.*Executing command.*: //g; s/^.*\(INFO\|WARN\|DEBUG\|FATAL\|ERROR\).*//g' | awk 'BEGIN { RS = ""; OFS = " "} {$1 = $1; print }' >${log_dir}/univ_set_hs2.sql

        grep -iv '^use' ${log_dir}/univ_set_hs2.sql |grep -iv '^show' | grep -iv 'Executing' | grep -iv 'drop table' | grep -iv 'select 1' >${log_dir}/clean_univ_set_hs2.sql

        tr A-Z a-z < ${log_dir}/clean_univ_set_hs2.sql >${log_dir}/clean_univ_set_hs2.sql.low

        mv ${log_dir}/clean_univ_set_hs2.sql.low ${log_dir}/clean_univ_set_hs2.sql

        sed -i -e  's/^select.*from/select from/' -e 's/^create.*from/select from/' ${log_dir}/clean_univ_set_hs2.sql

        python ${script_dir}/sql_parse_test.py ${log_dir}/clean_univ_set_hs2.sql ${log_dir}/hs2_tbl.lst

        cat ${log_dir}/hs2_tbl.lst >> ${log_dir}/hs2_tbl_history.lst

        rm -rf ${log_dir}/hs2_tbl.lst

done

DATE=`date +%Y-%m-%d`
sort ${log_dir}/hs2_tbl_history.lst | uniq > ${log_dir}/uniq_set_emr.lst
rm -rf ${tmp_loc}/hive-server2*
cp ${log_dir}/uniq_set.lst ${log_dir}/hs2_tbl_history.lst
mail -s "Table List from HS2 - ${DATE}" mailme@example.com < ${log_dir}/uniq_set_emr.lst