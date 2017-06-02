# AutoGroupAssignmenet
Powershell Script to add AD users to groups. This is a refinement of Auto_SecuirityGroups.ps1 found in Active-Drectory-Tasks from my work account "Justaschooltech".

The script will add users to groups based on attribute values. For example all users with Company A populated in the AD attribute "company" will be added to Group A. Group name, attribute and value can be set in groupslist.csv. 

You must edit the script to include the correct location to groupslist.csv and the location you would like to log results. 
