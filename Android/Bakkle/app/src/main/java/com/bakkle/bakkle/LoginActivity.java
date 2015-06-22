package com.bakkle.bakkle;

import android.app.ActionBar;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.app.NavUtils;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.TextView;

import com.facebook.AccessToken;
import com.facebook.AccessTokenTracker;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookSdk;
import com.facebook.Profile;
import com.facebook.ProfileTracker;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.facebook.login.widget.LoginButton;

import java.util.Arrays;


public class LoginActivity extends Activity implements OnClickListener {

    private LoginButton loginButton;
    private CallbackManager callbackManager;
    private boolean isResumed = false;
    private AccessTokenTracker accessTokenTracker;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        callbackManager = CallbackManager.Factory.create();
        final Context mContext = this;
        FacebookSdk.sdkInitialize(getApplicationContext());
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(getApplicationContext());
        SharedPreferences.Editor editor = preferences.edit();

        if(preferences.getBoolean("LoggedIn", false)) {

            Intent intent = new Intent(this, HomeActivity.class);
            startActivity(intent);
            finish();
        }




        setContentView(R.layout.activity_login);
        LoginManager.getInstance().registerCallback(callbackManager, new FacebookCallback<LoginResult>() {


            private ProfileTracker mProfileTracker;

            @Override
            public void onSuccess(LoginResult loginResult) {


                SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(getApplicationContext());
                SharedPreferences.Editor editor = preferences.edit();
                //AccessToken token = AccessToken.getCurrentAccessToken();
                AccessToken token = loginResult.getAccessToken();
                mProfileTracker = new ProfileTracker() {
                    @Override
                    protected void onCurrentProfileChanged(Profile oldProfile, Profile currentProfile) {
                        Profile.setCurrentProfile(currentProfile);
                        mProfileTracker.stopTracking();
                    }
                };

                mProfileTracker.startTracking();

                if(token != null) {
                    editor.putBoolean("LoggedIn", true);
                    editor.apply();
                    Intent intent = new Intent(getApplicationContext(), HomeActivity.class);
                    startActivity(intent);
                    finish();
                }


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
        ((LoginButton)findViewById(R.id.btnSignInFacebook)).setOnClickListener(this);
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
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
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
                SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(getApplicationContext());
                SharedPreferences.Editor editor = preferences.edit();
                if(preferences.getBoolean("LoggedIn", false)){
                    LoginManager.getInstance().logOut();
                    editor.putBoolean("LoggedIn", false);
                    editor.apply();
                }
                else{
                    LoginManager.getInstance().logInWithReadPermissions(this, Arrays.asList
                            ("public_profile", "email", "user_friends"));
                    LoginManager.getInstance().logInWithPublishPermissions(
                            this, Arrays.asList("publish_actions"));
                    editor.putBoolean("LoggedIn", true);
                    editor.apply();

                }
                break;
            case R.id.action_bar_home:
                NavUtils.navigateUpFromSameTask(this);
                break;
        }
    }







    @Override
    public void onBackPressed() {
        startActivity(new Intent(this, SignupActivity.class));
        finish();
    }

}
