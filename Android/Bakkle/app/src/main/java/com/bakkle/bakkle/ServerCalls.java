package com.bakkle.bakkle;

import android.content.Context;
import android.media.Image;
import android.os.AsyncTask;
import android.provider.Settings;

import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Scanner;

/**
 * Created by vanshgandhi on 6/16/15.
 */
public class ServerCalls extends AsyncTask{

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

    Context mContext;
    String id;


    public ServerCalls(Context c)
    {
        mContext = c;
        id = Settings.Secure.getString(mContext.getContentResolver(), Settings.Secure.ANDROID_ID);
    }

    @Override
    protected Object doInBackground(Object[] obj) {
        return null;
    }

    public String loginFacebook(String email, String gender, String username, String name,
                              String userid, String locale, String first_name, String last_name){

        String response = "";


        try {
            URL url = new URL(url_base + url_facebook);
            String postParameters = "email=" + email + "name=" + name + "user_name=" + username +
                    "gender=" + gender + "user_id=" + userid + "locale=" + locale + "first_name=" +
                    first_name + "last_name=" + last_name + "device_uuid=" + id;

            HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();
            urlConnection.setDoOutput(true);
            urlConnection.setRequestMethod("POST");
            urlConnection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

            PrintWriter out = new PrintWriter(urlConnection.getOutputStream());
            out.print(postParameters);
            out.close();


            Scanner in = new Scanner(urlConnection.getInputStream());
            while(in.hasNextLine()){
                response += in.nextLine();
            }
            urlConnection.disconnect();

        }
        catch(Exception e) {
            System.out.println(e.getMessage());
        }
        return response;

    }

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
