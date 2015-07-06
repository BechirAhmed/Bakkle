package com.bakkle.bakkle;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.daimajia.swipe.adapters.ArraySwipeAdapter;

import java.util.ArrayList;

/**
 * Created by vanshgandhi on 7/2/15.
 */
public class GarageAdapter extends ArraySwipeAdapter<FeedItem> {

    Context c;
    ArrayList<FeedItem> items;

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
        //TextView total;

    }

    public GarageAdapter(Context context, ArrayList<FeedItem> items){
        super(context, R.layout.garage_list_item, items);
        this.c = context;
        this.items = items;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent){
        FeedItem item = (FeedItem) getItem(position);
        ViewHolder viewHolder;
        if(convertView == null){
            viewHolder = new ViewHolder();
            convertView = LayoutInflater.from(getContext()).inflate(R.layout.garage_list_item, parent, false);
            viewHolder.icon = (ImageView) convertView.findViewById(R.id.icon);
            viewHolder.title = (TextView) convertView.findViewById(R.id.title);
            viewHolder.want = (TextView) convertView.findViewById(R.id.want_count);
            viewHolder.hold = (TextView) convertView.findViewById(R.id.hold_count);
            viewHolder.nope = (TextView) convertView.findViewById(R.id.nope_count);
            viewHolder.price = (TextView) convertView.findViewById(R.id.price);
            //viewHolder.total = (TextView) convertView.findViewById(R.id.total);
            convertView.setTag(viewHolder);
        }
        else {
            viewHolder = (ViewHolder) convertView.getTag();
        }


        viewHolder.icon.setImageBitmap(item.getFirstImage());
        viewHolder.title.setText(item.getTitle());
        viewHolder.price.setText("$" + item.getPrice());
        viewHolder.want.setText(item.getNumWant());
        viewHolder.hold.setText(item.getNumWant());
        viewHolder.nope.setText(item.getNumWant());

//        viewHolder.icon.setImageDrawable(c.getDrawable(R.drawable.bakkle_icon));
//        viewHolder.title.setText("Title");
//        viewHolder.want.setText("3");
//        viewHolder.hold.setText("3");
//        viewHolder.nope.setText("3");
//        viewHolder.price.setText("$5");

        return convertView;
    }
}
