package com.bakkle.bakkle.AddItem;

import android.content.Context;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.bakkle.bakkle.R;
import com.viewpagerindicator.CirclePageIndicator;

/**
 * A simple {@link Fragment} subclass.
 * Use the {@link InputDetailsFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class InputDetailsFragment extends Fragment
{
    public InputDetailsFragment()
    {
        // Required empty public constructor
    }

    public static InputDetailsFragment newInstance()
    {
        return new InputDetailsFragment();
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
        // Inflate the layout for this fragment
        View view =  inflater.inflate(R.layout.fragment_input_details, container, false);

        ViewPager viewPager = (ViewPager) view.findViewById(R.id.images);
        ImagePagerAdapter adapter = new ImagePagerAdapter(((AddItemActivity) getActivity()).getPhotoUris());
        viewPager.setAdapter(adapter);
        ((CirclePageIndicator) view.findViewById(R.id.indicator)).setViewPager(viewPager);
        ((CirclePageIndicator) view.findViewById(R.id.indicator)).setSnap(true);

        return view;
    }



    private class ImagePagerAdapter extends PagerAdapter
    {
        Uri[] uris;

        public ImagePagerAdapter(Uri[] uris)
        {
            this.uris = uris;
        }

        @Override
        public int getCount()
        {
            return uris.length;
        }

        @Override
        public boolean isViewFromObject(View view, Object object)
        {
            return view == object;
        }

        @Override
        public Object instantiateItem(ViewGroup container, int position)
        {
            Context context = getContext();
            ImageView imageView = new ImageView(context);
            imageView.setScaleType(ImageView.ScaleType.FIT_CENTER);
            imageView.setImageURI(uris[position]);
            container.addView(imageView, 0);
            return imageView;
        }

        @Override
        public void destroyItem(ViewGroup container, int position, Object object)
        {
            container.removeView((View) object);
        }
    }
}
