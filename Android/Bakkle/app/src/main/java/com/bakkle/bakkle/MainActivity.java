package com.bakkle.bakkle;

import android.location.Location;
import android.net.Uri;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.NavigationView;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.Response;
import com.android.volley.toolbox.ImageLoader;
import com.android.volley.toolbox.NetworkImageView;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.location.LocationServices;

import org.json.JSONException;
import org.json.JSONObject;

public class MainActivity extends AppCompatActivity
        implements GoogleApiClient.ConnectionCallbacks, GoogleApiClient.OnConnectionFailedListener,
                   NavigationView.OnNavigationItemSelectedListener,
                   FeedFragment.OnFragmentInteractionListener
{
    DrawerLayout    drawer;
    NavigationView  navigationView;
    Toolbar toolbar;
    View            navHeader;
    GoogleApiClient googleApiClient;
    Location        lastLocation;
    Prefs           prefs;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        toolbar = (Toolbar) findViewById(R.id.toolbar);
        //toolbar.setLogo(R.drawable.logo_white_clear);
        setSupportActionBar(toolbar);

        prefs = Prefs.getInstance(getApplicationContext());

        setupNavDrawer(toolbar);

        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {
                //Start AddItem Activity
            }
        });
        googleApiClient = new GoogleApiClient.Builder(this).addConnectionCallbacks(this)
                .addOnConnectionFailedListener(this)
                .addApi(LocationServices.API)
                .build();

        if (prefs.isAuthenticated()) {
            getSupportFragmentManager().beginTransaction()
                    .replace(R.id.content_frame, FeedFragment.newInstance())
                    .commit();
            navigationView.getMenu().getItem(0).setChecked(true);

            ((TextView) navHeader.findViewById(R.id.email)).setText(prefs.getEmail());
            ((TextView) navHeader.findViewById(R.id.name)).setText(prefs.getName());
        } else {
            Server.getInstance(getApplicationContext())
                    .getGuestUserId(new GuestIdResponseListener());
            ((TextView) navHeader.findViewById(R.id.email)).setText(R.string.guest_email);
            ((TextView) navHeader.findViewById(R.id.name)).setText(R.string.guest_user);
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
                                                                 R.string.navigation_drawer_open,
                                                                 R.string.navigation_drawer_close);

        drawer.setDrawerListener(toggle);
        toggle.syncState();

        NavigationView navigationView = (NavigationView) findViewById(R.id.nav_view);
        navigationView.setNavigationItemSelectedListener(this);
        this.navigationView = navigationView;
        navHeader = navigationView.getHeaderView(0);
        updateNavHeader();
    }

    public void updateNavHeader()
    {
        TextView name = (TextView) navHeader.findViewById(R.id.name);
        TextView email = (TextView) navHeader.findViewById(R.id.email);
        NetworkImageView picture = (NetworkImageView) navHeader.findViewById(R.id.prof_pic);
        ImageLoader imageLoader = Server.getInstance(getApplication()).getImageLoader();

        name.setText(prefs.getName());
        email.setText(prefs.getEmail());
        picture.setErrorImageResId(R.drawable.ic_account_circle);
        picture.setDefaultImageResId(R.drawable.ic_account_circle);
        picture.setImageUrl(prefs.getUserImageUrl(), imageLoader);

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
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
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
                        .replace(R.id.content_frame, FeedFragment.newInstance())
                        .commit();
            }
        } else if (id == R.id.seller) {
            if (!item.isChecked()) {
                getSupportFragmentManager().beginTransaction()
                        .replace(R.id.content_frame, SellingFragment.newInstance())
                        .commit();
            }
        } else if (id == R.id.buyer) {
            if (!item.isChecked()) {
                getSupportFragmentManager().beginTransaction()
                        .replace(R.id.content_frame, BuyingFragment.newInstance())
                        .commit();
            }
        } else if (id == R.id.watch) {
            if (!item.isChecked()) {
                getSupportFragmentManager().beginTransaction()
                        .replace(R.id.content_frame, WatchListFragment.newInstance())
                        .commit();
            }
        } else if (id == R.id.nav_share) {

        }

        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        drawer.closeDrawer(GravityCompat.START);
        return true;
    }

    public DrawerLayout getDrawer()
    {
        return drawer;
    }

    public Toolbar getToolbar()
    {
        return toolbar;
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
                    Server.getInstance(getApplicationContext())
                            .registerFacebook(new GuestLoginListener());
                } else {
                    Toast.makeText(getApplicationContext(), "There was error signing in",
                                   Toast.LENGTH_SHORT).show();
                }
            } catch (JSONException e) {
                Toast.makeText(getApplicationContext(), "There was error signing in",
                               Toast.LENGTH_SHORT).show();
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
                        .replace(R.id.content_frame, FeedFragment.newInstance())
                        .commit();
            } catch (JSONException e) {
                Toast.makeText(getApplicationContext(), "There was error signing in",
                               Toast.LENGTH_SHORT).show();
            }
        }
    }
}
