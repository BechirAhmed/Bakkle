package com.bakkle.bakkle.AddItem;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.ExifInterface;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.design.widget.FloatingActionButton;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ProgressBar;
import android.widget.Switch;
import android.widget.Toast;

import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.bakkle.bakkle.API;
import com.bakkle.bakkle.AddItem.MaterialCamera.MaterialCamera;
import com.bakkle.bakkle.Constants;
import com.bakkle.bakkle.ImagePagerAdapter;
import com.bakkle.bakkle.R;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.widget.ShareDialog;
import com.viewpagerindicator.CirclePageIndicator;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class AddItemActivity extends AppCompatActivity
{
    FloatingActionButton uploadFab;
    EditText             titleEditText;
    EditText             priceEditText;
    EditText             descriptionEditText;
    Switch               shareFacebookSwitch;
    ViewPager            viewPager;
    ImagePagerAdapter    adapter;
    ProgressBar          progressBar;
    FrameLayout          content;

    File f;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_add_item);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        toolbar.setTitle("List Item");
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        uploadFab = (FloatingActionButton) findViewById(R.id.upload);
        titleEditText = (EditText) findViewById(R.id.title);
        priceEditText = (EditText) findViewById(R.id.price);
        descriptionEditText = (EditText) findViewById(R.id.description);
        shareFacebookSwitch = (Switch) findViewById(R.id.share);
        progressBar = (ProgressBar) findViewById(R.id.progress_bar);
        content = (FrameLayout) findViewById(R.id.content);

        viewPager = (ViewPager) findViewById(R.id.images);
        adapter = new ImagePagerAdapter(this);
        CirclePageIndicator indicator = (CirclePageIndicator) findViewById(R.id.indicator);
        viewPager.setAdapter(adapter);
        indicator.setViewPager(viewPager);
        indicator.setSnap(true);

        titleEditText.addTextChangedListener(new TextWatcher()
        {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after)
            {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count)
            {
                if (s.length() != 0) {
                    if (adapter.getCount() > 0) {
                        uploadFab.show();
                    }
                } else {
                    uploadFab.hide();
                }
            }

            @Override
            public void afterTextChanged(Editable s)
            {
            }
        });

        uploadFab.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                postItem();
            }
        });

        uploadFab.hide();
    }

    private void postItem()
    {
        String title = titleEditText.getText().toString();
        String price = priceEditText.getText().toString();
        String description = descriptionEditText.getText().toString();

        boolean shareFb = shareFacebookSwitch.isChecked();

        if (title.equals("")) {
            return;
        }

        price = price.equals("") ? "0.00" : price;
        //description = description.equals("") ? "" : description;
        content.setVisibility(View.GONE);
        progressBar.setVisibility(View.VISIBLE);
        File[] files = new File[adapter.getCount()];
        for (int i = 0; i < files.length; i++) {
            files[i] = new File(adapter.getItem(i));
        }
        API.getInstance()
                .postItem(title, price, description, new PostItemListener(description, shareFb),
                        new PostItemErrorListener(), files);
    }

    private File createImageOrVideoFile(String extension) throws IOException
    {
        // Create an image file name
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String imageFileName = "Bakkle_" + timeStamp + "_";
        File storageDir = getExternalFilesDir(null);
        File image = File.createTempFile(imageFileName,  /* prefix */
                ".".concat(extension),         /* suffix */
                storageDir      /* directory */);

        f = image;

        return image;
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu)
    {
        getMenuInflater().inflate(R.menu.menu_add_item, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.add_photo) {
            File file;
            try {
                file = createImageOrVideoFile("jpg");
                Intent i = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
                i.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(file));
                startActivityForResult(i, Constants.REQUEST_CODE_TAKE_PICTURE);
                return true;
            } catch (IOException e) {
                return true;
            }

        } else if (id == R.id.add_video) {
            File file;
            try {
                file = createImageOrVideoFile("mp4");

                new MaterialCamera(this)
                        .allowRetry(false)
                        .autoSubmit(false)
                        .saveDir(getExternalFilesDir(null))
                        .primaryColorRes(R.color.colorPrimary)
                        .defaultToFrontFacing(false)
                        .showPortraitWarning(false)
                        .countdownSeconds(15)
                        .start(Constants.REQUEST_CODE_TAKE_VIDEO);

//                Intent i = new Intent(MediaStore.ACTION_VIDEO_CAPTURE);
//                i.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(file));
//                i.putExtra(MediaStore.EXTRA_VIDEO_QUALITY, 0); //Lowest quality
//                i.putExtra(MediaStore.EXTRA_DURATION_LIMIT, 15); //15 seconds long
//                startActivityForResult(i, Constants.REQUEST_CODE_TAKE_VIDEO);
                return true;
            } catch (IOException e) {
                return true;
            }
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == Constants.REQUEST_CODE_TAKE_PICTURE) {
            if (resultCode == RESULT_OK) {
                try {
                    Bitmap bmp = BitmapFactory.decodeFile(f.getPath());
                    FileOutputStream fos = new FileOutputStream(f);
                    ExifInterface ei = new ExifInterface(f.getPath());
                    int orientation = ei.getAttributeInt(ExifInterface.TAG_ORIENTATION,
                            ExifInterface.ORIENTATION_UNDEFINED);
                    Matrix m = new Matrix();
                    m.postRotate(90);

//                    switch (orientation) {
//                        case ExifInterface.ORIENTATION_ROTATE_90:
//                            m.postRotate(90);
//                            break;
//                        case ExifInterface.ORIENTATION_ROTATE_180:
//                            m.postRotate(180);
//                            break;
//                        case ExifInterface.ORIENTATION_ROTATE_270:
//                            m.postRotate(270);
//                            break;
//                    }
                    bmp = Bitmap.createBitmap(bmp, 0, 0, bmp.getWidth(), bmp.getHeight(), m, true);


                    //Makes sure image is a square
                    if (bmp.getWidth() >= bmp.getHeight()) {
                        bmp = Bitmap.createBitmap(bmp, bmp.getWidth() / 2 - bmp.getHeight() / 2, 0,
                                bmp.getHeight(), bmp.getHeight());

                    } else {
                        bmp = Bitmap.createBitmap(bmp, 0, bmp.getHeight() / 2 - bmp.getWidth() / 2,
                                bmp.getWidth(), bmp.getWidth());
                    }
                    Bitmap.createScaledBitmap(bmp, 640, 640, true)
                            .compress(Bitmap.CompressFormat.JPEG, 40, fos);
                    fos.flush();
                    fos.close();
                    adapter.addItem(f.getAbsolutePath());

                    if (titleEditText.getText().length() > 0) {
                        uploadFab.show();
                    } else {
                        uploadFab.hide();
                    }
                } catch (IOException e) {
                    Toast.makeText(this, "There was an error taking photo", Toast.LENGTH_SHORT)
                            .show();
                    e.printStackTrace();
                }
            }
        } else if (requestCode == Constants.REQUEST_CODE_TAKE_VIDEO) {
            if (resultCode == RESULT_OK) {
                Log.v("Result", data.getDataString());
                adapter.addItem(data.getDataString());
                Log.v("AddItemActivity", data.getDataString());
                if (titleEditText.getText().length() > 0) {
                    uploadFab.show();
                } else {
                    uploadFab.hide();
                }
            }
        }
    }

    private class PostItemListener implements Response.Listener<JSONObject>
    {
        String  description;
        boolean share;

        public PostItemListener(String description, boolean share)
        {
            this.description = description;
            this.share = share;
        }

        @Override
        public void onResponse(JSONObject response)
        {
            try {
                if (response.getInt("success") == 1) {
                    if (share) {
                        ShareDialog.show(AddItemActivity.this,
                                new ShareLinkContent.Builder().setContentUrl(Uri.parse(
                                        "https://app.bakkle.com/items/" + response.getInt(
                                                "item_id") + "/"))
                                        .setImageUrl(Uri.parse(response.getString("image_url")))
                                        .setContentDescription(description)
                                        .build());
                    }
                    Toast.makeText(AddItemActivity.this, "Your item has been posted successfully!",
                            Toast.LENGTH_LONG).show();
                    finish();
                } else {
                    content.setVisibility(View.VISIBLE);
                    progressBar.setVisibility(View.GONE);
                    Toast.makeText(AddItemActivity.this, "There was an error posting item",
                            Toast.LENGTH_SHORT).show();
                    Log.v("AddItemActivity", response.toString());
                }

            } catch (JSONException e) {
                content.setVisibility(View.VISIBLE);
                progressBar.setVisibility(View.GONE);
                e.printStackTrace();
                Log.v("AddItemActivity", response.toString());
            }
        }
    }

    private class PostItemErrorListener implements Response.ErrorListener
    {

        @Override
        public void onErrorResponse(VolleyError error)
        {
            content.setVisibility(View.VISIBLE);
            progressBar.setVisibility(View.GONE);
            Toast.makeText(AddItemActivity.this, "There was an error posting item",
                    Toast.LENGTH_SHORT).show();
            error.printStackTrace();
        }
    }
}
