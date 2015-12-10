package com.bakkle.bakkle.Activities;

import android.app.FragmentTransaction;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.TypedArray;
import android.graphics.drawable.Drawable;
import android.location.Location;
import android.net.Uri;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.provider.Settings;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.bakkle.bakkle.Fragments.BuyersTrunkFragment;
import com.bakkle.bakkle.Fragments.FeedFragment;
import com.bakkle.bakkle.Fragments.ProfileFragment;
import com.bakkle.bakkle.Fragments.RefineFragment;
import com.bakkle.bakkle.Fragments.SellersGarageFragment;
import com.bakkle.bakkle.Fragments.SplashFragment;
import com.bakkle.bakkle.Fragments.WatchListFragment;
import com.bakkle.bakkle.Helpers.Constants;
import com.bakkle.bakkle.Helpers.ServerCalls;
import com.bakkle.bakkle.R;
import com.bumptech.glide.Glide;
import com.mikepenz.materialdrawer.Drawer;
import com.mikepenz.materialdrawer.DrawerBuilder;
import com.mikepenz.materialdrawer.accountswitcher.AccountHeader;
import com.mikepenz.materialdrawer.accountswitcher.AccountHeaderBuilder;
import com.mikepenz.materialdrawer.model.PrimaryDrawerItem;
import com.mikepenz.materialdrawer.model.ProfileDrawerItem;
import com.mikepenz.materialdrawer.model.interfaces.IDrawerItem;
import com.mikepenz.materialdrawer.model.interfaces.IProfile;
import com.mikepenz.materialdrawer.util.DrawerImageLoader;

import java.util.ArrayList;
import java.util.Arrays;

import io.nlopez.smartlocation.OnLocationUpdatedListener;
import io.nlopez.smartlocation.SmartLocation;


public class MainActivity extends AppCompatActivity implements SellersGarageFragment.OnFragmentInteractionListener,
        BuyersTrunkFragment.OnFragmentInteractionListener, WatchListFragment.OnFragmentInteractionListener,
        RefineFragment.OnFragmentInteractionListener, SplashFragment.OnFragmentInteractionListener
{
    private Toolbar toolbar;
    AlertDialog.Builder builder;
    AlertDialog         dialog;

    Drawer drawer;

    SharedPreferences        preferences;
    SharedPreferences.Editor editor;
    LinearLayout             linearLayout;
    ServerCalls              serverCalls;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        linearLayout = (LinearLayout) findViewById(R.id.content_frame_holder);
        preferences = PreferenceManager.getDefaultSharedPreferences(getApplicationContext());
        editor = preferences.edit();
        toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        setupNavDrawer();
        serverCalls = new ServerCalls(this);

        if (!SmartLocation.with(this).location().state().locationServicesEnabled()) {
            showGpsDialog();
        }
        else {
            saveLocationToPreferences();
        }
        if (!preferences.contains(Constants.UUID)) {
            editor.putString(Constants.UUID, Settings.Secure.getString(getApplicationContext().getContentResolver(), Settings.Secure.ANDROID_ID));
            editor.apply();
        }
        if (preferences.getBoolean(Constants.AUTHENTICATED, false)) {

            getFragmentManager().beginTransaction().replace(R.id.content_frame,
                    FeedFragment.newInstance(false)).commit();
            //SmartLocation.with(this).location().stop();
        }
        else {
            editor.putString(Constants.USERNAME, "Guest User");
            editor.putString(Constants.NAME, "Guest User");
            editor.putString(Constants.USER_ID, serverCalls.getGuestUserId(preferences.getString(Constants.UUID, "")));
            editor.putString(Constants.FIRST_NAME, "Guest");
            editor.putString(Constants.LAST_NAME, "User");
            editor.apply();

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

            String auth_token =
                    serverCalls.loginFacebook(
                            preferences.getString(Constants.UUID, ""),
                            preferences.getString(Constants.USER_ID, ""),
                            getLocation()
                    );
            editor.putString(Constants.AUTH_TOKEN, auth_token);
            editor.putBoolean(Constants.AUTHENTICATED, true);
            editor.putBoolean(Constants.NEW_USER, false);
            editor.apply();

            getFragmentManager().beginTransaction().replace(R.id.content_frame,
                    FeedFragment.newInstance(true)).commit();
        }

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//        if (preferences.getBoolean(Constants.NEW_USER, true)) {
//            Log.v("new user", "true");
//            GraphRequest request = GraphRequest.newMeRequest(AccessToken.getCurrentAccessToken(),
//                    new GraphRequest.GraphJSONObjectCallback()
//                    {
//                        @Override
//                        public void onCompleted(JSONObject object, GraphResponse response)
//                        {
//                            addUserInfoToPreferences(object);
//                            Log.d("testing", preferences.getString(Constants.UUID, "0"));
//                            Log.d("testing", preferences.getString(Constants.USER_ID, "0"));
//
//                            serverCalls.registerFacebook(
//                                    preferences.getString(Constants.EMAIL, ""),
//                                    preferences.getString(Constants.GENDER, ""),
//                                    preferences.getString(Constants.USERNAME, ""),
//                                    preferences.getString(Constants.NAME, ""),
//                                    preferences.getString(Constants.USER_ID, ""),
//                                    preferences.getString(Constants.LOCALE, ""),
//                                    preferences.getString(Constants.FIRST_NAME, ""),
//                                    preferences.getString(Constants.LAST_NAME, ""),
//                                    preferences.getString(Constants.UUID, ""));
//
//                            String auth_token = serverCalls.loginFacebook(
//                                    preferences.getString(Constants.UUID, "0"),
//                                    preferences.getString(Constants.USER_ID, "0"),
//                                    getLocation()
//                            );
//                            editor.putString(Constants.AUTH_TOKEN, auth_token);
//                            editor.putBoolean(Constants.NEW_USER, false);
//                            editor.apply();
//
//                            getFragmentManager().beginTransaction().replace(R.id.content_frame,
//                                    FeedFragment.newInstance(true)).commit();
//                        }
//                    });
//
//            Bundle parameters = new Bundle();
//            parameters.putString("fields", "locale, email, gender");
//            //request.executeAsync();
//            StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
//
//            StrictMode.setThreadPolicy(policy);
//            addUserInfoToPreferences(request.executeAndWait().getJSONObject());
////            if(result == 1)
////                Toast.makeText(this, "Logged in successfully!", Toast.LENGTH_SHORT).show();
////            else //TODO:Display error on fail? and go back to login screen
////                Toast.makeText(this, "Login error!!", Toast.LENGTH_SHORT).show();
//
//        }

    }

    private void saveLocationToPreferences()
    {
        SmartLocation.with(this).location()
                .oneFix()
                .start(new OnLocationUpdatedListener()
                {
                    @Override
                    public void onLocationUpdated(Location location)
                    {
                        editor.putString(Constants.LOCATION, location.getLatitude() + "," + location.getLongitude());
                        editor.putString(Constants.LATITUDE, String.valueOf(location.getLatitude()));
                        editor.putString(Constants.LONGITUDE, String.valueOf(location.getLongitude()));
                        editor.apply();
                    }
                });
    }

    private void showGpsDialog()
    {
        builder = new AlertDialog.Builder(this);
        builder.setTitle("GPS not found");  // GPS not found
        builder.setMessage("In order for Bakkle to function properly, Location Services need to be enabled. Would like to enable them now?"); // Want to enable?
        builder.setPositiveButton("Yes", new DialogInterface.OnClickListener()
        {
            public void onClick(DialogInterface dialogInterface, int i)
            {
                startActivity(new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS));
            }
        });
        builder.setCancelable(false);
        builder.setNegativeButton("Not right now", null);
        dialog = builder.create();
        dialog.show();
    }


    public String getLocation()
    {
        return preferences.getString(Constants.LOCATION, "0,0");
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu)
    {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_home, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        switch (item.getItemId()) {
            case R.id.addItem:
                if (preferences.getBoolean(Constants.NEW_USER, true)) {
                    startActivity(new Intent(this, SignupActivity.class));
                }
                if (!preferences.getBoolean(Constants.NEW_USER, true)) {
                    startActivity(new Intent(this, AddItemActivity.class));
                }
                break;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onFragmentInteraction(String id)
    {

    }

    @Override
    public void onFragmentInteraction(Uri uri)
    {

    }

    public void refineButtonClick(View view)
    {
        getFragmentManager().beginTransaction().replace(R.id.content_frame,
                new RefineFragment()).addToBackStack(null)
                .setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE).commit();

    }


    @Override
    public void onBackPressed()
    {
        if (getFragmentManager().getBackStackEntryCount() > 0)
            getFragmentManager().popBackStackImmediate();
        else {
            Intent intent = new Intent(Intent.ACTION_MAIN);
            intent.addCategory(Intent.CATEGORY_HOME);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
        }
    }

    public void setupNavDrawer()
    {
        ArrayList<String> mDrawerItems = new ArrayList<>(Arrays.asList(getResources().getStringArray(R.array.drawer_items)));
        TypedArray mDrawerIcons = getResources().obtainTypedArray(R.array.drawer_icons);

        DrawerImageLoader.init(new DrawerImageLoader.IDrawerImageLoader()
        {
            @Override
            public void set(ImageView imageView, Uri uri, Drawable placeholder)
            {
                Glide.with(MainActivity.this)
                        .load(uri.toString())
                        .into(imageView);
            }

            @Override
            public void cancel(ImageView imageView)
            {
            }

            @Override
            public Drawable placeholder(Context ctx)
            {
                return null;
            }
        });


        AccountHeader headerResult = new AccountHeaderBuilder()
                .withActivity(this)
                .withCompactStyle(true)
                .withHeaderBackground(R.color.gray)
                .withSelectionListEnabled(false)
                .addProfiles(
                        new ProfileDrawerItem().withName(preferences.getString(Constants.NAME, "Guest User")).withIcon("http://graph.facebook.com/" + preferences.getString("userID", "") + "/picture?width=300&height=300")
                )
                .withProfileImagesClickable(true)
                .withProfileImagesVisible(true)
                .withOnAccountHeaderSelectionViewClickListener(new AccountHeader.OnAccountHeaderSelectionViewClickListener()
                {
                    @Override
                    public boolean onClick(View view, IProfile profile)
                    {
                        getFragmentManager().beginTransaction().replace(R.id.content_frame,
                                new ProfileFragment()).addToBackStack(null).
                                setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE).commit();

                        drawer.closeDrawer();
                        return true;
                    }
                })
                .build();
        //TODO: make picture in nav drawer bigger


        drawer = new DrawerBuilder()
                .withActivity(this)
                .withToolbar(toolbar)
                .withAccountHeader(headerResult)
                .withActionBarDrawerToggle(true)
                .withActionBarDrawerToggleAnimated(true)
                .withSelectedItem(0)
                .addDrawerItems(
                        new PrimaryDrawerItem().withName(mDrawerItems.get(0)).withIcon(mDrawerIcons.getDrawable(0)),
                        new PrimaryDrawerItem().withName(mDrawerItems.get(1)).withIcon(mDrawerIcons.getDrawable(1)),
                        new PrimaryDrawerItem().withName(mDrawerItems.get(2)).withIcon(mDrawerIcons.getDrawable(2)),
                        new PrimaryDrawerItem().withName(mDrawerItems.get(3)).withIcon(mDrawerIcons.getDrawable(3))
                )
                .withTranslucentStatusBar(false)
                .withOnDrawerItemClickListener(new Drawer.OnDrawerItemClickListener()
                {
                    @Override
                    public boolean onItemClick(AdapterView<?> parent, View view, int position, long id, IDrawerItem drawerItem)
                    {
                        switch (position) {
                            case 0:
                                getFragmentManager().beginTransaction().replace(R.id.content_frame,
                                        new FeedFragment()).addToBackStack(null).
                                        setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE).commit();
                                break;
                            case 1:
                                getFragmentManager().beginTransaction().replace(R.id.content_frame,
                                        new SellersGarageFragment()).addToBackStack(null).
                                        setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE).commit();
                                break;
                            case 2:
                                getFragmentManager().beginTransaction().replace(R.id.content_frame,
                                        new BuyersTrunkFragment()).addToBackStack(null).
                                        setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE).commit();
                                invalidateOptionsMenu();
                                break;
                            case 3:
                                getFragmentManager().beginTransaction().replace(R.id.content_frame,
                                        new WatchListFragment()).addToBackStack(null).
                                        setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE).commit();
                                invalidateOptionsMenu();
                                break;
                            default:
                                Toast.makeText(getParent(), "Error", Toast.LENGTH_SHORT).show();
                                break;
                        }

                        return false;
                    }
                })
                .build();
        mDrawerIcons.recycle();
    }

    public void hideSoftKeyBoard()
    {
        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);

        if (imm.isAcceptingText() && getCurrentFocus() != null) { // verify if the soft keyboard is open
            imm.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), 0);
        }
    }
}