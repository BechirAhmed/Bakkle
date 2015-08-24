package com.bakkle.bakkle.Fragments;


import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.bakkle.bakkle.R;

public class AnalyticsFragment extends Fragment
{
    public static AnalyticsFragment newInstance(String param1)
    {
        AnalyticsFragment fragment = new AnalyticsFragment();
        Bundle args = new Bundle();
//        args.putString(ARG_PARAM1, param1);
        fragment.setArguments(args);
        return fragment;
    }
    
    public AnalyticsFragment()
    {
        // Required empty public constructor
    }
    
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
//            mParam1 = getArguments().getString(ARG_PARAM1);
        }
    }
    
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState)
    {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_analytics, container, false);
    }
    
    
}
