
#!/bin/bash

#####################################################################################################
# Script Name: get_hive_query.sh
# Date of Creation: 8/3/2018
# Author: Ankur Wahi
#####################################################################################################

script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

display_usage()

{

 echo >&2
 echo "Usage: Get list of succesful hive queries and their execution time " >&2
 echo "Syntax: `basename $0`" >&2
 echo "Ex:  sh `basename $0` " >&2
 echo >&2
 exit 22

}


if [ $# -gt 0 ]
then
  echo "Error: Wrong number of parameters"
  display_usage
fi


start=$SECONDS
source ${script_path}/global_var.sh
rm -rf ${log_dir}/hive_*.stat
today=`date +%Y-%m-%d`
year=`date +%Y`
hs2=`hostname`
log_file=${log_dir}/hive_parser_${today}.log

cp ${hive_log_loc}/hive-server2.log ${log_dir}/hive-server2.log_${today}
tac ${log_dir}/hive-server2.log_${today} | sed -n "/^${year}/!{G; h; b}; G; s/\n//g; p; s/.*//; h" | tac > ${log_dir}/fmt_log_${today}
#echo "Hive log formatting is complete">>${log_file}

hive_cnt=`wc -l<${log_dir}/hive-server2.log_${today}`
fmt_cnt=`wc -l< ${log_dir}/fmt_log_${today}`
#echo "Count comparison unformat - ${hive_cnt} vs format - ${fmt_cnt}">>${log_file}

rm -rf  ${log_dir}/hive-server2.log_${today}
grep "Executing command" ${log_dir}/fmt_log_${today} | cut -d":" -f5 | grep -v interrupted | cut -d'=' -f2 | sed -e 's|)||' >${log_dir}/hive_id_${today}

GREPPER()
{
        hive_id=$1
        grep ${hive_id} ${log_dir}/fmt_log_${today} | grep -Ei "Executing command|Completed executing|viewAclString" >${log_dir}/${hive_id}.stat
}


STAT_COLLECTOR()
{
        stat_file=$1
        time_taken=`tail -1 ${stat_file} | cut -d":" -f6`
        query=`head -1 ${stat_file} | cut -d":" -f6`
        user=`sed -n '2p' ${stat_file} |cut -d'=' -f3|cut -d',' -f1`
        echo "${query}~${time_taken}" >>${log_dir}/stats_${today}
}

export -f GREPPER
export -f STAT_COLLECTOR
export log_dir today

#echo "Start log grepper" >> ${log_file}
parallel --will-cite -j3 "GREPPER {}" < ${log_dir}/hive_id_${today}

#echo "Get success queries only"  >> ${log_file}
wc -l ${log_dir}/hive*.stat | awk '$1==2 {print $2}' >${log_dir}/success_query.lst

#echo "Collect stats for success queries"  >> ${log_file}
parallel --will-cite -j3 "STAT_COLLECTOR {}" < ${log_dir}/success_query.lst

end=$SECONDS

duration=$(( end - start ))

rm -rf ${log_dir}/fmt_log_${today} ${log_dir}/hive_id_${today}
suc_cnt=`wc -l <${log_dir}/stats_${today}`
echo "Hive Log Parsing took $duration seconds to complete">${log_file}
echo "The attachment is a ~ delimited file containing user, query and execution time status for successful queries" >> ${log_file}
echo "The attachment has data for ${hs2} for ${suc_cnt} queries" >>${log_file}

cat ${log_file} | mailx -s "Hive Log Analysis ${hs2} for ${today}" -a ${log_dir}/stats_${today} mailme@example.com
