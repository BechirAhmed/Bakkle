package com.bakkle.bakkle.Adapters;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.CountDownTimer;
import android.preference.PreferenceManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.bakkle.bakkle.Helpers.FeedItem;
import com.bakkle.bakkle.R;
import com.bumptech.glide.Glide;

import java.util.ArrayList;

/**
 * Created by vanshgandhi on 6/26/15.
 */
public class HoldingAdapter extends ArrayAdapter<FeedItem>{

    SharedPreferences preferences;
    Context context;

    private static class ViewHolder{
        ImageView icon;
        TextView title;
        TextView method;
        TextView tags;
        TextView distance;
        TextView price;
        TextView clock;
    }

    //AsyncImageLoader asyncImageLoader;
    public HoldingAdapter(Context context, ArrayList<FeedItem> items){
        super(context, R.layout.buyers_trunk_list_item, items);
        this.context = context;
        //asyncImageLoader = new AsyncImageLoader(context);
        preferences = PreferenceManager.getDefaultSharedPreferences(context);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent){
        FeedItem item = getItem(position);
        final ViewHolder viewHolder;
        if(convertView == null){
            viewHolder = new ViewHolder();
            convertView = LayoutInflater.from(getContext()).inflate(R.layout.holding_pattern_list_item, parent, false);
            viewHolder.icon = (ImageView) convertView.findViewById(R.id.icon);
            viewHolder.title = (TextView) convertView.findViewById(R.id.title);
            viewHolder.method = (TextView) convertView.findViewById(R.id.method);
            viewHolder.tags = (TextView) convertView.findViewById(R.id.tags);
            viewHolder.distance = (TextView) convertView.findViewById(R.id.distance);
            viewHolder.price = (TextView) convertView.findViewById(R.id.price);
            viewHolder.clock = (TextView) convertView.findViewById(R.id.clock);
            convertView.setTag(viewHolder);
        }
        else {
            viewHolder = (ViewHolder) convertView.getTag();
        }


//        Drawable cachedImage = asyncImageLoader.loadDrawable(item.getImageUrls().get(0), new AsyncImageLoader.ImageCallback() {
//            public void imageLoaded(Drawable imageDrawable, String imageUrl) {
//                viewHolder.icon.setImageDrawable(imageDrawable);
//            }
//        });
//        viewHolder.icon.setImageDrawable(cachedImage);

        Glide.with(context)
                .load(item.getImageUrls().get(0))
                .centerCrop()
                .placeholder(R.drawable.loading)
                .crossFade()
                .into(viewHolder.icon);

        viewHolder.title.setText(item.getTitle());
        viewHolder.method.setText(item.getMethod());
        viewHolder.tags.setText("Tags: " + item.getTagsString());
        viewHolder.distance.setText(item.getDistance(preferences.getString("latitude", "0"), preferences.getString("longitude", "0")));
        viewHolder.price.setText("$" + item.getPrice());
        new CountDownTimer(5400000, 1000){
            public void onTick(long millisUntilFinished){
                viewHolder.clock.setText("Seconds left: " + millisUntilFinished/1000);

            }

            public void onFinish(){
                viewHolder.clock.setText("Expired!");

            }
        }.start();

        return convertView;
    }
}
