package com.bakkle.bakkle;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;


public class SignupActivity extends Activity implements OnClickListener {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_signup);
        getActionBar().hide();

        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);

        if(preferences.getBoolean("LoggedIn", false)) {
            Intent intent = new Intent(this, LoginActivity.class);
            startActivity(intent);

        }
//        else {
//            Intent intent = new Intent(this, SignupActivity.class);
//            startActivity(intent);
//        }

        ((Button)findViewById(R.id.btnSignIn)).setOnClickListener(this);
        ((Button)findViewById(R.id.btnSignUpEmail)).setOnClickListener(this);

        /*FacebookSdk.sdkInitialize(this.getApplicationContext());
        CallbackManager callbackManager = CallbackManager.Factory.create();
        LoginManager.getInstance().registerCallback(callbackManager, new FacebookCallback<LoginResult>() {
            @Override
            public void onSuccess(LoginResult loginResult) {

            }

            @Override
            public void onCancel() {

            }

            @Override
            public void onError(FacebookException e) {

            }
        });*/




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
}
