package com.bakkle.bakkle.Activities;

import android.content.ClipData;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.media.ThumbnailUtils;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Environment;
import android.preference.PreferenceManager;
import android.provider.MediaStore;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;
import android.widget.MediaController;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.VideoView;

import com.bakkle.bakkle.Helpers.Constants;
import com.bakkle.bakkle.Helpers.ServerCalls;
import com.bakkle.bakkle.R;
import com.bumptech.glide.Glide;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;


public class ItemDetailActivity extends AppCompatActivity
{

    //    private Toolbar toolbar;
    private ArrayList<View> productPictureViews = new ArrayList<>();
    String            parent;
    String            title;
    String            price;
    String            description;
    String            sellerImageUrl;
    ArrayList<String> imageURLs;
    String            seller;
    String            distance;
    String            pk;
    String            videoFilepath;
    boolean           garage;
    ServerCalls       serverCalls;
    SharedPreferences preferences;
    RelativeLayout relativeLayout;
    RelativeLayout.LayoutParams layoutParams;
    //ProgressBar bar;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_item_detail);
        //      toolbar_home = (Toolbar) findViewById(R.id.toolbar_home);
//        setSupportActionBar(toolbar_home);

        Intent intent = getIntent();
        serverCalls = new ServerCalls(this);
        preferences = PreferenceManager.getDefaultSharedPreferences(this);
        garage = intent.getBooleanExtra(Constants.GARAGE, false);
        title = intent.getStringExtra(Constants.TITLE);
        price = intent.getStringExtra(Constants.PRICE);
        description = intent.getStringExtra(Constants.DESCRIPTION);
        seller = intent.getStringExtra(Constants.SELLER);
        distance = intent.getStringExtra(Constants.DISTANCE);
        pk = intent.getStringExtra(Constants.PK);
        sellerImageUrl = intent.getStringExtra(Constants.SELLER_IMAGE_URL);
        imageURLs = intent.getStringArrayListExtra(Constants.IMAGE_URLS);
        parent = intent.getStringExtra(Constants.PARENT);
        relativeLayout = (RelativeLayout) findViewById(R.id.imageCollection);
        layoutParams = new RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.MATCH_PARENT);
        if (imageURLs != null) {
            for (String url : imageURLs) {
                loadPictureIntoView(url);
            }
        }
        else {
            //https://dansimpsonpoet.files.wordpress.com/2014/04/image-not-found.png?w=1000
            loadPictureIntoView("http://camaleon.tuzitio.com/assets/image-not-found-4a963b95bf081c3ea02923dceaeb3f8085e1a654fc54840aac61a57a60903fef.png");
        }

        ((TextView) findViewById(R.id.seller)).setText(seller);
        ((TextView) findViewById(R.id.title)).setText(title);
        ((TextView) findViewById(R.id.description)).setText(description);
        ((TextView) findViewById(R.id.distance)).setText(distance);
        ((TextView) findViewById(R.id.price)).setText(price);
        if (garage) {
            findViewById(R.id.wantButton).setVisibility(View.GONE);
        }

        Glide.with(this)
                .load(sellerImageUrl)
                .into((ImageView) findViewById(R.id.sellerImage));
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu)
    {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_item_detail, menu);
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

    public void loadPictureIntoView(String url)
    {

        if (!url.endsWith("mp4")) {
            ImageView imageView = new ImageView(this);
            imageView.setId(productPictureViews.size() + 1);

            if (imageView.getId() != 1) {
                ImageView previous = (ImageView) productPictureViews.get(productPictureViews.size() - 1);
                layoutParams.addRule(RelativeLayout.RIGHT_OF, previous.getId());
                imageView.setPadding(10, 0, 0, 0);
            }

            imageView.setLayoutParams(layoutParams);
            imageView.setAdjustViewBounds(true);
            imageView.setScaleType(ImageView.ScaleType.FIT_CENTER);

            relativeLayout.addView(imageView);

            Glide.with(this)
                    .load(url)
                    .fitCenter()
                    .crossFade()
                    .placeholder(R.drawable.loading)
                    .into(imageView);
            productPictureViews.add(imageView);
        }
        else { //TODO: Display video
            new DownloadVideo().execute(url);
            File f = null;
            Bitmap bmp = ThumbnailUtils.createVideoThumbnail(videoFilepath, MediaStore.Images.Thumbnails.MINI_KIND);
            String videoFileName = "Bakkle_" + pk + "_";
            File storageDir = Environment.getExternalStoragePublicDirectory(
                    Environment.DIRECTORY_MOVIES);
            try { //TODO: do not redownload file if it already exists
                f = File.createTempFile(
                        videoFileName,  /* prefix */
                        ".mp4",         /* suffix */
                        storageDir      /* directory */
                );
            }
            catch (Exception e)
            {

            }
            FileOutputStream out = null;
            try {
                out = new FileOutputStream(f);
                bmp.compress(Bitmap.CompressFormat.PNG, 100, out); // bmp is your Bitmap instance
                // PNG is a lossless format, the compression factor (100) is ignored
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                try {
                    if (out != null) {
                        out.close();
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }

            ImageView imageView = new ImageView(this);
            imageView.setId(productPictureViews.size() + 1);

            if (imageView.getId() != 1) {
                ImageView previous = (ImageView) productPictureViews.get(productPictureViews.size() - 1);
                layoutParams.addRule(RelativeLayout.RIGHT_OF, previous.getId());
                imageView.setPadding(10, 0, 0, 0);
            }

            imageView.setLayoutParams(layoutParams);
            imageView.setAdjustViewBounds(true);
            imageView.setScaleType(ImageView.ScaleType.FIT_CENTER);
            imageView.setOnClickListener(new View.OnClickListener()
            {
                @Override
                public void onClick(View v)
                {
                    Intent intent = new Intent(ItemDetailActivity.this, WatchVideo.class);
                    intent.putExtra("filepath", videoFilepath);
                    startActivity(intent);
                }
            });
            relativeLayout.addView(imageView);

            Glide.with(this)
                    .load(f)
                    .fitCenter()
                    .crossFade()
                    .placeholder(R.drawable.loading)
                    .into(imageView);
            productPictureViews.add(imageView);
        }

    }

    public void markWant(View view)
    {
        serverCalls.markItem("want",
                preferences.getString(Constants.AUTH_TOKEN, ""),
                preferences.getString(Constants.UUID, ""),
                pk,
                "42");
        Intent intent = new Intent();
        intent.putExtra(Constants.MARK_WANT, true);
        if (parent.equals("feed")) {
            setResult(1, intent);
        }
        finish();
    }

    public void end(View view)
    {
        finish();
    }


    private class DownloadVideo extends AsyncTask<String, String, String>
    {
        @Override
        protected void onPreExecute()
        {
            //bar.setVisibility(View.VISIBLE);
        }

        @Override
        protected String doInBackground(String... f_url)
        {
            int count;
            File f = null;
            try {
                URL url = new URL(f_url[0]);
                URLConnection connection = url.openConnection();
                connection.connect();

                // this will be useful so that you can show a typical 0-100%
                // progress bar
                int lengthOfFile = connection.getContentLength();

                // download the file
                InputStream input = new BufferedInputStream(url.openStream()); //add lengthOfFile as parameter

                // Output stream
                String videoFileName = "Bakkle_" + pk + "_";
                File storageDir = Environment.getExternalStoragePublicDirectory(
                        Environment.DIRECTORY_MOVIES);
                try { //TODO: do not redownload file if it already exists
                    f = File.createTempFile(
                            videoFileName,  /* prefix */
                            ".mp4",         /* suffix */
                            storageDir      /* directory */
                    );
                }
                catch (Exception e)
                {

                }
                OutputStream output = new FileOutputStream(f);

                byte data[] = new byte[1024];

                long total = 0;

                while ((count = input.read(data)) != -1) {
                    total += count;
                    // publishing the progress....
                    // After this onProgressUpdate will be called
                    //publishProgress("" + (int) ((total * 100) / lengthOfFile));

                    // writing data to file
                    output.write(data, 0, count);
                }

                // flushing output
                output.flush();

                // closing streams
                output.close();
                input.close();

            } catch (Exception e) {
                Log.e("Error: ", e.getMessage());
            }
            videoFilepath = f.getPath();
            return videoFilepath;
        }


        @Override
        protected void onPostExecute(String file_url)
        {
            //bar.setVisibility(View.GONE);
            //Uri uri = Uri.parse(file_url); //Declare your url here.

//                bar = new ProgressBar(this);
//                RelativeLayout.LayoutParams barParams = new RelativeLayout.LayoutParams(
//                        RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
            MediaController vidControl = new MediaController(ItemDetailActivity.this);
            VideoView mVideoView = new VideoView(ItemDetailActivity.this);
            mVideoView.setId(productPictureViews.size() + 1);

            ImageView previous = (ImageView) productPictureViews.get(productPictureViews.size() - 1);

            //barParams.addRule(RelativeLayout.RIGHT_OF, previous.getId());


            layoutParams.addRule(RelativeLayout.RIGHT_OF, previous.getId());
            mVideoView.setPadding(10, 0, 0, 0);
            mVideoView.setLayoutParams(layoutParams);

//            mVideoView.setMediaController(new MediaController(ItemDetailActivity.this));
  //          mVideoView.requestFocus();
            mVideoView.setVideoPath(file_url);
            vidControl.setAnchorView(mVideoView);
            mVideoView.setMediaController(vidControl);
            mVideoView.start();
        }
    }


}