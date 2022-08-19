# Hadoop to Databricks Migration

## Lab copy data
---

### Install Lab Environment
---
- by creating a resource Groupp p.ex. rg-wus-hditoadb, then
- by running
az deployment group create \
    -g 'resource group you created earlier' \
    --template-file ./main-hdi.bicep \
    -n hditoadb \
    --parameters pw='pw' adbMngResourceGroupName='resource group you created earlier'

- with the bicep a virtual machine is created named 'vm1-hditoadb-dev' to which you will connect via just in time access (JITA). In order to do that, you can either go to the configuration node in Azure Portal of the vm or go to the vm in Azure portal, click on 'Connect' RDP and click on button 'Request Access'. This should open a RDP session to this VM

- then you can also bring the system up to date by going to windows update to install the required updates

- reboot the system (after the reboot and a new login, open a command prompt to try to connect to the headnode, by getting first the name of the headnode from ambari (after going to resource group, cluster and click on ambari, and clicking on hosts)

- to create a ssh connection to the headnode, open a command prompt and enter ssh tdadmin@'headnodename'

- create table via hive view 2.0 in ambari (open hive 2 view via ambari)
   
       
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

>in casse you get permission denied enter: start ssh session and then enter hdfs dfs -chown -R hive:hadoop /example/data )

- now run the command in hive 2.0 view again (should complete without errors)

- run : select count(1) as cnt from log4Logs;

- also try this from beelint (select count...) by starting a ssh session nto head node and then beeline with 'beeline -u 'jdbc:hive2://hn0-hdi01h:10001/;transportMode=http;' - should render the same result 79348.


   now we have an external table default.log4jlogs on hive.



