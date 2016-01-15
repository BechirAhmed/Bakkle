package com.bakkle.bakkle;

import android.Manifest;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.location.Location;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.NavigationView;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v4.content.LocalBroadcastManager;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.Response;
import com.bakkle.bakkle.AddItem.AddItemActivity;
import com.bakkle.bakkle.Profile.ProfileActivity;
import com.bakkle.bakkle.Profile.RegisterActivity;
import com.bakkle.bakkle.Selling.SellingFragment;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.gcm.GoogleCloudMessaging;
import com.google.android.gms.iid.InstanceID;
import com.google.android.gms.location.LocationServices;
import com.squareup.picasso.Picasso;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.Timer;
import java.util.TimerTask;

public class MainActivity extends AppCompatActivity
        implements GoogleApiClient.ConnectionCallbacks, GoogleApiClient.OnConnectionFailedListener,
                   NavigationView.OnNavigationItemSelectedListener,
                   FeedFragment.OnFragmentInteractionListener
{
    DrawerLayout         drawer;
    NavigationView       navigationView;
    Toolbar              toolbar;
    View                 navHeader;
    GoogleApiClient      googleApiClient;
    Location             lastLocation;
    Prefs                prefs;
    FloatingActionButton undoFab;

    private BroadcastReceiver mRegistrationBroadcastReceiver;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        prefs = Prefs.getInstance(this);

        toolbar = (Toolbar) findViewById(R.id.toolbar);
        //toolbar.setLogo(R.drawable.logo_white_clear);
        setSupportActionBar(toolbar);

        setupNavDrawer(toolbar);

        FloatingActionButton addItemFab = (FloatingActionButton) findViewById(R.id.add_item_fab);
        addItemFab.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {
                if (prefs.isLoggedIn()) {
                    startActivity(new Intent(MainActivity.this, AddItemActivity.class));
                } else {
                    startActivityForResult(new Intent(MainActivity.this, RegisterActivity.class),
                            Constants.REQUEST_CODE_POST_ITEM);
                }
            }
        });
        undoFab = (FloatingActionButton) findViewById(R.id.undo);
        googleApiClient = new GoogleApiClient.Builder(this).addConnectionCallbacks(this)
                .addOnConnectionFailedListener(this)
                .addApi(LocationServices.API)
                .build();

        InstanceID instanceID = InstanceID.getInstance(this);
        String token;

        if (prefs.isFirstLaunch()) {
            startActivityForResult(new Intent(this, TutorialActivity.class),
                    Constants.SHOW_TUORIAL);
        } else {
            beginApp();
        }

    }

    public void beginApp()
    {
        Intent intent = new Intent(this, RegistrationIntentService.class);
        startService(intent);
        requestLocationPermission();

        mRegistrationBroadcastReceiver = new BroadcastReceiver()
        {
            @Override
            public void onReceive(Context context, Intent intent)
            {
                SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(
                        context);
                boolean sentToken = sharedPreferences.getBoolean("sentTokenToServer", false);
                if (sentToken) {
                    Log.v("MainActivity", "Sent token");
                } else {
                    Log.v("MainActivity", "NOT Sent token");
                }
            }
        };
        if (prefs.isLoggedIn()) {
            new AsyncTask<Void, Void, Void>()
            {
                @Override
                protected Void doInBackground(Void... params)
                {
                    try {
                        API.getInstance(MainActivity.this)
                                .registerPush(GoogleCloudMessaging.getInstance(MainActivity.this)
                                        .register(Constants.SENDER_ID));
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                    return null;
                }
            }.execute();
        }
    }

    private void requestLocationPermission()
    {
        int permissionCheck = ContextCompat.checkSelfPermission(this,
                Manifest.permission.ACCESS_FINE_LOCATION);
        if (permissionCheck != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this,
                    new String[]{Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION},
                    Constants.REQUEST_CODE_ACCESS_FINE_LOCATION);
        } else {
            if (prefs.isAuthenticated()) {
                getSupportFragmentManager().beginTransaction()
                        .replace(R.id.content_frame, FeedFragment.newInstance(), Constants.FEED)
                        .commit();

                navigationView.getMenu().getItem(0).setChecked(true);

                ((TextView) navHeader.findViewById(R.id.name)).setText(prefs.getName());
            } else {
                API.getInstance(getApplicationContext())
                        .getGuestUserId(new GuestIdResponseListener());
                ((TextView) navHeader.findViewById(R.id.name)).setText(R.string.guest_user);
            }
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[],
                                           final int[] grantResults)
    {
        switch (requestCode) {
            case Constants.REQUEST_CODE_ACCESS_FINE_LOCATION: {
                new Timer().schedule(new TimerTask()
                { //This is a workaround for a bug/crash in Android
                    @Override
                    public void run()
                    {
                        if (prefs.isAuthenticated()) {
                            getSupportFragmentManager().beginTransaction()
                                    .replace(R.id.content_frame, FeedFragment.newInstance(),
                                            Constants.FEED)
                                    .commit();
                            runOnUiThread(new Runnable()
                            {
                                @Override
                                public void run()
                                {
                                    navigationView.getMenu().getItem(0).setChecked(true);
                                }
                            });

                            ((TextView) navHeader.findViewById(R.id.name)).setText(prefs.getName());
                        } else {
                            API.getInstance(getApplicationContext())
                                    .getGuestUserId(new GuestIdResponseListener());
                            ((TextView) navHeader.findViewById(R.id.name)).setText(
                                    R.string.guest_user);
                        }

                        if (!(grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED)) {
                            final FeedFragment fragment = (FeedFragment) (getSupportFragmentManager()
                                    .findFragmentByTag(Constants.FEED));
                            if (fragment != null) {
                                runOnUiThread(new Runnable()
                                {
                                    @Override
                                    public void run()
                                    {
                                        fragment.showLocationError();
                                    }
                                });
                            }
                        }
                    }
                }, 0);
            }

            // other 'case' lines to check for other
            // permissions this app might request
        }
    }

    protected void onStart()
    {
        googleApiClient.connect();
        super.onStart();
    }

    protected void onStop()
    {
        googleApiClient.disconnect();
        super.onStop();
    }

    @Override
    protected void onResume()
    {
        super.onResume();
        FeedFragment fragment = (FeedFragment) getSupportFragmentManager().findFragmentByTag(
                Constants.FEED);
        if (fragment != null) {
            fragment.refreshFeed();
        }
        LocalBroadcastManager.getInstance(this)
                .registerReceiver(mRegistrationBroadcastReceiver,
                        new IntentFilter("registrationComplete"));

    }

    @Override
    protected void onPause()
    {
        LocalBroadcastManager.getInstance(this).unregisterReceiver(mRegistrationBroadcastReceiver);
        super.onPause();
    }

    @Override
    public void onConnected(Bundle connectionHint)
    {
        lastLocation = LocationServices.FusedLocationApi.getLastLocation(googleApiClient);
        if (lastLocation != null) {
            Prefs.getInstance(this).setLocation(lastLocation);
        }
    }

    @Override
    public void onConnectionSuspended(int i)
    {

    }

    @Override
    public void onConnectionFailed(ConnectionResult connectionResult)
    {
    }

    private void setupNavDrawer(Toolbar toolbar)
    {
        drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(this, drawer, toolbar,
                R.string.navigation_drawer_open, R.string.navigation_drawer_close);

        drawer.setDrawerListener(toggle);
        toggle.syncState();

        final NavigationView navigationView = (NavigationView) findViewById(R.id.nav_view);
        navigationView.setNavigationItemSelectedListener(this);
        this.navigationView = navigationView;
        navHeader = navigationView.getHeaderView(0);
        navHeader.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                Intent intent = new Intent(MainActivity.this, ProfileActivity.class);
                startActivityForResult(intent, Constants.REQUEST_CODE_PROFILE);
            }
        });
        updateNavHeader();
    }

    public void updateNavHeader()
    {
        TextView name = (TextView) navHeader.findViewById(R.id.name);
        ImageView picture = (ImageView) navHeader.findViewById(R.id.prof_pic);

        name.setText(prefs.getName());
        Picasso.with(this)
                .load(prefs.getUserImageUrl())
                .fit()
                .centerCrop()
                .noFade()
                .placeholder(R.drawable.ic_account_circle)
                .error(R.drawable.ic_account_circle)
                .into(picture);

    }

    @Override
    public void onBackPressed()
    {
        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        if (drawer.isDrawerOpen(GravityCompat.START)) {
            drawer.closeDrawer(GravityCompat.START);
        } else {
            super.onBackPressed();
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu)
    {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_search) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public boolean onNavigationItemSelected(MenuItem item)
    {
        // Handle navigation view item clicks here.
        int id = item.getItemId();

        if (id == R.id.feed) {
            if (!item.isChecked()) {
                getSupportFragmentManager().beginTransaction()
                        .replace(R.id.content_frame, FeedFragment.newInstance(), Constants.FEED)
                        .commit();
            } else {
                ((FeedFragment) getSupportFragmentManager().findFragmentByTag(
                        Constants.FEED)).refreshFeed();
            }
        } else if (id == R.id.seller) {
            if (!item.isChecked()) {
                getSupportFragmentManager().beginTransaction()
                        .replace(R.id.content_frame, SellingFragment.newInstance(),
                                Constants.SELLING)
                        .commit();
                undoFab.hide();
            } else {
                ((SellingFragment) getSupportFragmentManager().findFragmentByTag(Constants.SELLING))
                        .refreshSelling();
            }
        } else if (id == R.id.buyer) {
            if (!item.isChecked()) {
                getSupportFragmentManager().beginTransaction()
                        .replace(R.id.content_frame, BuyingFragment.newInstance(), Constants.BUYING)
                        .commit();
                undoFab.hide();
            } else {
                ((BuyingFragment) getSupportFragmentManager().findFragmentByTag(
                        Constants.BUYING)).refreshBuying();
            }
        } else if (id == R.id.watch) {
            if (!item.isChecked()) {
                getSupportFragmentManager().beginTransaction()
                        .replace(R.id.content_frame, WatchListFragment.newInstance(),
                                Constants.WATCH_LIST)
                        .commit();
                undoFab.hide();
            } else {
                ((WatchListFragment) getSupportFragmentManager().findFragmentByTag(
                        Constants.WATCH_LIST)).refreshWatchList();
            }
        } else if (id == R.id.nav_about) {
            startActivity(new Intent(this, AboutActivity.class));
        }

        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        drawer.closeDrawer(GravityCompat.START);
        return true;
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == Constants.SHOW_TUORIAL && resultCode == Constants.REUSLT_CODE_OK) {
            beginApp();
            prefs.setFirstLaunch(false);
        }
        if (requestCode == Constants.REQUEST_CODE_PROFILE && resultCode == Constants.RESULT_CODE_NOW_SIGNED_OUT) {
            updateNavHeader();
            API.getInstance(getApplicationContext()).getGuestUserId(new GuestIdResponseListener());
            ((TextView) navHeader.findViewById(R.id.name)).setText(R.string.guest_user);
        } else if (requestCode == Constants.REQUEST_CODE_PROFILE && resultCode == Constants.RESULT_CODE_NOW_SIGNED_IN) {
            updateNavHeader();

            // token = instanceID.getToken(Constants.SENDER_ID, // GoogleCloudMessaging.INSTANCE_ID_SCOPE, null); // Log.v("test", token);
            if (prefs.isLoggedIn() && !prefs.isRegistered()) {
                new AsyncTask<Void, Void, Void>()
                {
                    @Override
                    protected Void doInBackground(Void... params)
                    {
                        try {
                            API.getInstance(MainActivity.this)
                                    .registerPush(
                                            GoogleCloudMessaging.getInstance(MainActivity.this)
                                                    .register(Constants.SENDER_ID));
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                        return null;
                    }
                }.execute();
            }
        }

        FeedFragment fragment = (FeedFragment) getSupportFragmentManager().findFragmentByTag(
                Constants.FEED);
        if (fragment != null && requestCode != Constants.REQUEST_CODE_VIEW_ITEM) {
            fragment.refreshFeed();
        } else if (requestCode == Constants.REQUEST_CODE_POST_ITEM) {
            if (resultCode == Constants.RESULT_CODE_NOW_SIGNED_IN) {
                startActivity(new Intent(this, AddItemActivity.class));
            }
        }
    }

    public DrawerLayout getDrawer()
    {
        return drawer;
    }

    @Override
    public void onFragmentInteraction(Uri uri)
    {

    }

    public class GuestIdResponseListener implements Response.Listener<JSONObject>
    {
        @Override
        public void onResponse(JSONObject response)
        {
            try {
                if (response.has("status") && response.getInt("status") == 1) {
                    prefs.setUserId(response.getString("userid"));
                    prefs.setUsername("Guest User");
                    prefs.setName("Guest User");
                    prefs.setFirstName("Guest");
                    prefs.setLastName("User");
                    API.getInstance(MainActivity.this).registerFacebook(new GuestLoginListener());
                } else {
                    Toast.makeText(MainActivity.this, "There was error signing in",
                            Toast.LENGTH_SHORT).show();
                }
            } catch (JSONException e) {
                Toast.makeText(MainActivity.this, "There was error signing in", Toast.LENGTH_SHORT)
                        .show();
            }
        }
    }

    public class GuestLoginListener implements Response.Listener<JSONObject>
    {
        @Override
        public void onResponse(JSONObject response)
        {
            try {
                prefs.setAuthToken(response.getString("auth_token"));
                prefs.setAuthenticated(true);
                prefs.setLoggedIn(false);
                prefs.setGuest(true);

                getSupportFragmentManager().beginTransaction()
                        .replace(R.id.content_frame, FeedFragment.newInstance(), Constants.FEED)
                        .commit();
            } catch (JSONException e) {
                Toast.makeText(getApplicationContext(), "There was error signing in",
                        Toast.LENGTH_SHORT).show();
            }
        }
    }
}
