from django.shortcuts import render
from django.http import HttpResponse

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

