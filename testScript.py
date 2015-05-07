#!/usr/bin/python
#
# author: ajs
# license: bsd
# copyright: re2

import json 
import sys
import urllib2
import time

jenkinsUrl = "http://rhv-bakkle-jenkins.rose-hulman.edu:8080/job/"
jobName = "test"

try:
    print jenkinsUrl + jobName + "/lastBuild/api/json"
    jenkinsStream = urllib2.urlopen(jenkinsUrl + jobName + "/lastBuild/api/json")
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
    if buildStatusJson["result"] == "SUCCESS":
        req = urllib2.Request("http://sauron.rhventures.org:8765/lamp/A1/OFF")
        urllib2.urlopen(req)
        req = urllib2.Request("http://sauron.rhventures.org:8765/lamp/A2/ON")
        urllib2.urlopen(req)
        #time.sleep(0.5)
    else:
        req = urllib2.Request("http://sauron.rhventures.org:8765/lamp/A2/OFF")
        urllib2.urlopen(req)
        req = urllib2.Request("http://sauron.rhventures.org:8765/lamp/A1/ON")
        urllib2.urlopen(req)
        #time.sleep(0.5)
else:
    sys.exit(5)

sys.exit(0)