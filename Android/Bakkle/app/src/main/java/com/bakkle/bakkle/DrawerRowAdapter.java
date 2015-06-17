package com.bakkle.bakkle;

import android.content.Context;
import android.content.res.TypedArray;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;

import java.util.ArrayList;

/**
 * Created by watterlm on 3/24/2015.
 */
public class DrawerRowAdapter extends BaseAdapter {

    private Context mContext;
    private ArrayList<String> drawerItems;
    private TypedArray drawerIcons;

    public DrawerRowAdapter(Context mContext, ArrayList<String> drawerItems, TypedArray drawerIcons){
        this.mContext = mContext;
        this.drawerItems = drawerItems;
        this.drawerIcons = drawerIcons;
    }

    @Override
    public int getCount() {
        return this.drawerItems.size();
    }

    @Override
    public Object getItem(int position) {
        return drawerItems.get(position);
    }

    @Override
    public long getItemId(int position) {
        return 0;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        // set up drawer list items
        DrawerItemView view = null;
        if(convertView == null){
            view = new DrawerItemView(this.mContext);
        } else {
            view = (DrawerItemView) convertView;
        }

        view.setTitle(drawerItems.get(position));
        try {
            int id = drawerIcons.getResourceId(position, -1);
            view.setIcon(id);
        } catch(Exception e) {

        }

        return view;
    }
}
