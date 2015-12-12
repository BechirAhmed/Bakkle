package com.bakkle.bakkle;

import android.content.Context;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.text.method.ScrollingMovementMethod;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.MediaController;
import android.widget.TextView;
import android.widget.VideoView;

import com.android.volley.toolbox.ImageLoader;
import com.android.volley.toolbox.NetworkImageView;
import com.viewpagerindicator.CirclePageIndicator;

public class ItemDetailActivity extends AppCompatActivity
{
    NetworkImageView profilePictureImageView;
    TextView         sellerTextView;
    TextView         distanceTextView;
    TextView         titleTextView;
    TextView         priceTextView;
    TextView         descriptionTextView;
    //ViewPager        imagesViewPager;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_item_detail);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        toolbar.setTitle("Details");
        setSupportActionBar(toolbar);
        if (getSupportActionBar() != null) {
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }

        final FeedItem item = (FeedItem) getIntent().getSerializableExtra(Constants.FEED_ITEM);
        final ImageLoader imageLoader = Server.getInstance().getImageLoader();

        ViewPager viewPager = (ViewPager) findViewById(R.id.images);
        ImagePagerAdapter adapter = new ImagePagerAdapter(item.getImage_urls());
        viewPager.setAdapter(adapter);
        ((CirclePageIndicator) findViewById(R.id.indicator)).setViewPager(viewPager);
        ((CirclePageIndicator) findViewById(R.id.indicator)).setSnap(true);

        //imagesViewPager = (ViewPager) findViewById(R.id.images);
        profilePictureImageView = (NetworkImageView) findViewById(R.id.prof_pic);
        sellerTextView = (TextView) findViewById(R.id.seller);
        distanceTextView = (TextView) findViewById(R.id.distance);
        titleTextView = (TextView) findViewById(R.id.title);
        priceTextView = (TextView) findViewById(R.id.price);
        descriptionTextView = (TextView) findViewById(R.id.description);
        descriptionTextView.setMovementMethod(new ScrollingMovementMethod());

        sellerTextView.setText(item.getSeller().getDisplay_name());
        distanceTextView.setText("1 mile"); //TODO: Get Distance!
        titleTextView.setText(item.getTitle());
        priceTextView.setText('$' + item.getPrice());
        descriptionTextView.setText(item.getDescription());

        profilePictureImageView.setDefaultImageResId(R.drawable.ic_account_circle);
        profilePictureImageView.setErrorImageResId(R.drawable.ic_account_circle);
        profilePictureImageView.setImageUrl("http://graph.facebook.com/" + item.getSeller()
                .getFacebook_id() + "/picture?type=normal", imageLoader);

        findViewById(R.id.fab_want).setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {
                setResult(Constants.RESULT_CODE_WANT);
                finish();
            }
        });

        findViewById(R.id.fab_nope).setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {
                setResult(Constants.RESULT_CODE_NOPE);
                finish();
            }
        });
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        finish();
        return true;

    }

    private class ImagePagerAdapter extends PagerAdapter
    {
        String[] urls;

        public ImagePagerAdapter(String[] urls)
        {
            this.urls = urls;
        }

        @Override
        public int getCount()
        {
            return urls.length;
        }

        @Override
        public boolean isViewFromObject(View view, Object object)
        {
            return view == object;
        }

        @Override
        public Object instantiateItem(ViewGroup container, int position)
        {
            Context context = ItemDetailActivity.this;
            if (urls[position].endsWith(".jpg")) {
                NetworkImageView imageView = new NetworkImageView(context);
                imageView.setScaleType(ImageView.ScaleType.FIT_CENTER);
                imageView.setImageUrl(urls[position], Server.getInstance().getImageLoader());
                container.addView(imageView, 0);
                return imageView;
            } else { //It's a video
                VideoView videoView = new VideoView(context);
                final MediaController vidControl = new MediaController(context, false);
                vidControl.setAnchorView(videoView);
                videoView.setMediaController(vidControl);
                vidControl.hide();
                videoView.setVideoURI(Uri.parse(urls[position]));
                videoView.start();
                videoView.setOnClickListener(new View.OnClickListener()
                {
                    @Override
                    public void onClick(View v)
                    {
                        if (((VideoView)v).isPlaying()) {
                            ((VideoView)v).pause();
                            vidControl.hide();
                        } else {
                            ((VideoView)v).start();
                            vidControl.hide();
                        }
                    }
                });

                container.addView(videoView, 0);
                return videoView;
            }
        }

        @Override
        public void destroyItem(ViewGroup container, int position, Object object)
        {
            container.removeView((View) object);
        }
    }

}
