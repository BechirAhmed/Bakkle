from django.shortcuts import render
from django.http import HttpResponse

import json
import subprocess
from django.views.decorators.csrf import csrf_exempt

@csrf_exempt
def restart(request):
    subprocess.call(['service', 'bakkle', 'restart'])
    return HttpResponse("Restarting")

@csrf_exempt
def update(request):
    subprocess.call(['/home/ubuntu/omnisite-bakkle/99-update-prod.sh'])
    return HttpResponse("Updating")

@csrf_exempt
def update(request):
    subprocess.call(['/home/ubuntu/omnisite-bakkle/99-update-prod.sh'])
    return HttpResponse("Updating")

@csrf_exempt
def health(request):
    response_data = { "status": 1, "health": 1 }
    return HttpResponse(json.dumps(response_data), content_type="application/json")

@csrf_exempt
def version(request):
    response_data = { "status": 1, "version": 1.0 } # TODO: Version hardcoded to 1
    return HttpResponse(json.dumps(response_data), content_type="application/json")


