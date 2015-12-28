package com.bakkle.bakkle;

import android.content.Context;
import android.content.SharedPreferences;
import android.location.Location;
import android.preference.PreferenceManager;
import android.provider.Settings;

/**
 * Created by vanshgandhi on 12/3/15.
 */
public class Prefs
{
    private static Prefs                    ourInstance = null;
    private static SharedPreferences        preferences = null;
    private static SharedPreferences.Editor editor      = null;
    private String uuid;

    public static Prefs getInstance(Context c)
    {
        if(ourInstance == null)
        {
            ourInstance = new Prefs(c);
        }
        return ourInstance;
    }

    public static synchronized Prefs getInstance()
    {
        if (ourInstance == null)
        {
            throw new IllegalStateException(Prefs.class.getSimpleName() +
                    " is not initialized, call getInstance(Context c) first");
        }
        return ourInstance;
    }


    private Prefs(Context c)
    {
        preferences = PreferenceManager.getDefaultSharedPreferences(c);
        editor = preferences.edit();
        uuid = Settings.Secure.getString(c.getContentResolver(), Settings.Secure.ANDROID_ID);
    }

    public void setUserId(String userId)
    {
        editor.putString(Constants.USER_ID, userId);
        editor.commit();
    }

    public String getUserId()
    {
        return preferences.getString(Constants.USER_ID, "");
    }

    public String getAuthToken()
    {
        return preferences.getString(Constants.AUTH_TOKEN, "");
    }

    public void setAuthToken(String authToken)
    {
        editor.putString(Constants.AUTH_TOKEN, authToken);
        editor.commit();
    }

    public boolean isAuthenticated()
    {
        return preferences.getBoolean(Constants.AUTHENTICATED, false);
    }

    public void setAuthenticated(boolean authenticated)
    {
        editor.putBoolean(Constants.AUTHENTICATED, authenticated);
        editor.commit();
    }

    public boolean isGuest()
    {
        return preferences.getBoolean(Constants.GUEST, true);
    }

    public void setGuest(boolean guest)
    {
        editor.putBoolean(Constants.GUEST, guest);
        editor.commit();
    }

    public String getUuid()
    {
        String thisuuid = preferences.getString(Constants.UUID, "");
        if(! thisuuid.equals(""))
        {
            return thisuuid;
        }
        editor.putString(Constants.UUID, uuid);
        return uuid;
    }

    public String getUsername()
    {
        return preferences.getString(Constants.USERNAME, "");
    }

    public void setUsername(String username)
    {
        editor.putString(Constants.USERNAME, username);
        editor.commit();
    }

    public String getName()
    {
        return preferences.getString(Constants.NAME, "Guest User");
    }

    public void setName(String name)
    {
        editor.putString(Constants.NAME, name);
        editor.commit();
    }

    public String getFirstName()
    {
        return preferences.getString(Constants.FIRST_NAME, "Guest");
    }

    public void setFirstName(String firstName)
    {
        editor.putString(Constants.FIRST_NAME, firstName);
        editor.commit();
    }

    public String getLastName()
    {
        return preferences.getString(Constants.LAST_NAME, "User");
    }

    public void setLastName(String lastName)
    {
        editor.putString(Constants.LAST_NAME, lastName);
        editor.commit();
    }

    public String getEmail()
    {
        return preferences.getString(Constants.EMAIL, "guest@bakkle.com");
    }

    public void setEmail(String email)
    {
        editor.putString(Constants.EMAIL, email);
        editor.commit();
    }

    public String getGender()
    {
        return preferences.getString(Constants.GENDER, "");
    }

    public void setGender(String gender)
    {
        editor.putString(Constants.GENDER, gender);
        editor.commit();
    }

    public String getLocale()
    {
        return preferences.getString(Constants.LOCALE, "");
    }

    public void setLocale(String locale)
    {
        editor.putString(Constants.LOCALE, locale);
        editor.commit();
    }

    public void setLoggedIn(boolean loggedIn)
    {
        editor.putBoolean(Constants.LOGGED_IN, loggedIn);
        editor.commit();
    }

    public boolean isLoggedIn()
    {
        return preferences.getBoolean(Constants.LOGGED_IN, false);
    }

    public void setLocation(Location lastLocation)
    {
        editor.putFloat(Constants.LATITUDE, (float) lastLocation.getLatitude());
        editor.putFloat(Constants.LONGITUDE, (float) lastLocation.getLongitude());
        editor.commit();
    }

    public float getLatitude()
    {
        return preferences.getFloat(Constants.LATITUDE, 0);
    }

    public float getLongitude()
    {
        return preferences.getFloat(Constants.LONGITUDE, 0);
    }

    public void setUserImageUrl(String userImageUrl)
    {
        editor.putString(Constants.IMAGE_URL, userImageUrl);
        editor.commit();
    }

    public String getUserImageUrl()
    {
        return preferences.getString(Constants.IMAGE_URL, "https://app.bakkle.com/img/default_profile.png");
    }

    public void setDistanceFilter(int distance)
    {
        editor.putInt(Constants.DISTANCE_FILTER, distance);
        editor.commit();
    }

    public int getDistanceFilter()
    {
        return preferences.getInt(Constants.DISTANCE_FILTER, 100);
    }

    public void setPriceFilter(int price)
    {
        editor.putInt(Constants.PRICE_FILTER, price);
        editor.commit();
    }

    public int getPriceFilter()
    {
        return preferences.getInt(Constants.PRICE_FILTER, 100);
    }

    public String getSearchText()
    {
        return preferences.getString(Constants.SEARCH_TEXT, "");
    }

    public void setSearchText(String text){
        editor.putString(Constants.SEARCH_TEXT, text);
        editor.commit();
    }

    public void logout()
    {
        editor.remove(Constants.NAME);
        editor.remove(Constants.USER_ID);
        editor.remove(Constants.AUTH_TOKEN);
        editor.remove(Constants.AUTHENTICATED);
        editor.remove(Constants.USERNAME);
        editor.remove(Constants.FIRST_NAME);
        editor.remove(Constants.LAST_NAME);
        editor.remove(Constants.EMAIL);
        editor.remove(Constants.LOCALE);
        editor.remove(Constants.GENDER);
        editor.remove(Constants.IMAGE_URL);
        editor.commit();
        setGuest(true);
        setAuthenticated(false);
        setLoggedIn(false);


    }
}
