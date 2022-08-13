# Hadoop to Databricks Migration

## Lab copy data
---

### Install Cluster(s)
---
- by running
az deployment group create \
    -g $baseResourceGroupName \
    --template-file ./main-hdi.bicep \
    -n hditoadb \
    --parameters pw=Tested2222**  adbMngResourceGroupName=$mngResourceGroupName

- add local ip and 443 and 22 to inbound rules of hdi nsg

- verify by going to cluster and creating ssh connection from bash 

- create table via hive
   
   start ssh connection and beeline with 'beeline -u 'jdbc:hive2://hn0-hdi01h:10001/;transportMode=http'
      
      show tables;
      show databases;
      CREATE EXTERNAL TABLE log4jLogs (
    t1 string,
    t2 string,
    t3 string,
    t4 string,
    t5 string,
    t6 string,
    t7 string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ' '
STORED AS TEXTFILE LOCATION '/example/data/';

( in casse you get permission denied enter: hdfs dfs -chown -R hive:hadoop /example/data )
   
   run : select count(1) as cnt from log4Logs;


   now we have an external table default.log4jlogs on hive.



