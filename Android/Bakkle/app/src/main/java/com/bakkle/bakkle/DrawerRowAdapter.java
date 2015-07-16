package com.bakkle.bakkle;

import android.content.Context;
import android.content.res.TypedArray;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import java.util.ArrayList;

/**
 * Created by watterlm on 3/24/2015.
 */
public class DrawerRowAdapter extends RecyclerView.Adapter<DrawerRowAdapter.ViewHolder> {

    private Context mContext;
    private ArrayList<String> drawerItems;
    private TypedArray drawerIcons;


    private static final int TYPE_ITEM = 1;
    private static final int TYPE_HEADER = 0;

    public static class ViewHolder extends RecyclerView.ViewHolder {
        int Holderid;

        TextView textView;
        ImageView imageView;
        ImageView profile;
        TextView Name;


        public ViewHolder(View itemView, int ViewType) {                 // Creating ViewHolder Constructor with View and viewType As a parameter
            super(itemView);


            // Here we set the appropriate view in accordance with the the view type as passed when the holder object is created

            if(ViewType == TYPE_ITEM) {
                textView = (TextView) itemView.findViewById(R.id.txtTitle); // Creating TextView object with the id of textView from item_row.xml
                imageView = (ImageView) itemView.findViewById(R.id.imgIcon);// Creating ImageView object with the id of ImageView from item_row.xml
                Holderid = 1;                                               // setting holder id as 1 as the object being populated are of type item row
            }
            else{


                Name = (TextView) itemView.findViewById(R.id.name);
                profile = (ImageView) itemView.findViewById(R.id.circleView);
                Holderid = 0;
            }
        }


    }



    @Override
    public DrawerRowAdapter.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        if (viewType == TYPE_ITEM) {
            View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.drawer_list_item,parent,false); //Inflating the layout

            ViewHolder vhItem = new ViewHolder(v,viewType); //Creating ViewHolder and passing the object of type view

            return vhItem; // Returning the created object

            //inflate your layout and pass it to view holder

        } else if (viewType == TYPE_HEADER) {

            View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.header,parent,false); //Inflating the layout

            ViewHolder vhHeader = new ViewHolder(v,viewType); //Creating ViewHolder and passing the object of type view

            return vhHeader; //returning the object created


        }
        return null;
    }

    @Override
    public void onBindViewHolder(DrawerRowAdapter.ViewHolder holder, int position) {

        if(holder.Holderid == 1) {                              // as the list view is going to be called after the header view so we decrement the
            // position by 1 and pass it to the holder while setting the text and image
            holder.textView.setText(drawerItems.get(position - 1)); // Setting the Text with the array of our Titles
            holder.imageView.setImageResource(drawerIcons.getResourceId(position - 1, 0));// Settimg the image with array of our icons
        }
        else{

            holder.profile.setImageResource(R.drawable.bakkle_icon);           // Similarly we set the resources for header view
            holder.Name.setText("John Doe");
        }

    }

    @Override
    public int getItemCount() {
        return drawerItems.size() + 1;
    }

    // Witht the following method we check what type of view is being passed
    @Override
    public int getItemViewType(int position) {
        if (isPositionHeader(position))
            return TYPE_HEADER;

        return TYPE_ITEM;
    }

    private boolean isPositionHeader(int position) {
        return position == 0;
    }

    public DrawerRowAdapter(Context mContext, ArrayList<String> drawerItems, TypedArray drawerIcons){
        this.mContext = mContext;
        this.drawerItems = drawerItems;
        this.drawerIcons = drawerIcons;
    }

    /*@Override
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
    }*/
}
