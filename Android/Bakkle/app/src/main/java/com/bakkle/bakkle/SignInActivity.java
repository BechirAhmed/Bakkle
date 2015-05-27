package com.bakkle.bakkle;

import android.app.ActionBar;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.NavUtils;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;

import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookSdk;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;

import java.util.Arrays;


public class SignInActivity extends Activity implements OnClickListener {
    private CallbackManager callbackManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sign_in);
        FacebookSdk.sdkInitialize(getApplicationContext());
        callbackManager = CallbackManager.Factory.create();
        LoginManager.getInstance().registerCallback(callbackManager, new FacebookCallback<LoginResult>() {


            @Override
            public void onSuccess(LoginResult loginResult) {
                System.out.println(loginResult);
            }

            @Override
            public void onCancel() {
                System.out.println("Facebook Canceled");
            }

            @Override
            public void onError(FacebookException e) {
                System.out.println(e.getMessage());
            }
        });

        // Set up custom Action Bar and enable up navigation
        getActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
        getActionBar().setCustomView(R.layout.action_bar_title);
        getActionBar().setDisplayHomeAsUpEnabled(false);
        getActionBar().setDisplayShowHomeEnabled(false);
        getActionBar().setHomeButtonEnabled(false);

        ((TextView)findViewById(R.id.action_bar_title)).setText(R.string.title_activity_sign_in);
        ((ImageButton)findViewById(R.id.action_bar_right)).setVisibility(View.INVISIBLE);
        ((ImageButton) findViewById(R.id.action_bar_home)).setImageResource(R.drawable.ic_action_cancel);
        ((ImageButton) findViewById(R.id.action_bar_home)).setOnClickListener(this);

        // Add on click listeners to buttons
        ((Button)findViewById(R.id.btnSignIn)).setOnClickListener(this);
        ((Button)findViewById(R.id.btnSignInFacebook)).setOnClickListener(this);
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_sign_in, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        return super.onOptionsItemSelected(item);
    }

    @Override
    protected void onActivityResult(final int requestCode, final int resultCode, final Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        callbackManager.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        switch (id) {
            case R.id.btnSignIn:
                // TODO: Implement Sign in Code
                Intent homeIntent = new Intent(this, HomeActivity.class);
                startActivity(homeIntent);
                finish();
                break;
            case R.id.btnSignInFacebook:
//                // TODO: Implement Sign in Code
//                Intent homeIntentFacebook = new Intent(this, HomeActivity.class);
//                startActivity(homeIntentFacebook);
//                finish();
                LoginManager.getInstance().logInWithReadPermissions(this, Arrays.asList("public_profile", "user_friends"));
                break;
            case R.id.action_bar_home:
                NavUtils.navigateUpFromSameTask(this);
                break;
        }
    }
}
