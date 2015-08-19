package com.bakkle.bakkle.Fragments;


import android.app.Fragment;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
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
    String description;
    String url;
    
    public ProfileFragment()
    {
    }

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        preferences = PreferenceManager.getDefaultSharedPreferences(getActivity());
        description = null;
        editor = preferences.edit();
        serverCalls = new ServerCalls(getActivity());
        json = serverCalls.getAccount(preferences.getString("auth_token", ""), preferences.getString("uuid", ""));
        url = "http://graph.facebook.com/" + preferences.getString("userID", "0") + "/picture?width=300&height=300";
    }
    
    
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
    {
        View view = inflater.inflate(R.layout.fragment_profile, container, false);

        ((TextView) view.findViewById(R.id.name)).setText(preferences.getString("name", "Not Signed In"));
        final EditText editText = (EditText) view.findViewById(R.id.aboutMeTextEdit);
        final TextView textView = (TextView) view.findViewById(R.id.aboutMeText);
        final Button logout = (Button) (view.findViewById(R.id.logout));
        final Button edit = (Button) view.findViewById(R.id.edit);
        final Button save = (Button) view.findViewById(R.id.saveButton);
        description = json.get("account").getAsJsonObject().get("description").getAsString();
        textView.setText(description);

        Glide.with(getActivity())
                .load(url)
                .thumbnail(0.1f)
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

                Log.v("description is now", description);

                textView.setVisibility(View.VISIBLE);
                textView.setText(description);
                editText.setVisibility(View.INVISIBLE);
                edit.setVisibility(View.VISIBLE);
                logout.setVisibility(View.VISIBLE);
                save.setVisibility(View.GONE);


                serverCalls.setDescription(
                        preferences.getString("auth_token", ""),
                        preferences.getString("uuid", ""),
                        description);
            }
        });


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


        return view;
    }
    
    
}
