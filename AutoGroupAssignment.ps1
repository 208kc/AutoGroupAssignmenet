#Script Setup

#A file with a list of groups to modify. 
$File = "d:\groupslist.csv"
#Where to log errors. 
$LogLocation = "d:\Script Logs\AutoGroupAssignment.log"


function GetGroupsFromFile ($File){
    #Create an array with info from group file
    $GroupArray = import-csv $File
    #Walk through array and collect 
    foreach ($Group in $GroupArray){
        $GroupName = $Group.GroupName
        $TestAttribute = $Group.TestAttribute
        $TestValue = $Group.TestValue
        $Users = Get-ADUser -Filter {$TestAttribute -eq $TestValue}
        $GroupMembers = Get-ADGroupMember -Identity $GroupName
        
        AutoGroupAssignmentAddUser $GroupName $TestAttribute $TestValue $Users
        AutoGroupAssignmentRemoveUser $GroupName $TestAttribute $TestValue $GroupMembers
    }
}

function AutoGroupAssignmentAddUser ($GroupName, $Attributes, $Values, $Users){

    #Test if attribute matches value, if it does not match add the user from the group
    foreach($User in $Users){
        #Check to see if member is already in the group.
        if((Get-ADUser $User -Properties MemberOf).memberof -like "CN=$GroupName*"){
            #Log user already in group
            "$(Get-date) $User already in $GroupName" | Out-File $LogLocation -Append      
        }
        #Add user to group if not a member.
        else{
            Try{
                Add-ADGroupMember -Identity $GroupName -Members $user.SamAccountName -ErrorAction Stop
                "$(Get-date) $user added to $GroupName" | Out-File $LogLocation -Append
            }
            Catch{
                "$(Get-date) Failed to add $user to $GroupName" | Out-File $LogLocation -Append
            }
        }
    }       
}

function AutoGroupAssignmentRemoveUser ($GroupName, $TestAttribute, $TestValue, $GroupMembers){
    #Check to see if the group memeber still qualifies for membership based on attribute value. Remove them if they don't. Log actions.
    foreach($GroupMember in $GroupMembers){
        Try{
            if((Get-ADUser $GroupMember -Properties $TestAttribute).$TestAttribute -ne $TestValue){
                Remove-ADGroupMember -Identity $GroupName -Member $GroupMember.SamAccountName -Confirm:$false -ErrorAction Stop
                #Log success
                "$(Get-date) $GroupMember removed from $GroupName" | Out-File $LogLocation -Append
            }
        }
        Catch{
            #Log fail
            "$(Get-date) Failed to remove $member from $GroupName" | Out-File $LogLocation -Append
        }   
    }  
}

GetGroupsFromFile $File
