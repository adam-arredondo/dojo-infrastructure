
#!/bin/bash
# This script creates a user account downloads the public key from the specified s3 bucket and
# adds it to the autorized keys file for the user.

# S3 bucket and user agent that the S3 bucket poilcy allows GET object for
sshBucketAccess="https://s3-us-west-1.amazonaws.com/ssh-setup/"
s3_userAgent="oz-SSHSetupBot1.0"

ssh_user="$1"

# Sets S3 URLs for user public key and sudoer entry
s3_sshPubKey="$sshBucketAccess$ssh_user/$ssh_user-pub.txt"
s3_sshSudoer="$sshBucketAccess$ssh_user/$ssh_user-sudoer.txt"
sshPubKey="$ssh_user-pub.txt"
sshSudoer="$ssh_user-sudoer.txt"

# Adds user and checks status code
adduser --disabled-password --gecos "" $ssh_user
if [ $? -eq 0 ]
  then
    echo $ssh_user user has been created
    echo Proceeding with .ssh DIR setup...
    echo
  else
    echo "$ssh_user user was not created. Please capture any error message and send to $ssh_user "
    echo "Exiting... "
    echo
    exit
  fi

#Create ssh DIR in redIT user home DIR and confirm successful download of redIT public key
su - $ssh_user -c 'mkdir ~/.ssh'
su - $ssh_user -c 'chmod 700 ~/.ssh'
su - $ssh_user -c 'touch ~/.ssh/authorized_keys'
su - $ssh_user -c 'chmod 600 .ssh/authorized_keys'
wget -q -P /home/$ssh_user/.ssh/ --header="Accept: text/html" --user-agent="$s3_userAgent" "$s3_sshPubKey"
cat /home/$ssh_user/.ssh/$sshPubKey >> /home/$ssh_user/.ssh/authorized_keys
rm /home/$ssh_user/.ssh/$sshPubKey
if [ $? -eq 0 ]
  then
    echo "The public key has successfully downloaded "
    echo
  else
    echo "The Public Key for $ssh_user was not downloaded. Please check that the public key exists "
    echo "Exiting... "
    echo
    exit
fi

#Validation that authroized_keys file was created
authfile="/home/$ssh_user/.ssh/authorized_keys"
if [ -e "$authfile" ]
  then
    echo "ssh access has been configured for $ssh_user. "
    echo
  else
    echo "The authorized_keys file does not exist, setup failed "
    echo
fi

#Create the Sudoers entry for the user account which will grant it full access to the Yum command. This command will allow redIT to perform and manage updates
echo -e "Add $ssh_user to Sudoers? (y/n) : "
read text
sudo_choice=$text
if [ $sudo_choice == "y" ]
then
  wget -q --header="Accept: text/html" --user-agent="$s3_userAgent" "$s3_sshSudoer"
  if [ $? -eq 0 ]
    then
      echo "The $ssh_user user settings has successfully downloaded "
      echo "Adding to /etc/sudoers... "
      echo
    else
      echo "sudo settings for $ssh_user in $s3_sshSudoer not found or could not be downloaded "
      echo "Exiting... "
      exit
  fi
  cat $sshSudoer >> /etc/sudoers
  if [ $? -eq 0 ]
    then
      echo "$ssh_user user now has sudo permissions "
    else
      echo "There was an error when adding the permissions. "
      echo "Exiting..."
      exit
  fi
rm -f $sshSudoer
else
  echo "$ssh_user User not added to sudoers "
  echo "Exiting... "
  echo ""
  exit
fi
echo ""
