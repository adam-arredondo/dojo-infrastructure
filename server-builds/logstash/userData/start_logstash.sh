#!/bin/sh
sudo /opt/logstash/bin/logstash -f /etc/logstash/conf.d/logstash.conf --auto-reload
