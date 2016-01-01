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

import com.bakkle.bakkle.Chat.ChatActivity;
import com.bakkle.bakkle.Models.FeedItem;
import com.bakkle.bakkle.Profile.RegisterActivity;
import com.squareup.picasso.Picasso;

public class TakeActionFragment extends Fragment
{
    private MainActivity mainActivity;
    private FeedItem feedItem;

    private Prefs prefs;

    public TakeActionFragment()
    {
        // Required empty public constructor
    }

    public static TakeActionFragment newInstance(FeedItem feedItem)
    {
        TakeActionFragment fragment = new TakeActionFragment();
        Bundle args = new Bundle(2);
        args.putSerializable(Constants.FEED_ITEM, feedItem);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            this.feedItem = (FeedItem) getArguments().getSerializable(Constants.FEED_ITEM);
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
        }
    }
    
    private void sendMessage()
    {
        markWant();
        Intent intent = new Intent(getContext(), ChatActivity.class);
        intent.putExtra(Constants.FEED_ITEM, feedItem);
        startActivity(intent);
        getFragmentManager().popBackStack();
    }

    private void markWant()
    {
        API.getInstance().markItem(Constants.MARK_WANT, feedItem.getPk(), "42");
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

        product = (ImageView) view.findViewById(R.id.product);
        sendMessageButton = (Button) view.findViewById(R.id.message);
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

        saveButton.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                API.getInstance()
                        .markItem(Constants.MARK_HOLD, feedItem.getPk(), "42"); //TODO: Get actual view duration
                mainActivity.onBackPressed();
            }
        });

        Picasso.with(getContext()).load(feedItem.getImage_urls()[0]).centerCrop().fit().into(product);

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
