#!/usr/bin/python

import requests
from lxml import html

#link = "http://www.shopgoodwill.com/search/SearchKey.asp?itemTitle=&catid=4&sellerID=5&closed=no&minPrice=&maxPrice=&sortBy=itemEndTime&SortOrder=a&showthumbs=on"
#f = requests.get(link)


#import re
#m = re.search('(?<=tbody)(.*)tbody', f.text, re.DOTALL)
#print m.group(0)



#buyers = tree.xpath('//tr/text()')
#print buyers


page=1
base_url = "http://www.shopgoodwill.com/search/searchKey.asp?sortBy=itemEndTime&sortOrder=a&itemTitle=&minPrice=&maxPrice=&closed=&month=&day=&year=&days=0&catID=4&sellerID=5&srchdesc=&showthumbs=on&itemSellerStore=&page={}"


def read_page(url, page):
    url = url.format(page)
    f = requests.get(url)
    tree = html.fromstring(f.text)

    # item-id
    x = tree.xpath('/html/body/div[2]/div[2]/table/tbody/tr/th[1]')
    p_item_ids = [i.text for i in x]

    # images
    x = tree.xpath('//th/img/@src')
    [i for i in x]
    p_images = [i.replace("-thumb","") for i in x]

    # titles
    x = tree.xpath('//tr/th/a')
    p_titles = [i.text for i in x]

    # price
    x = tree.xpath('//td/b')
    p_prices = [i.text for i in x]

    items = []
    for n in range(len(p_item_ids)):
        tmp = {'item_id': p_item_ids[n],
               'image': p_images[n],
               'title': p_titles[n],
               'price': p_prices[n],
           }
        items.append(tmp)
    return items

items = []
for i in range(1,20):
    page_items = read_page(base_url, i)
    items = items+page_items
    print("Page {} found {} items.".format(i, len(page_items)))

print("Total items: {}".format(len(items)))

#for item in items:
#    bakkle.addItem(item)

#import pdb; pdb.set_trace()
