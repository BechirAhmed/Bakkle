package com.bakkle.bakkle;

import android.app.ActionBar;
import android.app.Fragment;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.content.res.TypedArray;
import android.location.Location;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.Toast;

import com.facebook.AccessToken;
import com.facebook.FacebookSdk;
import com.facebook.GraphRequest;
import com.facebook.GraphResponse;
import com.facebook.Profile;
import com.facebook.login.LoginManager;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.location.LocationServices;
import com.mikepenz.materialdrawer.Drawer;
import com.mikepenz.materialdrawer.DrawerBuilder;
import com.mikepenz.materialdrawer.accountswitcher.AccountHeader;
import com.mikepenz.materialdrawer.accountswitcher.AccountHeaderBuilder;
import com.mikepenz.materialdrawer.model.PrimaryDrawerItem;
import com.mikepenz.materialdrawer.model.ProfileDrawerItem;
import com.mikepenz.materialdrawer.model.interfaces.IDrawerItem;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;


public class HomeActivity extends AppCompatActivity implements SellersGarage.OnFragmentInteractionListener,
        BuyersTrunk.OnFragmentInteractionListener, HoldingPattern.OnFragmentInteractionListener,
        GoogleApiClient.ConnectionCallbacks, GoogleApiClient.OnConnectionFailedListener,
        FeedFragment.OnCardSelected{

    private DrawerLayout mDrawerLayout;
    private ListView mDrawerList;
    private DrawerRowAdapter mDrawerAdapter;
    private ArrayList<String> mDrawerItems;
    private TypedArray mDrawerIcons;
    private ActionBarDrawerToggle mDrawerToggle;
    private ActionBar mActionBar;

    RecyclerView mRecyclerView;
    RecyclerView.Adapter mAdapter;
    RecyclerView.LayoutManager mLayoutManager;

    private Toolbar toolbar;

    FeedItem item;

    Drawer drawer = null;

    SharedPreferences preferences;
    SharedPreferences.Editor editor;

    ServerCalls serverCalls;

    GoogleApiClient mGoogleApiClient;
    Location mLastLocation;

    int result = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

        preferences = PreferenceManager.getDefaultSharedPreferences(getApplicationContext());
        editor = preferences.edit();

        toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        mDrawerItems = new ArrayList<String>(Arrays.asList(getResources().getStringArray(R.array.drawer_items)));
        mDrawerIcons = getResources().obtainTypedArray(R.array.drawer_icons);
//        mDrawerToggle = new ActionBarDrawerToggle(this, Drawer, /*toolbar,*/ R.string.openDrawer, R.string.closeDrawer) {
//
//            @Override
//            public void onDrawerOpened(View drawerView) {
//                super.onDrawerOpened(drawerView);
//                // code here will execute once the drawer is opened( As I dont want anything happened whe drawer is
//                // open I am not going to put anything here)
//            }
//
//            @Override
//            public void onDrawerClosed(View drawerView) {
//                super.onDrawerClosed(drawerView);
//                getSupportActionBar().setDisplayHomeAsUpEnabled(false);
//                drawer.getActionBarDrawerToggle().setDrawerIndicatorEnabled(true);
//            }
//        };

//        Bitmap profpic = null;
//        Drawable prof;
//
//        try {
//            profpic = Ion.with(this)
//                    .load("http://graph.facebook.com/" + preferences.getString("userID", "0") + "/picture?type=square")
//                    .withBitmap()
//                    .asBitmap()
//                    .get();
//            prof = new BitmapDrawable(getResources(), profpic);
//        }
//        catch(Exception e){
//            prof = getResources().getDrawable(R.drawable.loading);
//        }




        AccountHeader headerResult = new AccountHeaderBuilder()
                .withActivity(this)
                .withHeaderBackground(R.color.dark_green)
                .withSelectionListEnabled(false)
                .addProfiles(
                        new ProfileDrawerItem().withName(preferences.getString("name", "Not Signed In")).withIcon("http://graph.facebook.com/" + preferences.getString("userID", "0") + "/picture?type=square")
                )
                .withProfileImagesClickable(true)
                .withProfileImagesVisible(true)
                /*.withOnAccountHeaderListener(new AccountHeader.OnAccountHeaderListener() {
                    @Override
                    public boolean onProfileChanged(View view, IProfile profile, boolean currentProfile) {
                        return false;
                    }
                })*/
                .withSavedInstance(savedInstanceState)
                .build();


        drawer = new DrawerBuilder()
                .withActivity(this)
                .withToolbar(toolbar)
                .withSavedInstance(savedInstanceState)
                .withAccountHeader(headerResult)
                .addDrawerItems(
                        new PrimaryDrawerItem().withName(mDrawerItems.get(0)).withIcon(mDrawerIcons.getDrawable(0)),
                        new PrimaryDrawerItem().withName(mDrawerItems.get(1)).withIcon(mDrawerIcons.getDrawable(1)),
                        new PrimaryDrawerItem().withName(mDrawerItems.get(2)).withIcon(mDrawerIcons.getDrawable(2)),
                        new PrimaryDrawerItem().withName(mDrawerItems.get(3)).withIcon(mDrawerIcons.getDrawable(3)),
                        new PrimaryDrawerItem().withName(mDrawerItems.get(4)).withIcon(mDrawerIcons.getDrawable(4)),
                        new PrimaryDrawerItem().withName(mDrawerItems.get(5)).withIcon(mDrawerIcons.getDrawable(5))
                )
                .withTranslucentStatusBar(false)
                /*.withAdapter(mDrawerAdapter)*/
                .withOnDrawerItemClickListener(new Drawer.OnDrawerItemClickListener() {
                    @Override
                    public boolean onItemClick(AdapterView<?> parent, View view, int position, long id, IDrawerItem drawerItem) {
                        switch (position) {
                            case 0:
                                getFragmentManager().beginTransaction().replace(R.id.content_frame,
                                        new FeedFragment()).addToBackStack(null).
                                        setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE).commit();
                                break;
                            case 1:
                                getFragmentManager().beginTransaction().replace(R.id.content_frame,
                                        new SellersGarage()).addToBackStack(null).
                                        setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE).commit();
                                break;
                            case 2:
                                getFragmentManager().beginTransaction().replace(R.id.content_frame,
                                        new BuyersTrunk()).addToBackStack(null).
                                        setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE).commit();
                                invalidateOptionsMenu();
                                break;
                            case 3:
                                getFragmentManager().beginTransaction().replace(R.id.content_frame,
                                        new HoldingPattern()).addToBackStack(null).
                                        setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE).commit();
                                break;
                            case 4:
//                              new ServerCalls(getApplicationContext()).getFeedItems(
                                //                            preferences.getString("auth_token", "0"),
                                //                            "999999999",
                                //                            "100",
                                //                            "",
                                //                            "32,32",
                                //                            "",
                                //                            preferences.getString("uuid", "0")
                                //                        );
                                //startActivity(new Intent(getApplicationContext(), FeedFilter.class));
                                break;
                            case 5:
                                //startActivity(new Intent(getApplicationContext(), DemoOptions.class));
                                getFragmentManager().beginTransaction().replace(R.id.content_frame,
                                        new DemoOptions()).addToBackStack(null)
                                        .setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE).commit();
                                break;
                            default:
                                Toast.makeText(getParent(), "Error", Toast.LENGTH_SHORT).show();
                                break;
                        }

                        return false;
                    }
                })
                .build();

//        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
//        getSupportActionBar().setHomeButtonEnabled(false);






//
        mRecyclerView = (RecyclerView) findViewById(R.id.left_drawer);
//        mRecyclerView.setHasFixedSize(true);
        mAdapter = new DrawerRowAdapter(this, mDrawerItems, mDrawerIcons);
        mRecyclerView.setAdapter(mAdapter);
//
        mLayoutManager = new LinearLayoutManager(this);
        mRecyclerView.setLayoutManager(mLayoutManager);

        // Setup drawer

//        mDrawerLayout = (DrawerLayout) findViewById(R.id.drawer_layout);
//        mDrawerList = (ListView) findViewById(R.id.left_drawer);

        // Set the adapter for the list view
        //mDrawerAdapter = new DrawerRowAdapter(this, mDrawerItems, mDrawerIcons);
        //mDrawerList.setAdapter(mDrawerAdapter);


        // Set the list's click listener
        //mDrawerList.setOnItemClickListener(new DrawerItemClickListener());

//        Drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
//
//        mDrawerToggle = new ActionBarDrawerToggle(this, Drawer, /*toolbar,*/ R.string.openDrawer, R.string.closeDrawer){
//
//            @Override
//            public void onDrawerOpened(View drawerView) {
//                super.onDrawerOpened(drawerView);
//                // code here will execute once the drawer is opened( As I dont want anything happened whe drawer is
//                // open I am not going to put anything here)
//            }
//
//            @Override
//            public void onDrawerClosed(View drawerView) {
//                super.onDrawerClosed(drawerView);
//                // Code here will execute once drawer is closed
//            }
//
//
//
//        }; // Drawer Toggle Object Made
//        Drawer.setDrawerListener(mDrawerToggle); // Drawer Listener set to the Drawer toggle
//        mDrawerToggle.syncState();               // Finally we set the drawer toggle sync State



  /*      mDrawerToggle = new ActionBarDrawerToggle(this, mDrawerLayout, *//*R.drawable.ic_drawer,*//*
                R.string.drawer_open, R.string.drawer_close) {

            *//** Called when a drawer has settled in a completely closed state. *//*
            public void onDrawerClosed(View view) {
                super.onDrawerClosed(view);
                getActionBar().setTitle(getTitle());
                getActionBar().setBackgroundDrawable(new ColorDrawable(getResources().getColor(R.color.green)));
                invalidateOptionsMenu(); // creates call to onPrepareOptionsMenu()
            }

            *//** Called when a drawer has settled in a completely open state. *//*
            public void onDrawerOpened(View drawerView) {
                super.onDrawerOpened(drawerView);
                getActionBar().setBackgroundDrawable(new ColorDrawable(getResources().getColor(R.color.brown)));
                getActionBar().setTitle(getString(R.string.drawer_title));
                invalidateOptionsMenu(); // creates call to onPrepareOptionsMenu()
            }
        };*/

        // Set the drawer toggle as the DrawerListener
        //mDrawerLayout.setDrawerListener(mDrawerToggle);

        // Custom Action bar
//        mActionBar = getActionBar();
//        mActionBar.setDisplayShowHomeEnabled(false);
//        mActionBar.setDisplayShowTitleEnabled(false);
//        LayoutInflater mInflater = LayoutInflater.from(this);
//
//        View mCustomView = mInflater.inflate(R.layout.action_bar_image, null);
//
//        mActionBar.setCustomView(mCustomView);
//        mActionBar.setDisplayShowCustomEnabled(true);
        serverCalls = new ServerCalls(this);

        buildGoogleApiClient();

    }

    @Override
    protected void onPostCreate(Bundle savedInstanceState) {

        super.onPostCreate(savedInstanceState);
        // Sync the toggle state after onRestoreInstanceState has occurred.
        //mDrawerToggle.syncState();

        if(preferences.getBoolean("newuser", true)){
            GraphRequest request = GraphRequest.newMeRequest(AccessToken.getCurrentAccessToken(),
                    new GraphRequest.GraphJSONObjectCallback(){
                @Override
                public void onCompleted(JSONObject object, GraphResponse response) {
                    addUserInfoToPreferences(object);
                    result = serverCalls.registerFacebook(
                            preferences.getString("email", "null"),
                            preferences.getString("gender", "null"),
                            preferences.getString("username", "null"),
                            preferences.getString("name", "null"),
                            preferences.getString("userID", "null"),
                            preferences.getString("locale", "null"),
                            preferences.getString("first_name", "null"),
                            preferences.getString("last_name", "null"),
                            preferences.getString("uuid", "0"));
                    editor.putBoolean("done", true);
                    editor.apply();
                }
                    });

            Bundle parameters = new Bundle();
            parameters.putString("fields", "locale, email, gender");
            request.executeAsync();

            if(result == 1)
                Toast.makeText(this, "Logged in successfully!", Toast.LENGTH_SHORT).show();
            else //TODO:Display error on fail? and go back to login screen
                Toast.makeText(this, "Login error!!", Toast.LENGTH_SHORT).show();

        }

        //while(preferences.getBoolean("done", true)){}

        Log.d("testing", preferences.getString("uuid", "0"));
        Log.d("testing", preferences.getString("userID", "0"));
        String auth_token = serverCalls.loginFacebook(
                preferences.getString("uuid", "0"),
                preferences.getString("userID", "0"),
                getLocation()
        );

        editor.putString("auth_token", auth_token);
        editor.putBoolean("newuser", false);
        editor.apply();

        Fragment fragment = new FeedFragment();

        FragmentManager fragmentManager = getFragmentManager();
        fragmentManager.beginTransaction().replace(R.id.content_frame, fragment).commit();

    }

    protected synchronized void buildGoogleApiClient() {
        mGoogleApiClient = new GoogleApiClient.Builder(this)
                .addConnectionCallbacks(this)
                .addOnConnectionFailedListener(this)
                .addApi(LocationServices.API)
                .build();
    }

    @Override
    protected void onStart() {
        super.onStart();
        mGoogleApiClient.connect();
    }

    @Override
    protected void onStop() {
        super.onStop();
        if (mGoogleApiClient.isConnected()) {
            mGoogleApiClient.disconnect();
        }
    }

    public String getLocation(){
        if(mLastLocation != null)
            return mLastLocation.getLatitude() + ", " + mLastLocation.getLongitude();
        else
            return "32, 32";
    }

    @Override
    public void onConnected(Bundle bundle) {

        mLastLocation = LocationServices.FusedLocationApi.getLastLocation(mGoogleApiClient);

    }

    @Override
    public void onConnectionSuspended(int i) {

    }

    @Override
    public void onConnectionFailed(ConnectionResult connectionResult) {

    }


    public void addUserInfoToPreferences(JSONObject object){
        try{

            SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(getApplicationContext());
            SharedPreferences.Editor editor = preferences.edit();
            editor.putString("email", object.getString("email"));
            editor.putString("gender", object.getString("gender"));
            editor.putString("username", "");
            editor.putString("name", Profile.getCurrentProfile().getName());
            editor.putString("userID", Profile.getCurrentProfile().getId());
            editor.putString("locale", object.getString("locale"));
            editor.putString("first_name", Profile.getCurrentProfile().getFirstName());
            editor.putString("last_name", Profile.getCurrentProfile().getLastName());
            editor.apply();
        }
        catch(Exception e){
            Log.v("testt", e.getMessage());
        }
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        //mDrawerToggle.onConfigurationChanged(newConfig);
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_home, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement

//        if (mDrawerToggle.onOptionsItemSelected(item)) {
//            return true;
//        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onFragmentInteraction(String id) {

    }

    @Override
    public void OnCardSelected(FeedItem item) {
        this.item = item;
//        getFragmentManager().beginTransaction().replace(R.id.content_frame,
//                new ItemPage(), "frag").addToBackStack(null)
//                .setTransition(R.anim.abc_slide_in_bottom).commit();
        //ItemPage itempage = (ItemPage) getFragmentManager().findFragmentByTag("frag");
        //itempage.setItem(item);

    }

    private class DrawerItemClickListener implements ListView.OnItemClickListener{
        @Override
        public void onItemClick(AdapterView parent, View view, int position, long id){


            //TODO: put this code in a separate class so that it can be called from anywhere
            //TODO: don't re-launch home activity if already in there

            switch(position){
                case 0:
                    getFragmentManager().beginTransaction().replace(R.id.content_frame,
                            new FeedFragment()).addToBackStack(null).
                            setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE).commit();
                    break;
                case 1:
                    getFragmentManager().beginTransaction().replace(R.id.content_frame,
                            new SellersGarage()).addToBackStack(null).
                            setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE).commit();
                    break;
                case 2:
                    getFragmentManager().beginTransaction().replace(R.id.content_frame,
                            new BuyersTrunk()).addToBackStack(null).
                            setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE).commit();
                    invalidateOptionsMenu();
                    break;
                case 3:
                    getFragmentManager().beginTransaction().replace(R.id.content_frame,
                            new HoldingPattern()).addToBackStack(null).
                            setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE).commit();
                    break;
                case 4:
//                    new ServerCalls(getApplicationContext()).getFeedItems(
//                            preferences.getString("auth_token", "0"),
//                            "999999999",
//                            "100",
//                            "",
//                            "32,32",
//                            "",
//                            preferences.getString("uuid", "0")
//                        );
                    //startActivity(new Intent(getApplicationContext(), FeedFilter.class));
                    break;
                case 5:
                    //startActivity(new Intent(getApplicationContext(), BakkleSettings.class));
                    break;
                case 6:
                    //startActivity(new Intent(getApplicationContext(), DemoOptions.class));
                    getFragmentManager().beginTransaction().replace(R.id.content_frame,
                            new DemoOptions()).addToBackStack(null)
                            .setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE).commit();
                    break;
                case 7:
                    //startActivity(new Intent(getApplicationContext(), Logout.class));
                    FacebookSdk.sdkInitialize(getApplicationContext());
                    LoginManager.getInstance().logOut();
                    editor.putBoolean("LoggedIn", false);
                    editor.putBoolean("newuser", true);
                    editor.apply();
                    startActivity(new Intent(getApplicationContext(), LoginActivity.class));
                    finish();
                    break;
                default:
                    break;
            }
        }
    }

    public void addItem(View view)
    {
        Intent intent = new Intent(this, AddItem.class);
        startActivity(intent);
    }

    public void launchSettings(View view)
    {
        return;
    }



    @Override
    public void onBackPressed() {
        if(getFragmentManager().getBackStackEntryCount() > 0)
            getFragmentManager().popBackStackImmediate();
        else {
            Intent intent = new Intent(Intent.ACTION_MAIN);
            intent.addCategory(Intent.CATEGORY_HOME);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
        }
    }
    public void reset(View view){
        serverCalls.resetDemo(preferences.getString("auth_token", "0"), preferences.getString("uuid", "0"));
    }

}