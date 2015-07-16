package com.bakkle.bakkle;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.location.LocationManager;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.provider.Settings;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.Toast;


public class SignupActivity extends AppCompatActivity implements OnClickListener {

    boolean locationEnabled = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        //getActionBar().hide();

        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);

        LocationManager locationManager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
        if(!locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER) && !locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)) {

            Toast.makeText(this, "Test", Toast.LENGTH_SHORT).show();

        }

        if(preferences.getBoolean("LoggedIn", false)) {
            Intent intent = new Intent(this, LoginActivity.class);
            startActivity(intent);

        }

        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("uuid", Settings.Secure.getString(getApplicationContext().getContentResolver(), Settings.Secure.ANDROID_ID));
        editor.apply();

        setContentView(R.layout.activity_signup);

        ((Button)findViewById(R.id.btnSignIn)).setOnClickListener(this);
        //((Button)findViewById(R.id.btnSignUpEmail)).setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        // TODO: Handle button actions
        switch(v.getId()){
            case R.id.btnSignUpEmail:
                break;
            case R.id.btnSignIn:
                startActivity(new Intent(this, LoginActivity.class));
                break;
        }
    }
    @Override
    public void onBackPressed() {
        Intent intent = new Intent(Intent.ACTION_MAIN);
        intent.addCategory(Intent.CATEGORY_HOME);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
        finish();
    }

}
