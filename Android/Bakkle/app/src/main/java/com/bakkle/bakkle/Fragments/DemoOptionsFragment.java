package com.bakkle.bakkle.Fragments;


import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.bakkle.bakkle.R;


/**
 * A simple {@link Fragment} subclass.
 */
public class DemoOptionsFragment extends Fragment
{
    public DemoOptionsFragment() {}

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
    {
        return inflater.inflate(R.layout.fragment_demo_options, container, false);
    }


}

