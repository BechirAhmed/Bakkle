package com.bakkle.bakkle;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.andtinder.CircleImageView;
import com.koushikdutta.ion.Ion;

import java.util.ArrayList;


public class ItemDetail extends AppCompatActivity {

    private Toolbar toolbar;
    private ArrayList<ImageView> productPictureViews = new ArrayList<>();

    String title;
    String price;
    String description;
    String sellerImageUrl;
    ArrayList <String> imageURLs;
    String url1;
    String seller;
    String distance;
    String pk;

    ServerCalls serverCalls;
    SharedPreferences preferences;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_item_detail);
  //      toolbar = (Toolbar) findViewById(R.id.toolbar);
//        setSupportActionBar(toolbar);

        Intent intent = getIntent();
        serverCalls = new ServerCalls(this);
        preferences = PreferenceManager.getDefaultSharedPreferences(this);

        title = intent.getStringExtra("title");
        price = intent.getStringExtra("price");
        description = intent.getStringExtra("description");
        seller = intent.getStringExtra("seller");
        distance = intent.getStringExtra("distance");
        url1 = intent.getStringExtra("url1");
        pk = intent.getStringExtra("pk");
        sellerImageUrl = intent.getStringExtra("sellerImageUrl");
        //imageURLs = intent.getStringArrayListExtra("imageURLs");

        Log.v("test", title + price + description + seller + distance);


        loadPictureIntoView(url1);
//        for(String url : imageURLs)
//        {
//            loadPictureIntoView(url);
//        }

        ((TextView) findViewById(R.id.seller)).setText(seller);
        ((TextView) findViewById(R.id.title)).setText(title);
        ((TextView) findViewById(R.id.description)).setText(description);
        ((TextView) findViewById(R.id.distance)).setText(distance);
        ((TextView) findViewById(R.id.price)).setText(price);

        Ion.with((ImageView) findViewById(R.id.sellerImage))
                .placeholder(R.drawable.loading)
                .load(sellerImageUrl);
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_item_detail, menu);
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

    public void loadPictureIntoView(String url)
    {
        RelativeLayout relativeLayout = (RelativeLayout) findViewById(R.id.imageCollection);
        ImageView imageView = new ImageView(this);
        imageView.setId(productPictureViews.size() + 1);
        //imageView.setImageBitmap(temp);
        Ion.with(imageView)
                .placeholder(R.drawable.loading)
                .load(url);
        RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.MATCH_PARENT);
        if(imageView.getId() != 1){
            ImageView previous = productPictureViews.get(productPictureViews.size() - 1);
            layoutParams.addRule(RelativeLayout.RIGHT_OF, previous.getId());
            imageView.setPadding(10, 0, 0, 0);
        }
        imageView.setLayoutParams(layoutParams);
        imageView.setAdjustViewBounds(true);
        imageView.setScaleType(ImageView.ScaleType.FIT_CENTER);

        relativeLayout.addView(imageView);
    }

    public void markWant(View view){
        serverCalls.markItem("want",
                preferences.getString("auth_token", "0"),
                preferences.getString("uuid", "0"),
                pk,
                "42");
        finish();
    }

    public void end(View view){
        finish();
    }
}
