package com.bakkle.bakkle.Activities;

import android.app.FragmentTransaction;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.content.res.TypedArray;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.bakkle.bakkle.Fragments.BuyersTrunkFragment;
import com.bakkle.bakkle.Fragments.DemoOptionsFragment;
import com.bakkle.bakkle.Fragments.FeedFragment;
import com.bakkle.bakkle.Fragments.HoldingPatternFragment;
import com.bakkle.bakkle.Fragments.ProfileFragment;
import com.bakkle.bakkle.Fragments.RefineFragment;
import com.bakkle.bakkle.Fragments.SellersGarageFragment;
import com.bakkle.bakkle.Fragments.SplashFragment;
import com.bakkle.bakkle.Helpers.FeedItem;
import com.bakkle.bakkle.Helpers.ServerCalls;
import com.bakkle.bakkle.R;
import com.bumptech.glide.Glide;
import com.facebook.AccessToken;
import com.facebook.GraphRequest;
import com.facebook.GraphResponse;
import com.mikepenz.materialdrawer.Drawer;
import com.mikepenz.materialdrawer.DrawerBuilder;
import com.mikepenz.materialdrawer.accountswitcher.AccountHeader;
import com.mikepenz.materialdrawer.accountswitcher.AccountHeaderBuilder;
import com.mikepenz.materialdrawer.model.PrimaryDrawerItem;
import com.mikepenz.materialdrawer.model.ProfileDrawerItem;
import com.mikepenz.materialdrawer.model.interfaces.IDrawerItem;
import com.mikepenz.materialdrawer.model.interfaces.IProfile;
import com.mikepenz.materialdrawer.util.DrawerImageLoader;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;


public class HomeActivity extends AppCompatActivity implements SellersGarageFragment.OnFragmentInteractionListener,
        BuyersTrunkFragment.OnFragmentInteractionListener, HoldingPatternFragment.OnFragmentInteractionListener,
        RefineFragment.OnFragmentInteractionListener, SplashFragment.OnFragmentInteractionListener
{
    private ArrayList<String> mDrawerItems;
    private TypedArray mDrawerIcons;
    private Toolbar toolbar;

    FeedItem item;

    Drawer drawer = null;

    SharedPreferences preferences;
    SharedPreferences.Editor editor;
    LinearLayout linearLayout;
    ServerCalls serverCalls;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);
        linearLayout = (LinearLayout) findViewById(R.id.content_frame_holder);
        preferences = PreferenceManager.getDefaultSharedPreferences(getApplicationContext());
        editor = preferences.edit();
        toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        mDrawerItems = new ArrayList<String>(Arrays.asList(getResources().getStringArray(R.array.drawer_items)));
        mDrawerIcons = getResources().obtainTypedArray(R.array.drawer_icons);

        DrawerImageLoader.init(new DrawerImageLoader.IDrawerImageLoader()
        {
            @Override
            public void set(ImageView imageView, Uri uri, Drawable placeholder)
            {
                Glide.with(HomeActivity.this)
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
                        new ProfileDrawerItem().withName(preferences.getString("name", "Not Signed In")).withIcon("http://graph.facebook.com/" + preferences.getString("userID", "0") + "/picture?width=300&height=300")
                )
                .withProfileImagesClickable(true)
                .withProfileImagesVisible(true)
                .withOnAccountHeaderSelectionViewClickListener(new onAccountHeaderSelectionViewClickListener())
                .withSavedInstance(savedInstanceState)
                .build();

//        headerResult.getHeaderBackgroundView().getLayoutParams().height += 50;
//        headerResult.getHeaderBackgroundView().getLayoutParams().width += 50;

        //TODO: make picture in nav drawer bigger


        drawer = new DrawerBuilder()
                .withActivity(this)
                .withToolbar(toolbar)
                .withSavedInstance(savedInstanceState)
                .withAccountHeader(headerResult)
                .withActionBarDrawerToggle(true)
                .withActionBarDrawerToggleAnimated(true)
                .addDrawerItems(
                        new PrimaryDrawerItem().withName(mDrawerItems.get(0)).withIcon(mDrawerIcons.getDrawable(0)),
                        new PrimaryDrawerItem().withName(mDrawerItems.get(1)).withIcon(mDrawerIcons.getDrawable(1)),
                        new PrimaryDrawerItem().withName(mDrawerItems.get(2)).withIcon(mDrawerIcons.getDrawable(2)),
                        new PrimaryDrawerItem().withName(mDrawerItems.get(3)).withIcon(mDrawerIcons.getDrawable(3)),
                        new PrimaryDrawerItem().withName(mDrawerItems.get(4)).withIcon(mDrawerIcons.getDrawable(4))
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
                                        new HoldingPatternFragment()).addToBackStack(null).
                                        setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE).commit();
                                break;
                            case 4:
                                //startActivity(new Intent(getApplicationContext(), DemoOptionsFragment.class));
                                getFragmentManager().beginTransaction().replace(R.id.content_frame,
                                        new DemoOptionsFragment()).addToBackStack(null)
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


        serverCalls = new ServerCalls(this);

        new Login().execute();
    }

    @Override
    protected void onPostCreate(Bundle savedInstanceState)
    {
        super.onPostCreate(savedInstanceState);
    }


    public String getLocation()
    {
        return preferences.getString("location", "0, 0");
    }


    public void addUserInfoToPreferences(JSONObject object)
    {
        try {
            Log.v("the fb object is", object.toString());
            editor.putString("email", object.getString("email"));
            editor.putString("gender", object.getString("gender"));
            editor.putString("username", "");
            editor.putString("name", object.getString("name"));
            editor.putString("userID", object.getString("id"));
            editor.putString("locale", object.getString("locale"));
            editor.putString("first_name", object.getString("first_name"));
            editor.putString("last_name", object.getString("last_name"));
            editor.apply();
        }
        catch (Exception e) {
            Log.v("testt", e.getMessage());
        }
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig)
    {
        super.onConfigurationChanged(newConfig);
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
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement

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

    public void addItem(MenuItem item)
    {
        Intent intent = new Intent(this, AddItemActivity.class);
        startActivity(intent);
    }

    public void launchSettings(View view)
    {
        return;
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

    public void reset(View view)
    {
        serverCalls.resetDemo(preferences.getString("auth_token", ""), preferences.getString("uuid", ""));
    }

    public void hideSoftKeyBoard()
    {
        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);

        if (imm.isAcceptingText()) { // verify if the soft keyboard is open
            imm.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), 0);
        }
    }

    private class onAccountHeaderSelectionViewClickListener implements AccountHeader.OnAccountHeaderSelectionViewClickListener
    {
        @Override
        public boolean onClick(View view, IProfile iProfile)
        {
            getFragmentManager().beginTransaction().replace(R.id.content_frame,
                    new ProfileFragment()).addToBackStack(null).
                    setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE).commit();

            drawer.closeDrawer();
            return true;
        }
    }

    private class Login extends AsyncTask<Void, Void, Void>
    {
        @Override
        protected void onPreExecute()
        {

        }

        @Override
        protected Void doInBackground(Void... voids)
        {
            if (preferences.getBoolean("newuser", true)) {
                Log.v("new user", "true");
                GraphRequest request = GraphRequest.newMeRequest(AccessToken.getCurrentAccessToken(),
                        new GraphRequest.GraphJSONObjectCallback()
                        {
                            @Override
                            public void onCompleted(JSONObject object, GraphResponse response)
                            {
                                addUserInfoToPreferences(object);
//                    result = serverCalls.registerFacebook(
//                            preferences.getString("email", "null"),
//                            preferences.getString("gender", "null"),
//                            preferences.getString("username", "null"),
//                            preferences.getString("name", "null"),
//                            preferences.getString("userId", "null"),
//                            preferences.getString("locale", "null"),
//                            preferences.getString("first_name", "null"),
//                            preferences.getString("last_name", "null"),
//                            preferences.getString("uuid", "0"));
//                    editor.putBoolean("done", true);
//                    editor.apply();
                            }
                        });

                Bundle parameters = new Bundle();
                parameters.putString("fields", "locale, email, gender");
                //request.executeAsync();
                addUserInfoToPreferences(request.executeAndWait().getJSONObject());
//            if(result == 1)
//                Toast.makeText(this, "Logged in successfully!", Toast.LENGTH_SHORT).show();
//            else //TODO:Display error on fail? and go back to login screen
//                Toast.makeText(this, "Login error!!", Toast.LENGTH_SHORT).show();

            }

            Log.d("testing", preferences.getString("uuid", "0"));
            Log.d("testing", preferences.getString("userID", "0"));
            if (preferences.getBoolean("newuser", true) ||
                    preferences.getString("auth_token", "0").equals("0") ||
                    preferences.getString("userID", "0").equals("0")) {

                String auth_token = serverCalls.loginFacebook(
                        preferences.getString("uuid", "0"),
                        preferences.getString("userID", "0"),
                        getLocation()
                );
                editor.putString("auth_token", auth_token);
                editor.putBoolean("newuser", false);
                editor.apply();
            }

            return null;
        }

        @Override
        protected void onPostExecute(Void voids)
        {
            getFragmentManager().beginTransaction().replace(R.id.content_frame,
                    new FeedFragment()).commitAllowingStateLoss();
        }


    }


}