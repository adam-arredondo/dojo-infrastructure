
#!/bin/bash
# This script creates a user account downloads the public key from the specified s3 bucket and
# adds it to the autorized keys file for the user.

# Colors
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"

# S3 bucket and user agent that the S3 bucket poilcy allows GET object for
sshBucketAccess="https://s3-us-west-1.amazonaws.com/ssh-setup/"
s3_userAgent="oz-SSHSetupBot1.0"

# Prompt for username OR comment out and hard code username
echo -n -e "$COL_GREEN Enter Username $COL_RED (Must match folder in ssh-setup bucket):$COL_RESET"
read text
ssh_user=$text
export $ssh_user

# Sets S3 URLs for user public key and sudoer entry
s3_sshPubKey="$sshBucketAccess$ssh_user/$ssh_user-pub.txt"
s3_sshSudoer="$sshBucketAccess$ssh_user/$ssh_user-sudoer.txt"
sshPubKey="$ssh_user-pub.txt"
sshSudoer="$ssh_user-sudoer.txt"

# Adds user and checks status code
sudo adduser $ssh_user
if [ $? -eq 0 ]
  then
    echo $ssh_user user has been created
    echo Proceeding with .ssh DIR setup...
    echo
  else
    echo -n -e "$COL_RED $ssh_user user was not created. Please capture any error message and send to $ssh_user $COL_RESET"
    echo -n -e "$COL_RED Exiting... $COL_RESET"
    echo
    exit
  fi

#Create ssh DIR in redIT user home DIR and confirm successful download of redIT public key
su - $ssh_user -c 'mkdir ~/.ssh'
su - $ssh_user -c 'chmod 700 ~/.ssh'
su - $ssh_user -c 'touch ~/.ssh/authorized_keys'
su - $ssh_user -c 'chmod 600 .ssh/authorized_keys'
wget -P /home/$ssh_user/.ssh/ --header="Accept: text/html" --user-agent="$s3_userAgent" "$s3_sshPubKey"
cat /home/$ssh_user/.ssh/$sshPubKey >> /home/$ssh_user/.ssh/authorized_keys
rm /home/$ssh_user/.ssh/$sshPubKey
if [ $? -eq 0 ]
  then
    echo -e -n "$COL_GREEN The public key has successfully downloaded $COL_RESET"
    echo
  else
    echo -n -e "$COL_RED The Public Key for $ssh_user was not downloaded. Please check that the public key exists $COL_RESET"
    echo -n -e "$COL_RED Exiting... $COL_RESET"
    echo
    exit
fi

#Validation that authroized_keys file was created
authfile="/home/$ssh_user/.ssh/authorized_keys"
if [ -e "$authfile" ]
  then
    echo -e -n "$COL_GREEN ssh access has been configured for $ssh_user. $COL_RESET"
    echo
  else
    echo -n -e "$COL_RED The authorized_keys file does not exist, setup failed $COL_RESET"
    echo
fi

#Create the Sudoers entry for the user account which will grant it full access to the Yum command. This command will allow redIT to perform and manage updates
echo -n -e "$COL_GREEN Add $ssh_user to Sudoers? $COL_RED (y/n) : $COL_RESET"
read text
sudo_choice=$text
if [ $sudo_choice == "y" ]
then
  wget --header="Accept: text/html" --user-agent="$s3_userAgent" "$s3_sshSudoer"
  if [ $? -eq 0 ]
    then
      echo -e -n "$COL_GREEN The $ssh_user user settings has successfully downloaded $COL_RESET"
      echo -e -n "$COL_GREEN Adding to /etc/sudoers... $COL_RESET"
      echo
    else
      echo -n -e "$COL_RED sudo settings for $ssh_user in $s3_sshSudoer not found or could not be downloaded $COL_RESET"
      echo -n -e "$COL_RED Exiting... $COL_RESET"
      exit
  fi
  cat $sshSudoer >> /etc/sudoers
  if [ $? -eq 0 ]
    then
      echo -e -n "$COL_GREEN $ssh_user user now has sudo permissions $COL_RESET"
    else
      echo -n -e "$COL_RED There was an error when adding the permissions. $COL_RESET"
      echo -n -e "$COL_RED Exiting...$COL_RESET"
      exit
  fi
rm -f $sshSudoer
else
  echo -n -e "$COL_RED $ssh_user User not added to sudoers $COL_RESET"
  echo -n -e "$COL_RED Exiting... $COL_RESET"
  echo ""
  exit
fi
echo ""
