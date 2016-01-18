package com.bakkle.bakkle;

import android.content.Context;
import android.os.Bundle;
import android.support.design.widget.Snackbar;
import android.support.v4.app.Fragment;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.helper.ItemTouchHelper;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.bakkle.bakkle.Models.FeedItem;
import com.bakkle.bakkle.Models.Person;
import com.bakkle.bakkle.Views.DividerItemDecoration;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class BuyingFragment extends Fragment
{
    RecyclerView       recyclerView;
    SwipeRefreshLayout listContainer;
    BuyingAdapter      buyingAdapter;
    List<FeedItem>     items;

    public BuyingFragment()
    {
    }

    public static BuyingFragment newInstance()
    {
        return new BuyingFragment();
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
        final View view = inflater.inflate(R.layout.recycler_view, container, false);

        ((MainActivity) getActivity()).getSupportActionBar().setTitle(getString(R.string.buying));

        ItemTouchHelper.SimpleCallback simpleItemTouchCallback = new ItemTouchHelper.SimpleCallback(
                0, ItemTouchHelper.LEFT)
        {

            @Override
            public boolean onMove(RecyclerView recyclerView, RecyclerView.ViewHolder viewHolder,
                                  RecyclerView.ViewHolder target)
            {
                return false;
            }

            @Override
            public void onSwiped(RecyclerView.ViewHolder viewHolder, int direction)
            {
                final int position = viewHolder.getAdapterPosition();
                final FeedItem deletedItem = items.remove(position);
                buyingAdapter.notifyItemRemoved(position);

                final Snackbar snackbar = Snackbar.make(view,
                        deletedItem.getTitle().concat(" has been deleted from Buying"),
                        Snackbar.LENGTH_LONG).setAction("Undo", new View.OnClickListener()
                {
                    @Override
                    public void onClick(View v)
                    {
                        items.add(position, deletedItem);
                        buyingAdapter.notifyItemInserted(position);
                    }
                }).setCallback(new Snackbar.Callback()
                {
                    @Override
                    public void onDismissed(Snackbar snackbar, int event)
                    {
                        if (event == DISMISS_EVENT_ACTION) {
                            Snackbar.make(view,
                                    deletedItem.getTitle().concat(" has been restored to Buying"),
                                    Snackbar.LENGTH_SHORT).show();
                            return; //If an action was used to dismiss, the user wants to undo the deletion, so we do not need to continue
                        }
                        API.getInstance(getContext())
                                .markItem(Constants.MARK_NOPE, deletedItem.getPk(), "42");
                    }
                });
                snackbar.show();
            }
        };

        ItemTouchHelper itemTouchHelper = new ItemTouchHelper(simpleItemTouchCallback);

        recyclerView = (RecyclerView) view.findViewById(R.id.list);
        listContainer = (SwipeRefreshLayout) view.findViewById(R.id.listContainer);

        listContainer.setColorSchemeResources(R.color.colorPrimary, R.color.colorNope,
                R.color.colorHoldBlue);

        listContainer.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener()
        {
            @Override
            public void onRefresh()
            {
                refreshBuying();
            }
        });

        recyclerView.addItemDecoration(
                new DividerItemDecoration(getContext(), DividerItemDecoration.VERTICAL_LIST));

        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        itemTouchHelper.attachToRecyclerView(recyclerView);

        refreshBuying();

        return view;
    }

    public void refreshBuying()
    {
        API.getInstance(getContext()).getBuying(new BuyingListener(), new BuyingErrorListener());
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
    "buyers_trunk": [
        {
            "view_time": "2015-12-02 04:43:30 ",
            "status": "Want",
            "confirmed_price": "26.95",
            "item": {
                "status": "Active",
                "description": "",
                "tags": "GUMPTION, NICK, OFFERMAN book",
                "price": "26.95",
                "image_urls": [
                    "https://s3-us-west-2.amazonaws.com/com.bakkle.prod/com.bakkle.prod_4_7b3a4a6d62c9e276e24d63bcc21358f5.jpg",
                    "https://s3-us-west-2.amazonaws.com/com.bakkle.prod/com.bakkle.prod_4_d4600c9cddc53d2343fcee5b1d8ed83c.jpg"
                ],
                "post_date": "2015-07-13 20:24:44 ",
                "title": "Gumption by Nick Offerman",
                "seller": {
                    "avatar_image_url": "http://graph.facebook.com/1632949983606546/picture",
                    "buyer_rating": null,
                    "display_name": "James Kozuch",
                    "description": "Simply the Greatest",
                    "facebook_id": "1632949983606546",
                    "pk": 4,
                    "flavor": 1,
                    "user_location": "39.17,-86.52",
                    "seller_rating": null
                },
                "location": "39.42,-87.33",
                "pk": 2564,
                "method": "Pick up"
            },
            "buyer": {
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
            "pk": 26334,
            "accepted_sale_price": false,
            "sale": null,
            "view_duration": "42.00"
        }, etc
     */

    public List<FeedItem> processJson(JSONObject json) throws JSONException
    {
        if (json.getInt("status") != 1) {
            Toast.makeText(getContext(), "There was error retrieving the Buyer's Trunk",
                    Toast.LENGTH_SHORT).show();
            return null;
        }
        JSONArray jsonArray = json.getJSONArray("buyers_trunk");
        int length = jsonArray.length();
        List<FeedItem> items = new ArrayList<>(length);
        for (int i = 0; i < length; i++) {
            JSONObject item = jsonArray.getJSONObject(i)
                    .getJSONObject("item"); //TODO: Capture rest of JSON information returned
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
                            "[0-9]+") ? "https://graph.facebook.com/" + seller.getFacebook_id() + "/picture?type=normal" : null);
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

    private class BuyingListener implements Response.Listener<JSONObject>
    {
        @Override
        public void onResponse(JSONObject response)
        {
            try {
                items = processJson(response);
                buyingAdapter = new BuyingAdapter(items, getActivity());
                recyclerView.setAdapter(buyingAdapter);
                listContainer.setRefreshing(false);
            } catch (JSONException e) {
                Toast.makeText(getContext(), "There was error retrieving the Buyer's Trunk",
                        Toast.LENGTH_SHORT).show();
                showError();
            }
        }
    }

    private void showError()
    {
        //TODO: Move showError() in FeedFragment to MainActivity, so that it can be used by any fragment
    }

    private class BuyingErrorListener implements Response.ErrorListener
    {

        @Override
        public void onErrorResponse(VolleyError error)
        {
            Toast.makeText(getContext(), "There was error retrieving the Buyer's Trunk",
                    Toast.LENGTH_SHORT).show();
            showError();
        }
    }
}
