package com.bakkle.bakkle;

import android.content.Context;
import android.media.Image;
import android.os.AsyncTask;
import android.provider.Settings;
import android.util.Log;

import java.io.BufferedInputStream;
import java.io.InputStream;
import java.io.PrintWriter;
import java.net.URL;
import java.util.Scanner;

import javax.net.ssl.HttpsURLConnection;

/**
 * Created by vanshgandhi on 6/16/15.
 */
public class ServerCalls{

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

    public String loginFacebook(String email, String gender, String username, String name,
                              String userid, String locale, String first_name, String last_name){

        String response;


        String baseUrl = url_base + url_facebook;
        String postParameters = "email=" + email + "name=" + name + "user_name=" + username +
                "gender=" + gender + "user_id=" + userid + "locale=" + locale + "first_name=" +
                first_name + "last_name=" + last_name + "device_uuid=" + id;
        //URL url = new URL(baseUrl);
        String[] urls = new String[2];
        urls[0] = baseUrl;
        urls[1] = postParameters;
        backgroundTask bgtask = new backgroundTask();
        bgtask.execute(urls);
        return "";

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

    public void test(){new backgroundTask().execute(new String[2]);}

    private class backgroundTask extends AsyncTask<String, String, String>{

        @Override
        protected String doInBackground(String... urls) {
            String response1 = "";
            String response2 = "";
            String response3;
            InputStream in;
            InputStream error;
            try {
                URL url = new URL(urls[0]);
                HttpsURLConnection urlConnection = (HttpsURLConnection) url.openConnection();
                urlConnection.setDoOutput(true);
                urlConnection.setRequestMethod("POST");
                urlConnection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

                PrintWriter out = new PrintWriter(urlConnection.getOutputStream());
                out.print(urls[1]);
                out.close();

                in = new BufferedInputStream(urlConnection.getInputStream());
                error = new BufferedInputStream(urlConnection.getErrorStream());

                byte[] contents = new byte[1024];

                int bytesRead = 0;
                String strFileContents = "";
                while( (bytesRead = in.read(contents)) != -1){
                    strFileContents += new String(contents, 0, bytesRead);
                }
                Log.d("testing", strFileContents);




                Scanner in1 = new Scanner(urlConnection.getInputStream());
                while (in1.hasNextLine()) {
                    response1 += in1.nextLine();
                }

                in.toString();
            }
            catch(Exception e){
                Log.d("testing1", e.getMessage());
            }
            Log.d("testing2", response1 + "testinggg");
            return response1;

            //============================

//            SharedPreferences.Editor editor;
//            SharedPreferences preferences;
//
//            preferences = PreferenceManager.getDefaultSharedPreferences(mContext);
//            editor = preferences.edit();
//
//            String email = preferences.getString("email", "null");
//            String gender = preferences.getString("gender", "null");
//            String username = preferences.getString("username", "null");
//            String name = preferences.getString("name", "null");
//            String userid = preferences.getString("userID", "null");
//            String locale = preferences.getString("locale", "null");
//            String first_name = preferences.getString("first_name", "null");
//            String last_name = preferences.getString("last_name", "null");
//
//            HttpClient httpclient = new DefaultHttpClient();
//            HttpPost httppost = new HttpPost("https://bakkle.rhventures.org/account/facebook/");
//            HttpResponse response;

//            try {
//                // Add your data
//                List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>(9);
//                nameValuePairs.add(new BasicNameValuePair("email", email));
//                nameValuePairs.add(new BasicNameValuePair("name", name));
//                nameValuePairs.add(new BasicNameValuePair("username", ""));
//                nameValuePairs.add(new BasicNameValuePair("gender", gender));
//                nameValuePairs.add(new BasicNameValuePair("user_id", userid));
//                nameValuePairs.add(new BasicNameValuePair("locale", locale));
//                nameValuePairs.add(new BasicNameValuePair("first_name", first_name));
//                nameValuePairs.add(new BasicNameValuePair("last_name", last_name));
//                nameValuePairs.add(new BasicNameValuePair("device_uuid", Settings.Secure.getString(mContext.getContentResolver(), Settings.Secure.ANDROID_ID)));
//                httppost.setEntity(new UrlEncodedFormEntity(nameValuePairs));
//
//
//                // Execute HTTP Post Request
//                response = httpclient.execute(httppost);
//
//                Log.d("testing", "working");
//                return response.toString();
//
//            } catch (ClientProtocolException e) {
//                // TODO Auto-generated catch block
//                Log.d("testing", "catch 1");
//                return null;
//
//            } catch (IOException e) {
//                Log.d("testing", "catch 2");
//                Log.d("testing", e.getMessage());
//                // TODO Auto-generated catch block
//                return null;
//            }


        }


    }

}
