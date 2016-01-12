package com.bakkle.bakkle.Profile;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.Toast;

import com.android.volley.Response;
import com.bakkle.bakkle.API;
import com.bakkle.bakkle.Constants;
import com.bakkle.bakkle.Prefs;
import com.bakkle.bakkle.R;
import com.facebook.AccessToken;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookSdk;
import com.facebook.GraphRequest;
import com.facebook.GraphResponse;
import com.facebook.HttpMethod;
import com.facebook.login.LoginResult;
import com.facebook.login.widget.LoginButton;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * A simple {@link Fragment} subclass.
 */
public class SignupLoginChooser extends Fragment
{
    CallbackManager callbackManager;

    public SignupLoginChooser()
    {
        // Required empty public constructor
    }

    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        FacebookSdk.sdkInitialize(getContext());
        callbackManager = CallbackManager.Factory.create();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState)
    {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_signup_login_chooser, container, false);

        Button emailButton = (Button) view.findViewById(R.id.email_button);
        Button signInButton = (Button) view.findViewById(R.id.sign_in_button);
        LoginButton loginButton = (LoginButton) view.findViewById(R.id.facebook_button);

        emailButton.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                getFragmentManager().beginTransaction().replace(R.id.content_frame, SignupEmailFragment.newInstance()).commit();
            }
        });

        signInButton.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                getFragmentManager().beginTransaction().replace(R.id.content_frame, LoginFragment.newInstance()).commit();
            }
        });

        loginButton.setReadPermissions("public_profile", "email");
        loginButton.setFragment(this);
        loginButton.registerCallback(callbackManager, new FacebookCallback<LoginResult>()
        {
            @Override
            public void onSuccess(LoginResult loginResult)
            {
                final AccessToken accessToken = loginResult.getAccessToken();
                Bundle parameters = new Bundle();
                parameters.putString("fields", "picture.type(normal), id, first_name, last_name, name, email, gender, locale");
                new GraphRequest(accessToken, "/" + accessToken.getUserId(), parameters, HttpMethod.GET, new GraphRequest.Callback()
                {
                    public void onCompleted(GraphResponse response)
                    {
                        JSONObject jsonObject = response.getJSONObject();
                        Prefs prefs = Prefs.getInstance();
                        try {
                            prefs.setFirstName(jsonObject.getString("first_name"));
                            prefs.setLastName(jsonObject.getString("last_name"));
                            prefs.setName(jsonObject.getString("name"));
                            prefs.setEmail(jsonObject.getString("email"));
                            prefs.setGender(jsonObject.getString("gender"));
                            prefs.setLocale(jsonObject.getString("locale"));
                            prefs.setUserId(jsonObject.getString("id"));
                            prefs.setUserImageUrl(jsonObject.getJSONObject("picture").getJSONObject("data").getString("url"));

                            API.getInstance().registerFacebook(new LoginListener());
                        } catch (JSONException | NullPointerException e) {
                            Toast.makeText(getContext(), "There was an error signing in", Toast.LENGTH_SHORT).show();
                        }

                    }
                }).executeAsync();
            }

            @Override
            public void onCancel()
            {
                Toast.makeText(getContext(), "There was error signing in", Toast.LENGTH_SHORT).show();
            }

            @Override
            public void onError(FacebookException exception)
            {
                Toast.makeText(getContext(), "There was error signing in", Toast.LENGTH_SHORT).show();
            }
        });

        return view;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        super.onActivityResult(requestCode, resultCode, data);
        callbackManager.onActivityResult(requestCode, resultCode, data);
    }


    private class LoginListener implements Response.Listener<JSONObject>
    {
        @Override
        public void onResponse(JSONObject response)
        {
            try {
                Prefs prefs = Prefs.getInstance(getContext());
                prefs.setAuthToken(response.getString("auth_token"));
                prefs.setAuthenticated(true);
                prefs.setLoggedIn(true);
                prefs.setGuest(false);

                getActivity().setResult(Constants.REUSLT_CODE_OK);
                getActivity().finish();
            }
            catch (JSONException e) {
                Toast.makeText(getContext(), "There was error signing in", Toast.LENGTH_SHORT).show();
            }
        }
    }

}
