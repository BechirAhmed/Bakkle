package com.bakkle.bakkle.AddItem;

import android.net.Uri;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;

import com.bakkle.bakkle.Constants;
import com.bakkle.bakkle.R;

public class AddItemActivity extends AppCompatActivity
{
    private Uri[] photoUris;
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_add_item);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().hide();

        photoUris = new Uri[4];

        getSupportFragmentManager()
                .beginTransaction()
                .replace(R.id.content_frame, TakePictureFragment.newInstance(), Constants.CAMERA)
                .commit();
    }

    public void addPhotoUri(Uri uri) {
        photoUris[photoUris.length] = uri;
    }

    public Uri[] getPhotoUris()
    {
        return photoUris;
    }

    public void onCancel(View view) {
        getSupportFragmentManager().popBackStack();
    }
}
