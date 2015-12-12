package com.bakkle.bakkle;

import android.content.Context;
import android.graphics.Bitmap;
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

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

/**
 * Created by vanshgandhi on 12/3/15.
 */
public class Server
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
    //</editor-fold>

    private static Server ourInstance = null;
    private RequestQueue queue;
    private ImageLoader  imageLoader;
    private Prefs        prefs;
    private Context      context;

    public static synchronized Server getInstance(Context c)
    {
        if (ourInstance == null) {
            ourInstance = new Server(c);
        }
        return ourInstance;
    }

    public static synchronized Server getInstance()
    {
        if (ourInstance == null) {
            throw new IllegalStateException(Server.class.getSimpleName() + " is not initialized, call getInstance(Context c) first");
        }
        return ourInstance;
    }

    public ImageLoader getImageLoader()
    {
        return imageLoader;
    }

    private Server(Context c)
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

        try {
            url += "?auth_token=" + URLEncoder.encode(prefs.getAuthToken(), "UTF-8") + "&device_uuid=" + URLEncoder.encode(prefs.getUuid(), "UTF-8") + "&filter_distance=" + prefs.getDistanceFilter() + "&filter_price=" + prefs.getPriceFilter() + "&search_text=" + URLEncoder.encode(prefs.getSearchText(), "UTF-8") + "&user_location=" + URLEncoder.encode(location, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            Toast.makeText(context, "There was error retrieving the feed", Toast.LENGTH_SHORT).show();
        }
        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, url, responseListener, errorListener);

        request.setShouldCache(true);
        queue.add(request);
    }

    public void getWatchList(Response.Listener<JSONObject> responseListener,
                             Response.ErrorListener errorListener)
    {
        String url = url_base + url_get_holding_pattern;

        try {
            url += "?auth_token=" + URLEncoder.encode(prefs.getAuthToken(), "UTF-8") + "&device_uuid=" + URLEncoder.encode(prefs.getUuid(), "UTF-8");
        } catch (UnsupportedEncodingException e) {
            Toast.makeText(context, "There was error retrieving the Watch List", Toast.LENGTH_SHORT).show();
        }
        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, url, responseListener, errorListener);

        request.setShouldCache(true);
        queue.add(request);
    }

    public void getBuying(Response.Listener<JSONObject> responseListener,
                          Response.ErrorListener errorListener)
    {
        String url = url_base + url_buyers_trunk;

        try {
            url += "?auth_token=" + URLEncoder.encode(prefs.getAuthToken(), "UTF-8") + "&device_uuid=" + URLEncoder.encode(prefs.getUuid(), "UTF-8");
        } catch (UnsupportedEncodingException e) {
            Toast.makeText(context, "There was error retrieving the Buyer's Trunk", Toast.LENGTH_SHORT).show();
        }
        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, url, responseListener, errorListener);

        request.setShouldCache(true);
        queue.add(request);
    }

    public void getSellers(Response.Listener<JSONObject> responseListener,
                           Response.ErrorListener errorListener)
    {
        String url = url_base + url_sellers;

        try {
            url += "?auth_token=" + URLEncoder.encode(prefs.getAuthToken(), "UTF-8") + "&device_uuid=" + URLEncoder.encode(prefs.getUuid(), "UTF-8");
        } catch (UnsupportedEncodingException e) {
            Toast.makeText(context, "There was error retrieving the Seller Items", Toast.LENGTH_SHORT).show();
        }
        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, url, responseListener, errorListener);

        request.setShouldCache(true);
        queue.add(request);
    }

    public void markItem(String status, int itemId, String viewDuration)
    {
        markItem(status, itemId, viewDuration, null);
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

        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, url, new Response.Listener<JSONObject>()
        {
            @Override
            public void onResponse(JSONObject response)
            {
                try {
                    if (response.getInt("status") != 1) {
                        Toast.makeText(context, "There was error marking item", Toast.LENGTH_SHORT).show();
                    }
                } catch (JSONException e) {
                    Toast.makeText(context, "There was error marking item", Toast.LENGTH_SHORT).show();
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

    public void getGuestUserId(Response.Listener<JSONObject> responseListener)
    {
        String url = url_base + url_guest_id;

        try {
            url += "?" + "device_uuid=" + URLEncoder.encode(prefs.getUuid(), "UTF-8");
        } catch (UnsupportedEncodingException e) {
            Toast.makeText(context, "There was error signing in", Toast.LENGTH_SHORT).show();
        }

        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, url, responseListener, new Response.ErrorListener()
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
            url += "?" + "device_uuid=" + URLEncoder.encode(prefs.getUuid(), "UTF-8") + "&email=" + email;
        } catch (UnsupportedEncodingException e) {
            Toast.makeText(context, "There was error signing in", Toast.LENGTH_SHORT).show();
        }

        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, url, responseListener, new Response.ErrorListener()
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

    public void registerFacebook(final Response.Listener<JSONObject> LoginListener)
    {
        String url = url_base + url_facebook;

        try {
            url += "?email=" + URLEncoder.encode(prefs.getEmail(), "UTF-8") +
                    "&name=" + URLEncoder.encode(prefs.getName(), "UTF-8") +
                    "&user_name=" + URLEncoder.encode(prefs.getUsername(), "UTF-8") + "&gender=" + URLEncoder.encode(prefs.getGender(), "UTF-8") + "&user_id=" + URLEncoder.encode(prefs.getUserId(), "UTF-8") + "&locale=" + URLEncoder.encode(prefs.getLocale(), "UTF-8") + "&first_name=" + URLEncoder.encode(prefs.getFirstName(), "UTF-8") + "&last_name=" + URLEncoder.encode(prefs.getLastName(), "UTF-8") + "&device_uuid=" + URLEncoder.encode(prefs.getUuid(), "UTF-8");
        } catch (UnsupportedEncodingException e) {
            Toast.makeText(context, "There was error signing in", Toast.LENGTH_SHORT).show();
        }

        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, url, new Response.Listener<JSONObject>()
        {
            @Override
            public void onResponse(JSONObject response)
            {
                try {
                    if (response.getInt("status") == 1) {
                        loginFacebook(LoginListener);
                    } else {
                        Toast.makeText(context, "There was error signing in", Toast.LENGTH_SHORT).show();
                    }
                } catch (JSONException e) {
                    Toast.makeText(context, "There was error signing in", Toast.LENGTH_SHORT).show();
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
            url += "?app_version=" + URLEncoder.encode(BuildConfig.VERSION_NAME, "UTF-8") + "&is_ios=false" + "&user_location=" + URLEncoder.encode(location, "UTF-8") + "&user_id=" + URLEncoder.encode(prefs.getUserId(), "UTF-8") + "&device_uuid=" + URLEncoder.encode(prefs.getUuid(), "UTF-8");
        } catch (UnsupportedEncodingException e) {
            Toast.makeText(context, "There was error signing in", Toast.LENGTH_SHORT).show();
        }

        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, url, responseListener, new Response.ErrorListener()
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
}
