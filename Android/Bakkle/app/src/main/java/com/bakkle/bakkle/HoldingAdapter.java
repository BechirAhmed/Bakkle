package com.bakkle.bakkle;

import android.content.Context;
import android.os.CountDownTimer;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.ArrayList;

/**
 * Created by vanshgandhi on 6/26/15.
 */
public class HoldingAdapter extends ArrayAdapter<FeedItem>{

    private static class ViewHolder{
        ImageView icon;
        TextView title;
        TextView method;
        TextView tags;
        TextView distance;
        TextView price;
        TextView clock;
    }

    public HoldingAdapter(Context context, ArrayList<FeedItem> items){
        super(context, R.layout.buyers_trunk_list_item, items);
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


        viewHolder.icon.setImageBitmap(item.getFirstImage());
        viewHolder.title.setText(item.getTitle());
        viewHolder.method.setText(item.getMethod());
        viewHolder.tags.setText("Tags: " + item.getTagsString());
        viewHolder.distance.setText(item.getDistance());
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
