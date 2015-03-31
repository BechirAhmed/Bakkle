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
import android.widget.ImageView;
import android.widget.TextView;


public class SignInActivity extends Activity implements OnClickListener {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sign_in);

        // Set up custom Action Bar and enable up navigation
        getActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
        getActionBar().setCustomView(R.layout.action_bar_title);
        getActionBar().setDisplayHomeAsUpEnabled(true);
        ((TextView)findViewById(R.id.action_bar_title)).setText(R.string.title_activity_sign_in);
        ((ImageView)findViewById(R.id.action_bar_rightImage)).setVisibility(View.INVISIBLE);

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
        int id = item.getItemId();

        switch (id) {
            case android.R.id.home:
                NavUtils.navigateUpFromSameTask(this);
                return true;

        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        switch (id) {
            case R.id.btnSignIn:
                // TODO: Implement Sign in Code
                Intent homeIntent = new Intent(this, HomeActivity.class);
                startActivity(homeIntent);
                break;
            case R.id.btnSignInFacebook:
                // TODO: Implement Sign in Code
                Intent homeIntentFacebook = new Intent(this, HomeActivity.class);
                startActivity(homeIntentFacebook);
                break;
        }
    }
}
