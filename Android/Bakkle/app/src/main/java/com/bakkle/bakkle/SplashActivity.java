package com.bakkle.bakkle;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;

import java.security.MessageDigest;
import java.text.SimpleDateFormat;
import java.util.Calendar;

public class SplashActivity extends Activity {
    private Context mContext;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getActionBar().hide();
        setContentView(R.layout.activity_splash);
        mContext = this;

        new Handler().postDelayed(new Runnable() {

            @Override
            public void run() {
                SharedPreferences sp = mContext.getSharedPreferences(Constants.SHARED_PREFERENCES, 0);
                if (sp.contains(Constants.DEVICE_ID)){
                    if (sp.contains(Constants.AUTH_TOKEN_KEY) && !sp.getString(Constants.AUTH_TOKEN_KEY, "").equals("")){
                        Intent intent = new Intent(mContext, HomeActivity.class);
                        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                        try {
                            Thread.sleep(3000);
                        }catch(Exception e) {}
                        startActivity(intent);
                        finish();
                    }else {
                        Intent intent = new Intent(mContext, LoginActivity.class);
                        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                        try {
                            Thread.sleep(3000);
                        } catch (Exception e) {
                        }
                        startActivity(intent);
                        finish();
                    }
                } else {
                    String deviceID = "";
                    try {
                        MessageDigest digest = MessageDigest.getInstance("MD5");
                        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                        Calendar cal = Calendar.getInstance();
                        String date = sdf.format(cal);
                        byte[] hashBytes = digest.digest(date.getBytes("UTF-8"));
                        deviceID = hashBytes.toString();

                    } catch (Exception e){

                    }

                    SharedPreferences.Editor ed = sp.edit();
                    ed.putString(Constants.DEVICE_ID, deviceID);

                    Intent intent = new Intent(mContext, LoginActivity.class);
                    intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                    try {
                        Thread.sleep(2000);
                    } catch (Exception e) {
                    }
                    startActivity(intent);
                    finish();
                }
            }
        }, 5000);
    }


}
