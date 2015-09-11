package com.bakkle.bakkle.Activities;

import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.media.ThumbnailUtils;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.preference.PreferenceManager;
import android.provider.MediaStore;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.SwitchCompat;
import android.support.v7.widget.Toolbar;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.bakkle.bakkle.Fragments.FeedFragment;
import com.bakkle.bakkle.Helpers.Constants;
import com.bakkle.bakkle.Helpers.ServerCalls;
import com.bakkle.bakkle.R;
import com.bumptech.glide.Glide;
import com.facebook.CallbackManager;
import com.facebook.FacebookSdk;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.widget.ShareDialog;
import com.google.gson.JsonObject;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;


public class AddItemActivity extends AppCompatActivity
{

    String mCurrentPhotoPath;
    static final int REQUEST_TAKE_PHOTO = 1;
    static final int MAX_IMAGE_COUNT = 4;
    EditText titleEditText, priceEditText, descriptionEditText;
    SwitchCompat facebookSwitch;
    CallbackManager callbackManager;
    String title;
    String price;
    String description;

    ArrayList<ImageView> productPictureViews = new ArrayList<>();
    ArrayList<String> picturePaths = new ArrayList<>();
    File video = null;
//    final String[] commonWords = {"the", "of", "and", "a", "to", "in", "is", "you",
//            "that", "it", "he", "was", "for", "on", "are", "as", "with", "his", "they", "i", "at",
//            "be", "this", "have", "from", "or", "one", "had", "by", "but", "not", "what", "all",
//            "were", "we", "when", "your", "can", "said", "there", "use", "an", "each", "which",
//            "she", "do", "how", "their", "if", "will", "up", "other", "about", "out", "many",
//            "then", "them", "these", "so", "some", "her"," would", "make", "like", "him", "into",
//            "has", "look", "more", "write", "go", "see", "no", "way", "could", "people", "my",
//            "than", "first", "been", "call", "who","its","now","find","down","day","did","get",
//            "come","made","may","part", "another", "any", "anybody", "anyone", "anything", "both",
//            "either", "everybody", "everyone", "everything", "am"};

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        startActivityForResult((new Intent(this, CameraActivity.class)), 1);
//        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
//        if (intent.resolveActivity(getPackageManager()) != null)  //TODO: Add my own mCamera interface so that only square pictures are taken
//        //TODO: add video
//        {
//            File photoFile = null;
//            try {
//                photoFile = createImageFile();
//            }
//            catch (Exception e) {
//                Log.v("create image file error", e.getMessage());
//            }
//            if (photoFile != null) {
//                intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(photoFile));
//                startActivityForResult(intent, REQUEST_TAKE_PHOTO);
//            }
//        }
        setContentView(R.layout.activity_add_item);
        FacebookSdk.sdkInitialize(this);
        callbackManager = CallbackManager.Factory.create();
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        TextView textView = (TextView) toolbar.findViewById(R.id.title);
        textView.setText("Add Item");
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        final Drawable upArrow = getResources().getDrawable(R.drawable.abc_ic_ab_back_mtrl_am_alpha);
        upArrow.setColorFilter(getResources().getColor(R.color.white), PorterDuff.Mode.SRC_ATOP);
        getSupportActionBar().setHomeAsUpIndicator(upArrow);
        toolbar.setNavigationOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                Intent intent = new Intent(AddItemActivity.this, CameraActivity.class);
                int i;
                for(i = 0; i < picturePaths.size(); i++)
                {
                    intent.putExtra(Constants.PICTURE_PATH + i, picturePaths.get(i));
                }
                intent.putExtra(Constants.NUM_OF_PICS, i);
                startActivityForResult(intent, 1);
            }
        });

        titleEditText = (EditText) findViewById(R.id.titleField);
        priceEditText = (EditText) findViewById(R.id.priceField);
        descriptionEditText = (EditText) findViewById(R.id.descriptionField);

        facebookSwitch = (SwitchCompat) findViewById(R.id.share);
        facebookSwitch.setChecked(true);

        //productPictureViews.add((ImageView) findViewById(R.id.firstImage));

    }

    public int dpToPx(int dp)
    {
        DisplayMetrics displayMetrics = this.getResources().getDisplayMetrics();
        int px = Math.round(dp * (displayMetrics.xdpi / DisplayMetrics.DENSITY_DEFAULT));
        return px;
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        if (requestCode == REQUEST_TAKE_PHOTO && resultCode == RESULT_OK) {
            ArrayList<String> paths = new ArrayList<>();
            int i = 0;
            while(i < data.getIntExtra(Constants.NUM_OF_PICS, 0)) {
                paths.add(data.getStringExtra(Constants.PICTURE_PATH + i));
                i++;
            }
            if(data.hasExtra(Constants.VIDEO_PATH))
                video = new File(data.getStringExtra(Constants.VIDEO_PATH));

            for (String path : paths) {
                RelativeLayout relativeLayout = (RelativeLayout) findViewById(R.id.imageCollection);
                RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(
                        RelativeLayout.LayoutParams.WRAP_CONTENT,
                        RelativeLayout.LayoutParams.MATCH_PARENT);
                final BitmapFactory.Options options = new BitmapFactory.Options();
                options.inSampleSize = 8;

                Bitmap temp = ThumbnailUtils.extractThumbnail(BitmapFactory.decodeFile(path, options), dpToPx(250), dpToPx(250));

                FileOutputStream fileOutputStream;

                try {
                    fileOutputStream = new FileOutputStream(path);
                    Bitmap.createScaledBitmap(temp, 640, 640, true)
                            .compress(Bitmap.CompressFormat.JPEG, 85, fileOutputStream);
                    fileOutputStream.flush();
                    fileOutputStream.close();
                }
                catch (Exception e) {
                    Log.v("Bitmap scaling error", ""+e.getMessage());
                }

                ImageView imageView = new ImageView(this);
                imageView.setId(productPictureViews.size() + 1);
                //imageView.setImageBitmap(temp);

                if (imageView.getId() != 1) {
                    ImageView previous = productPictureViews.get(productPictureViews.size() - 1);
                    layoutParams.addRule(RelativeLayout.RIGHT_OF, previous.getId());
                    imageView.setPadding(10, 0, 0, 0);
                }
                imageView.setLayoutParams(layoutParams);
                imageView.setAdjustViewBounds(true);
                imageView.setScaleType(ImageView.ScaleType.FIT_CENTER);

                relativeLayout.addView(imageView);
                Glide.with(this).load(new File(path)).
                        fitCenter().crossFade().into(imageView);
                //productPictures.add(temp);
                productPictureViews.add(imageView);
                picturePaths.add(path);
            }
        }

        else {
            super.onActivityResult(requestCode, resultCode, data);
            callbackManager.onActivityResult(requestCode, resultCode, data);
        }
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu)
    {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_add_item, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }


//    public void addAnotherImage(View view)
//    {
//        if (picturePaths.size() == MAX_IMAGE_COUNT) {
//            Toast.makeText(this, "5 Pictures Max!", Toast.LENGTH_SHORT).show();
//            return;
//        }
//
//        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
//        if (intent.resolveActivity(getPackageManager()) != null)  //TODO: Add my own mCamera interface so that only square pictures are taken
//        {
//            File photoFile = null;
//            try {
//                photoFile = createImageFile();
//            }
//            catch (Exception e) {
//
//            }
//            if (photoFile != null) {
//                intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(photoFile));
//                startActivityForResult(intent, REQUEST_TAKE_PHOTO);
//            }
//        }
//
//    }

    public void uploadItem(View view)
    {
        title = titleEditText.getText().toString();
        price = priceEditText.getText().toString();
        description = descriptionEditText.getText().toString();

        boolean shareFB = facebookSwitch.isChecked();
        JsonObject json = null;
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);

        if (!title.equals("") && !price.equals("") && !description.equals("")) {

            ProgressDialog dialog = new ProgressDialog(this);
            dialog.show();
            json = new ServerCalls(this).addItem(title, description, price, "Pick-up", "", picturePaths, video,
                    preferences.getString(Constants.AUTH_TOKEN, ""), preferences.getString(Constants.UUID, ""),
                    preferences.getString(Constants.LOCATION, "0,0"));
            dialog.dismiss();
        }

        if (shareFB && json != null && json.has("status") && json.get("status").getAsInt() == 1) {

            ShareDialog.show(this, new ShareLinkContent.Builder()
                    .setContentUrl(Uri.parse("https://app.bakkle.com/items/" + json.get("item_id").getAsString() + "/"))
                    .setImageUrl(Uri.parse(json.get("image_url").getAsString()))
                    .setContentDescription(description)
                    .build());
        }

        finish();
        new FeedFragment().new bgTask().execute();
    }

    @Override
    public void onBackPressed()
    {
        Intent intent = new Intent(AddItemActivity.this, CameraActivity.class);
        int i;
        for(i = 0; i < picturePaths.size(); i++)
        {
            intent.putExtra(Constants.PICTURE_PATH + i, picturePaths.get(i));
        }
        intent.putExtra(Constants.NUM_OF_PICS, i);
        startActivityForResult(intent, 1);
    }
}
