package com.bakkle.bakkle;

import com.bakkle.bakkle.Helpers.Constants;
import com.parse.Parse;
import com.parse.ParseInstallation;

/**
 * Created by vanshgandhi on 10/16/15.
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
