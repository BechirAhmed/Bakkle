package com.bakkle.bakkle.Fragments;

import android.app.Activity;
import android.app.Fragment;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;

import com.bakkle.bakkle.Activities.ChatActivity;
import com.bakkle.bakkle.Helpers.ChatCalls;
import com.bakkle.bakkle.R;
import com.bumptech.glide.Glide;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.koushikdutta.async.http.AsyncHttpClient;
import com.koushikdutta.async.http.WebSocket;

import org.json.JSONObject;

/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * {@link SplashFragment.OnFragmentInteractionListener} interface
 * to handle interaction events.
 * Use the {@link SplashFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class SplashFragment extends Fragment
{
    
    private OnFragmentInteractionListener mListener;
    Activity mActivity;


    public static SplashFragment newInstance(String pk, String url)
    {
        SplashFragment fragment = new SplashFragment();
        Bundle args = new Bundle();
        args.putString("pk", pk);
        args.putString("url", url);
        fragment.setArguments(args);
        return fragment;
    }
    
    public SplashFragment()
    {
        // Required empty public constructor
    }
    
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
    }
    
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
    {
        View view = inflater.inflate(R.layout.fragment_splash, container, false);
        Glide.with(mActivity)
                .load(getArguments().getString("url"))
                .crossFade()
                .into((ImageView) view.findViewById(R.id.productImage));

        Button sendMessage = (Button) view.findViewById(R.id.sendMessageButton);
        Button keepBrowsing = (Button) view.findViewById(R.id.keepBrowsingButton);
        keepBrowsing.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {
                getFragmentManager().beginTransaction().detach(SplashFragment.this).commit();
            }
        });
        sendMessage.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {
                new StartChatIntermediary(getArguments().getString("pk"));
            }
        });

        return view;
    }


    private class StartChatIntermediary
    {
        String pk;
        ChatCalls chatCalls;
        SharedPreferences preferences;

        public StartChatIntermediary(String pk)
        {
            this.pk = pk;
            preferences = PreferenceManager.getDefaultSharedPreferences(mActivity);
            chatCalls = new ChatCalls(preferences.getString("uuid", ""), preferences.getString("sellerPk", ""), preferences.getString("auth_token", ""), new WebSocketCallBack());
        }

        private class WebSocketCallBack implements AsyncHttpClient.WebSocketConnectCallback
        {


            @Override
            public void onCompleted(Exception ex, WebSocket webSocket)
            {
                if(ex != null)
                {
                    Log.v("callback exception", ex.getMessage());
                    return;
                }
                JSONObject json = new JSONObject();
                try {
                    json.put("method", "chat_startChat");
                    json.put("itemId", pk);
                    json.put("uuid", "E7F742EB-67EE-4738-ABEC-F0A3B62B45EB");
                    json.put("auth_token", "f02dfb77e9615ae630753b37637abb31_10");
                }
                catch (Exception e) {
                    Log.v("Websocket callback", e.getMessage());
                }

                webSocket.send(json.toString());
                webSocket.setStringCallback(new WebSocket.StringCallback()
                {
                    @Override
                    public void onStringAvailable(String s)
                    {
                        JsonParser jsonParser = new JsonParser();
                        JsonElement jsonElement = jsonParser.parse(s);
                        JsonObject jsonObject = jsonElement.getAsJsonObject();
                        Intent i = new Intent(mActivity, ChatActivity.class);
                        i.putExtra("chatId", jsonObject.get("chatId").getAsInt());
                        startActivity(i);
                    }
                });
            }
        }


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
        mActivity = activity;
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
