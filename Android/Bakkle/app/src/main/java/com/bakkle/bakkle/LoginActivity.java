package com.bakkle.bakkle;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;

import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookSdk;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;


public class LoginActivity extends Activity implements OnClickListener {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        getActionBar().hide();
        FacebookSdk.sdkInitialize(this.getApplicationContext());
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
        });


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
                Intent intent = new Intent(this, SignInActivity.class);
                startActivity(intent);
                break;

        }
    }
}
