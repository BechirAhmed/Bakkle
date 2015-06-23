package com.bakkle.bakkle;

import android.app.ActionBar;
import android.app.Activity;
import android.app.Fragment;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.content.res.TypedArray;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.util.Log;
import android.view.LayoutInflater;
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

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;


public class HomeActivity extends Activity implements SellersGarage.OnFragmentInteractionListener,
        BuyersTrunk.OnFragmentInteractionListener, HoldingPattern.OnFragmentInteractionListener {


    private DrawerLayout mDrawerLayout;
    private ListView mDrawerList;
    private DrawerRowAdapter mDrawerAdapter;
    private ArrayList<String> mDrawerItems;
    private TypedArray mDrawerIcons;
    private ActionBarDrawerToggle mDrawerToggle;
    private ActionBar mActionBar;

    SharedPreferences.Editor editor;
    SharedPreferences preferences;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);
        preferences = PreferenceManager.getDefaultSharedPreferences(getApplicationContext());
        editor = preferences.edit();

        // Setup drawer
        mDrawerItems = new ArrayList<String>(Arrays.asList(getResources().getStringArray(R.array.drawer_items)));
        mDrawerIcons = getResources().obtainTypedArray(R.array.drawer_icons);
        mDrawerLayout = (DrawerLayout) findViewById(R.id.drawer_layout);
        mDrawerList = (ListView) findViewById(R.id.left_drawer);

        // Set the adapter for the list view
        mDrawerAdapter = new DrawerRowAdapter(this, mDrawerItems, mDrawerIcons);
        mDrawerList.setAdapter(mDrawerAdapter);
        // Set the list's click listener
        mDrawerList.setOnItemClickListener(new DrawerItemClickListener());

        mDrawerToggle = new ActionBarDrawerToggle(this, mDrawerLayout, /*R.drawable.ic_drawer,*/
                R.string.drawer_open, R.string.drawer_close) {

            /** Called when a drawer has settled in a completely closed state. */
            public void onDrawerClosed(View view) {
                super.onDrawerClosed(view);
                getActionBar().setTitle(getTitle());
                getActionBar().setBackgroundDrawable(new ColorDrawable(getResources().getColor(R.color.green)));
                invalidateOptionsMenu(); // creates call to onPrepareOptionsMenu()
            }

            /** Called when a drawer has settled in a completely open state. */
            public void onDrawerOpened(View drawerView) {
                super.onDrawerOpened(drawerView);
                getActionBar().setBackgroundDrawable(new ColorDrawable(getResources().getColor(R.color.brown)));
                getActionBar().setTitle(getString(R.string.drawer_title));
                invalidateOptionsMenu(); // creates call to onPrepareOptionsMenu()
            }
        };

        // Set the drawer toggle as the DrawerListener
        mDrawerLayout.setDrawerListener(mDrawerToggle);


        // Custom Action bar
        mActionBar = getActionBar();
        mActionBar.setDisplayShowHomeEnabled(false);
        mActionBar.setDisplayShowTitleEnabled(false);
        LayoutInflater mInflater = LayoutInflater.from(this);

        View mCustomView = mInflater.inflate(R.layout.action_bar_image, null);

        mActionBar.setCustomView(mCustomView);
        mActionBar.setDisplayShowCustomEnabled(true);

        Fragment fragment = new FeedFragment();

        FragmentManager fragmentManager = getFragmentManager();
        fragmentManager.beginTransaction().replace(R.id.content_frame, fragment).commit();

    }

    @Override
    protected void onPostCreate(Bundle savedInstanceState) {
        super.onPostCreate(savedInstanceState);
        // Sync the toggle state after onRestoreInstanceState has occurred.
        mDrawerToggle.syncState();

        if(preferences.getBoolean("newuser", true)){
            GraphRequest request = GraphRequest.newMeRequest(AccessToken.getCurrentAccessToken(),
                    new GraphRequest.GraphJSONObjectCallback(){
                @Override
                public void onCompleted(JSONObject object, GraphResponse response) {
                    addUserInfoToPreferences(object);
                }
            });

            Bundle parameters = new Bundle();
            parameters.putString("fields", "locale, email, gender");
            request.executeAsync();

            String testresult = new ServerCalls(this).loginFacebook(
                    preferences.getString("email", "null"),
                    preferences.getString("gender", "null"),
                    preferences.getString("username", "null"),
                    preferences.getString("name", "null"),
                    preferences.getString("userID", "null"),
                    preferences.getString("locale", "null"),
                    preferences.getString("first_name", "null"),
                    preferences.getString("last_name", "null"));
            /*

            String email = preferences.getString("email", "null");
            String gender = preferences.getString("gender", "null");
            String username = preferences.getString("username", "null");
            String name = preferences.getString("name", "null");
            String userid = preferences.getString("userID", "null");
            String locale = preferences.getString("locale", "null");
            String first_name = preferences.getString("first_name", "null");
            String last_name = preferences.getString("last_name", "null");

            */

            Toast.makeText(this, testresult, Toast.LENGTH_SHORT).show();
        }


        editor.putBoolean("newuser", false);
        editor.apply();
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
            Log.d("debug", e.getMessage());
        }
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        mDrawerToggle.onConfigurationChanged(newConfig);
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

        if (mDrawerToggle.onOptionsItemSelected(item)) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onFragmentInteraction(String id) {

    }

    private class DrawerItemClickListener implements ListView.OnItemClickListener{
        @Override
        public void onItemClick(AdapterView parent, View view, int position, long id){


            //TODO: put this code in a separate class so that it can be called from anywhere
            //TODO: don't re-launch home activity if already in there

            switch(position){
                case 0:
                    //if(){}
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
                    break;
                case 3:
                    getFragmentManager().beginTransaction().replace(R.id.content_frame,
                            new HoldingPattern()).addToBackStack(null).
                            setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE).commit();
                    break;
                case 4:
                    //startActivity(new Intent(getApplicationContext(), FeedFilter.class));
                    break;
                case 5:
                    //startActivity(new Intent(getApplicationContext(), BakkleSettings.class));
                    break;
                case 6:
                    //startActivity(new Intent(getApplicationContext(), DemoOptions.class));
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



    @Override
    public void onBackPressed() {
        Intent intent = new Intent(Intent.ACTION_MAIN);
        intent.addCategory(Intent.CATEGORY_HOME);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
    }

}