package com.bakkle.bakkle.Fragments;


import android.app.Fragment;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import com.bakkle.bakkle.Activities.LoginActivity;
import com.bakkle.bakkle.Helpers.ServerCalls;
import com.bakkle.bakkle.R;
import com.bumptech.glide.Glide;
import com.facebook.FacebookSdk;
import com.facebook.login.LoginManager;
import com.google.gson.JsonObject;

/**
 * A simple {@link Fragment} subclass.
 */
public class ProfileFragment extends Fragment
{

    SharedPreferences preferences;
    SharedPreferences.Editor editor;
    ServerCalls serverCalls;
    JsonObject json;
    
    public ProfileFragment()
    {}

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        preferences = PreferenceManager.getDefaultSharedPreferences(getActivity());
        editor = preferences.edit();
        serverCalls = new ServerCalls(getActivity());
        json = serverCalls.populateGarage(preferences.getString("auth_token", ""), preferences.getString("uuid", ""));
    }
    
    
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState)
    {
        // Inflate the layout for this fragment
        View view =  inflater.inflate(R.layout.fragment_profile, container, false);

        ((TextView) view.findViewById(R.id.name)).setText(preferences.getString("name", "Not Signed In"));

        Button logout = (Button) (view.findViewById(R.id.logout));
        Button edit = (Button) view.findViewById(R.id.edit);

        logout.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {
                FacebookSdk.sdkInitialize(getActivity());
                LoginManager.getInstance().logOut();
                editor.putBoolean("LoggedIn", false);
                editor.putBoolean("newuser", true);
                editor.apply();
                startActivity(new Intent(getActivity(), LoginActivity.class));
                getActivity().finish();
            }
        });

        edit.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {
                //((EditText) view.findViewById(R.id.aboutMeText)).setEnabled();
                //TODO: make the edit button bring focus to the edit text box
            }
        });

        EditText editText = (EditText) view.findViewById(R.id.aboutMeText);

        editText.setText(json.get("seller_garage").getAsJsonArray().get(0).getAsJsonObject().get("seller").getAsJsonObject().get("description").getAsString());

        String url = "http://graph.facebook.com/" + preferences.getString("userID", "0") + "/picture?width=300&height=300";

        Glide.with(getActivity())
                .load(url)
                .into((ImageView) view.findViewById(R.id.profilePicture));




        return view;
    }
    
    
}
