# Hadoop to Databricks Migration


# Spark Module Labs

## Lab 1 'copy data from HDI to delta via CETAS'
---

### Clone the Repo
---
- Go to https://github.com/mipcips/https://github.com/mipcips/ossspark-to-adb and clone the repo to a directory on your workstation either on Windows WSL or a Linux/MacOs workstation
- CD into the newly created directory and open VSCode by typing code .
<br />
<br />

### Install Lab Environment (60 min)
---

> in order for the next part to work, you have to be logged in (via azure-cli) to the subscription you want to install the lab environment into. You need to have at least contributor permission and user access administrator on the subscription. The lab environment is going to be installed into one resource group. Note, that for successful deployment of the cluster you'd need 16 HDInsight vCores available in the region of your choice. 

- open a command prompt (or use the one from VsCode) and login to your subscription (az login - az account set -s 'subscription name')
- click on /helper-scripts and open 'delete-and-createresgroups.sh'. Edit the the name of the resource group and its location as well as the password at the top of the file. Currently it is set to 'westus' and 'rg-wus-hditoadb'. Adjust these to your preference. The password is going to be the password for SQL Server, HDInsight clusteradmin and VM. 

- now open a command prompt and execute 'bash helper/delete-and-createresgroups.sh'. This script deletes the resource group, with the name, you set previously, creates it anew and starts the deployment of the lab environment.

- with the bicep a virtual machine is created named 'vm1-hditoadb-dev' to which you will connect via just in time access (JITA). In order to do that, you can either go to the configuration node in Azure Portal of the vm or go to the vm in Azure portal, click on 'Connect' RDP and click on button 'Request Access'. This should open a RDP session to this VM

- after logging on to the vm, install the necessary updates

- reboot the vm (after the reboot and a new login, open a command prompt to try to connect to the headnode, by getting first the name of the headnode from ambari (after going to resource group, cluster and click on ambari, and clicking on hosts)

- to create a ssh connection to the headnode, open a command prompt and enter ssh tdadmin@'headnodename'

- install git on the vm by 
  - going to 'https://git-scm.com/downloads' 
  - click on 'Windows'
  - click on '64-bit Git for Windows Setup'
  - open file and then click next until the installation starts
  - on the last dialog of the installation click 'Launch Git Bash', clear the check mark on 'View Release Notes'
  - and click 'Finish'
<br />
<br />
- clone this repo by 
  - going to 'https://github.com/mipcips'
  - click on 'ossspark-to-adb'
  - click on 'Code' (green button)
  - click on copy symbol (to the right of https://github.com....)
  - go to git bash windows and enter 'git clone ' and paste what you copied in the previous step
  - press enter
  - Finished ! Now you should have this repo cloned into /c/Users/tdamin/ossspark-to-adb.

  
! You installed your lab environment. Congratulations !


![lab-environment](/images/hadoop-to-adb-mig.png)

### Download data by executing a Notebook 
---

- the notebook in question you find in 'notebooks/hdi/ossspark-toadb-hdipart-lab1.ipynb'. Make sure, that you're logged on to the VM. You need to be working in the VNet where the cluster is.

- open Edge and open ambari by entering https://'clustername'-int.azurehdinsight.net. (you find the url to ambari in 'Resource Group' - 'hdi01hditoadb-dev' - 'URL'. copy the url and add an '-int' behind the '-dev') login credentials are tdadmin and the password, you configured in the helper script earlier

- open a connection to Jupyter by opening a new tab in the browswer and entering https://'clustername'-int.azurehdinsight.net/jupyter

- from the Jupyter screen
  - click 'Upload'
  - double click 'ossspark-to-adb'
  - select 'osspark-toadb-hdipart-lab1.ipynb'
  - click 'Open'
  - click 'Upload'
  - click 'osspark-toadb-hdipart-lab1.ipynb, which opens the notebook
  - click 'Cell -> All Output -> Clear'
  - Now run the notebook cell by cell by selecting the first cell and pressing 'Shift + Enter'

> After each of the cells have been run successfully, you should have census data 'population by county' in the cluster folder '/example/popbycorc' as an orc file. You could verify by going to the ssh session to the head node, you created earlier and then entering 'hdfs dfs -ls /example'. 

- to create a Hive table, open either beeline in the ssh session to the headnode or Hive view 2 from Ambari
- execute the hive script, which you find here: '/notebooks/hdi/create-table.hql'

> if you get an access denied error message, especially when you wanted to create the table, the hive user doesn't have the necessary permissions. In order to permit the hive user enter the following command in the ssh session to the head node 'hdfs dfs -chown -R hive:Hadoop /example' 
<br />
<br />

### Databricks Part
---

In this lab, you will create a databricks cluster, connect it to the storage account and the Hive metastore of the HDI cluster and then copy the population by country table to another location on the storage account as Delta table via CETAS.

- in Azure Portal, open Databricks Service and 'Launch Workspace'.
- go to 'Compute' and create a Single Node Cluster by
  - clicking 'Single Node' radio at the bottom and leaving everything as default
  - click 'create cluster'
- wait until the cluster is running
- go to 'Workspace' and import from 'notebooks/setup_metastore_jars.dbc'
- after opening the notebook, make sure, that username and password, as well as the jdbc connection string is correct and reflects your environment.To find the jdbc connectionstring to the hive database:
  - in Azure Portal, in your Resource Group, click on 'hivedbhditoadbdev'
  - click on 'Connection strings' on the left
  - click on the 'JDBC' tab; copy everything up to and excluding user=...
- attach the notebook to the newly created cluster and run it. The notebook is going to create a bash script file in '/databricks/scripts/' named 'external-metastore.sh'. This bash script is going to set a few hive variables and download the needed hive jars with the correct version
- from the second executed cell, copy the path contents
- go to your cluster and click 'Edit' in the right upper corner
- open 'Advanced options'
- click the 'Init Scripts' tab
- copy the whole path, that you copied, after dbfs:/ then delete the second occurence of dbfs:/ off the string
- click 'Add'
- to set the cluster configuration to connect to the blob storage of the HDInsight cluster as well as the target data lake gen 2 account do the following:
  - go to the cluster and click 'Edit' to edit its configuration (right upper corner)
  - open 'Advanced Options' and on the 'Spark' tab in the 'spark config' box, enter the following to key value pairs:
    - fs.azure.account.key.'dlg2 storage accountname'.dfs.core.windows.net 'account key for blob storage account'
    - fs.azure.account.key.'blob storage account name of hdinsight cluster'.blob.core.windows.net 'account key for blob storage account'
    - (be sure to have just one blank between key and value)
- click 'Confirm and restart'

> the cluster restarts and loads the necessary jar files from maven as well as sets its configuration to point to the hive metastore of the HDI cluster

- import the notebook 'notebooks/hdi-to-adb-lab2.dbc'
- open it and attach it to the cluster
- set the storageAccountName to the storage account name of the HDInsight cluster: sa...; and then the storageAcctKey to the account key of the storage account (to be found in portal)
- run the first cell to check the connection to the Hive metastore server (should read something like connection succeeded)
- in the second cell, you have to storage account name and access key (you get all these values from the Azure Portal and the storage account in your resource group)



## Lab 2 - Migrate Spark Code
---

### Run legacy code on HDI

- goto jupyter environment on Spark cluster 'https://spark-cluster-int.azurehdinsight.net/jupyter'
- upload notebook from 'ossspark-to-adb/notebooks/hdi/LegacyContext.ipynb'
- run notebook cell by cell and notice it's working

---

- goto Databricks environment and create/start a cluster if not yet already done so
- upload notebook from /notebooks/hdi/LegacyContext.ipynb and run cell by cell
- in cell 3 (sc = SparkContext()) notice the error message: VelueError: Cannot run multiple sparkContexts at once
- change the code in cell 3 to 'sc = SparkContext.getOrCreate(conf=conf) and
- run the notebook cell by cell and notice it's running successfully
- in the last line, when executing sc.stop() notice the message 'The Spark Context has stopped and the driver is restarting. Your notebook will be automatically attached.'

> You do not want to stop the context or spark session, since it's affects ALL users of the cluster (restarts the driver node)
   
   

---

---

# Ranger Module Labs

## Lab 1 Table Access Control in Databricks
---

> you need a Premium plan workspace. AlsoTable Access control has to be enabled in 'Settings' - 'Admin Console' - 'workspace settings' - 'Access Control\Table Access Control: Enabled'

### Create a cluster and add a second user to the workspace
---

- log on to your workspace as the admin. This will be called the 1st browser session
- click 'Compute' and then 'Create Cluster'
- make the following settings:
  - Access Mode: Shared
  - Runtime: at least 10.4 LTS or higher
  - Autoscaling: unchecked
  - Workers: 1
- click 'Create Cluster'
- add a second user to the workspace p.ex. 'hugo' (needs to be existing in AAD)
  - go to 'Settings' - 'Admin Console' - 'Users' - 'Add User' and enter the upn of the newly added user
  - for the newly added user check 'Workspace Access' and 'Databricks SQL Access' (don't check 'Allow unrestricted cluster creation' and 'Admin')
  - either give this new user then Reader permissions to the Resource Group or give him/her the ADB workspace url
  - in a new private/incognito session of the browser login as this user to the workspace by either going to https://portal.azure.com and entering the password or entering the ADB workspace url in the browser address input box
  - in this 2nd browser session click in 'Data Science Engineering' on 'SQL'
  - click on 'SQL Warehouses' and here click on 'Start' and wait for the warehouse to be started
<br />
<br />
    
### Create a table and verify access, grant access
---
  
  - click on 'Query' and enter 'Select * from silver' -> notice the error message "User does not have permission SELECT on table 'default'.'silver', which was expected
  - in the 1st browser session click on 'Data' - 'silver' - 'Permissions', then click on 'Grant' in the dialog in the input box ('type to add...') add hugo@... and check 'SELECT', click on 'Grant'
  - goto 2nd browser session and click 'Run all' again notice again the error message, that the user needs usage permission on database
  - goto 1st browser session and click on 'Default' - 'Permissions' and grant 'hugo@...' 'Usage'
  - goto 2nd browswer session and click again 'Run all'
  - Notice, that the query succeeds now, after he/she was granted 'Usage' on database and 'Select' on table


### create a gold table filter rows, mask columns