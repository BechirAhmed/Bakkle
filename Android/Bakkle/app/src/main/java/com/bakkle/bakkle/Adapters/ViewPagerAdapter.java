package com.bakkle.bakkle.Adapters;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;

import com.bakkle.bakkle.Fragments.AnalyticsFragment;
import com.bakkle.bakkle.Fragments.ChatListFragment;

/**
 * Created by vanshgandhi on 8/24/15.
 */
public class ViewPagerAdapter extends FragmentStatePagerAdapter
{

    CharSequence Titles[]; // This will Store the Titles of the Tabs which are Going to be passed when ViewPagerAdapter is created
    int numTabs; // Store the number of tabs, this will also be passed when the ViewPagerAdapter is created
    private String itemId;
    private String numWant;
    private String numHold;
    private String numMeh;
    private String numView;


    // Build a Constructor and assign the passed Values to appropriate values in the class
    public ViewPagerAdapter(FragmentManager fm,CharSequence mTitles[], int numTabs,
                            String itemId, String numView, String numWant, String numHold, String numMeh) {
        super(fm);

        this.Titles = mTitles;
        this.numTabs = numTabs;
        this.itemId = itemId;
        this.numView = numView;
        this.numWant = numWant;
        this.numMeh = numMeh;
        this.numHold = numHold;

    }

    //This method return the fragment for the every position in the View Pager
    @Override
    public Fragment getItem(int position) {
        if(position == 0) // if the position is 0 we are returning the First tab
        {
            ChatListFragment chatListFragment = ChatListFragment.newInstance(itemId);
            return chatListFragment;
        }
        else             // As we are having 2 tabs if the position is now 0 it must be 1 so we are returning second tab
        {
            AnalyticsFragment analyticsFragment = AnalyticsFragment.newInstance(numView, numWant, numHold, numMeh);
            return analyticsFragment;
        }

    }

    // This method return the titles for the Tabs in the Tab Strip

    @Override
    public CharSequence getPageTitle(int position) {
        return Titles[position];
    }

    // This method return the Number of tabs for the tabs Strip

    @Override
    public int getCount() {
        return numTabs;
    }
}