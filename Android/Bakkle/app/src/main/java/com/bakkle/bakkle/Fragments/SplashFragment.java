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
import com.bakkle.bakkle.Activities.SignupActivity;
import com.bakkle.bakkle.Helpers.ChatCalls;
import com.bakkle.bakkle.Helpers.Constants;
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
    Activity          mActivity;
    SharedPreferences preferences;
    protected String authToken;
    String uuid;

    public static SplashFragment newInstance(String pk, String url)
    {
        SplashFragment fragment = new SplashFragment();
        Bundle args = new Bundle();
        args.putString(Constants.PK, pk);
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
        preferences = PreferenceManager.getDefaultSharedPreferences(mActivity);
        authToken = preferences.getString(Constants.AUTH_TOKEN, "");
        uuid = preferences.getString(Constants.UUID, "");
        Glide.with(mActivity)
                .load(getArguments().getString("url"))
                .thumbnail(0.1f)
                .crossFade()
                .into((ImageView) view.findViewById(R.id.productImage));

        Button sendMessage = (Button) view.findViewById(R.id.sendMessageButton);
        Button keepBrowsing = (Button) view.findViewById(R.id.keepBrowsingButton);
        keepBrowsing.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {
                getFragmentManager().popBackStack();
            }
        });
        sendMessage.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {
                if (preferences.getBoolean(Constants.NEW_USER, true)) {
                    startActivity(new Intent(mActivity, SignupActivity.class));
                }
                if (!preferences.getBoolean(Constants.NEW_USER, true)) {
                    new StartChatIntermediary(getArguments().getString(Constants.PK));
                }
            }
        });

        return view;
    }


    private class StartChatIntermediary
    {
        public StartChatIntermediary(String pk)
        {
            ChatCalls chatCalls = new ChatCalls(uuid, authToken.substring(33, 35), authToken, new WebSocketCallBack(pk));
            chatCalls.connect();
        }
    }

    private class WebSocketCallBack implements AsyncHttpClient.WebSocketConnectCallback
    {
        String pk;

        public WebSocketCallBack(String pk)
        {
            this.pk = pk;
        }

        @Override
        public void onCompleted(Exception ex, WebSocket webSocket)
        {
            if (ex != null) {
                Log.e("callback exception", ex.getMessage());
                return;
            }
            JSONObject json = new JSONObject();
            try {
                json.put("method", "chat_startChat");
                json.put("itemId", pk);
                json.put("uuid", uuid);
                json.put("auth_token", authToken);
            }
            catch (Exception e) {
                Log.e("Websocket callback", e.getMessage());
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
                    if (!jsonObject.has("chatId"))
                        return;
                    Intent i = new Intent(mActivity, ChatActivity.class);
                    i.putExtra(Constants.CHAT_ID, Integer.parseInt(jsonObject.get("chatId").getAsString()));
                    i.putExtra(Constants.SELF_BUYER, true);
                    startActivity(i);
                }
            });
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
