#!/bin/sh
sudo mv ./cronjobs/* /etc/cron.d/
find /etc/cron.d/ -type f -print0 | sudo xargs -0 chmod 644 
