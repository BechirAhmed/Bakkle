#!/usr/bin/python
#
# author: ajs
# license: bsd
# copyright: re2


import json 
import sys
import urllib2

jenkinsUrl = "https://rhv-bakkle-jenkins.rose-hulman.edu/job/"
jobName = "test"

try:
    jenkinsStream = urllib2.urlopen( jenkinsUrl + jobName + "/lastBuild/api/json" )
except urllib2.HTTPError, e:
    print "URL Error: " + str(e.code) 
    print "      (job name [" + jobName + "] probably wrong)"
    sys.exit(2)

try:
    buildStatusJson = json.load(jenkinsStream)
except:
    print "Failed to parse json"
    sys.exit(3)

if buildStatusJson.has_key("result"):      
    if buildStatusJson["result"] != "SUCCESS": 
        req = urllib2.Request("http://sauron.rhventures.org:8765/lamp/A1/ON")
        urllib2.urlopen(req)
    else:
        req = urllib2.Request("http://sauron.rhventures.org:8765/lamp/A1/OFF")
        urllib2.urlopen(req)
else:
    sys.exit(5)

sys.exit(0)