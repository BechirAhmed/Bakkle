package com.bakkle.bakkle;

import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.squareup.picasso.Picasso;
import com.viewpagerindicator.CirclePageIndicator;

public class TutorialActivity extends AppCompatActivity
{

    private SectionsPagerAdapter mSectionsPagerAdapter;
    private ViewPager            mViewPager;
    private CirclePageIndicator  indicator;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_tutorial);

        mSectionsPagerAdapter = new SectionsPagerAdapter(getSupportFragmentManager());
        indicator = (CirclePageIndicator) findViewById(R.id.indicator);
        mViewPager = (ViewPager) findViewById(R.id.container);
        mViewPager.setAdapter(mSectionsPagerAdapter);
        indicator.setSnap(true);
        indicator.setViewPager(mViewPager);

    }

    public static class TutorialScreenFragment extends Fragment
    {
        private static final String ARG_SECTION_NUMBER = "section_number";

        public TutorialScreenFragment()
        {
        }

        public static TutorialScreenFragment newInstance(int sectionNumber)
        {
            TutorialScreenFragment fragment = new TutorialScreenFragment();
            Bundle args = new Bundle();
            args.putInt(ARG_SECTION_NUMBER, sectionNumber);
            fragment.setArguments(args);
            return fragment;
        }

        @Override
        public View onCreateView(LayoutInflater inflater, ViewGroup container,
                                 Bundle savedInstanceState)
        {
            View rootView = inflater.inflate(R.layout.fragment_tutorial, container, false);
            int sectionNumber = getArguments().getInt(ARG_SECTION_NUMBER);

            ImageView imageView = (ImageView) rootView.findViewById(R.id.tutorial_image);
            TextView textView = (TextView) rootView.findViewById(R.id.instructions);
            textView.setText(getInstructions(sectionNumber));
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                imageView.setImageResource(getResourceId(sectionNumber));
                imageView.setRotation(sectionNumber == 2 || sectionNumber == 3 ? -90 : 0);
            } else {
                Picasso.with(getContext())
                        .load(getResourceId(sectionNumber))
                        .rotate(sectionNumber == 2 || sectionNumber == 3 ? -90 : 0) //only rotate for swipe up and down
                        .into(imageView);
            }
            return rootView;
        }

        private int getResourceId(int sectionNumber)
        {
            switch (sectionNumber) {
                case 0:
                    return R.drawable.swipe_right;
                case 2:
                    return R.drawable.swipe_right;
                case 1:
                    return R.drawable.swipe_left;
                case 3:
                    return R.drawable.swipe_left;
                case 4:
                    return R.drawable.ic_add_a_photo;
            }
            return R.drawable.ic_add_a_photo; //section number should be between 0-4, so this doesn't matter
        }
    }

    public static class TutorialScreenLastFragment extends Fragment
    {
        private static final String ARG_SECTION_NUMBER = "section_number";

        public TutorialScreenLastFragment()
        {
        }

        public static TutorialScreenLastFragment newInstance(int sectionNumber)
        {
            TutorialScreenLastFragment fragment = new TutorialScreenLastFragment();
            Bundle args = new Bundle();
            args.putInt(ARG_SECTION_NUMBER, sectionNumber);
            fragment.setArguments(args);
            return fragment;
        }

        @Override
        public View onCreateView(LayoutInflater inflater, ViewGroup container,
                                 Bundle savedInstanceState)
        {
            View rootView = inflater.inflate(R.layout.fragment_tutorial_last, container, false);
            int sectionNumber = getArguments().getInt(ARG_SECTION_NUMBER);
            rootView.findViewById(R.id.button).setOnClickListener(new View.OnClickListener()
            {
                @Override
                public void onClick(View v)
                {
                    getActivity().setResult(Constants.REUSLT_CODE_OK);
                    getActivity().finish();
                }
            });
            TextView textView = (TextView) rootView.findViewById(R.id.instructions);
            textView.setText(getInstructions(sectionNumber));
            return rootView;
        }
    }

    private static String getInstructions(int sectionNumber)
    {
        switch (sectionNumber) {
            case 0:
                return "SWIPE RIGHT IF YOU\nWANT AN ITEM";
            case 1:
                return "SWIPE LEFT IF YOU\nDON'T WANT AN ITEM";
            case 2:
                return "SWIPE UP TO\nSAVE AN ITEM";
            case 3:
                return "SWIPE DOWN TO\nREPORT AN ITEM";
            case 4:
                return "CLICK THIS ICON TO\nSELL YOUR OWN ITEM";
            case 5:
                return "READY TO SWIPE?\nCLICK BELOW";
        }
        return "";
    }

    public class SectionsPagerAdapter extends FragmentPagerAdapter
    {

        public SectionsPagerAdapter(FragmentManager fm)
        {
            super(fm);
        }

        @Override
        public Fragment getItem(int position)
        {
            if (position == 5) {
                return TutorialScreenLastFragment.newInstance(position);
            }
            return TutorialScreenFragment.newInstance(position);
        }

        @Override
        public int getCount()
        {
            // Show 6 total pages.
            return 6;
        }
    }
}
