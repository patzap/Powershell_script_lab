# Advance version of the Powershell script from Lab 8 which includes control statements and loops for more interaction 

# Create a function named CreateUserGroup to store each input and cmdlets 
function CreateUserGroup {

    # Create variable attempts as initializer 
    $attempts = 3

    #BONUS MARKS: Do loop allows user to make a new username if one is taken 
    do {

        # set variables zapa0013_usr for user to input local host
        $zapa0013_usr = Read-Host "Please Enter name of host: "

        # set variable password for user to set an encryped password 
        $Password = Read-Host -AsSecureString 

        # set variable zapa0013_grp for user tp enter name of new local group
        $zapa0013_grp = Read-Host "Please enter name of group: "

        # create variables localuser and localgroup to store cmdlets that search for names that user prompted
        $localuser = Get-LocalUser $zapa0013_usr 2> $null

        $localgroup = Get-LocalGroup $zapa0013_grp 2> $null

        # Conditonal states that if user name already exists in localgroup in true, tell user it already exists
        if ($zapa0013_usr -eq $localuser){

            Write-Host "$zapa0013_usr already exists!!!"  

            $new_user = Read-Host "Do you wish to make a new username? Y/N"

            # will exit script if user chooses N as input
            if ($new_user -eq "N"){

                Write-Host "Press any key to continue..."
                
                exit 
           
            }
            
        # if condition is false, create a new local user using read host variable input    
        }else { 
    
            New-LocalUser -Name $zapa0013_usr -Description "User Example" -Password $Password 2> $null
    
            Write-Host "$zapa0013_usr was created !!!"
        
        }

        # Similar condition as above, but checks group name already exists 
        if ($zapa0013_grp -eq $localgroup){

             Write-Host "$zapa0013_grp already exists!!!"

        }else {
    
            New-LocalGroup -Name $zapa0013_grp -Description "Local Group Example" 2> $null

            Write-Host "$zapa0013_grp was created !!!"

        }

        # Each time the loop is execute, the value of attempts increases by 1 
        $attempts--

        Write-Host "Attempts: $attempts"

        # Add user created to localgroup
        Add-LocalGroupMember -Group $zapa0013_grp -Member $zapa0013_usr

        # Create User home folder using usr variable
        Write-Host "Creating folder $zapa0013_usr in local disk" 2> $null
    
        # Set variable for path for new folder 
        $HOMEDIR = "C:\$zapa0013_usr"

        # Create a new folder using name of user 
        New-Item -PATH $HOMEDIR -ItemType Directory 2> $null

        $Share_Name = -Join ($zapa0013_usr , "-Share") 

        # Create Share using the username 
        New-SmbShare -Name $zapa0013_usr-Share -Path $HOMEDIR 2> $null

        # Asks the user to give a drive letter to map a drive
        $Drive_Map = Read-Host "Please enter a drive letter for shared drive: "

        #Checks if there is existing drive letter used 
        $Mapped_Drive = Get-PSDrive -Name "$Drive_Map" 2> $null

        if ($Drive_Map -eq $Mapped_Drive){

            Write-Host "Drive $Drive_Map already exists"
    
            # Prompts the user if drive must be removed 
            $remove_disk = Read-Host "Do you wish to remove $Drive_Map? Y/N "
    
            if ( $remove_disk -eq "Y") {
    
                Remove-PSDrive $Drive_Map
    
            }
    
        }else {
    
            New-PSDrive -Name $Drive_Map -PSProvider FileSystem -Root "\\$env:COMPUTERNAME\$Share_Name" 
    
            Write-Host "Created shared folder in Drive $Drive_Map" 
    
        }

        # Add user permission of new user with shared folder
        Grant-SmbShareAccess -name $Share_Name -AccountName $zapa0013_usr -AccessRight Full

        # Add group permssion of new group with shared folder
        Grant-SmbShareAccess -name $Share_Name -AccessName $zapa0013_grp -AccessRight Control

    # Condition loops only if user inputs Y and if number of attempts is less or equal to 3
    } while ($new_user -eq "Y" -And $attempts -ge 0)
   
}

# Do loop that replays the function CreateUserGroup if user types Y 
do{

    CreateUserGroup
    $replay = Read-Host "Do you wish to replay script again? Y/N"

    if ($replay -eq "N"){

        Write-Host "Have a good day"

    }

} while ($replay -eq "Y")