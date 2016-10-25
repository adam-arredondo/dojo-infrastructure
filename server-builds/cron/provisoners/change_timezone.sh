#!/bin/sh
sudo sed 's_UTC_America/Phoenix_' /etc/sysconfig/clock
sudo ln -sf /usr/share/zoneinfo/America/Phoenix /etc/localtime
