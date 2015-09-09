package com.bakkle.bakkle.Adapters;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.preference.PreferenceManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.bakkle.bakkle.Activities.ItemDetailActivity;
import com.bakkle.bakkle.Helpers.FeedItem;
import com.bakkle.bakkle.Helpers.ServerCalls;
import com.bakkle.bakkle.R;
import com.bumptech.glide.Glide;
import com.daimajia.swipe.adapters.ArraySwipeAdapter;

import java.util.ArrayList;

/**
 * Created by vanshgandhi on 7/2/15.
 */
public class GarageAdapter extends ArraySwipeAdapter<FeedItem>
{

    Context c;
    ArrayList<FeedItem> items;
    ServerCalls serverCalls;
    SharedPreferences preferences;

    @Override
    public int getSwipeLayoutResourceId(int i)
    {
        return R.layout.garage_list_item;
    }

    private static class ViewHolder
    {
        ImageView icon;
        TextView title;
        TextView price;
        TextView want;
        TextView hold;
        TextView nope;
        Button delete;
        TextView total;
        FrameLayout frameLayout;

    }

    public GarageAdapter(Context context, ArrayList<FeedItem> items)
    {
        super(context, R.layout.garage_list_item, items);
        this.c = context;
        this.items = items;
        serverCalls = new ServerCalls(c);
        preferences = PreferenceManager.getDefaultSharedPreferences(c);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent)
    {
        final FeedItem item = (FeedItem) getItem(position);
        final ViewHolder viewHolder;
        if (convertView == null) {
            viewHolder = new ViewHolder();
            convertView = LayoutInflater.from(getContext()).inflate(R.layout.garage_list_item, parent, false);
            viewHolder.icon = (ImageView) convertView.findViewById(R.id.icon);
            viewHolder.title = (TextView) convertView.findViewById(R.id.title);
            viewHolder.want = (TextView) convertView.findViewById(R.id.want_count);
            viewHolder.hold = (TextView) convertView.findViewById(R.id.hold_count);
            viewHolder.nope = (TextView) convertView.findViewById(R.id.nope_count);
            viewHolder.price = (TextView) convertView.findViewById(R.id.price);
            viewHolder.delete = (Button) convertView.findViewById(R.id.delete);
            viewHolder.total = (TextView) convertView.findViewById(R.id.total_count);
            viewHolder.frameLayout = (FrameLayout) convertView.findViewById(R.id.frame_layout);
            convertView.setTag(viewHolder);
        }
        else {
            viewHolder = (ViewHolder) convertView.getTag();
        }

        Glide.with(c)
                .load(item.getImageUrls().get(0))
                .centerCrop()
                .thumbnail(0.1f)
                .crossFade()
                .into(viewHolder.icon);

        viewHolder.icon.setColorFilter(Color.rgb(123, 123, 123), android.graphics.PorterDuff.Mode.MULTIPLY);

        viewHolder.title.setText(item.getTitle());
        viewHolder.price.setText("$" + item.getPrice());
        viewHolder.want.setText(item.getNumWant());
        viewHolder.hold.setText(item.getNumHold());
        viewHolder.nope.setText(item.getNumMeh());
        viewHolder.total.setText(item.getNumView());
        viewHolder.delete.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {
                Toast.makeText(c, "You are in the delete Item page", Toast.LENGTH_SHORT).show();
                //serverCalls.deleteItem(preferences.getString("auth_token", "0"), preferences.getString("uuid", "0"), item.getPk());
            }
        });

        viewHolder.frameLayout.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {
                Intent intent = new Intent(c, ItemDetailActivity.class);
                intent.putExtra("title", item.getTitle());
                intent.putExtra("seller", item.getSellerDisplayName());
                intent.putExtra("price", item.getPrice());
                intent.putExtra("distance", item.getDistance(
                        preferences.getString("latitude", "0"),
                        preferences.getString("longitude", "0")));
                intent.putExtra("sellerImageUrl", "http://graph.facebook.com/" + item.getSellerFacebookId() + "/picture?width=142&height=142");
                intent.putExtra("description", item.getDescription());
                intent.putExtra("pk", item.getPk());
                intent.putExtra("garage", true);
                intent.putStringArrayListExtra("imageURLs", item.getImageUrls());
                c.startActivity(intent);
            }
        });

        return convertView;
    }
}
