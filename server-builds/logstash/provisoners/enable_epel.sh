#!/bin/sh
# Backup repo file
sudo mv /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo_bak

# Replace with enabled epel
sudo mv /home/ec2-user/files/enabled_epel /etc/yum.repos.d/epel.repo
