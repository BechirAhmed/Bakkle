package com.bakkle.bakkle;

import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;

import com.google.gson.JsonObject;
import com.koushikdutta.async.future.FutureCallback;
import com.koushikdutta.ion.Ion;
import com.koushikdutta.ion.builder.Builders;

import java.io.File;
import java.util.ArrayList;

/**
 * Created by vanshgandhi on 6/16/15.
 */
public class ServerCalls{

//    final static String url_base                 = "https://bakkle.rhventures.org/";
    final static String url_base                 = "https://app.bakkle.com/";
    final static String url_login                = "account/login_facebook/";
    final static String url_logout               = "account/logout/";
    final static String url_facebook             = "account/facebook/";
    final static String url_register_push        = "account/device/register_push/";
    final static String url_reset                = "items/reset/";
    final static String url_mark                 = "items/";
    final static String url_feed                 = "items/feed/";
    final static String url_garage               = "items/get_seller_items/";
    final static String url_add_item             = "items/add_item/";
    final static String url_send_chat            = "conversation/send_message/";
    final static String url_view_item            = "items/";
    final static String url_buyers_trunk         = "items/get_buyers_trunk/";
    final static String url_get_holding_pattern  = "items/get_holding_pattern/";
    final static String url_buyertransactions    = "items/get_buyer_transactions/";
    final static String url_sellertransactions   = "items/get_seller_transactions/";

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
        //Log.v("auth_token is ", auth_token);
        return auth_token;
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
        Log.v("auth_token is ", authToken);
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
            Ion.with(mContext)
                    .load(url_base + url_mark + status + "/")
                    .setBodyParameter("auth_token", authToken)
                    .setBodyParameter("device_uuid", uuid)
                    .setBodyParameter("item_id", item_id)
                    .setBodyParameter("view_duration", viewDuration)
                    .asJsonObject()
                    .setCallback(new FutureCallback<JsonObject>() {
                        @Override
                        public void onCompleted(Exception e, JsonObject result) {

                            if(e == null) {
                                jsonResponse = result;
                                Log.v("response is ", jsonResponse.toString());
                            }

                            else{
                                jsonResponse = null;
                                Log.v("testing error 00", "json was null (there was an exception)");
                                Log.v("test", e.getMessage());
                                Log.v("test", e.getStackTrace()[0].toString());

                            }
                        }
                    });
            Log.v("auth token is ", authToken);

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

    public JsonObject addItem(String name, String description, String price, String pickupMethod, String tags,
                              ArrayList<String> imageUri, String authToken, String uuid)
    {
//
//        FileOutputStream fileOutputStream = null;
//        Bitmap temp;
//
//        try {
//            fileOutputStream = new FileOutputStream(mCurrentPhotoPath);
//            temp = Bitmap.createScaledBitmap(BitmapFactory.decodeFile(mCurrentPhotoPath), 640, 640, true);
//            temp.compress(Bitmap.CompressFormat.JPEG, 70, fileOutputStream);
//            fileOutputStream.flush();
//            fileOutputStream.close();
//        }
//        catch (Exception e){
//            Log.v("Bitmap scaling error", e.getMessage());
//        }


        try {
            Log.v("imageURI 0 is ", imageUri.get(0));


            Builders.Any.M body = Ion.with(mContext)
                    .load("POST", url_base + url_add_item)
                    .setLogging("UPLOAD LOG ", Log.VERBOSE)
                    .setMultipartParameter("auth_token", authToken)
                    .setMultipartParameter("device_uuid", uuid)
                    .setMultipartParameter("title", name)
                    .setMultipartParameter("description", description)
                    .setMultipartParameter("price", price)
                    .setMultipartParameter("method", pickupMethod)
                    .setMultipartParameter("tags", tags)
                    .setMultipartParameter("location", "32,32"); //TODO: GET REAL LOCATION

            for(String uri : imageUri){
                body.setMultipartFile("image", new File(uri));
            }


            body.asJsonObject().setCallback(new FutureCallback<JsonObject>() {
                    @Override
                    public void onCompleted(Exception e, JsonObject result) {
                if (e != null)
                    e.printStackTrace();
                Log.v("the result is ", result.toString());
                jsonResponse = result;
                }
            });
        }
        catch (Exception e){
            Log.v("testing upload", e.getMessage());
            e.printStackTrace();
        }

        return jsonResponse;


    }

    public void deleteItem(String authToken, String uuid, String pk)
    {
        markItem("meh", authToken, uuid, pk, "42");
    }

    public void resetDemo(String authToken, String uuid){
        try {
            Ion.with(mContext)
                    .load(url_base + url_reset)
                    .setBodyParameter("auth_token", authToken)
                    .setBodyParameter("device_uuid", uuid)
                    .asJsonObject()
                    .setCallback(new FutureCallback<JsonObject>() {
                        @Override
                        public void onCompleted(Exception e, JsonObject result) {
                            jsonResponse = result;
                        }
                    });
        }
        catch (Exception e) {
            Log.d("testing error 00", e.getMessage());
        }

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
