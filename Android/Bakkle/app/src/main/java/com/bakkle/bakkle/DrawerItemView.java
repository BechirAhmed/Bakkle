package com.bakkle.bakkle;

import android.content.Context;
import android.view.LayoutInflater;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

/**
 * Created by watterlm on 3/24/2015.
 */
public class DrawerItemView extends LinearLayout {
    private TextView txtTitle;
    private ImageView icon;

    public DrawerItemView(Context context) {
        super(context);
        LayoutInflater.from(context).inflate(R.layout.drawer_list_item, this);

        txtTitle = (TextView)findViewById(R.id.txtTitle);
        icon = (ImageView)findViewById(R.id.imgIcon);
    }

    public void setTitle(String title){
        txtTitle.setText(title);
    }

    public void setIcon (int id){
        icon.setImageResource(id);
    }
}
