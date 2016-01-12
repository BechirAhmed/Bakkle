package com.bakkle.bakkle.Selling;

/**
 * Created by vanshgandhi on 12/10/15.
 */

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.bakkle.bakkle.API;
import com.bakkle.bakkle.Views.DividerItemDecoration;
import com.bakkle.bakkle.MainActivity;
import com.bakkle.bakkle.Models.FeedItem;
import com.bakkle.bakkle.Models.Person;
import com.bakkle.bakkle.R;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class SellingFragment extends Fragment
{
    RecyclerView recyclerView;
    SwipeRefreshLayout listContainer;

    public SellingFragment()
    {
    }

    public static SellingFragment newInstance()
    {
        return new SellingFragment();
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

        ((MainActivity) getActivity()).getSupportActionBar().setTitle("Selling");

        recyclerView = (RecyclerView) view.findViewById(R.id.list);
        listContainer = (SwipeRefreshLayout) view.findViewById(R.id.listContainer);

        listContainer.setColorSchemeResources(R.color.colorPrimary, R.color.colorNope, R.color.colorHoldBlue);

        listContainer.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                refreshSelling();
            }
        });


        recyclerView.addItemDecoration(
                new DividerItemDecoration(getContext(), DividerItemDecoration.VERTICAL_LIST));

        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));

        refreshSelling();

        return view;
    }

    public void refreshSelling()
    {
        API.getInstance().getSellers(new SellersListener(), new SellersErrorListener());
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
    {
    "status": 1,
    "seller_garage": [
        {
            "status": "Active",
            "description": "Good for sitting",
            "tags": "",
            "price": "15.00",
            "image_urls": [
                "https://s3-us-west-2.amazonaws.com/com.bakkle.prod/com.bakkle.prod_11_b173ce1d8398cdf7d38ee0bd043c6618.jpg"
            ],
            "post_date": "2015-12-01 15:31:36 ",
            "number_of_views": 11,
            "number_of_meh": 9,
            "number_of_holding": 0,
            "title": "Chair",
            "number_of_report": 0,
            "convos_with_new_message": 0,
            "seller": {
                "avatar_image_url": "https://app.bakkle.com/img/default_profile.png",
                "buyer_rating": null,
                "display_name": "Vansh Gandhi",
                "description": "Testing description on Android!",
                "facebook_id": "953976251314552",
                "pk": 11,
                "flavor": 1,
                "user_location": "37.65,-121.9",
                "seller_rating": null
            },
            "number_of_want": 2,
            "location": "34.07,-118.45",
            "pk": 3258,
            "method": "Pick-up"
        }, etc
     */

    public List<FeedItem> processJson(JSONObject json) throws JSONException
    {
        if (json.getInt("status") != 1) {
            Toast.makeText(getContext(), "There was error retrieving the Seller Items",
                           Toast.LENGTH_SHORT).show();
            return null;
        }
        JSONArray jsonArray = json.getJSONArray("seller_garage");
        int length = jsonArray.length();
        List<FeedItem> items = new ArrayList<>(length);
        for (int i = 0; i < length; i++) {
            JSONObject item = jsonArray.getJSONObject(
                    i); //TODO: Capture rest of JSON information returned
            JSONObject sellerJson = item.getJSONObject("seller");
            JSONArray image_urlsJson = item.getJSONArray("image_urls");

            FeedItem feedItem = new FeedItem();
            Person seller = new Person();
            String[] image_urls = new String[image_urlsJson.length()];

            for (int k = 0; k < image_urls.length; k++) {
                image_urls[k] = image_urlsJson.getString(k);
            }

            seller.setDisplay_name(sellerJson.getString("display_name"));
            seller.setDescription(sellerJson.getString("description"));
            seller.setFacebook_id(sellerJson.getString("facebook_id"));
            seller.setAvatar_image_url(seller.getFacebook_id()
                                               .matches(
                                                       "[0-9]+") ? "https://graph.facebook.com/" + seller
                    .getFacebook_id() + "/picture?type=normal" : null);
            seller.setPk(sellerJson.getInt("pk"));
            seller.setFlavor(sellerJson.getInt("flavor"));
            seller.setUser_location(sellerJson.getString("user_location"));

            feedItem.setStatus(item.getString("status"));
            feedItem.setDescription(item.getString("description"));
            feedItem.setPrice(item.getString("price"));
            feedItem.setPost_date(item.getString("post_date"));
            feedItem.setTitle(item.getString("title"));
            feedItem.setLocation(item.getString("location"));
            feedItem.setMethod(item.getString("method"));
            feedItem.setPk(item.getInt("pk"));
            feedItem.setNumViews(item.getInt("number_of_views"));
            feedItem.setNumHolding(item.getInt("number_of_holding"));
            feedItem.setNumWant(item.getInt("number_of_want"));
            feedItem.setNumNope(item.getInt("number_of_meh"));
            feedItem.setNumReport(item.getInt("number_of_report"));
            feedItem.setConvosWithNewMessage(item.getInt("convos_with_new_message"));
            feedItem.setImage_urls(image_urls);
            feedItem.setSeller(seller);

            items.add(feedItem);
        }
        return items;
    }

    private class SellersListener implements Response.Listener<JSONObject>
    {
        @Override
        public void onResponse(JSONObject response)
        {
            try {
                recyclerView.setAdapter(new SellingAdapter(processJson(response), getActivity()));
                listContainer.setRefreshing(false);
            } catch (JSONException e) {
                Toast.makeText(getContext(), "There was error retrieving the Seller's Garage",
                               Toast.LENGTH_SHORT).show();
                showError();
            }
        }
    }

    private void showError()
    {
        //TODO: Move showError() in FeedFragment to MainActivity, so that it can be used by any fragment
    }

    private class SellersErrorListener implements Response.ErrorListener
    {

        @Override
        public void onErrorResponse(VolleyError error)
        {
            Toast.makeText(getContext(), "There was error retrieving the Seller's Garage",
                           Toast.LENGTH_SHORT).show();
            showError();
        }
    }
}
