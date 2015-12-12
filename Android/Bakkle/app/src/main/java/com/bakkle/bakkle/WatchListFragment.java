package com.bakkle.bakkle;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import com.android.volley.Response;
import com.android.volley.VolleyError;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class WatchListFragment extends Fragment
{
    RecyclerView recyclerView;

    public WatchListFragment()
    {
    }

    public static WatchListFragment newInstance()
    {
        return new WatchListFragment();
    }

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState)
    {
        View view = inflater.inflate(R.layout.recycler_view, container, false);

        ((MainActivity) getActivity()).getSupportActionBar().setTitle("Watch List");

        recyclerView = (RecyclerView) view;

        recyclerView.addItemDecoration(new DividerItemDecoration(getContext(), DividerItemDecoration.VERTICAL_LIST));

        recyclerView.setHasFixedSize(true);
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));

        Server.getInstance().getWatchList(new WatchListListener(), new WatchListErrorListener());

        return view;
    }

    @Override
    public void onAttach(Context context)
    {
        super.onAttach(context);
    }

    @Override
    public void onDetach()
    {
        super.onDetach();
    }

    // Format of JSON:
    /*
    "status": ,
    "holding_pattern": [
        {
            "view_time": "2015-12-07 01:31:08 ",
            "status": "Hold",
            "confirmed_price": "0.00",
            "item": {
                "status": "Active",
                "description": "WORDS TO DESCRIBE ITEM",
                "tags": "",
                "price": "0.00",
                "image_urls": [
                    "https://s3-us-west-2.amazonaws.com/com.bakkle.prod/com.bakkle.prod_223_df2b464a179a24ff6574e752a387f578.jpg",
                    "https://s3-us-west-2.amazonaws.com/com.bakkle.prod/com.bakkle.prod_223_c7e4940f34cee924a6cf2a242d5de5b4.mp4"
                ],
                "post_date": "2015-12-03 16:52:26 ",
                "title": "Golden  phone",
                "seller": {
                    "avatar_image_url": "https://app.bakkle.com/img/default_profile.png",
                    "buyer_rating": null,
                    "display_name": "Niraj",
                    "description": null,
                    "facebook_id": "533675fb606daeed071c7b447a8779bf",
                    "pk": 223,
                    "flavor": 1,
                    "user_location": "40.6,-74.49",
                    "seller_rating": null
                },
                "location": "40.73,-74.53",
                "pk": 3278,
                "method": "Pick-up"
            },
            "buyer": {
                "avatar_image_url": "http://graph.facebook.com/953976251314552/picture",
                "buyer_rating": null,
                "display_name": "Vansh Gandhi",
                "description": "Testing description on Android!",
                "facebook_id": "953976251314552",
                "pk": 11,
                "flavor": 1,
                "user_location": "37.65,-121.9",
                "seller_rating": null
            },
            "pk": 26753,
            "accepted_sale_price": false,
            "sale": null,
            "view_duration": "42.00"
        }, etc
     */

    public List<FeedItem> processJson(JSONObject json) throws JSONException
    {
        if (json.getInt("status") != 1) {
            return null;
        }
        JSONArray jsonArray = json.getJSONArray("holding_pattern");
        int length = jsonArray.length();
        List<FeedItem> items = new ArrayList<>(length);
        for (int i = 0; i < length; i++) {
            JSONObject item = jsonArray.getJSONObject(i)
                    .getJSONObject("item"); //TODO: Capture rest of JSON information returned
            JSONObject sellerJson = item.getJSONObject("seller");
            JSONArray image_urlsJson = item.getJSONArray("image_urls");

            FeedItem feedItem = new FeedItem();
            Seller seller = new Seller();
            String[] image_urls = new String[image_urlsJson.length()];

            for (int k = 0; k < image_urls.length; k++) {
                image_urls[k] = image_urlsJson.getString(k);
            }

            seller.setAvatar_image_url(sellerJson.getString("avatar_image_url"));
            seller.setDisplay_name(sellerJson.getString("display_name"));
            seller.setDescription(sellerJson.getString("description"));
            seller.setFacebook_id(sellerJson.getString("facebook_id"));
            seller.setPk(sellerJson.getInt("pk"));
            seller.setFlavor(sellerJson.getInt("flavor"));
            seller.setUser_location(sellerJson.getString("user_location"));

            feedItem.setStatus(item.getString("status"));
            feedItem.setDescription(item.getString("description"));
            feedItem.setPrice(item.getString("price"));
            feedItem.setPost_date(item.getString("post_date"));
            feedItem.setTitle(item.getString("title"));
            feedItem.setLocation(item.getString("location"));
            feedItem.setPk(item.getInt("pk"));
            feedItem.setMethod(item.getString("method"));
            feedItem.setImage_urls(image_urls);
            feedItem.setSeller(seller);

            items.add(feedItem);
        }
        return items;
    }

    public class WatchListListener implements Response.Listener<JSONObject>
    {
        @Override
        public void onResponse(JSONObject response)
        {
            try {
                recyclerView.setAdapter(new WatchListAndBuyingAdapter(processJson(response), getActivity()));
            } catch (JSONException e) {
                Toast.makeText(getContext(), "There was error retrieving the Watch List",
                               Toast.LENGTH_SHORT).show();
                showError();
            }
        }
    }

    private void showError()
    {
        //TODO: Move showError() in FeedFragment to MainActivity, so that it can be used by any fragment
    }

    public class WatchListErrorListener implements Response.ErrorListener
    {

        @Override
        public void onErrorResponse(VolleyError error)
        {
            Toast.makeText(getContext(), "There was error retrieving the Watch List",
                           Toast.LENGTH_SHORT).show();
            showError();
        }
    }
}
