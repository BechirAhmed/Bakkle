package com.bakkle.bakkle.Chat;

import android.content.Context;

import com.bakkle.bakkle.API;
import com.bakkle.bakkle.Prefs;

import de.tavendo.autobahn.WebSocketConnection;

/**
 * Created by vanshgandhi on 12/14/15.
 */
public class Chat
{
    final static String ws_base = "ws://app.bakkle.com:8000/ws/";


    private static Chat ourInstance = null;
    private Prefs               prefs;
    private Context             context;
    private WebSocketConnection webSocketConnection;
    String url;

    public static synchronized Chat getInstance(Context c)
    {
        if (ourInstance == null) {
            ourInstance = new Chat(c);
        }
        return ourInstance;
    }

    public static synchronized Chat getInstance()
    {
        if (ourInstance == null) {
            throw new IllegalStateException(API.class.getSimpleName() + " is not initialized, call getInstance(Context c) first");
        }
        return ourInstance;
    }

    private Chat(Context c)
    {
        prefs = Prefs.getInstance(c);
        this.context = c;
        webSocketConnection = new WebSocketConnection();
        url = ws_base + "?uuid=" + prefs.getUuid() + "&userId=" + prefs.getUserId();
    }


}
