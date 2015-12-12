package com.bakkle.bakkle;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.view.MenuItemCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.AlertDialog;
import android.support.v7.widget.SearchView;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.Toast;

import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.lorentzos.flingswipe.Direction;
import com.lorentzos.flingswipe.SwipeFlingAdapterView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class FeedFragment extends Fragment
        implements SwipeFlingAdapterView.OnItemClickListener, SwipeFlingAdapterView.onFlingListener
{
    SwipeFlingAdapterView  flingContainer;
    List<FeedItem>         items;
    ArrayAdapter<FeedItem> adapter;
    MainActivity           activity;
    Prefs                  prefs;
    RelativeLayout         error;
    RelativeLayout         done;
    Button                 refresh;

    @Override
    public void onResume()
    {
        super.onResume();
    }

    private OnFragmentInteractionListener mListener;

    public FeedFragment()
    {
        // Required empty public constructor
    }

    public static FeedFragment newInstance()
    {
        FeedFragment fragment = new FeedFragment();
        Bundle args = new Bundle();

        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
        if (getArguments() != null) {

        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState)
    {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_feed, container, false);
        prefs = Prefs.getInstance(getContext());

        ((MainActivity) getActivity()).getSupportActionBar().setTitle("Bakkle");

        flingContainer = (SwipeFlingAdapterView) view.findViewById(R.id.feed);
        error = (RelativeLayout) view.findViewById(R.id.error);
        done = (RelativeLayout) view.findViewById(R.id.done);
        refresh = (Button) view.findViewById(R.id.refresh);

        refresh.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
                refreshFeed();
            }
        });

        flingContainer.setOnItemClickListener(this);
        flingContainer.setFlingListener(this);

        refreshFeed();

        return view;
    }

    @Override
    public void onItemClicked(int itemPosition, Object dataObject)
    {
        FeedItem item = (FeedItem) dataObject;
        Intent intent = new Intent(getContext(), ItemDetailActivity.class);
        intent.putExtra(Constants.FEED_ITEM, item);
        intent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
        startActivityForResult(intent, Constants.REQUEST_CODE_VIEW_ITEM);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == Constants.REQUEST_CODE_VIEW_ITEM) {
            switch (resultCode) {
                case Constants.RESULT_CODE_WANT:
                    flingContainer.getTopCardListener().selectRight();
                    break;
                case Constants.RESULT_CODE_NOPE:
                    flingContainer.getTopCardListener().selectLeft();
                    break;
            }
        }
    }

    @Override
    public void removeFirstObjectInAdapter()
    {
        // this is the simplest way to delete an object from the Adapter (/AdapterView)
        items.remove(0);
        adapter.notifyDataSetChanged();
    }

    public void onCardExit(int direction, Object dataObject)
    {
        final FeedItem item = (FeedItem) dataObject;
        if (Direction.hasRight(direction)) {
            /** Show splash screen.
             *
             *  If user is not logged in and selects anything besides "Save to WatchList", start
             *  a RegisterActivity (with a Login fragment and a Signup fragment). If user
             *  doesn't complete the process, don't complete chosen action, and go back to
             *  splash screen.
             *  If user does complete the process, complete the action.
             *
             *  If user is logged in, complete the action
             */
            showTakeActionFragment(item.getImage_urls()[0], item.getPk());

        } else if (Direction.hasLeft(direction)) {
            Server.getInstance()
                    .markItem(Constants.MARK_NOPE, item.getPk(),
                              "42"); //TODO: Get actual view duration
        } else if (Direction.hasTop(direction)) {
            Server.getInstance()
                    .markItem(Constants.MARK_HOLD, item.getPk(),
                              "42"); //TODO: Get actual view duration
        } else if (Direction.hasBottom(direction)) {
            final EditText input = new EditText(getContext());
            input.setSingleLine(false);

            new AlertDialog.Builder(getContext()).setTitle("Report")
                    .setMessage("Please explain why you are reporting this item")
                    .setView(input)
                    .setNegativeButton("CANCEL", new DialogInterface.OnClickListener()
                    {
                        @Override
                        public void onClick(DialogInterface dialog, int which)
                        {
                        }
                    })
                    .setPositiveButton("REPORT", new DialogInterface.OnClickListener()
                    {
                        @Override
                        public void onClick(DialogInterface dialog, int which)
                        {
                            String reportText = input.getText().toString();
                            Server.getInstance()
                                    .markItem(Constants.MARK_REPORT, item.getPk(), "42",
                                              reportText); //TODO: Get actual view duration
                        }
                    })
                    .show();
        }

    }

    @Override
    public void onAdapterAboutToEmpty(int itemsInAdapter)
    {
        if (itemsInAdapter == 0) {
            showDone();
        }
        // TODO: Ask for more data here/Auto refresh feed
        adapter.notifyDataSetChanged();
    }

    @Override
    public void onScroll(float scrollProgressPercentHorizontal, float scrollProgressPercentVertical)
    {
        View view = flingContainer.getSelectedView();
        float alpha = Math.min(Math.abs(scrollProgressPercentHorizontal) > Math.abs(
                scrollProgressPercentVertical) ? Math.abs(
                scrollProgressPercentHorizontal) : Math.abs(scrollProgressPercentVertical), .6f);
        view.findViewById(R.id.darkener).setAlpha(alpha);
        view.findViewById(R.id.item_swipe_right_indicator)
                .setAlpha(
                        scrollProgressPercentHorizontal < 0 ? -scrollProgressPercentHorizontal : 0);
        view.findViewById(R.id.item_swipe_left_indicator)
                .setAlpha(
                        scrollProgressPercentHorizontal > 0 ? scrollProgressPercentHorizontal : 0);
        view.findViewById(R.id.item_swipe_bottom_indicator)
                .setAlpha(scrollProgressPercentVertical < 0 ? -scrollProgressPercentVertical : 0);
        view.findViewById(R.id.item_swipe_top_indicator)
                .setAlpha(scrollProgressPercentVertical > 0 ? scrollProgressPercentVertical : 0);
    }

    private void showTakeActionFragment(String image_url, int pk)
    {
        getFragmentManager().beginTransaction()
                .add(R.id.drawer_layout, TakeActionFragment.newInstance(image_url, pk))
                .addToBackStack(null)
                .commit();

        //Prevent drawer from opening when taking action
        activity.getDrawer().setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED);
    }

    private void showError()
    {
        error.setVisibility(View.VISIBLE);
        refresh.setVisibility(View.VISIBLE);
    }

    private void showDone()
    {
        done.setVisibility(View.VISIBLE);
        refresh.setVisibility(View.VISIBLE);
    }

    private void hideErrorAndDone()
    {
        error.setVisibility(View.GONE);
        done.setVisibility(View.GONE);
        refresh.setVisibility(View.GONE);
    }

    private void refreshFeed()
    {
        hideErrorAndDone();
        Server.getInstance(getContext()).getFeed(new FeedListener(), new FeedErrorListener());
    }

    private void doneProcessing()
    {
        if (items == null) {
            showError();
            return;
        } else if (items.size() == 0) {
            showDone();
            return;
        }
        adapter = new FeedAdapter(getContext(), R.layout.feed_item, items);
        flingContainer.setAdapter(adapter);
        adapter.notifyDataSetChanged();
    }

    public List<FeedItem> processJson(JSONObject json) throws JSONException
    {
        if (json.getInt("status") != 1) {
            return null;
        }
        JSONArray jsonArray = json.getJSONArray("feed");
        int length = jsonArray.length();
        List<FeedItem> items = new ArrayList<>(length);
        for (int i = 0; i < length; i++) {
            JSONObject item = jsonArray.getJSONObject(i);
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

    // TODO: Rename method, update argument and hook method into UI event
    public void onButtonPressed(Uri uri)
    {
        if (mListener != null) {
            mListener.onFragmentInteraction(uri);
        }
    }

    @Override
    public void onAttach(Context context)
    {
        super.onAttach(context);
        if (context instanceof OnFragmentInteractionListener) {
            mListener = (OnFragmentInteractionListener) context;
        } else {
            throw new RuntimeException(
                    context.toString() + " must implement OnFragmentInteractionListener");
        }

        activity = (MainActivity) context;
    }

    @Override
    public void onDetach()
    {
        super.onDetach();
        mListener = null;
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater)
    {
        // Inflate the menu; this adds items to the action bar if it is present.
        inflater.inflate(R.menu.feed, menu);

        final SearchView searchView = (SearchView) MenuItemCompat.getActionView(menu.findItem(R.id.action_search));
        searchView.onActionViewCollapsed();
        searchView.setOnQueryTextListener(new SearchView.OnQueryTextListener()
        {
            @Override
            public boolean onQueryTextSubmit(String query)
            {
                prefs.setSearchText(query);
                refreshFeed();
                return false;
            }

            @Override
            public boolean onQueryTextChange(String newText)
            {
                prefs.setSearchText(newText);
                refreshFeed();
                return false;
            }
        });
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item)
    {
        int id = item.getItemId();
        if (id == R.id.refine) {
            View view = LayoutInflater.from(getContext()).inflate(R.layout.refine_dialog, null);

            final EditText priceEditText = (EditText) view.findViewById(R.id.priceValue);
            final EditText distanceEditText = (EditText) view.findViewById(R.id.distanceValue);
            final SeekBar priceSeekBar = (SeekBar) view.findViewById(R.id.priceBar);
            final SeekBar distanceSeekBar = (SeekBar) view.findViewById(R.id.distanceBar);

            priceEditText.setText("$" + (prefs.getPriceFilter() == 100 ? "∞" : prefs.getPriceFilter()));
            distanceEditText.setText((prefs.getDistanceFilter() == 100 ? "∞" : prefs.getDistanceFilter()) + " mi");
            distanceSeekBar.setProgress(prefs.getDistanceFilter());
            priceSeekBar.setProgress(prefs.getPriceFilter());

            priceEditText.addTextChangedListener(new TextWatcher()
            {
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after)
                {

                }

                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count)
                {

                }

                @Override
                public void afterTextChanged(Editable s)
                {
                    String price = extractNumber(s.toString());
                    if (!price.equals("")) {
                        priceSeekBar.setProgress(
                                price.contains("∞") ? 100 : Integer.parseInt(price));
                    }
                }
            });

            distanceEditText.addTextChangedListener(new TextWatcher()
            {
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after)
                {

                }

                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count)
                {

                }

                @Override
                public void afterTextChanged(Editable s)
                {
                    String distance = extractNumber(s.toString());
                    if (!distance.equals("")) {
                        distanceSeekBar.setProgress(
                                distance.contains("∞") ? 100 : Integer.parseInt(distance));
                    }
                }
            });

            priceSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener()
            {
                @Override
                public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser)
                {
                    if (fromUser && progress < 100) {
                        priceEditText.setText("$" + progress);
                    } else if (fromUser) {
                        priceEditText.setText("$∞");
                    }
                }

                @Override
                public void onStartTrackingTouch(SeekBar seekBar)
                {

                }

                @Override
                public void onStopTrackingTouch(SeekBar seekBar)
                {

                }
            });

            distanceSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener()
            {
                @Override
                public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser)
                {
                    if (fromUser && progress < 100) {
                        distanceEditText.setText(progress + " mi");
                    } else if (fromUser) {
                        distanceEditText.setText("∞ mi");
                    }
                }

                @Override
                public void onStartTrackingTouch(SeekBar seekBar)
                {

                }

                @Override
                public void onStopTrackingTouch(SeekBar seekBar)
                {

                }
            });

            new AlertDialog.Builder(getContext()).setTitle("Refine")
                    .setMessage("Select maximum distance and price for your Feed")
                    .setView(view)
                    .setNegativeButton("CANCEL", new DialogInterface.OnClickListener()
                    {
                        @Override
                        public void onClick(DialogInterface dialog, int which)
                        {
                        }
                    })
                    .setPositiveButton("SAVE", new DialogInterface.OnClickListener()
                    {
                        @Override
                        public void onClick(DialogInterface dialog, int which)
                        {
                            prefs.setDistanceFilter(distanceSeekBar.getProgress());
                            prefs.setPriceFilter(priceSeekBar.getProgress());
                            refreshFeed();
                        }
                    })
                    .show();
        }

        return super.onOptionsItemSelected(item);
    }

    public class FeedListener implements Response.Listener<JSONObject>
    {
        @Override
        public void onResponse(JSONObject response)
        {
            try {
                items = processJson(response);
                doneProcessing();
            } catch (JSONException e) {
                Toast.makeText(getContext(), "There was error retrieving the feed",
                               Toast.LENGTH_SHORT).show();
                showError();
            }
        }
    }

    public class FeedErrorListener implements Response.ErrorListener
    {

        @Override
        public void onErrorResponse(VolleyError error)
        {
            Toast.makeText(getContext(), "There was error retrieving the feed", Toast.LENGTH_SHORT)
                    .show();
            showError();
        }
    }

    public String extractNumber(final String str)
    {

        if (str == null || str.isEmpty()) {
            return "";
        }

        StringBuilder sb = new StringBuilder();
        boolean found = false;
        for (char c : str.toCharArray()) {
            if (Character.isDigit(c)) {
                sb.append(c);
                found = true;
            } else if (c == '∞') {
                sb.append(c);
                break;
            } else if (found) {
                // If we already found a digit before and this char is not a digit, stop looping
                break;
            }
        }

        return sb.toString();
    }

    /**
     * This interface must be implemented by activities that contain this
     * fragment to allow an interaction in this fragment to be communicated
     * to the activity and potentially other fragments contained in that
     * activity.
     * <p/>
     * See the Android Training lesson <a href=
     * "http://developer.android.com/training/basics/fragments/communicating.html"
     * >Communicating with Other Fragments</a> for more information.
     */
    public interface OnFragmentInteractionListener
    {
        public void onFragmentInteraction(Uri uri);
    }

}
