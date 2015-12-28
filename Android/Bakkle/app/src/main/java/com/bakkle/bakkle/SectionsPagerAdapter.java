package com.bakkle.bakkle;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;

import com.bakkle.bakkle.Chat.MessageListFragment;
import com.bakkle.bakkle.Selling.AnalyticsFragment;

public class SectionsPagerAdapter extends FragmentPagerAdapter
{
    public SectionsPagerAdapter(FragmentManager fm)
    {
        super(fm);
    }

    @Override
    public Fragment getItem(int position)
    {
        return position == 0 ? MessageListFragment.newInstance() : AnalyticsFragment.newInstance();
    }

    @Override
    public int getCount()
    {
        return 2;
    }

    @Override
    public CharSequence getPageTitle(int position)
    {
        return position == 0 ? "Messages" : "Analytics";
    }
}