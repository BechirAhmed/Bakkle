package com.bakkle.bakkle;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.widget.Toast;

import com.facebook.AccessToken;
import com.facebook.FacebookSdk;

public class SplashActivity extends Activity {
    private Context mContext;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getActionBar().hide();
        setContentView(R.layout.activity_splash);
        mContext = this;

//Use this to get the Facebook Development hash for each new computer. The hash will appear in logcat. Send the hash to Rameen
//        try {
//            PackageInfo info = getPackageManager().getPackageInfo(
//                    "com.bakkle.bakkle",
//                    PackageManager.GET_SIGNATURES);
//            for (android.content.pm.Signature signature : info.signatures) {
//                MessageDigest md = MessageDigest.getInstance("SHA");
//                md.update(signature.toByteArray());
//                Log.d("KeyHash:", Base64.encodeToString(md.digest(), Base64.DEFAULT));
//            }
//        } catch (PackageManager.NameNotFoundException e) {
//            e.printStackTrace();
//
//        } catch (NoSuchAlgorithmException e) {
//            e.printStackTrace();
//        }


        //


        //------------

        /*new Handler().postDelayed(new Runnable() {

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
        }, 5000);*/


        FacebookSdk.sdkInitialize(getApplicationContext());

        AccessToken token = AccessToken.getCurrentAccessToken();
        if(token != null) {
            Toast.makeText(getApplicationContext(), token.toString(), Toast.LENGTH_SHORT).show();
            Intent intent = new Intent(this, HomeActivity.class);
            startActivity(intent);
        }
        else {
            Toast.makeText(getApplicationContext(), "Not working", Toast.LENGTH_SHORT).show();
            Intent intent = new Intent(this, LoginActivity.class);
            startActivity(intent);
        }



    }


}
