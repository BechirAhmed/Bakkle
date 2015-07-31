package com.bakkle.bakkle;

import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.drawable.Drawable;
import android.preference.PreferenceManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.ArrayList;

/**
 * Created by vanshgandhi on 6/26/15.
 */
public class TrunkAdapter extends ArrayAdapter<FeedItem>{

    ServerCalls serverCalls;
    SharedPreferences preferences;

    private static class ViewHolder{
        ImageView icon;
        TextView title;
        TextView method;
        TextView tags;
        TextView distance;
        TextView price;
        Button delete;

    }

    AsyncImageLoader asyncImageLoader;

    public TrunkAdapter(Context context, ArrayList<FeedItem> items){
        super(context, R.layout.buyers_trunk_list_item, items);
        asyncImageLoader = new AsyncImageLoader(context);
        serverCalls = new ServerCalls(context);
        preferences = PreferenceManager.getDefaultSharedPreferences(context);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent){
        final FeedItem item = getItem(position);
        final ViewHolder viewHolder;
        if(convertView == null){
            viewHolder = new ViewHolder();
            convertView = LayoutInflater.from(getContext()).inflate(R.layout.buyers_trunk_list_item, parent, false);
            viewHolder.icon = (ImageView) convertView.findViewById(R.id.icon);
            viewHolder.title = (TextView) convertView.findViewById(R.id.title);
            viewHolder.method = (TextView) convertView.findViewById(R.id.method);
            viewHolder.tags = (TextView) convertView.findViewById(R.id.tags);
            viewHolder.distance = (TextView) convertView.findViewById(R.id.distance);
            viewHolder.price = (TextView) convertView.findViewById(R.id.price);
            viewHolder.delete = (Button) convertView.findViewById(R.id.delete);
            convertView.setTag(viewHolder);
        }
        else {
            viewHolder = (ViewHolder) convertView.getTag();
        }


        //viewHolder.icon.setImageBitmap(item.getFirstImage());
        Drawable cachedImage = asyncImageLoader.loadDrawable(item.getImageUrls().get(0), new AsyncImageLoader.ImageCallback() {
            public void imageLoaded(Drawable imageDrawable, String imageUrl) {
                viewHolder.icon.setImageDrawable(imageDrawable);
            }
        });
        viewHolder.icon.setImageDrawable(cachedImage);
        viewHolder.title.setText(item.getTitle());
        viewHolder.method.setText(item.getMethod());
        viewHolder.tags.setText("Tags: " + item.getTagsString());
        viewHolder.distance.setText(item.getDistance(preferences.getString("latitude", "0"), preferences.getString("longitude", "0")));
        viewHolder.price.setText("$" + item.getPrice());
        viewHolder.delete.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                serverCalls.deleteItem(preferences.getString("auth_token", "0"), preferences.getString("uuid", "0"), item.getPk());
                remove(item);
//                notifyDataSetChanged();
            }
        });

        return convertView;
    }
}
