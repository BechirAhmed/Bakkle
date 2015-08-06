package com.bakkle.bakkle.Fragments;

import android.app.Activity;
import android.app.Fragment;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.SeekBar;
import android.widget.TextView;

import com.bakkle.bakkle.R;


/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * {@link RefineFragment.OnFragmentInteractionListener} interface
 * to handle interaction events.
 * Use the {@link RefineFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class RefineFragment extends Fragment
{
    
    private OnFragmentInteractionListener mListener;
    private SharedPreferences preferences;
    private SharedPreferences.Editor editor;


    // TODO: Rename and change types and number of parameters
    public static RefineFragment newInstance()
    {
        RefineFragment fragment = new RefineFragment();
        return fragment;
    }
    
    public RefineFragment()
    {
        // Required empty public constructor
    }
    
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        preferences = PreferenceManager.getDefaultSharedPreferences(getActivity());
        editor = preferences.edit();

    }
    
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState)
    {
        // Inflate the layout for this fragment
        View view =  inflater.inflate(R.layout.fragment_refine, container, false);
        SeekBar distanceBar = (SeekBar) view.findViewById(R.id.distanceBar);
        SeekBar priceBar = (SeekBar) view.findViewById(R.id.priceBar);
        final TextView distanceValue = (TextView) view.findViewById(R.id.distanceValue);
        final TextView priceValue = (TextView) view.findViewById(R.id.priceValue);
        distanceBar.setProgress(preferences.getInt("distance_filter", 100));
        priceBar.setProgress(preferences.getInt("price_filter", 100));
        int distanceBarValue = distanceBar.getProgress();
        int priceBarValue = priceBar.getProgress();
        if(distanceBarValue != 100)
            distanceValue.setText(distanceBarValue + " mi");
        else
            distanceValue.setText("100+ mi");
        if(priceBarValue != 100)
            priceValue.setText("$" + priceBarValue);
        else
            priceValue.setText("$100+");
        distanceBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener()
        {
            int progress = 0;

            @Override
            public void onProgressChanged(SeekBar seekBar, int i, boolean b)
            {
                progress = i;
                if(progress != 100)
                    distanceValue.setText(progress + " mi");
                else
                    distanceValue.setText("∞ mi");
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar)
            {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar)
            {
                if(progress != 100)
                    distanceValue.setText(progress + " mi");
                else
                    distanceValue.setText("∞ mi");
                editor.putInt("distance_filter", progress);
                editor.apply();
            }
        });


        priceBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener()
        {
            int progress = 0;

            @Override
            public void onProgressChanged(SeekBar seekBar, int i, boolean b)
            {
                progress = i;
                if(progress != 100)
                    priceValue.setText("$" + progress);
                else
                    priceValue.setText("$∞");
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar)
            {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar)
            {
                if(progress != 100)
                    priceValue.setText("$" + progress);
                else
                    priceValue.setText("$∞");
                editor.putInt("price_filter", progress);
                editor.apply();
            }
        });

        return view;
    }
    
    // TODO: Rename method, update argument and hook method into UI event
    public void onButtonPressed(Uri uri)
    {
        if (mListener != null) {
            mListener.onFragmentInteraction(uri);
        }
    }
    
    @Override
    public void onAttach(Activity activity)
    {
        super.onAttach(activity);
        try {
            mListener = (OnFragmentInteractionListener) activity;
        }
        catch (ClassCastException e) {
            throw new ClassCastException(activity.toString()
                    + " must implement OnFragmentInteractionListener");
        }
    }
    
    @Override
    public void onDetach()
    {
        super.onDetach();
        mListener = null;
    }


    
    /**
     * This interface must be implemented by activities that contain this
     * fragment to allow an interaction in this fragment to be communicated
     * to the activity and potentially other fragments contained in that
     * activity.
     * <p/>
     * See the Android Training lesson <a href=
     * "http://developer.android.com/training/basics/fragments/communicating.html"
     * >Communicating with Other Fragments</a> for more information.
     */
    public interface OnFragmentInteractionListener
    {
        // TODO: Update argument type and name
        public void onFragmentInteraction(Uri uri);
    }
    
}
