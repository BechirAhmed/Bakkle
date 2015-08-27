package com.bakkle.bakkle.Activities;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;

import com.bakkle.bakkle.Adapters.ViewPagerAdapter;
import com.bakkle.bakkle.Helpers.FeedItem;
import com.bakkle.bakkle.R;
import com.bakkle.bakkle.Views.SlidingTabLayout;
import com.google.gson.Gson;

import java.util.ArrayList;

public class GarageItem extends AppCompatActivity
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
        Intent i = getIntent();
        itemId = i.getStringExtra("itemId");
        numWant = i.getStringExtra("numWant");
        numHold = i.getStringExtra("numHold");
        numMeh = i.getStringExtra("numMeh");
        numView = i.getStringExtra("numView");
        title = i.getStringExtra("title");
        price = i.getStringExtra("price");
        description = i.getStringExtra("description");
        seller = i.getStringExtra("seller");
        distance = i.getStringExtra("distance");
        pk = i.getStringExtra("pk");
        sellerImageUrl = i.getStringExtra("sellerImageUrl");
        imageURLs = i.getStringArrayListExtra("imageURLs");
        item = new Gson().fromJson(i.getStringExtra("item"), FeedItem.class);
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
}
