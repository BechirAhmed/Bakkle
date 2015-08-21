package com.bakkle.bakkle.Fragments;

import android.app.Activity;
import android.app.ListFragment;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.ColorFilter;
import android.graphics.LightingColorFilter;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.RectF;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.View;
import android.widget.ListView;

import com.bakkle.bakkle.Activities.ChatListActivity;
import com.bakkle.bakkle.Adapters.GarageAdapter;
import com.bakkle.bakkle.Helpers.FeedItem;
import com.bakkle.bakkle.Helpers.ServerCalls;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.util.ArrayList;

/**
 * A fragment representing a list of Items.
 * <p/>
 * <p/>
 * Activities containing this fragment MUST implement the {@link OnFragmentInteractionListener}
 * interface.
 */
public class SellersGarageFragment extends ListFragment
{

    SharedPreferences preferences;
    private OnFragmentInteractionListener mListener;
    ServerCalls serverCalls;
    ArrayList<FeedItem> items = null;
    JsonObject json;
    Activity mActivity;


    // TODO: Rename and change types of parameters
    public static SellersGarageFragment newInstance()
    {
        SellersGarageFragment fragment = new SellersGarageFragment();
//        Bundle args = new Bundle();
//        args.putString(ARG_PARAM1, param1);
//        args.putString(ARG_PARAM2, param2);
//        fragment.setArguments(args);
        return fragment;
    }

    /**
     * Mandatory empty constructor for the fragment manager to instantiate the
     * fragment (e.g. upon screen orientation changes).
     */
    public SellersGarageFragment()
    {
    }

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

        serverCalls = new ServerCalls(mActivity);

        preferences = PreferenceManager.getDefaultSharedPreferences(mActivity);

        json = serverCalls.populateGarage(preferences.getString("auth_token", ""), preferences.getString("uuid", ""));

        items = getItems(json);
        setListAdapter(new GarageAdapter(mActivity, items));


        /*SwipeLayout swipeLayout =  (SwipeLayout) getListView().findViewById(R.id.swipe);
        swipeLayout.setShowMode(SwipeLayout.ShowMode.PullOut); //null pointer exception? need to set content layout first aka move this code somehwere else?
        swipeLayout.addDrag(SwipeLayout.DragEdge.Right, mActivity.findViewById(R.id.bottom_wrapper));

        swipeLayout.addSwipeListener(new SwipeLayout.SwipeListener() {
            @Override
            public void onClose(SwipeLayout layout) {
                //when the SurfaceView totally cover the BottomView.
            }

            @Override
            public void onUpdate(SwipeLayout layout, int leftOffset, int topOffset) {
                //you are swiping.
            }

            @Override
            public void onStartOpen(SwipeLayout layout) {

            }

            @Override
            public void onOpen(SwipeLayout layout) {
                deleteItem();
            }

            @Override
            public void onStartClose(SwipeLayout layout) {

            }

            @Override
            public void onHandRelease(SwipeLayout layout, float xvel, float yvel) {
                //when user's hand released.
            }
        }); */

    }

    @Override
    public void onAttach(Activity activity)
    {
        super.onAttach(activity);
        mActivity = activity;
        try {
            mListener = (OnFragmentInteractionListener) activity;
        }
        catch (ClassCastException e) {
            throw new ClassCastException(activity.toString()
                    + " must implement OnFragmentInteractionListener");
        }
    }

    @Override
    public void onDetach()
    {
        super.onDetach();
        mListener = null;
    }

    @Override
    public void onListItemClick(ListView l, View v, int position, long id)
    {
        super.onListItemClick(l, v, position, id);

        FeedItem item = (FeedItem) getListAdapter().getItem(position);
        Log.v("Intent start", "value of itemId is " + item.getPk());
        Intent intent = new Intent(mActivity, ChatListActivity.class);
        intent.putExtra("itemId", item.getPk());
        startActivity(intent);

        if (mListener != null) {
            // Notify the active callbacks interface (the activity, if the
            // fragment is attached to one) that an item has been selected.
            //mListener.onFragmentInteraction(DummyContent.ITEMS.get(position).id);
        }
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
        // TODO: Update argument type and name
        public void onFragmentInteraction(String id);
    }

    public ArrayList<FeedItem> getItems(JsonObject json)
    {

        JsonArray jsonArray = json.getAsJsonArray("seller_garage");
        JsonObject temp, item;
        ArrayList<FeedItem> feedItems = new ArrayList<>();
        ArrayList<String> tags, imageUrls;
        JsonObject seller;
        JsonArray imageUrlArray, tagArray;
        FeedItem feedItem;
        String pk, sellerFacebookId;


        for (JsonElement element : jsonArray) {
            item = element.getAsJsonObject();
            temp = item.getAsJsonObject("seller");

            feedItem = new FeedItem(mActivity);

            feedItem.setTitle(item.get("title").getAsString());
            feedItem.setPrice(item.get("price").getAsString());
            feedItem.setNumView(item.get("number_of_views").getAsString());
            feedItem.setNumMeh(item.get("number_of_meh").getAsString());
            feedItem.setNumWant(item.get("number_of_want").getAsString());
            feedItem.setNumHold(item.get("number_of_holding").getAsString());
            pk = item.get("pk").getAsString();
            feedItem.setPk(pk);


            imageUrlArray = item.get("image_urls").getAsJsonArray();
            imageUrls = new ArrayList<>();
            for (JsonElement urlElement : imageUrlArray) {
                imageUrls.add(urlElement.getAsString());
            }
            feedItem.setImageUrls(imageUrls);


            feedItems.add(feedItem);
        }

        return feedItems;

    }


    public static Bitmap getRoundedCornerAndDarkenedBitmap(Bitmap bitmap)
    {
        Bitmap output = Bitmap.createBitmap(bitmap.getWidth(),
                bitmap.getHeight(), Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(output);

        final int color = 0xff424242;
        final Paint paint = new Paint();
        final Rect rect = new Rect(0, 0, bitmap.getWidth(), bitmap.getHeight());
        final RectF rectF = new RectF(rect);
        final float roundPx = 12;
        final ColorFilter filter = new LightingColorFilter(0xFF222222, 0x00000000);

        paint.setAntiAlias(true);
        canvas.drawARGB(0, 0, 0, 0);
        paint.setColor(color);
        paint.setColorFilter(filter);
        canvas.drawRoundRect(rectF, roundPx, roundPx, paint);

        paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_IN));
        canvas.drawBitmap(bitmap, rect, rect, paint);

        return output;
    }

}
