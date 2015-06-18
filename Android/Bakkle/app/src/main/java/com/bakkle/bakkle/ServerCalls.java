package com.bakkle.bakkle;

import android.media.Image;

/**
 * Created by vanshgandhi on 6/16/15.
 */
public class ServerCalls {

    double apiVersion = 1.2;
    final String url_base                 = "https://bakkle.rhventures.org/"; //https://app.bakkle.com for production
    final String url_login                = "account/login_facebook/";
    final String url_logout               = "account/logout/";
    final String url_facebook             = "account/facebook/";
    final String url_register_push        = "account/device/register_push/";
    final String url_reset                = "items/reset/";
    final String url_mark                 = "items/"; //+status/
    final String url_feed                 = "items/feed/";
    final String url_garage               = "items/get_seller_items/";
    final String url_add_item             = "items/add_item/";
    final String url_send_chat            = "conversation/send_message/";
    final String url_view_item            = "items/";
    final String url_buyers_trunk         = "items/get_buyers_trunk/";
    final String url_get_holding_pattern  = "items/get_holding_pattern/";
    final String url_buyertransactions    = "items/get_buyer_transactions/";
    final String url_sellertransactions   = "items/get_seller_transactions/";

    public String getTitle(){
        return null;
    }

    public double getPrice(){
        return 0;
    }

    public String getDescription(){
        return null;
    }

    public String[] getTags(){
        return null;
    }

    public String getPickupMethod(){
        return null;
    }

    public double getDistance(){
        return 0;
    }

    public double getRating(){
        return 0;
    }

    public String getSellerName(){
        return null;
    }

    public Image[] getPictures(){
        return null;
    }

    public void want(){

    }

    public void nope(){

    }

    public void holding(){

    }

    public void comment(){

    }

    public void addItem(String name, String description, double price, double rating, String pickupMethod, String[] tags, Image[] pictures, boolean shareFB){

    }

}
