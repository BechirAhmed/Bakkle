package com.bakkle.bakkle;

import android.app.ActionBar;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.NavUtils;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.Toast;

import com.facebook.AccessToken;
import com.facebook.AccessTokenTracker;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.facebook.login.widget.LoginButton;

import java.util.Arrays;


public class SignInActivity extends Activity implements OnClickListener {

    private LoginButton loginButton;
    private CallbackManager callbackManager;
    private boolean isResumed = false;
    private AccessTokenTracker accessTokenTracker;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        callbackManager = CallbackManager.Factory.create();
        /*accessTokenTracker = new AccessTokenTracker() {
            @Override
            protected void onCurrentAccessTokenChanged(AccessToken oldAccessToken,
                                                       AccessToken currentAccessToken) {
                if (isResumed) {
                    //FragmentManager manager = getSupportFragmentManager();
                    int backStackSize = manager.getBackStackEntryCount();
                    for (int i = 0; i < backStackSize; i++) {
                        manager.popBackStack();
                    }
                    if (currentAccessToken != null) {
                        Intent intent = new Intent(this, HomeActivity.class);
                        //showFragment(SELECTION, false);
                    } else {
                        //showFragment(SPLASH, false);
                    }
                }
            }
        };*/




        //FacebookSdk.sdkInitialize(getApplicationContext());
        setContentView(R.layout.activity_sign_in);
        LoginManager.getInstance().registerCallback(callbackManager, new FacebookCallback<LoginResult>() {


            @Override
            public void onSuccess(LoginResult loginResult) {
                System.out.println(loginResult);
                Toast.makeText(getApplicationContext(), "Success", Toast.LENGTH_SHORT).show();
            }

            @Override
            public void onCancel() {
                System.out.println("Facebook Canceled");
                Toast.makeText(getApplicationContext(), "Canceled", Toast.LENGTH_SHORT).show();
            }

            @Override
            public void onError(FacebookException e) {
                System.out.println(e.getMessage());
                Toast.makeText(getApplicationContext(), "Error", Toast.LENGTH_SHORT).show();
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
                // TODO: Implement Sign in Code
                AccessToken token = AccessToken.getCurrentAccessToken();
                if(token != null)
                    Toast.makeText(getApplicationContext(), token.toString(), Toast.LENGTH_SHORT).show();
                else
                    Toast.makeText(getApplicationContext(), "Not working", Toast.LENGTH_SHORT).show();
                //
                LoginManager.getInstance().logInWithReadPermissions(this, Arrays.asList("public_profile", "user_friends"));

//                Intent homeIntentFacebook = new Intent(this, HomeActivity.class);
//                startActivity(homeIntentFacebook);
//                finish();
                break;
            case R.id.action_bar_home:
                NavUtils.navigateUpFromSameTask(this);
                break;
        }
    }
}
