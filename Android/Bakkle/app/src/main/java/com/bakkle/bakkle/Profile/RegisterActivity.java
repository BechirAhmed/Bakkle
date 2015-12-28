package com.bakkle.bakkle.Profile;

import android.net.Uri;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.MenuItem;

import com.bakkle.bakkle.R;

public class RegisterActivity extends AppCompatActivity
        implements SignupEmailFragment.OnFragmentInteractionListener
{

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_register);

        if (getSupportActionBar() != null) {
            getSupportActionBar().hide();
        }

        //getSupportFragmentManager().addOnBackStackChangedListener(this);

        getSupportFragmentManager().beginTransaction().replace(R.id.content_frame, new SignupLoginChooser()).commit();
    }

    //TODO: On Activity Result, change the nav header, update the feed, make/send offer as expected

    @Override
    public void onFragmentInteraction(Uri uri)
    {

    }

    @Override
    public void onBackPressed()
    {
        if (getFragmentManager().getBackStackEntryCount() == 0) {
            super.onBackPressed();
        } else {
            getFragmentManager().popBackStack();
        }
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        onBackPressed();
        return super.onOptionsItemSelected(item);
    }
//    @Override
//    public void onBackStackChanged()
//    {
//        getSupportActionBar().setDisplayHomeAsUpEnabled(getSupportFragmentManager().getBackStackEntryCount() > 0);
//    }
//
//    @Override
//    public boolean onSupportNavigateUp()
//    {
//        getSupportFragmentManager().popBackStack();
//        return true;
//    }
}

