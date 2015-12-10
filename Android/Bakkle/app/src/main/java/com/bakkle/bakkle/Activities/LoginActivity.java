package com.bakkle.bakkle.Activities;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.StrictMode;
import android.preference.PreferenceManager;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;

import com.bakkle.bakkle.Helpers.Constants;
import com.bakkle.bakkle.Helpers.ServerCalls;
import com.bakkle.bakkle.R;
import com.facebook.AccessToken;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookSdk;
import com.facebook.GraphRequest;
import com.facebook.GraphResponse;
import com.facebook.Profile;
import com.facebook.ProfileTracker;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;

import org.json.JSONObject;

import java.util.Arrays;


public class LoginActivity extends AppCompatActivity implements OnClickListener
{

    private CallbackManager callbackManager;
    SharedPreferences        preferences;
    SharedPreferences.Editor editor;


    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        callbackManager = CallbackManager.Factory.create();
        FacebookSdk.sdkInitialize(this);
        preferences = PreferenceManager.getDefaultSharedPreferences(this);
        editor = preferences.edit();
        setContentView(R.layout.activity_login);
        final ServerCalls serverCalls = new ServerCalls(this);

        findViewById(R.id.btnSignIn).setOnClickListener(this);
        findViewById(R.id.btnSignInFacebook).setOnClickListener(this);

        LoginManager.getInstance().registerCallback(callbackManager, new FacebookCallback<LoginResult>()
        {
            private ProfileTracker mProfileTracker;

            @Override
            public void onSuccess(LoginResult loginResult)
            {
                AccessToken token = loginResult.getAccessToken();
                mProfileTracker = new ProfileTracker()
                {
                    @Override
                    protected void onCurrentProfileChanged(Profile oldProfile, Profile currentProfile)
                    {
                        Profile.setCurrentProfile(currentProfile);
                        mProfileTracker.stopTracking();
                    }
                };

                mProfileTracker.startTracking();

                if (token != null) {
                    editor.putBoolean("LoggedIn", true);
                    editor.apply();

                    GraphRequest request = GraphRequest.newMeRequest(token,
                            new GraphRequest.GraphJSONObjectCallback()
                            {
                                @Override
                                public void onCompleted(JSONObject object, GraphResponse response)
                                {
                                    addUserInfoToPreferences(object);
                                    Log.d("testing", preferences.getString(Constants.UUID, ""));
                                    Log.d("testing", preferences.getString(Constants.USER_ID, ""));

                                    serverCalls.registerFacebook(
                                            preferences.getString(Constants.EMAIL, ""),
                                            preferences.getString(Constants.GENDER, ""),
                                            preferences.getString(Constants.USERNAME, ""),
                                            preferences.getString(Constants.NAME, ""),
                                            preferences.getString(Constants.USER_ID, ""),
                                            preferences.getString(Constants.LOCALE, ""),
                                            preferences.getString(Constants.FIRST_NAME, ""),
                                            preferences.getString(Constants.LAST_NAME, ""),
                                            preferences.getString(Constants.UUID, ""));

                                    String auth_token = serverCalls.loginFacebook(
                                            preferences.getString(Constants.UUID, ""),
                                            preferences.getString(Constants.USER_ID, ""),
                                            getLocation()
                                    );
                                    editor.putString(Constants.AUTH_TOKEN, auth_token);
                                    editor.putBoolean(Constants.NEW_USER, false);
                                    editor.apply();
                                }
                            });

                    Bundle parameters = new Bundle();
                    parameters.putString("fields", "locale, email, gender");
                    //request.executeAsync();
                    StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();

                    StrictMode.setThreadPolicy(policy);
                    addUserInfoToPreferences(request.executeAndWait().getJSONObject());


                    Intent intent = new Intent(getApplicationContext(), MainActivity.class);
                    startActivity(intent);
                    finish();
                }
            }

            @Override
            public void onCancel()
            {

            }

            @Override
            public void onError(FacebookException e)
            {

            }
        });
    }

    @Override
    public void onResume()
    {
        super.onResume();
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        super.onActivityResult(requestCode, resultCode, data);
        callbackManager.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onClick(View v)
    {
        int id = v.getId();
        switch (id) {
            case R.id.btnSignIn:
                // TODO: Implement Sign in Code

                break;
            case R.id.btnSignInFacebook:
                LoginManager.getInstance().logInWithReadPermissions(this, Arrays.asList
                        ("public_profile", "email", "user_friends"));
                LoginManager.getInstance().logInWithPublishPermissions(
                        this, Arrays.asList("publish_actions"));
                editor.putBoolean(Constants.LOGGED_IN, true);
                editor.putBoolean(Constants.NEW_USER, true);
                editor.apply();
                break;
        }
    }


    @Override
    public void onBackPressed()
    {
        //startActivity(new Intent(this, SignupActivity.class));
        finish();
    }

    public String getLocation()
    {
        return preferences.getString(Constants.LOCATION, "0,0");
    }

    public void addUserInfoToPreferences(JSONObject object)
    {
        try {
            editor.putString(Constants.EMAIL, object.getString("email"));
            editor.putString(Constants.GENDER, object.getString("gender"));
            editor.putString(Constants.USERNAME, "");
            editor.putString(Constants.NAME, object.getString("name"));
            editor.putString(Constants.USER_ID, object.getString("id"));
            editor.putString(Constants.LOCALE, object.getString("locale"));
            editor.putString(Constants.FIRST_NAME, object.getString("first_name"));
            editor.putString(Constants.LAST_NAME, object.getString("last_name"));
            editor.apply();
        }
        catch (Exception e) {
            Log.v("Error", e.getMessage());
        }
    }

}
