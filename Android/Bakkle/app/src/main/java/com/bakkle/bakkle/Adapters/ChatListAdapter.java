package com.bakkle.bakkle.Adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.bakkle.bakkle.Helpers.BuyerInfo;
import com.bakkle.bakkle.R;
import com.bumptech.glide.Glide;

import java.util.ArrayList;

/**
 * Created by vanshgandhi on 7/30/15.
 */
public class ChatListAdapter extends ArrayAdapter<BuyerInfo> {

    ArrayList<BuyerInfo> items;
    Context c;


    public ChatListAdapter(Context context, ArrayList<BuyerInfo> objects) {
        super(context, R.layout.chat_list_item, objects);
        items = objects;
        c = context;
    }

    public static class ViewHolder{

        TextView nameText;
        ImageView picture;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent){

        final BuyerInfo item = getItem(position);
        final ViewHolder viewHolder;
        if(convertView == null){
            viewHolder = new ViewHolder();
            convertView = LayoutInflater.from(getContext()).inflate(R.layout.chat_list_item, parent, false);
            viewHolder.picture = (ImageView) convertView.findViewById(R.id.icon);
            viewHolder.nameText = (TextView) convertView.findViewById(R.id.buyer_name);
            convertView.setTag(viewHolder);
        }
        else {
            viewHolder = (ViewHolder) convertView.getTag();
        }


        viewHolder.nameText.setText(item.getName());
        Glide.with(c)
                .load(item.getFacebookURL())
                .thumbnail(0.1f)
                .crossFade()
                .into(viewHolder.picture);

        return convertView;
    }

    @Override
    public boolean hasStableIds() {
        return true;
    }
}
