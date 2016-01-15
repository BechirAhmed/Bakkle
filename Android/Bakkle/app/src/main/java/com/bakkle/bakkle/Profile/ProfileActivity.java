package com.bakkle.bakkle.Profile;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ViewSwitcher;

import com.android.volley.Response;
import com.bakkle.bakkle.API;
import com.bakkle.bakkle.Constants;
import com.bakkle.bakkle.Prefs;
import com.bakkle.bakkle.R;
import com.facebook.FacebookSdk;
import com.facebook.login.LoginManager;
import com.squareup.picasso.Picasso;

import org.json.JSONException;
import org.json.JSONObject;

public class ProfileActivity extends AppCompatActivity
{
    Button       loginLogoutButton;
    Button       saveEditButton;
    ImageView    profilePictureImageView;
    EditText     descriptionEditText;
    TextView     nameTextView;
    TextView     descriptionTextView;
    ViewSwitcher viewSwitcher;

    Prefs prefs;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_profile);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        toolbar.setTitle("Profile");
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        FacebookSdk.sdkInitialize(this);

        prefs = Prefs.getInstance(this);

        loginLogoutButton = (Button) findViewById(R.id.login_logout_button);
        saveEditButton = (Button) findViewById(R.id.save_edit_button);
        nameTextView = (TextView) findViewById(R.id.name);
        descriptionTextView = (TextView) findViewById(R.id.description_text);
        descriptionEditText = (EditText) findViewById(R.id.description_edit);
        profilePictureImageView = (ImageView) findViewById(R.id.prof_pic);
        viewSwitcher = (ViewSwitcher) findViewById(R.id.view_switcher);
        API.getInstance(this).getAccount(new AccountListener());

        nameTextView.setText(prefs.getName());

        Picasso.with(this)
                .load(prefs.getUserImageUrl())
                .fit()
                .centerCrop()
                .placeholder(R.drawable.ic_account_circle)
                .into(profilePictureImageView);

        if (prefs.isLoggedIn()) {
            loginLogoutButton.setText(R.string.log_out);
        } else {
            loginLogoutButton.setText(R.string.log_in);
        }

        saveEditButton.setText(R.string.edit);

        loginLogoutButton.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                if (prefs.isLoggedIn()) {
                    loginLogoutButton.setText(R.string.log_in);
                    profilePictureImageView.setImageResource(R.drawable.ic_account_circle);
                    LoginManager.getInstance().logOut();
                    prefs.logout();
                    setResult(Constants.RESULT_CODE_NOW_SIGNED_OUT);

                } else {
                    startActivityForResult(new Intent(ProfileActivity.this, RegisterActivity.class),
                            Constants.REQUEST_CODE_SIGN_IN);
                }
            }
        });

        saveEditButton.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                if (saveEditButton.getText().toString().equals(getString(R.string.save))) {
                    String description = descriptionEditText.getText().toString();
                    API.getInstance(ProfileActivity.this)
                            .setDescription(new DescriptionListener(), description);
                    descriptionTextView.setText(description);
                    viewSwitcher.showNext();
                    saveEditButton.setText(R.string.edit);
                } else {
                    viewSwitcher.showNext();
                    descriptionEditText.requestFocus();
                    saveEditButton.setText(R.string.save);
                }
            }
        });

    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == Constants.REQUEST_CODE_SIGN_IN && resultCode == Constants.REUSLT_CODE_OK) {
            loginLogoutButton.setText(R.string.log_out);

            Picasso.with(this)
                    .load(prefs.getUserImageUrl())
                    .fit()
                    .centerCrop()
                    .placeholder(R.drawable.ic_account_circle)
                    .into(profilePictureImageView);

            nameTextView.setText(prefs.getName());
            API.getInstance(this).getAccount(new AccountListener());
            setResult(Constants.RESULT_CODE_NOW_SIGNED_IN);
        }
    }

    private class AccountListener implements Response.Listener<JSONObject>
    {

        @Override
        public void onResponse(JSONObject response)
        {
            try {
                String description = response.getJSONObject("account").getString("description");
                descriptionEditText.setText(description);
                descriptionTextView.setText(description);

            } catch (JSONException e) {
                Toast.makeText(getApplicationContext(), "There was an error getting the account",
                        Toast.LENGTH_SHORT).show();
            }
        }
    }

    private class DescriptionListener implements Response.Listener<JSONObject>
    {

        @Override
        public void onResponse(JSONObject response)
        {
            try {
                if (response.getInt("status") != 1) {
                    Toast.makeText(ProfileActivity.this,
                            "There was an error setting the description", Toast.LENGTH_SHORT)
                            .show();
                }
            } catch (JSONException e) {
                Toast.makeText(ProfileActivity.this, "There was an error setting the description",
                        Toast.LENGTH_SHORT).show();
            }
        }
    }

}
