<# 
 .SYNOPSIS
  This script creates multiple users from a CSV file in a specific OU

 .DESCRIPTION
  This Script takes input from a CSV file with user details, one per 
  line, it then creates users in the specified OU and outputs a CSV 
  file with the expected username and either "Done" or "Failed" with 
  the exception

 .INPUTS
   infile CSV needs to have fields named 
    surname = the user's family Name
    givenName = the user's given name
    department = the department to set

   OU needs to be the distinguished name of an AD OU
  
  .OUTPUTS
   The script creates a CSV with the results in the same directory as
   The input file that contains the username and the result

   the user(s) created in the OU with the AD properties created from 
   The infile CSV is as follows:
   
    sAMAccountName = givenName.surname
    displayName = givenName surname
    givenName = givenName
    surname = surname
    department = department
  .NOTES
   Copyright {2022} {Enviable Network Support and Solutions Ltd.}

   Licensed under the Apache License, Version 2.0 (the "License"); you 
   may not use this file except in compliance with the License. You may
   obtain a copy of the License at:

   http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software 
   distributed under the License is distributed on an "AS IS" BASIS, 
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or 
   implied. See the License for the specific language governing 
   permissions and limitations under the License. 
#>
begin{
$path = "CSV\file\path"                    #location of csv files
$infile = "InputUsers.csv"                 #name of input file
$Resultsfile = "UserResults.csv"           #name for resultsfile
$OU = "OU=department,OU=division,OU=Users,DC=contoso,DC=com" #place to create users
$users = Import-Csv "$path\$infile" -UseCulture
}
process{
foreach ($user in $users){
    Try{
     New-ADuser -Path $ou -Surname $User.surname -GivenName $User.givenName -DisplayName "$($user.givenName) $($user.surname)" -SamAccountName "$($user.givenName).$($user.surname.replace(" ","-"))" -Department $user.department
     $done = new-object
      $done | Add-Member -MemberType NoteProperty -Name User -Value "$($user.givenName) $($user.surname)"
      $done | Add-Member -MemberType NoteProperty -Name Result -Value "Done"
    }
    Catch {
    $done = new-object
      $done | Add-Member -MemberType NoteProperty -Name User -Value "$($user.givenName) $($user.surname)"
      $done | Add-Member -MemberType NoteProperty -Name Result -Value "Failed: $($_.exception)"
    }
    finally{
     $results += $done
    }
}
}
end{
$results | Export-Csv -NoTypeInformation -NoClobber -Path "$path\$Resultsfile" -Encoding UTF8 -UseCulture
}
