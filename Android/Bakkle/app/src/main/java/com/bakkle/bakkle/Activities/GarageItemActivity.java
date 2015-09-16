package com.bakkle.bakkle.Activities;

import android.content.Intent;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;

import com.bakkle.bakkle.Adapters.ViewPagerAdapter;
import com.bakkle.bakkle.Helpers.Constants;
import com.bakkle.bakkle.Helpers.FeedItem;
import com.bakkle.bakkle.R;
import com.bakkle.bakkle.Views.SlidingTabLayout;

import java.util.ArrayList;

public class GarageItemActivity extends AppCompatActivity
{
    Toolbar toolbar;
    ViewPager pager;
    ViewPagerAdapter adapter;
    SlidingTabLayout tabs;
    FeedItem item;
    CharSequence Titles[] = {"Messages", "Analytics"};
    int numTabs = 2;
    
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        String itemId;
        String numWant;
        String numHold;
        String numMeh;
        String numView;
        String title, price, description, seller, distance, pk, sellerImageUrl;
        ArrayList<String> imageURLs;

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_garage_item);
        toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        final Drawable upArrow = getResources().getDrawable(R.drawable.abc_ic_ab_back_mtrl_am_alpha);
        upArrow.setColorFilter(getResources().getColor(R.color.white), PorterDuff.Mode.SRC_ATOP);
        getSupportActionBar().setHomeAsUpIndicator(upArrow);
        toolbar.setNavigationOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                onBackPressed();
            }
        });
        Intent i = getIntent();
        itemId = i.getStringExtra(Constants.ITEM_ID);
        numWant = i.getStringExtra(Constants.NUM_WANT);
        numHold = i.getStringExtra(Constants.NUM_HOLD);
        numMeh = i.getStringExtra(Constants.NUM_MEH);
        numView = i.getStringExtra(Constants.NUM_VIEW);
        title = i.getStringExtra(Constants.TITLE);
        price = i.getStringExtra(Constants.PRICE);
        description = i.getStringExtra(Constants.DESCRIPTION);
        seller = i.getStringExtra(Constants.SELLER);
        distance = i.getStringExtra(Constants.DISTANCE);
        pk = i.getStringExtra(Constants.PK);
        sellerImageUrl = i.getStringExtra(Constants.SELLER_IMAGE_URL);
        imageURLs = i.getStringArrayListExtra(Constants.IMAGE_URLS);
        //item = new Gson().fromJson(i.getStringExtra("item"), FeedItem.class);
        adapter = new ViewPagerAdapter(getSupportFragmentManager(), Titles, numTabs, itemId,
                numView, numWant, numHold, numMeh, title, price, description, seller, distance,
                pk, sellerImageUrl, imageURLs);
        pager = (ViewPager) findViewById(R.id.pager);
        pager.setAdapter(adapter);
        tabs = (SlidingTabLayout) findViewById(R.id.tabs);
        tabs.setDistributeEvenly(true);
        tabs.setCustomTabColorizer(new SlidingTabLayout.TabColorizer()
        {
            @Override
            public int getIndicatorColor(int position)
            {
                return getResources().getColor(R.color.white);
            }
        });

        tabs.setViewPager(pager);
    }
    
    @Override
    public boolean onCreateOptionsMenu(Menu menu)
    {
        // Inflate the menu; this adds items to the action bar if it is present.
//        getMenuInflater().inflate(R.menu.menu_garage_item, menu);
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
//        if (id == R.id.action_settings) {
//            return true;
//        }
        
        return super.onOptionsItemSelected(item);
    }

    public Toolbar getToolbar()
    {
        return toolbar;
    }
}
