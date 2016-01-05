package com.bakkle.bakkle;

import android.location.Location;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.text.method.ScrollingMovementMethod;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.bakkle.bakkle.Models.FeedItem;
import com.squareup.picasso.Picasso;
import com.viewpagerindicator.CirclePageIndicator;

public class ItemDetailActivity extends AppCompatActivity
{
    ImageView profilePictureImageView;
    TextView  sellerTextView;
    TextView  distanceTextView;
    TextView  titleTextView;
    TextView  priceTextView;
    TextView  descriptionTextView;
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

        ViewPager viewPager = (ViewPager) findViewById(R.id.images);
        ImagePagerAdapter adapter = new ImagePagerAdapter(this, item.getImage_urls());
        viewPager.setAdapter(adapter);
        ((CirclePageIndicator) findViewById(R.id.indicator)).setViewPager(viewPager);
        ((CirclePageIndicator) findViewById(R.id.indicator)).setSnap(true);

        FloatingActionButton fabNope = (FloatingActionButton) findViewById(R.id.fab_nope);
        FloatingActionButton fabWant = (FloatingActionButton) findViewById(R.id.fab_want);

        profilePictureImageView = (ImageView) findViewById(R.id.prof_pic);
        sellerTextView = (TextView) findViewById(R.id.seller);
        distanceTextView = (TextView) findViewById(R.id.distance);
        titleTextView = (TextView) findViewById(R.id.title);
        priceTextView = (TextView) findViewById(R.id.price);
        descriptionTextView = (TextView) findViewById(R.id.description);
        descriptionTextView.setMovementMethod(new ScrollingMovementMethod());

        sellerTextView.setText(item.getSeller().getDisplay_name());

        String itemLocation = item.getLocation();
        String[] latLong = itemLocation.split(",");
        String lat = latLong[0];
        String longitude = latLong[1];
        float userLat = Prefs.getInstance().getLatitude();
        float userLong = Prefs.getInstance().getLongitude();
        Location loc1 = new Location("");
        loc1.setLatitude(userLat);
        loc1.setLongitude(userLong);
        Location loc2 = new Location("");
        loc2.setLatitude(Double.valueOf(lat));
        loc2.setLongitude(Double.valueOf(longitude));
        double distanceInMiles = loc1.distanceTo(loc2) * 0.00062137;
        distanceTextView.setText(String.valueOf(Math.round(distanceInMiles)).concat(" miles"));

        titleTextView.setText(item.getTitle());
        priceTextView.setText("$".concat(item.getPrice()));
        descriptionTextView.setText(item.getDescription());
        //"http://graph.facebook.com/" + item.getSeller().getFacebook_id() + "/picture?type=normal"

        Picasso.with(this)
                .load(item.getSeller().getAvatar_image_url())
                .fit()
                .centerCrop()
                .into(profilePictureImageView);

        if (getIntent().getBooleanExtra(Constants.SHOW_NOPE, false)) {
            fabNope.setOnClickListener(new View.OnClickListener()
            {
                @Override
                public void onClick(View view)
                {
                    setResult(Constants.RESULT_CODE_NOPE);
                    finish();
                }
            });
        } else {
            fabNope.setVisibility(View.GONE);
        }

        if (getIntent().getBooleanExtra(Constants.SHOW_WANT, false)) {
            fabWant.setOnClickListener(new View.OnClickListener()
            {
                @Override
                public void onClick(View view)
                {
                    Snackbar.make(view, "Item moved to Buying",
                                  Snackbar.LENGTH_LONG); //TODO: Make the snackbar have an undo button
                    setResult(Constants.RESULT_CODE_WANT);
                    finish();
                }
            });
        } else {
            fabWant.setVisibility(View.GONE);
        }

    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        finish();
        return true;

    }

}
