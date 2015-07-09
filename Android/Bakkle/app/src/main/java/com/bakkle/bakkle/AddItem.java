package com.bakkle.bakkle;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.annotation.IdRes;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.Toast;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;


public class AddItem extends Activity{

    String mCurrentPhotoPath;
    static final int REQUEST_TAKE_PHOTO = 1;
    static final int MAX_IMAGE_COUNT = 5;
    //Bitmap firstPhoto;
    //ImageView firstImageView;
    ArrayList <Bitmap> productPictures = new ArrayList<>();
    ArrayList <ImageView> productPictureViews = new ArrayList<>();
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

            }
            if(photoFile != null) {
                intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(photoFile));
                startActivityForResult(intent, REQUEST_TAKE_PHOTO);
            }
        }
        setContentView(R.layout.activity_add_item);

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

    protected void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        if(requestCode == REQUEST_TAKE_PHOTO && resultCode == RESULT_OK)
        {
            Bitmap temp = BitmapFactory.decodeFile(mCurrentPhotoPath);
            //productPictureViews.get(productPictureViews.size() - 1).setImageBitmap(temp);

            RelativeLayout relativeLayout = (RelativeLayout) findViewById(R.id.imageCollection);
            ImageView imageView = new ImageView(this);
            imageView.setId(productPictureViews.size() + 1);
            imageView.setImageBitmap(temp);
            RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(
                    RelativeLayout.LayoutParams.WRAP_CONTENT,
                    RelativeLayout.LayoutParams.MATCH_PARENT);
            if(imageView.getId() == 1){
                //layoutParams.addRule(RelativeLayout.LEFT_OF, R.id.add);
            }
            else{
                ImageView previous = productPictureViews.get(productPictureViews.size() - 1);
                layoutParams.addRule(RelativeLayout.RIGHT_OF, previous.getId());
                //layoutParams.addRule(RelativeLayout.LEFT_OF, R.id.add);
            }
            imageView.setLayoutParams(layoutParams);
            imageView.setAdjustViewBounds(true);
            imageView.setScaleType(ImageView.ScaleType.FIT_CENTER);
            imageView.setPadding(10, 0, 0, 0);

            relativeLayout.addView(imageView);

            productPictures.add(temp);
            productPictureViews.add(imageView);
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
        if(productPictures.size() == MAX_IMAGE_COUNT){
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
}
