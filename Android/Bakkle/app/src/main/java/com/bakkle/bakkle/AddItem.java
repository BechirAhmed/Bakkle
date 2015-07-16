package com.bakkle.bakkle;

import android.app.ActionBar;
import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.ThumbnailUtils;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.preference.PreferenceManager;
import android.provider.MediaStore;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.SwitchCompat;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.Spinner;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.JsonObject;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;


public class AddItem extends AppCompatActivity{

    private ActionBar mActionBar;

    String mCurrentPhotoPath;
    static final int REQUEST_TAKE_PHOTO = 1;
    static final int MAX_IMAGE_COUNT = 5;
    EditText titleEditText, priceEditText, tagsEditText;
    Spinner methodSpinner;
    SwitchCompat facebookSwitch;
    //Bitmap firstPhoto;
    //ImageView firstImageView;
    //ArrayList <Bitmap> productPictures = new ArrayList<>();
    ArrayList <ImageView> productPictureViews = new ArrayList<>();
    ArrayList <String> picturePaths = new ArrayList<>();
    final String[] commonWords = {"the", "of", "and", "a", "to", "in", "is", "you",
            "that", "it", "he", "was", "for", "on", "are", "as", "with", "his", "they", "i", "at",
            "be", "this", "have", "from", "or", "one", "had", "by", "but", "not", "what", "all",
            "were", "we", "when", "your", "can", "said", "there", "use", "an", "each", "which",
            "she", "do", "how", "their", "if", "will", "up", "other", "about", "out", "many",
            "then", "them", "these", "so", "some", "her"," would", "make", "like", "him", "into",
            "has", "look", "more", "write", "go", "see", "no", "way", "could", "people", "my",
            "than", "first", "been", "call", "who","its","now","find","down","day","did","get",
            "come","made","may","part", "another", "any", "anybody", "anyone", "anything", "both",
            "either", "everybody", "everyone", "everything", "am"};

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        if(intent.resolveActivity(getPackageManager()) != null)  //TODO: Add my own camera interface so that only square pictures are taken
        {
            File photoFile = null;
            try
            {
                photoFile = createImageFile();
            }
            catch (Exception e)
            {
                Log.v("create image file error", e.getMessage());
            }
            if(photoFile != null) {
                intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(photoFile));
                startActivityForResult(intent, REQUEST_TAKE_PHOTO);
            }
        }
        setContentView(R.layout.activity_add_item);

//        mActionBar = getActionBar();
//        mActionBar.setDisplayShowHomeEnabled(false);
//        mActionBar.setDisplayShowTitleEnabled(false);
        LayoutInflater mInflater = LayoutInflater.from(this);

        View mCustomView = mInflater.inflate(R.layout.action_bar_title, null);

        TextView textView = (TextView) mCustomView.findViewById(R.id.action_bar_title);

        textView.setText("List Item");

        mCustomView.findViewById(R.id.action_bar_home).setVisibility(View.GONE);
        mCustomView.findViewById(R.id.action_bar_right).setVisibility(View.GONE);


//        mActionBar.setCustomView(mCustomView);
//        mActionBar.setDisplayShowCustomEnabled(true);

        titleEditText = (EditText) findViewById(R.id.titleField);
        priceEditText = (EditText) findViewById(R.id.priceField);
        tagsEditText = (EditText) findViewById(R.id.tagsField);

        methodSpinner = (Spinner) findViewById(R.id.methodPicker);

        facebookSwitch = (SwitchCompat) findViewById(R.id.share);

        //productPictureViews.add((ImageView) findViewById(R.id.firstImage));

    }

    private File createImageFile() throws IOException {
        // Create an image file name
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String imageFileName = "Bakkle_" + timeStamp + "_";
        File storageDir = Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_PICTURES);
        File image = File.createTempFile(
                imageFileName,  /* prefix */
                ".jpg",         /* suffix */
                storageDir      /* directory */
        );

        // Save a file: path for use with ACTION_VIEW intents
        mCurrentPhotoPath = image.getAbsolutePath();
        return image;
    }

    public int dpToPx(int dp) {
        DisplayMetrics displayMetrics = this.getResources().getDisplayMetrics();
        int px = Math.round(dp * (displayMetrics.xdpi / DisplayMetrics.DENSITY_DEFAULT));
        return px;
    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        if(requestCode == REQUEST_TAKE_PHOTO && resultCode == RESULT_OK)
        {

            Matrix matrix = new Matrix();
            matrix.postRotate(90);

            Bitmap temp = ThumbnailUtils.extractThumbnail(BitmapFactory.decodeFile(mCurrentPhotoPath), dpToPx(250), dpToPx(250));
            temp = Bitmap.createBitmap(temp, 0, 0, temp.getWidth(), temp.getHeight(), matrix, true); //rotate picture 90 degrees


            FileOutputStream fileOutputStream = null;

            try {
                fileOutputStream = new FileOutputStream(mCurrentPhotoPath);
                Bitmap.createScaledBitmap(BitmapFactory.decodeFile(mCurrentPhotoPath), 640, 640, true)
                        .compress(Bitmap.CompressFormat.JPEG, 70, fileOutputStream);
                fileOutputStream.flush();
                fileOutputStream.close();
            }
            catch (Exception e){
                Log.v("Bitmap scaling error", e.getMessage());
            }

            //productPictureViews.get(productPictureViews.size() - 1).setImageBitmap(temp);

            RelativeLayout relativeLayout = (RelativeLayout) findViewById(R.id.imageCollection);
            ImageView imageView = new ImageView(this);
            imageView.setId(productPictureViews.size() + 1);
            imageView.setImageBitmap(temp);
            RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(
                    RelativeLayout.LayoutParams.WRAP_CONTENT,
                    RelativeLayout.LayoutParams.MATCH_PARENT);
            if(imageView.getId() == 1){
            }
            else{
                ImageView previous = productPictureViews.get(productPictureViews.size() - 1);
                layoutParams.addRule(RelativeLayout.RIGHT_OF, previous.getId());
                imageView.setPadding(10, 0, 0, 0);
            }
            imageView.setLayoutParams(layoutParams);
            imageView.setAdjustViewBounds(true);
            imageView.setScaleType(ImageView.ScaleType.FIT_CENTER);

            relativeLayout.addView(imageView);

            //productPictures.add(temp);
            productPictureViews.add(imageView);
            picturePaths.add(mCurrentPhotoPath);
            temp = null;
            imageView = null;
            relativeLayout = null;
        }
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_add_item, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
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


    public void addAnotherImage(View view)
    {
        if(picturePaths.size() == MAX_IMAGE_COUNT){
            Toast.makeText(this, "5 Pictures Max!", Toast.LENGTH_SHORT).show();
            return;
        }

        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        if(intent.resolveActivity(getPackageManager()) != null)  //TODO: Add my own camera interface so that only square pictures are taken
        {
            File photoFile = null;
            try
            {
                photoFile = createImageFile();
            }
            catch (Exception e)
            {

            }
            if(photoFile != null) {
                intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(photoFile));
                startActivityForResult(intent, REQUEST_TAKE_PHOTO);
            }
        }

    }

    public void uploadItem(View view)
    {
        String title = titleEditText.getText().toString();
        String price = priceEditText.getText().toString();
        String tags = tagsEditText.getText().toString();
        String description = "";
        String method = methodSpinner.getSelectedItem().toString();

        boolean shareFB = facebookSwitch.isChecked();

        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);

        JsonObject json = new ServerCalls(this).addItem(title, description, price, method, tags, picturePaths, shareFB,
            preferences.getString("auth_token", "0"), preferences.getString("uuid", "0"));


    }
}
