#!/usr/bin/python

import requests
from lxml import html
import os
import json
from Queue import Queue
from threading import Thread
import urllib
import urllib2
import base64
#import Image

server_id = 3 # SET to change server
image_width = 660
image_height = image_width

page=1
base_url = "http://www.shopgoodwill.com/search/SearchKey.asp?itemtitle=&showthumbs=on&sortBy=itemEndTime&sortOrder=a&closed=&sellerid=5&srchdesc=&month=&day=&year=&days=0&itemSellerStore=&page={}"

#Collectables
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
    p_image_urls = [i.replace("-thumb","") for i in x]

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
if test_mode:
    max_page = 2 #20
    for i in range(1,max_page):
        page_items = read_page(base_url, i)
        print("Page {} found {} items.".format(i, len(page_items)))
        items.update(page_items)


print("Total items: {}".format(len(items)))


print("Writing JSON")
with open(data_file, 'w') as outfile:
    json.dump(items, outfile)

def download_item_image(item):
    image_file_name = os.path.join(image_dir, item['image_url'].split('/')[-1])
    if not os.path.isfile(image_file_name):
        print("Downloading image for {} ({})".format(item['id'], item['image_url']))
        urllib.urlretrieve(item['image_url'], image_file_name)
        #im = Image.open(image_file_name)
        #width, height = im.size
        #if width > height:
        #    # l,t,r,b
        #    im.crop( (width-height)/2, 0, width+(width-height)/2, height )
        #else:
        #    im.crop( 0, (height-width)/2, width, height+(height-width)/2 )
        ##im.resize( 660, 660 )
    else:
        print("Image exists for {} ({})".format(item['id'], item['image_url']))



def worker():
    while True:
        item = q.get()
        download_item_image(item)
        q.task_done()

num_worker_threads = 10
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
        pass

    def server_url(self):
        if server_id==0:
            return "https://app.bakkle.com/"
        elif server_id==2:
            return "http://bakkle.rhventures.org:8000"
        elif server_id==3:
            return "http://wongb.rhventures.org:8000"
        else:
            return "http://bakkle.rhventures.org"

    def addItem(self, item):
        print("Uploading item to bakkle server")
        print(item)
        image_file_name = os.path.join(image_dir, item['image_url'].split('/')[-1])
        print image_file_name
        image_abs_path = os.path.dirname(os.path.abspath(__file__)) + "/" + image_file_name

        url = self.server_url() + '/items/add_item/?notify=0&device_uuid=E6264D84-C395-4132-8C63-3EF051480191&auth_token=asdfasdfasdfasdf_2&title=' + urllib.quote(item['title'], '') + '&description=dummyDesc&location=39.417672,-87.330438&tags=dummyTags&price=' + item['price'].replace("$", "") + '&method=Pick%20up' 
        
        files = {'image': open(image_abs_path, "rb") } #'file' => name of html input field
        r = requests.post(url, files=files)

b = Bakkle()
for item in items:
    b.addItem(items[item])

#import pdb; pdb.set_trace()
