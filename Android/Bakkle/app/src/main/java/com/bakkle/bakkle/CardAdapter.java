package com.bakkle.bakkle;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.andtinder.CircleImageView;

/**
 * Created by vanshgandhi on 7/1/15.
 */
public class CardAdapter extends ArrayAdapter<FeedItem> {

    public CardAdapter(Context c){
        super(c, R.layout.card_layout);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent){
        if(convertView == null) {
            LayoutInflater inflater = LayoutInflater.from(getContext());
            convertView = inflater.inflate(R.layout.card_layout, parent, false);
            assert convertView != null;
        }


        ((ImageView) convertView.findViewById(com.andtinder.R.id.image)).setImageBitmap(getItem(position).getFirstImage());
        ((CircleImageView) convertView.findViewById(com.andtinder.R.id.sellerImage)).setImageBitmap(getItem(position).getSellerImage());
        ((TextView) convertView.findViewById(com.andtinder.R.id.title)).setText(getItem(position).getTitle());
        ((TextView) convertView.findViewById(com.andtinder.R.id.seller)).setText(getItem(position).getSellerDisplayName());
        ((TextView) convertView.findViewById(com.andtinder.R.id.price)).setText("$" + getItem(position).getPrice());
        ((TextView) convertView.findViewById(com.andtinder.R.id.location)).setText(getItem(position).getDistance());
        ((TextView) convertView.findViewById(com.andtinder.R.id.method)).setText(getItem(position).getMethod());

        return convertView;
    }
}
