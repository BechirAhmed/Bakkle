#!/usr/bin/python
# author: ajs
# license: bsd
# copyright: re2

import json 
import sys
import urllib2
import time

### Jenkins Solution
# jenkinsUrl = "http://rhv-bakkle-jenkins.rose-hulman.edu:8080/job/"
# jobName = "test"

# try:
#     print jenkinsUrl + jobName + "/lastBuild/api/json"
#     jenkinsStream = urllib2.urlopen(jenkinsUrl + jobName + "/lastBuild/api/json")
# except urllib2.HTTPError, e:
#     print "URL Error: " + str(e.code) 
#     print "      (job name [" + jobName + "] probably wrong)"
#     sys.exit(2)

# try:
#     buildStatusJson = json.load(jenkinsStream)
# except:
#     print "Failed to parse json"
#     sys.exit(3)

###Health Check Solution
bldUrl = "http://rhv-bakkle-bld.rhventures.org:8000"
statusUrl = "/system/health/"

try:
    check = urllib2.urlopen(bldUrl + statusUrl)
except urllib2.HTTPError, e:
    print "URL Error: " + str(e.code)
    sys.exit(2)
try:
    buildStatus = json.load(check)
except:
    print "Failed to parse json"
    sys.exit(3)

if buildStatus.has_key("health"):    
    if buildStatus["health"] == 1:
        req = urllib2.Request("http://sauron.rhventures.org:8765/lamp/A1/OFF")
        urllib2.urlopen(req)
        req = urllib2.Request("http://sauron.rhventures.org:8765/lamp/A2/ON")
        urllib2.urlopen(req)
        print "Website is Healthy! Green GO! Red NO!"
    else:
        req = urllib2.Request("http://sauron.rhventures.org:8765/lamp/A2/OFF")
        urllib2.urlopen(req)
        req = urllib2.Request("http://sauron.rhventures.org:8765/lamp/A1/ON")
        urllib2.urlopen(req)
        print "Website has Croaked! Red GO! Green NO!"
else:
    sys.exit(5)

sys.exit(0)