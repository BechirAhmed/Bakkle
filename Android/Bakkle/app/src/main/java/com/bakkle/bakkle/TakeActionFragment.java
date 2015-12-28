package com.bakkle.bakkle;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.widget.DrawerLayout;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;

import com.bakkle.bakkle.Profile.RegisterActivity;
import com.squareup.picasso.Picasso;

public class TakeActionFragment extends Fragment
{
    private MainActivity mainActivity;
    private String       image_url;
    private int          pk;

    private Prefs prefs;

    public TakeActionFragment()
    {
        // Required empty public constructor
    }

    public static TakeActionFragment newInstance(String image_url, int pk)
    {
        TakeActionFragment fragment = new TakeActionFragment();
        Bundle args = new Bundle(1);
        args.putString(Constants.IMAGE_URL, image_url);
        args.putInt(Constants.PK, pk);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            this.image_url = getArguments().getString(Constants.IMAGE_URL);
        }
    }
    
    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        if (requestCode == Constants.REQUEST_CODE_SEND_MESSAGE) {
            // Make sure the request was successful
            if (resultCode == Constants.REUSLT_CODE_OK) {
                mainActivity.updateNavHeader();
                sendMessage();
            }
        } else if (requestCode == Constants.REQUEST_CODE_MAKE_OFFER) {
            if (resultCode == Constants.REUSLT_CODE_OK) {
                mainActivity.updateNavHeader();
                makeOffer();
            }
        }
    }

    private void makeOffer()
    {
        markWant();
        //TODO: Start ChatActivity, with making offer as parameter
    }
    
    private void sendMessage()
    {
        markWant();
        //TODO: Start ChatActivity, with sending message as parameter
    }

    private void markWant()
    {
        API.getInstance().markItem(Constants.MARK_WANT, pk, "42");
    }
    
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState)
    {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_take_action, container, false);

        prefs = Prefs.getInstance();

        ImageView product;
        Button saveButton;
        Button sendMessageButton;
        Button makeOfferButton;

        product = (ImageView) view.findViewById(R.id.product);
        sendMessageButton = (Button) view.findViewById(R.id.message);
        makeOfferButton = (Button) view.findViewById(R.id.offer);
        saveButton = (Button) view.findViewById(R.id.save);

        sendMessageButton.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                if (!prefs.isLoggedIn()) {
                    startActivityForResult(new Intent(getContext(), RegisterActivity.class),
                                           Constants.REQUEST_CODE_SEND_MESSAGE);
                } else {
                    sendMessage();
                }
            }
        });

        makeOfferButton.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                if (!prefs.isLoggedIn()) {
                    startActivityForResult(new Intent(getContext(), RegisterActivity.class),
                                           Constants.REQUEST_CODE_MAKE_OFFER);
                } else {
                    makeOffer();
                }
            }
        });

        saveButton.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                API.getInstance()
                        .markItem(Constants.MARK_HOLD, pk, "42"); //TODO: Get actual view duration
                mainActivity.onBackPressed();
            }
        });

        Picasso.with(getContext()).load(image_url).centerCrop().fit().into(product);

        return view;
    }

    @Override
    public void onAttach(Context context)
    {
        super.onAttach(context);
        if (context instanceof MainActivity) {
            mainActivity = (MainActivity) context;
        }
    }

    @Override
    public void onPause()
    {
        super.onPause();
        //Allow drawer to be opened again
        mainActivity.getDrawer().setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED);
    }

    @Override
    public void onDetach()
    {
        super.onDetach();
    }
}
