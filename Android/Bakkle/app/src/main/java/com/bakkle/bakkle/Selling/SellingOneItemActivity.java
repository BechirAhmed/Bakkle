package com.bakkle.bakkle.Selling;

import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.design.widget.TabLayout;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;

import com.bakkle.bakkle.Constants;
import com.bakkle.bakkle.GetFeedItem;
import com.bakkle.bakkle.Models.FeedItem;
import com.bakkle.bakkle.R;
import com.bakkle.bakkle.SectionsPagerAdapter;

public class SellingOneItemActivity extends AppCompatActivity implements GetFeedItem
{
    private SectionsPagerAdapter mSectionsPagerAdapter;
    private ViewPager            mViewPager;
    public  FeedItem             item;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_selling_one_item);
        item = (FeedItem) getIntent().getSerializableExtra(Constants.FEED_ITEM);

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        toolbar.setTitle(item.getTitle());
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);


        mSectionsPagerAdapter = new SectionsPagerAdapter(getSupportFragmentManager());
        mViewPager = (ViewPager) findViewById(R.id.container);
        mViewPager.setAdapter(mSectionsPagerAdapter);

        TabLayout tabLayout = (TabLayout) findViewById(R.id.tabs);
        tabLayout.setupWithViewPager(mViewPager);

        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {
                //TODO: Start AddItem Activity
                Snackbar.make(view, "This feature is coming soon!", Snackbar.LENGTH_SHORT).show();
            }
        });

    }

    public FeedItem getItem ()
    {
        return item;
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu)
    {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_selling_one_item, menu);
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
        if (id == R.id.action_edit) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
