# Hadoop to Databricks Migration

## Lab 'copy data from HDI to delta via CETAS'
---

### Clone the Repo
---
- Go to https://github.com/mipcips/https://github.com/mipcips/ossspark-to-adb and clone the repo to a local directory either on Windows WSL or a Linux/MacOs workstation
- CD into the newly created directory and open VSCode by typing code .


### Install Lab Environment
---

> in order for the next part to work, you have to be logged in (via azure-cli) to the subscription you want to install the lab environment into. the lab environment is going to be installed into one resource group. 

- click on /helper-scripts and open delete-and-createresgroups.sh. Edit the the name of the resource group and its location as well as the password at the top of the file. Currently it is set to westus and rg-wus-hditoadb and . Adjust these to your preference. The password is going to be the password for SQL Server, HDInsight clusteradmin and VM. 

- now open a command prompt and execute bash helper/delete-and-createresgroups.sh. This script deletes the resource group, with the name, you set in the bash script, creates it anew and starts the deployment of the lab

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



