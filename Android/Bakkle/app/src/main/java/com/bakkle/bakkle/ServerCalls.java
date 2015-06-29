package com.bakkle.bakkle;

import android.content.Context;
import android.media.Image;
import android.os.AsyncTask;
import android.util.Log;

import com.google.gson.JsonObject;
import com.koushikdutta.ion.Ion;

import java.util.ArrayList;

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
    int response;
    String auth_token;
    ArrayList items;
    JsonObject jsonResponse;

    //TODO: make this entire class non-instantiable. aka, make the class final, make the constructor private, and pass the context to each method individually

    public ServerCalls(Context c)
    {
        mContext = c;
        jsonResponse = null;

    }

    public int registerFacebook(final String email, final String gender, final String username,
                                final String name, final String userid, final String locale,
                                final String first_name, final String last_name, String id){

        response = 0;
        /*Ion.with(mContext)
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
                });*/
        try {
            response = Ion.with(mContext)
                    .load(url_base + url_facebook)
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
                    .get()
                    .get("status")
                    .getAsInt();
        }
        catch (Exception e) {
            Log.d("testing error 1", e.getMessage());
        }
        //Toast.makeText(mContext, "The value of response is: " + response, Toast.LENGTH_SHORT).show();
        return response;
    }

    public String loginFacebook(String device_uuid, String userid, String location){

        /*Ion.with(mContext)
                .load(url_base + url_login)
                .setBodyParameter("device_uuid", device_uuid)
                .setBodyParameter("user_id", userid)
                .setBodyParameter("app_version", BuildConfig.VERSION_NAME)
                .setBodyParameter("user_location", location)
                .setBodyParameter("is_ios", "false")
                .asJsonObject()
                .setCallback(new FutureCallback<JsonObject>() {
                    @Override
                    public void onCompleted(Exception e, JsonObject result) {
                        if (result != null) {
                            Log.d("testing 2234", result.toString());
                            Toast.makeText(mContext, result.toString(), Toast.LENGTH_SHORT).show();
                            response = result.get("status").getAsInt();
                            auth_token = result.get("auth_token").getAsString();
                            Toast.makeText(mContext, "The value of response is: " + response, Toast.LENGTH_SHORT).show();
                        } else {
                            Log.d("testing 2234", "did not work");
                            Toast.makeText(mContext, "did not work", Toast.LENGTH_SHORT).show();
                        }
                    }
                });*/
        try {
            auth_token = Ion.with(mContext)
                    .load(url_base + url_login)
                    .setBodyParameter("device_uuid", device_uuid)
                    .setBodyParameter("user_id", userid)
                    .setBodyParameter("app_version", BuildConfig.VERSION_NAME)
                    .setBodyParameter("user_location", location)
                    .setBodyParameter("is_ios", "false")
                    .asJsonObject()
                    .get()
                    .get("auth_token")
                    .getAsString();
        }
        catch (Exception e){
            Log.d("testing error", e.getMessage());
        }
        return "71b8789fb02532f64d01601a812b0140_12";
        //return auth_token;
    }

    public JsonObject getFeedItems(String authToken, String filterPrice, String filterDistance,
                             String search, String location, String filterNumber, String uuid){

        /*Ion.with(mContext)
                .load(url_base + url_feed)
                .setBodyParameter("auth_token", authToken)
                .setBodyParameter("device_uuid", uuid)
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
                            Toast.makeText(mContext, result.toString(), Toast.LENGTH_SHORT).show();
                            response = result.get("status").getAsInt();
                            jsonResponse = result;
                            Toast.makeText(mContext, "The value of response is: " + response, Toast.LENGTH_SHORT).show();
                        } else {
                            Log.d("testing 3234", "did not work");
                            Toast.makeText(mContext, "did not work", Toast.LENGTH_SHORT).show();
                        }



                    }
                });*/
        try {
            jsonResponse = Ion.with(mContext)
                    .load(url_base + url_feed)
                    .setBodyParameter("auth_token", authToken)
                    .setBodyParameter("device_uuid", uuid)
                    .setBodyParameter("search_text", search)
                    .setBodyParameter("filter_distance", filterDistance)
                    .setBodyParameter("filter_price", filterPrice)
                    .setBodyParameter("filter_number", filterNumber)
                    .setBodyParameter("user_location", location)
                    .asJsonObject()
                    .get();
        }
        catch (Exception e){
            Log.d("testing error 00", e.getMessage());
        }

        //Toast.makeText(mContext, jsonResponse.toString(), Toast.LENGTH_SHORT).show();

        return jsonResponse;
    }

    public int logout(){

        return 0;
    }

    public void registerDeviceForPushNotifications(){

    }

    public void markItem(String status, String authToken, String uuid, String item_id, String viewDuration){
//TODO: defintely make these Async as soon as possible
        try {
            jsonResponse = Ion.with(mContext)
                    .load(url_base + url_mark + status + "/")
                    .setBodyParameter("auth_token", authToken)
                    .setBodyParameter("device_uuid", uuid)
                    .setBodyParameter("item_id", item_id)
                    .setBodyParameter("view_duration", viewDuration)
                    .asJsonObject()
                    .get();
        }
        catch (Exception e){
            Log.d("testing error 00", e.getMessage());
        }

    }

    public JsonObject populateGarage(String authToken, String uuid){

        try {
            jsonResponse = Ion.with(mContext)
                    .load(url_base + url_garage)
                    .setBodyParameter("auth_token", authToken)
                    .setBodyParameter("device_uuid", uuid)
                    .asJsonObject()
                    .get();
        }
        catch (Exception e) {
            Log.d("testing error 005", e.getMessage());

        }

        return jsonResponse;

    }

    public JsonObject populateHolding(String authToken, String uuid){
        try {
            jsonResponse = Ion.with(mContext)
                    .load(url_base + url_get_holding_pattern)
                    .setBodyParameter("auth_token", authToken)
                    .setBodyParameter("device_uuid", uuid)
                    .asJsonObject()
                    .get();
        }
        catch (Exception e) {
            Log.d("testing error 006", e.getMessage());

        }

        return jsonResponse;

    }

    public JsonObject populateTrunk(String authToken, String uuid){


        try {
            jsonResponse = Ion.with(mContext)
                    .load(url_base + url_buyers_trunk)
                    .setBodyParameter("auth_token", authToken)
                    .setBodyParameter("device_uuid", uuid)
                    .asJsonObject()
                    .get();
        }
        catch (Exception e) {
            Log.d("testing error 007", e.getMessage());

        }

        return jsonResponse;

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

    private class backgroundTask extends AsyncTask<String, String, String>{

        @Override
        protected String doInBackground(String... urls) {

            return null;
        }

        @Override
        protected void onPostExecute(String result)
        {

        }


    }

}
