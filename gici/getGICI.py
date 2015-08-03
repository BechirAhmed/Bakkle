#!/usr/bin/python
#
# run ./giciDeps.sh to install PIL before running this script

import requests
from lxml import html
import os
import socket
import json
from Queue import Queue
from threading import Thread
import urllib
from PIL import Image
import time
import urllib2
import base64
import random
#import Image

server_id = 1  # SET to change server
image_width = 660
image_height = image_width

page = 1
base_url = "http://www.shopgoodwill.com/search/SearchKey.asp?itemtitle=&showthumbs=on&sortBy=itemEndTime&sortOrder=a&closed=&sellerid=5&srchdesc=&month=&day=&year=&days=0&itemSellerStore=&page={}"

# Collectables
#base_url = "http://www.shopgoodwill.com/search/searchKey.asp?sortBy=itemEndTime&sortOrder=a&itemTitle=&minPrice=&maxPrice=&closed=&month=&day=&year=&days=0&catID=4&sellerID=5&srchdesc=&showthumbs=on&itemSellerStore=&page={}"

data_file = "data.json"
image_dir = "gici_images"
if not os.path.exists(image_dir):
    os.makedirs(image_dir)


def read_page(url, page):
    url = url.format(page)
    f = requests.get(url)
    tree = html.fromstring(f.text)

    # item-id
    x = tree.xpath('/html/body/div[2]/div[2]/table/tbody/tr/th[1]')
    p_ids = [i.text for i in x]

    # images
    x = tree.xpath('//th/img/@src')
    [i for i in x]
    p_image_urls = [i.replace("-thumb", "") for i in x]

    # titles
    x = tree.xpath('//tr/th/a')
    p_titles = [i.text for i in x]

    # price
    x = tree.xpath('//td/b')
    p_prices = [i.text for i in x]

    # date end
    x = tree.xpath('/html/body/div[2]/div[2]/table/tbody/tr/th[5]')
    p_end_dates = [i.text for i in x]

    page_items = {}
    for n in range(len(p_ids)):
        tmp = {'id':        p_ids[n],
               'image_url': p_image_urls[n],
               'title':     p_titles[n],
               'price':     p_prices[n],
               'end_date':  p_end_dates[n],
               }
        page_items[p_ids[n]] = tmp
    return page_items


items = {}
print("Reading existing JSON")
if os.path.isfile(data_file):
    with open(data_file, 'r') as f:
        items = json.load(f)
        print("{} items loaded from JSON".format(len(items)))


test_mode = True
if not test_mode:
    max_page = 2  # 100
    for i in range(1, max_page):
        page_items = read_page(base_url, i)
        print("Page {} found {} items.".format(i, len(page_items)))
        items.update(page_items)
        time.sleep(.4)


print("Total items: {}".format(len(items)))


print("Writing JSON")
with open(data_file, 'w') as outfile:
    json.dump(items, outfile)


def download_item_image(item):
    image_file_name = os.path.join(image_dir, item['image_url'].split('/')[-1])
    scaled_image_file_name = os.path.join(
        image_dir, "scaled_" + item['image_url'].split('/')[-1])
    if not os.path.isfile(image_file_name):
        print("Downloading image for {} ({})".format(
            item['id'], item['image_url']))
        urllib.urlretrieve(item['image_url'], image_file_name)
    else:
        pass
        #print("Image exists for {} ({})".format(item['id'], item['image_url']))

    if not os.path.isfile(scaled_image_file_name):
        print("Rescaling")
        try:
            im = Image.open(image_file_name)
            width, height = im.size
            if width > height:
                # l,t,r,b
                im = im.crop(((width - height) / 2, 0, height, height))
            else:
                im = im.crop((0, (height - width) / 2, width, width))
            scaled_size = (image_width, image_height)
            im = im.resize(scaled_size, Image.ANTIALIAS)
            im.save(scaled_image_file_name)
        except:
            print("Error rescaling {}".format(item['id']))


def worker():
    while True:
        item = q.get()
        download_item_image(item)
        q.task_done()

num_worker_threads = 3
q = Queue()
for i in range(num_worker_threads):
    t = Thread(target=worker)
    t.daemon = True
    t.start()

for item in items:
    q.put(items[item])

q.join()       # block until all tasks are done


class Bakkle():

    def __init__(self):
        self.location = "39.97,-86.12"
        self.user_id = 0
        self.auth_token = None
        self.device_uuid = 42
        pass

    def server_url(self):

        hostname = socket.gethostname()

        # if(hostname == 'ip-172-31-21-18' or hostname == 'ip-172-31-27-192'):
        if(server_id == 0):
            return "https://app.bakkle.com"

        # elif(hostname == 'bakkle'):
        elif(server_id == 1):
            return "http://bakkle.rhventures.org:8000"

        # elif(hostname == 'rhv-bakkle-bld' or hostname == 'RHV-291SCS-Linux'):
        elif(server_id == 2):
            return "http://wongb.rhventures.org:8000"

        else:
            return "http://bakkle.rhventures.org:8000"

    def set_location(self, location):
        self.location = location

    def facebook(self, email, gender, username, name, facebook_user_id, locale, first_name, last_name, device_uuid=0):
        url = self.server_url() + '/account/facebook/'
        data = {'email': email,
                'gender': gender,
                'username': username,
                'name': name,
                'user_id': facebook_user_id,
                'locale': locale,
                'first_name': first_name,
                'last_name': last_name,
                'device_uuid': device_uuid,
                'user_location': self.location,
                'flavor': 2,
                'app_version': '1.1',
                }
        self.facebook_user_id = facebook_user_id
        self.device_uuid = device_uuid
        r = requests.post(url, data=data)
        print("Create account. Return: {}".format(r.json()))

    def login(self):
        # let postString =
        # "device_uuid=\(self.deviceUUID)&user_id=\(self.facebook_id_str)&screen_width=\(screen_width)&screen_height=\(screen_height)&app_version=\(a)&app_build=\(b)&user_location=\(encLocation)&is_ios=true"
        url = self.server_url() + '/account/login_facebook/'
        data = {'device_uuid': self.device_uuid,
                'user_id': self.facebook_user_id,
                'screen_width': 1,
                'screen_height': 1,
                'user_location': '39.8661123,-86.1239327',
                'app_version': '1',
                'app_build': '1',
                'is_ios': False,
                'flavor':2
                }
        r = requests.post(url, data=data)
        print("Login(facebook). Return: {}".format(r.text))
        self.auth_token = r.json()['auth_token']

    def addItem(self, item):
        #print("Uploading item to bakkle server")
        # print(item)
        image_file_name = os.path.join(
            image_dir, item['image_url'].split('/')[-1])
        trimmed_title = item['title'][0:item['title'][0:32].rfind(' ')]
        print("{} - {}".format(trimmed_title.rjust(32), image_file_name))

        image_abs_path = os.path.dirname(
            os.path.abspath(__file__)) + "/" + image_file_name

        url = self.server_url() + '/items/add_item/?notify=0&device_uuid={}&auth_token={}&title='.format(self.device_uuid, self.auth_token) + urllib.quote(trimmed_title,
                                                                                                                                                           '') + '&description={}&location={}&tags={}&price='.format(item['title'], self.location, item['title']) + item['price'].replace("$", "") + '&method=Pick%20up'

        # 'file' => name of html input field
        files = {'image': open(image_abs_path, "rb")}
        r = requests.post(url, files=files)
        print("Return: {}".format(r.json()))


q = Queue()
b = Bakkle()
b.set_location = "39.8661123,-86.1239327"
print("Uploading items to bakkle server: {}".format(b.server_url()))
b.facebook("goodwill2@pethes.com", "male", "goodwill",
           "Goodwill Industries", 3, "", "Goodwill", "Industries", 0)
b.login()


def addImageWorker():
    while True:
        item = q.get()
        b.addItem(item)
        q.put(item)

        delayTime = 30 + random.randint(0, 30) - 15
        time.sleep(delayTime)
        q.task_done()

for i in range(num_worker_threads):
    t = Thread(target=addImageWorker)
    t.daemon = True
    t.start()

for item in items:
    # b.addItem(items[item])

    q.put(items[item])

q.join()       # block until all tasks are done


#import pdb; pdb.set_trace()
