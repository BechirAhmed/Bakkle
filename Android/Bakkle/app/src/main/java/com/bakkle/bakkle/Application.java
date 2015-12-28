package com.bakkle.bakkle;

import com.parse.Parse;
import com.parse.ParseInstallation;

/**
 * Created by vanshgandhi on 12/3/15.
 */
public class Application extends android.app.Application
{
    @Override
    public void onCreate()
    {
        super.onCreate();
        Parse.initialize(this, Constants.APPLICATION_ID, Constants.CLIENT_ID);
        ParseInstallation.getCurrentInstallation().saveInBackground();
    }
}
