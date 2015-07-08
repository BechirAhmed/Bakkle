package com.bakkle.bakkle;


import android.os.Bundle;
import android.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;


/**
 * A simple {@link Fragment} subclass.
 */
public class ItemPage extends Fragment {

    FeedItem item;


    public ItemPage() {
        // Required empty public constructor
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_item_page, container, false);
    }

    public void setItem(FeedItem item){
        this.item = item;
        setupPage();
    }

    public void setupPage(){
        ImageView picture = (ImageView) getActivity().findViewById(R.id.itempic);
        TextView price = (TextView) getActivity().findViewById(R.id.price);
        TextView method = (TextView) getActivity().findViewById(R.id.method);
        TextView tags = (TextView) getActivity().findViewById(R.id.tags);

        picture.setImageBitmap(item.getFirstImage());
        price.setText("$" + item.getPrice());
        method.setText(item.getMethod());
        tags.setText("Tags: " + item.getTagsString());

    }

}
