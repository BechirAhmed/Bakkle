package com.bakkle.bakkle;

import android.app.ActionBar;
import android.app.Activity;
import android.app.Fragment;
import android.app.FragmentManager;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.content.res.TypedArray;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.Arrays;


public class HomeActivity extends Activity {
    private DrawerLayout mDrawerLayout;
    private ListView mDrawerList;
    private DrawerRowAdapter mDrawerAdapter;
    private ArrayList<String> mDrawerItems;
    private TypedArray mDrawerIcons;
    private ActionBarDrawerToggle mDrawerToggle;
    private ActionBar mActionBar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(getApplicationContext());
        SharedPreferences.Editor editor = preferences.edit();

        preferences.getString("userID", "0");

        Toast.makeText(this, preferences.getString("userID", "NOT LOGGED IN"), Toast.LENGTH_SHORT).show();

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

        mDrawerToggle = new ActionBarDrawerToggle(this, mDrawerLayout,
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


//        ActivityManager activityManager = (ActivityManager) getSystemService(ACTIVITY_SERVICE);
//        List<ActivityManager.RunningTaskInfo> taskInfo = activityManager.getRunningTasks(1);
//        ComponentName currentActivity = taskInfo.get(0).topActivity;



        return super.onOptionsItemSelected(item);
    }

    private class DrawerItemClickListener implements ListView.OnItemClickListener{
        @Override
        public void onItemClick(AdapterView parent, View view, int position, long id){


            //TODO: put this code in a separate class so that it can be called from anywhere
            //TODO: don't re-launch home activity if already in there

            switch(position){
                case 0:
                    //if(){}
                    startActivity(new Intent(getApplicationContext(), HomeActivity.class));
                    break;
                case 1:
                    //startActivity(new Intent(getApplicationContext(), SellersGarage.class));
                    break;
                case 2:
                    startActivity(new Intent(getApplicationContext(), BuyersTrunk.class));
                    break;
                case 3:
                    //startActivity(new Intent(getApplicationContext(), HoldingPattern.class));
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
                    break;
                default:
                    break;
            }
        }
    }

}
