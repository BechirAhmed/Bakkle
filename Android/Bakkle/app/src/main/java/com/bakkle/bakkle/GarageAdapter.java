package com.bakkle.bakkle;

import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.drawable.Drawable;
import android.preference.PreferenceManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.daimajia.swipe.adapters.ArraySwipeAdapter;

import java.util.ArrayList;

/**
 * Created by vanshgandhi on 7/2/15.
 */
public class GarageAdapter extends ArraySwipeAdapter<FeedItem> {

    Context c;
    ArrayList<FeedItem> items;
    ServerCalls serverCalls;
    SharedPreferences preferences;

    @Override
    public int getSwipeLayoutResourceId(int i) {
        return R.layout.garage_list_item;
    }

    private static class ViewHolder{
        ImageView icon;
        TextView title;
        TextView price;
        TextView want;
        TextView hold;
        TextView nope;
        Button delete;
        //TextView total;

    }

    AsyncImageLoader asyncImageLoader;

    public GarageAdapter(Context context, ArrayList<FeedItem> items){
        super(context, R.layout.garage_list_item, items);
        this.c = context;
        this.items = items;
        asyncImageLoader = new AsyncImageLoader(context);
        serverCalls = new ServerCalls(c);
        preferences = PreferenceManager.getDefaultSharedPreferences(c);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent){
        final FeedItem item = (FeedItem) getItem(position);
        final ViewHolder viewHolder;
        if(convertView == null){
            viewHolder = new ViewHolder();
            convertView = LayoutInflater.from(getContext()).inflate(R.layout.garage_list_item, parent, false);
            viewHolder.icon = (ImageView) convertView.findViewById(R.id.icon);
            viewHolder.title = (TextView) convertView.findViewById(R.id.title);
            viewHolder.want = (TextView) convertView.findViewById(R.id.want_count);
            viewHolder.hold = (TextView) convertView.findViewById(R.id.hold_count);
            viewHolder.nope = (TextView) convertView.findViewById(R.id.nope_count);
            viewHolder.price = (TextView) convertView.findViewById(R.id.price);
            viewHolder.delete = (Button) convertView.findViewById(R.id.delete);
            //viewHolder.total = (TextView) convertView.findViewById(R.id.total);
            convertView.setTag(viewHolder);
        }
        else {
            viewHolder = (ViewHolder) convertView.getTag();
        }

        Drawable cachedImage = asyncImageLoader.loadDrawable(item.getImageUrls().get(0), new AsyncImageLoader.ImageCallback() {
            public void imageLoaded(Drawable imageDrawable, String imageUrl) {
                viewHolder.icon.setImageDrawable(imageDrawable);
            }
        });
        //viewHolder.icon.setImageDrawable(cachedImage);
        viewHolder.title.setText(item.getTitle());
        viewHolder.price.setText("$" + item.getPrice());
        viewHolder.want.setText(item.getNumWant());
        viewHolder.hold.setText(item.getNumHold());
        viewHolder.nope.setText(item.getNumMeh());
        viewHolder.delete.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Toast.makeText(c, "You are in the delete Item page", Toast.LENGTH_SHORT).show();
                //serverCalls.deleteItem(preferences.getString("auth_token", "0"), preferences.getString("uuid", "0"), item.getPk());
            }
        });

        return convertView;
    }
}
