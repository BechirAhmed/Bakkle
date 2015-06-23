package com.bakkle.bakkle;

import android.content.Context;
import android.media.Image;
import android.provider.Settings;
import android.util.Log;
import android.widget.Toast;

import com.google.gson.JsonObject;
import com.koushikdutta.async.future.FutureCallback;
import com.koushikdutta.ion.Ion;

/**
 * Created by vanshgandhi on 6/16/15.
 */
public class ServerCalls{

    double apiVersion = 1.2;
    final String url_base                 = "https://bakkle.rhventures.org/";
//    final String url_base                 = "https://app.bakkle.com/";
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
    final String id;
    int response;
    String auth_token;


    public ServerCalls(Context c)
    {
        mContext = c;
        id = Settings.Secure.getString(mContext.getContentResolver(), Settings.Secure.ANDROID_ID);
    }

    public int registerFacebook(final String email, final String gender, final String username,
                                final String name, final String userid, final String locale,
                                final String first_name, final String last_name){

        response = 0;
        String URL = url_base + url_facebook;
        Ion.with(mContext)
                .load(URL)
                .setBodyParameter("email", email)
                .setBodyParameter("name", name)
                .setBodyParameter("user_name", username)
                .setBodyParameter("gender", gender)
                .setBodyParameter("user_id", userid)
                .setBodyParameter("locale", locale)
                .setBodyParameter("first_name", first_name)
                .setBodyParameter("last_name", last_name)
                .setBodyParameter("device_uuid", id)
                .asJsonObject()
                .setCallback(new FutureCallback<JsonObject>() {
                    @Override
                    public void onCompleted(Exception e, JsonObject result) {
                        if (result != null) {
                            Log.d("testing 1234", result.toString());
                            Toast.makeText(mContext, result.toString(), Toast.LENGTH_SHORT).show();
                            response = result.get("status").getAsInt();
                            Toast.makeText(mContext, "The value of response is: " + response, Toast.LENGTH_SHORT).show();
                        } else {
                            Log.d("testing 1234", "did not work");
                            Toast.makeText(mContext, "did not work", Toast.LENGTH_SHORT).show();
                        }
                    }
                });
        Toast.makeText(mContext, "The value of response is: " + response, Toast.LENGTH_SHORT).show();
        return response;

    }

    public void loginFacebook(String device_uuid, String userid, int location){

        Ion.with(mContext)
                .load(url_base + url_login)
                .setBodyParameter("device_uuid", device_uuid)
                .setBodyParameter("user_id", userid)
                .setBodyParameter("app_version", BuildConfig.VERSION_NAME)
                .setBodyParameter("location", ""+location)
                .asJsonObject()
                .setCallback(new FutureCallback<JsonObject>() {
                    @Override
                    public void onCompleted(Exception e, JsonObject result) {
                        if (result != null) {
                            Log.d("testing 2234", result.toString());
                            Toast.makeText(mContext, result.toString(), Toast.LENGTH_SHORT).show();
                            response = result.get("status").getAsInt();
                            Toast.makeText(mContext, "The value of response is: " + response, Toast.LENGTH_SHORT).show();
                        } else {
                            Log.d("testing 2234", "did not work");
                            Toast.makeText(mContext, "did not work", Toast.LENGTH_SHORT).show();
                        }

                    }
                });


    }

    public void populateFeed(String authToken, String filterPrice, String filterDistance,
                             String search, String location, String filterNumber){

        Ion.with(mContext)
                .load(url_base + url_feed)
                .setBodyParameter("auth_token", authToken)
                .setBodyParameter("device_uuid", id)
                .setBodyParameter("search_text", search)
                .setBodyParameter("filter_distance", filterDistance)
                .setBodyParameter("filter_price", filterPrice)
                .setBodyParameter("filter_number", filterNumber)
                .setBodyParameter("user_location", location)
                .asJsonObject()
                .setCallback(new FutureCallback<JsonObject>() {
                    @Override
                    public void onCompleted(Exception e, JsonObject result) {
                        if (result != null) {
                            Log.d("testing 3234", result.toString());
                            Log.d("testing 3324 id is ", id);
                            Toast.makeText(mContext, result.toString(), Toast.LENGTH_SHORT).show();
                            //response = result.get
                            Toast.makeText(mContext, "The value of response is: " + response, Toast.LENGTH_SHORT).show();
                        } else {
                            Log.d("testing 3234", "did not work");
                            Toast.makeText(mContext, "did not work", Toast.LENGTH_SHORT).show();
                        }

                    }
                });
    }

    public int logout(){

        return 0;
    }

    public void registerDeviceForPushNotifications(){

    }

    public void markItem(){

    }

    public void populateGarage(){

    }

    public void populateHolding(){

    }

    public void populateTrunk(){

    }

    public void sendChat(){

    }

    public void onNewChat(){

    }

    public void addItem(String name, String description, double price, double rating, String pickupMethod, String[] tags, Image[] pictures, boolean shareFB){

    }

    public void resetDemo(){

    }

    public void getFilter(){

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
}
