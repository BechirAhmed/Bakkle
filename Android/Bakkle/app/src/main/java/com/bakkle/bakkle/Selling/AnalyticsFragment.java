package com.bakkle.bakkle.Selling;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.bakkle.bakkle.R;

public class AnalyticsFragment extends Fragment
{
    public AnalyticsFragment()
    {
    }

    public static AnalyticsFragment newInstance()
    {
        return new AnalyticsFragment();
    }

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState)
    {
        View view = inflater.inflate(R.layout.recycler_view, container, false);

        return view;
    }

}
