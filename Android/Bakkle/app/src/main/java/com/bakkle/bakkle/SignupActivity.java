package com.bakkle.bakkle;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.provider.Settings;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;


public class SignupActivity extends Activity implements OnClickListener {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getActionBar().hide();

        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);

        if(preferences.getBoolean("LoggedIn", false)) {
            Intent intent = new Intent(this, LoginActivity.class);
            startActivity(intent);

        }

        SharedPreferences.Editor editor = preferences.edit();
        editor.putString("uuid", Settings.Secure.getString(getApplicationContext().getContentResolver(), Settings.Secure.ANDROID_ID));
        editor.apply();

        setContentView(R.layout.activity_signup);

        ((Button)findViewById(R.id.btnSignIn)).setOnClickListener(this);
        ((Button)findViewById(R.id.btnSignUpEmail)).setOnClickListener(this);
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
