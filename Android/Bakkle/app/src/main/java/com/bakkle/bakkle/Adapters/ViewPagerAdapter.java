package com.bakkle.bakkle.Adapters;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;

import com.bakkle.bakkle.Fragments.AnalyticsFragment;
import com.bakkle.bakkle.Fragments.ChatListFragment;

import java.util.ArrayList;

/**
 * Created by vanshgandhi on 8/24/15.
 */
public class ViewPagerAdapter extends FragmentStatePagerAdapter
{

    CharSequence Titles[];
    int numTabs;
    private String itemId;
    private String numWant;
    private String numHold;
    private String numMeh;
    private String numView;
    String title, price, description, seller, distance, pk, sellerImageUrl;
    ArrayList<String> imageURLs;

    public ViewPagerAdapter(FragmentManager fm, CharSequence mTitles[], int numTabs,
                            String itemId, String numView, String numWant, String numHold,
                            String numMeh, String title, String price, String description,
                            String seller, String distance, String pk, String sellerImageUrl,
                            ArrayList<String> imageURLs) {
        super(fm);

        this.Titles = mTitles;
        this.numTabs = numTabs;
        this.itemId = itemId;
        this.numView = numView;
        this.numWant = numWant;
        this.numMeh = numMeh;
        this.numHold = numHold;
        this.title = title;
        this.price = price;
        this.description = description;
        this.seller = seller;
        this.distance = distance;
        this.pk = pk;
        this.sellerImageUrl = sellerImageUrl;
        this.imageURLs = imageURLs;

    }

    @Override
    public Fragment getItem(int position) {
        if(position == 0)
        {
            ChatListFragment chatListFragment = ChatListFragment.newInstance(itemId, title, price, description, seller, distance, pk, sellerImageUrl, imageURLs);
            return chatListFragment;
        }
        else
        {
            AnalyticsFragment analyticsFragment = AnalyticsFragment.newInstance(numView, numWant, numHold, numMeh);
            return analyticsFragment;
        }

    }

    @Override
    public CharSequence getPageTitle(int position) {
        return Titles[position];
    }

    @Override
    public int getCount() {
        return numTabs;
    }
}