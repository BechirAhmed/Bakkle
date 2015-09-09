package com.bakkle.bakkle.Fragments;


import android.app.Activity;
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
import com.bakkle.bakkle.Helpers.Constants;
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
    String description;
    String url;
    Activity mActivity;
    
    public ProfileFragment()
    {
    }

    @Override
    public void onAttach(Activity activity)
    {
        super.onAttach(activity);
        mActivity = activity;
    }

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        preferences = PreferenceManager.getDefaultSharedPreferences(mActivity);
        description = null;
        editor = preferences.edit();
        serverCalls = new ServerCalls(mActivity);
        json = serverCalls.getAccount(preferences.getString(Constants.AUTH_TOKEN, ""), preferences.getString(Constants.UUID, ""));
        url = "http://graph.facebook.com/" + preferences.getString(Constants.USER_ID, "0") + "/picture?width=300&height=300";
    }
    
    
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
    {
        View view = inflater.inflate(R.layout.fragment_profile, container, false);

        ((TextView) view.findViewById(R.id.name)).setText(preferences.getString(Constants.NAME, "Not Signed In"));
        final EditText editText = (EditText) view.findViewById(R.id.aboutMeTextEdit);
        final TextView textView = (TextView) view.findViewById(R.id.aboutMeText);
        final Button logout = (Button) (view.findViewById(R.id.logout));
        final Button edit = (Button) view.findViewById(R.id.edit);
        final Button save = (Button) view.findViewById(R.id.saveButton);
        description = json.get("account").getAsJsonObject().get("description").getAsString();
        textView.setText(description);

        Glide.with(mActivity)
                .load(url)
                .placeholder(R.drawable.loading)
                .into((ImageView) view.findViewById(R.id.profilePicture));

        edit.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {
                //((EditText) view.findViewById(R.id.aboutMeText)).setEnabled();
                //TODO: make the edit button bring focus to the edit text box
                editText.setText(description);
                textView.setVisibility(View.INVISIBLE);
                editText.setVisibility(View.VISIBLE);
                edit.setVisibility(View.GONE);
                logout.setVisibility(View.GONE);
                save.setVisibility(View.VISIBLE);

            }
        });

        save.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {
                description = editText.getText().toString();

                textView.setVisibility(View.VISIBLE);
                textView.setText(description);
                editText.setVisibility(View.INVISIBLE);
                edit.setVisibility(View.VISIBLE);
                logout.setVisibility(View.VISIBLE);
                save.setVisibility(View.GONE);


                serverCalls.setDescription(
                        preferences.getString(Constants.AUTH_TOKEN, ""),
                        preferences.getString(Constants.UUID, ""),
                        description);
            }
        });


        logout.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {
                FacebookSdk.sdkInitialize(mActivity);
                LoginManager.getInstance().logOut();
                editor.putBoolean(Constants.LOGGED_IN, false);
                editor.putBoolean(Constants.NEW_USER, true);
                editor.apply();
                startActivity(new Intent(mActivity, LoginActivity.class));
                mActivity.finish();
            }
        });


        return view;
    }
    
    
}
