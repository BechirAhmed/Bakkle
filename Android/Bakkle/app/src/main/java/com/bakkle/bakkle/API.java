package com.bakkle.bakkle;

import android.content.Context;
import android.graphics.Bitmap;
import android.util.Log;
import android.util.LruCache;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.ImageLoader;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.Volley;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

/**
 * Created by vanshgandhi on 12/3/15.
 */
public class API
{
    //<editor-fold desc="URLS">
    final static String url_base                = "https://app.bakkle.com/";
    final static String url_login               = "account/login_facebook/";
    final static String url_logout              = "account/logout/";
    final static String url_facebook            = "account/facebook/";
    final static String url_register_push       = "account/device/register_push/";
    final static String url_reset               = "items/reset/";
    final static String url_mark                = "items/";
    final static String url_feed                = "items/feed/";
    final static String url_sellers             = "items/get_seller_items/";
    final static String url_add_item            = "items/add_item/";
    final static String url_delete_item         = "items/delete_item/";
    final static String url_send_chat           = "conversation/send_message/";
    final static String url_view_item           = "items/";
    final static String url_buyers_trunk        = "items/get_buyers_trunk/";
    final static String url_get_holding_pattern = "items/get_holding_pattern/";
    final static String url_buyertransactions   = "items/get_buyer_transactions/";
    final static String url_sellertransactions  = "items/get_seller_transactions/";
    final static String url_getaccount          = "account/get_account/";
    final static String url_setdescription      = "account/set_description/";
    final static String url_guest_id            = "account/guestuserid/";
    final static String url_email_id            = "account/localuserid/";
    final static String url_account_password    = "account/authenticatelocal/";
    final static String url_set_password        = "account/setpassword/";
    //</editor-fold>

    private static API ourInstance = null;
    private RequestQueue queue;
    private ImageLoader  imageLoader;
    private Prefs        prefs;
    private Context      context;

    public static synchronized API getInstance(Context c)
    {
        if (ourInstance == null) {
            ourInstance = new API(c);
        }
        return ourInstance;
    }

    public static synchronized API getInstance()
    {
        if (ourInstance == null) {
            throw new IllegalStateException(
                    API.class.getSimpleName() + " is not initialized, call getInstance(Context c) first");
        }
        return ourInstance;
    }

    public ImageLoader getImageLoader()
    {
        return imageLoader;
    }

    private API(Context c)
    {
        queue = Volley.newRequestQueue(c.getApplicationContext());
        imageLoader = new ImageLoader(queue, new ImageLoader.ImageCache()
        {
            private final LruCache<String, Bitmap> cache = new LruCache<>(20);

            @Override
            public Bitmap getBitmap(String url)
            {
                return cache.get(url);
            }

            @Override
            public void putBitmap(String url, Bitmap bitmap)
            {
                cache.put(url, bitmap);
            }
        });
        prefs = Prefs.getInstance(c);
        this.context = c;
    }

    public void getFeed(Response.Listener<JSONObject> responseListener,
                        Response.ErrorListener errorListener)
    {
        String location = prefs.getLatitude() + "," + prefs.getLongitude();
        String url = url_base + url_feed;
        int distance = prefs.getDistanceFilter() == 100 ? 101 : prefs.getDistanceFilter();
        int price = prefs.getPriceFilter() == 100 ? 101 : prefs.getPriceFilter();

        try {
            url += "?auth_token=" + URLEncoder.encode(prefs.getAuthToken(),
                    "UTF-8") + "&device_uuid=" + URLEncoder.encode(prefs.getUuid(),
                    "UTF-8") + "&filter_distance=" + distance + "&filter_price=" + price + "&search_text=" + URLEncoder
                    .encode(prefs.getSearchText(), "UTF-8") + "&user_location=" + URLEncoder.encode(
                    location, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            Toast.makeText(context, "There was error retrieving the feed", Toast.LENGTH_SHORT)
                    .show();
        }
        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, url,
                responseListener, errorListener);

        request.setShouldCache(true);
        queue.add(request);
    }

    public void getWatchList(Response.Listener<JSONObject> responseListener,
                             Response.ErrorListener errorListener)
    {
        String url = url_base + url_get_holding_pattern;

        try {
            url += "?auth_token=" + URLEncoder.encode(prefs.getAuthToken(),
                    "UTF-8") + "&device_uuid=" + URLEncoder.encode(prefs.getUuid(), "UTF-8");
        } catch (UnsupportedEncodingException e) {
            Toast.makeText(context, "There was error retrieving the Watch List", Toast.LENGTH_SHORT)
                    .show();
        }
        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, url,
                responseListener, errorListener);

        request.setShouldCache(true);
        queue.add(request);
    }

    public void getBuying(Response.Listener<JSONObject> responseListener,
                          Response.ErrorListener errorListener)
    {
        String url = url_base + url_buyers_trunk;

        try {
            url += "?auth_token=" + URLEncoder.encode(prefs.getAuthToken(),
                    "UTF-8") + "&device_uuid=" + URLEncoder.encode(prefs.getUuid(), "UTF-8");
        } catch (UnsupportedEncodingException e) {
            Toast.makeText(context, "There was error retrieving the Buyer's Trunk",
                    Toast.LENGTH_SHORT).show();
        }
        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, url,
                responseListener, errorListener);

        request.setShouldCache(true);
        queue.add(request);
    }

    public void getSellers(Response.Listener<JSONObject> responseListener,
                           Response.ErrorListener errorListener)
    {
        String url = url_base + url_sellers;

        try {
            url += "?auth_token=" + URLEncoder.encode(prefs.getAuthToken(),
                    "UTF-8") + "&device_uuid=" + URLEncoder.encode(prefs.getUuid(), "UTF-8");
        } catch (UnsupportedEncodingException e) {
            Toast.makeText(context, "There was error retrieving the Seller Items",
                    Toast.LENGTH_SHORT).show();
        }
        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, url,
                responseListener, errorListener);

        request.setShouldCache(true);
        queue.add(request);
    }

    public void markItem(String status, int itemId, String viewDuration)
    {
        markItem(status, itemId, viewDuration, null);
    }

    public void deleteItem(int itemId)
    {
        String url = url_base + url_delete_item;
        try {
            url += "?auth_token=" + URLEncoder.encode(prefs.getAuthToken(), "UTF-8") +
                    "&device_uuid=" + URLEncoder.encode(prefs.getUuid(), "UTF-8") +
                    "&item_id=" + itemId;
        } catch (UnsupportedEncodingException e) {
            Toast.makeText(context, "There was error marking item", Toast.LENGTH_SHORT).show();
        }

        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, url,
                new Response.Listener<JSONObject>()
                {
                    @Override
                    public void onResponse(JSONObject response)
                    {

                    }
                }, new Response.ErrorListener()
        {
            @Override
            public void onErrorResponse(VolleyError error)
            {
                Toast.makeText(context, "There was an error deleting item", Toast.LENGTH_SHORT)
                        .show();
                error.printStackTrace();
            }
        });

        queue.add(request);
    }

    public void markItem(String status, int itemId, String viewDuration, String reportMessage)
    {
        String url = url_base + url_mark + status + '/';
        try {
            url += "?auth_token=" + URLEncoder.encode(prefs.getAuthToken(), "UTF-8") +
                    "&device_uuid=" + URLEncoder.encode(prefs.getUuid(), "UTF-8") +
                    "&item_id=" + itemId +
                    "&view_duration=" + viewDuration; //TODO: Get actual view duration of item
            if (reportMessage != null) {
                url += "&reportMessage=" + reportMessage;
            }
        } catch (UnsupportedEncodingException e) {
            Toast.makeText(context, "There was error marking item", Toast.LENGTH_SHORT).show();
        }

        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, url,
                new Response.Listener<JSONObject>()
                {
                    @Override
                    public void onResponse(JSONObject response)
                    {
                        try {
                            if (response.getInt("status") != 1) {
                                Toast.makeText(context, "There was error marking item",
                                        Toast.LENGTH_SHORT).show();
                            }
                        } catch (JSONException e) {
                            Toast.makeText(context, "There was error marking item",
                                    Toast.LENGTH_SHORT).show();
                        }
                    }
                }, new Response.ErrorListener()
        {
            @Override
            public void onErrorResponse(VolleyError error)
            {
                Toast.makeText(context, "There was error marking item", Toast.LENGTH_SHORT).show();
            }
        });

        request.setShouldCache(false);
        queue.add(request);

    }

    public void getAccount(Response.Listener<JSONObject> responseListener)
    {
        String url = url_base + url_getaccount;

        try {
            url += "?auth_token=" + URLEncoder.encode(prefs.getAuthToken(), "UTF-8") +
                    "&device_uuid=" + URLEncoder.encode(prefs.getUuid(), "UTF-8") +
                    "&accountId=" + prefs.getAuthToken().substring(33);
        } catch (UnsupportedEncodingException e) {
            Toast.makeText(context, "There was an error getting the account", Toast.LENGTH_SHORT)
                    .show();
        }

        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, url,
                responseListener, new Response.ErrorListener()
        {
            @Override
            public void onErrorResponse(VolleyError error)
            {
                Toast.makeText(context, "There was an error getting the account",
                        Toast.LENGTH_SHORT).show();
            }
        });

        request.setShouldCache(false);
        queue.add(request);
    }

    public void setDescription(Response.Listener<JSONObject> responseListener, String description)
    {
        String url = url_base + url_setdescription;
        try {
            url += "?auth_token=" + URLEncoder.encode(prefs.getAuthToken(), "UTF-8") +
                    "&device_uuid=" + URLEncoder.encode(prefs.getUuid(), "UTF-8") +
                    "&description=" + URLEncoder.encode(description, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            Toast.makeText(context, "There was an error setting the description",
                    Toast.LENGTH_SHORT).show();
        }

        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, url,
                responseListener, new Response.ErrorListener()
        {
            @Override
            public void onErrorResponse(VolleyError error)
            {
                Toast.makeText(context, "There was an error setting the description",
                        Toast.LENGTH_SHORT).show();
            }
        });

        request.setShouldCache(false);
        queue.add(request);

    }

    public void getGuestUserId(Response.Listener<JSONObject> responseListener)
    {
        String url = url_base + url_guest_id;

        try {
            url += "?" + "device_uuid=" + URLEncoder.encode(prefs.getUuid(), "UTF-8");
        } catch (UnsupportedEncodingException e) {
            Toast.makeText(context, "There was error signing in", Toast.LENGTH_SHORT).show();
        }

        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, url,
                responseListener, new Response.ErrorListener()
        {
            @Override
            public void onErrorResponse(VolleyError error)
            {
                Toast.makeText(context, "There was error signing in", Toast.LENGTH_SHORT).show();
            }
        });

        request.setShouldCache(false);
        queue.add(request);
    }

    public void getEmailUserId(String email, Response.Listener<JSONObject> responseListener)
    {
        String url = url_base + url_email_id;

        try {
            url += "?" + "device_uuid=" + URLEncoder.encode(prefs.getUuid(),
                    "UTF-8") + "&email=" + email;
        } catch (UnsupportedEncodingException e) {
            Toast.makeText(context, "There was error signing in", Toast.LENGTH_SHORT).show();
        }

        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, url,
                responseListener, new Response.ErrorListener()
        {
            @Override
            public void onErrorResponse(VolleyError error)
            {
                Toast.makeText(context, "There was error signing in", Toast.LENGTH_SHORT).show();
            }
        });

        request.setShouldCache(false);
        queue.add(request);
    }

    public void setPassword(String password, Response.Listener<JSONObject> responseListener,
                            Response.ErrorListener errorListener)
    {
        String url = url_base + url_set_password;
        try {
            url += "?user_id=" + URLEncoder.encode(prefs.getUserId(),
                    "UTF-8") + "&device_uuid=" + URLEncoder.encode(prefs.getUuid(),
                    "UTF-8") + "&password=" + URLEncoder.encode(password, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            Toast.makeText(context, "There was error setting password", Toast.LENGTH_SHORT).show();
            e.printStackTrace();
        }

        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, url,
                responseListener, errorListener);

        queue.add(request);
    }

    public void authenticatePassword(String password,
                                     Response.Listener<JSONObject> responseListener,
                                     Response.ErrorListener errorListener)
    {
        String url = url_base + url_account_password;
        try {
            url += "?user_id=" + URLEncoder.encode(prefs.getUserId(),
                    "UTF-8") + "&device_uuid=" + URLEncoder.encode(prefs.getUuid(),
                    "UTF-8") + "&password=" + URLEncoder.encode(password, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            Toast.makeText(context, "There was error signing in", Toast.LENGTH_SHORT).show();
        }

        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, url,
                responseListener, errorListener);

        request.setShouldCache(false);
        queue.add(request);

    }

    public void registerFacebook(final Response.Listener<JSONObject> LoginListener)
    {
        String url = url_base + url_facebook;

        try {
            url += "?email=" + URLEncoder.encode(prefs.getEmail(), "UTF-8") +
                    "&name=" + URLEncoder.encode(prefs.getName(), "UTF-8") +
                    "&user_name=" + URLEncoder.encode(prefs.getUsername(),
                    "UTF-8") + "&gender=" + URLEncoder.encode(prefs.getGender(),
                    "UTF-8") + "&user_id=" + URLEncoder.encode(prefs.getUserId(),
                    "UTF-8") + "&locale=" + URLEncoder.encode(prefs.getLocale(),
                    "UTF-8") + "&first_name=" + URLEncoder.encode(prefs.getFirstName(),
                    "UTF-8") + "&last_name=" + URLEncoder.encode(prefs.getLastName(),
                    "UTF-8") + "&device_uuid=" + URLEncoder.encode(prefs.getUuid(), "UTF-8");
        } catch (UnsupportedEncodingException e) {
            Toast.makeText(context, "There was error signing in", Toast.LENGTH_SHORT).show();
        }

        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, url,
                new Response.Listener<JSONObject>()
                {
                    @Override
                    public void onResponse(JSONObject response)
                    {
                        try {
                            if (response.getInt("status") == 1) {
                                loginFacebook(LoginListener);
                            } else {
                                Toast.makeText(context, "There was error signing in",
                                        Toast.LENGTH_SHORT).show();
                            }
                        } catch (JSONException e) {
                            Toast.makeText(context, "There was error signing in",
                                    Toast.LENGTH_SHORT).show();
                        }
                    }
                }, new Response.ErrorListener()
        {

            @Override
            public void onErrorResponse(VolleyError error)
            {
                Toast.makeText(context, "There was error signing in", Toast.LENGTH_SHORT).show();
            }
        });

        request.setShouldCache(false);
        queue.add(request);
    }

    public void loginFacebook(Response.Listener<JSONObject> responseListener)
    {
        String location = prefs.getLatitude() + "," + prefs.getLongitude();
        String url = url_base + url_login;

        try {
            url += "?app_version=" + URLEncoder.encode(BuildConfig.VERSION_NAME,
                    "UTF-8") + "&is_ios=false" + "&user_location=" + URLEncoder.encode(location,
                    "UTF-8") + "&user_id=" + URLEncoder.encode(prefs.getUserId(),
                    "UTF-8") + "&device_uuid=" + URLEncoder.encode(prefs.getUuid(), "UTF-8");
        } catch (UnsupportedEncodingException e) {
            Toast.makeText(context, "There was error signing in", Toast.LENGTH_SHORT).show();
        }

        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, url,
                responseListener, new Response.ErrorListener()
        {

            @Override
            public void onErrorResponse(VolleyError error)
            {
                Toast.makeText(context, "There was error signing in", Toast.LENGTH_SHORT).show();
            }
        });

        request.setShouldCache(false);
        queue.add(request);
    }

    public void logout()
    {
        String url = url_base + url_logout;
        try {
            url += "?auth_token=" + URLEncoder.encode(prefs.getAuthToken(), "UTF-8") +
                    "&device_uuid=" + URLEncoder.encode(prefs.getUuid(), "UTF-8");
        } catch (UnsupportedEncodingException e) {
            Toast.makeText(context, "There was an error logging out", Toast.LENGTH_SHORT).show();
        }
        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, url,
                new Response.Listener<JSONObject>()
                {
                    @Override
                    public void onResponse(JSONObject response)
                    {
                        try {
                            if (response.getInt("status") != 1) {
                                Toast.makeText(context, "There was an error logging out",
                                        Toast.LENGTH_SHORT).show();
                            }
                        } catch (JSONException e) {
                            Toast.makeText(context, "There was an error logging out",
                                    Toast.LENGTH_SHORT).show();
                        }
                    }
                }, new Response.ErrorListener()
        {
            @Override
            public void onErrorResponse(VolleyError error)
            {
                Toast.makeText(context, "There was an error logging out", Toast.LENGTH_SHORT)
                        .show();
            }
        });

        queue.add(request);
    }

    public void registerPush(String token)
    {
        String url = url_base + url_register_push;
        try {
            url += "?auth_token=" + URLEncoder.encode(prefs.getAuthToken(), "UTF-8") +
                    "&device_uuid=" + URLEncoder.encode(prefs.getUuid(),
                    "UTF-8") + "&device_token=" + URLEncoder.encode(token,
                    "UTF-8") + "&device_type=gcm";
        } catch (UnsupportedEncodingException e) {
            Toast.makeText(context, "There was an error registering push", Toast.LENGTH_SHORT)
                    .show();
            e.printStackTrace();
        }

        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, url,
                new Response.Listener<JSONObject>()
                {
                    @Override
                    public void onResponse(JSONObject response)
                    {
                        Prefs.getInstance(context).registeredPush(true);
                        Log.v("RegisterPush", "successfully reigstered");
                    }
                }, new Response.ErrorListener()
        {
            @Override
            public void onErrorResponse(VolleyError error)
            {
                error.printStackTrace();
            }
        });

        queue.add(request);
    }

    public void postItem(int pk, String title, String price, String description,
                         Response.Listener<JSONObject> responseListener,
                         Response.ErrorListener errorListener, File[] files)
    {
        String url = url_base + url_add_item;
        String location = prefs.getLatitude() + "," + prefs.getLongitude();
        try {
            url += "?auth_token=" + URLEncoder.encode(prefs.getAuthToken(), "UTF-8") +
                    "&device_uuid=" + URLEncoder.encode(prefs.getUuid(),
                    "UTF-8") + "&title=" + URLEncoder.encode(title,
                    "UTF-8") + "&price=" + price + "&description=" + URLEncoder.encode(description,
                    "UTF-8") + "&location=" + URLEncoder.encode(location, "UTF-8");

            if (pk != -1) { //We are editing an item, not posting a new one
                url += "&item_id=" + pk;
            }

        } catch (UnsupportedEncodingException e) {
            Toast.makeText(context, "There was an error posting item", Toast.LENGTH_SHORT).show();
            e.printStackTrace();
        }

        ImageUploadRequest request = new ImageUploadRequest(url, errorListener, responseListener,
                files);

        queue.add(request);
    }

    public void postItem(String title, String price, String description,
                         Response.Listener<JSONObject> responseListener,
                         Response.ErrorListener errorListener, File[] files)
    {
        postItem(-1, title, price, description, responseListener, errorListener, files);
    }
}
