package com.bakkle.bakkle;

import android.app.Activity;
import android.app.ListFragment;
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
import android.view.View;
import android.widget.ListView;
import android.widget.Toast;

import com.bakkle.bakkle.dummy.DummyContent;
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
public class SellersGarage extends ListFragment {

    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";

    // TODO: Rename and change types of parameters
    private String mParam1;
    private String mParam2;

    SharedPreferences preferences;
    SharedPreferences.Editor editor;

    private OnFragmentInteractionListener mListener;

    ServerCalls serverCalls;

    ArrayList<FeedItem> items = null;

    JsonObject json;


    // TODO: Rename and change types of parameters
    public static SellersGarage newInstance(String param1, String param2) {
        SellersGarage fragment = new SellersGarage();
        Bundle args = new Bundle();
        args.putString(ARG_PARAM1, param1);
        args.putString(ARG_PARAM2, param2);
        fragment.setArguments(args);
        return fragment;
    }

    /**
     * Mandatory empty constructor for the fragment manager to instantiate the
     * fragment (e.g. upon screen orientation changes).
     */
    public SellersGarage() {
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        serverCalls = new ServerCalls(getActivity());

        preferences = PreferenceManager.getDefaultSharedPreferences(getActivity());

        json = serverCalls.populateGarage(preferences.getString("auth_token", "0"), preferences.getString("uuid", "0"));

        items = getItems(json);
        setListAdapter(new GarageAdapter(getActivity(), items));

        /*SwipeLayout swipeLayout =  (SwipeLayout) getListView().findViewById(R.id.swipe);
        swipeLayout.setShowMode(SwipeLayout.ShowMode.PullOut); //null pointer exception? need to set content layout first aka move this code somehwere else?
        swipeLayout.addDrag(SwipeLayout.DragEdge.Right, getActivity().findViewById(R.id.bottom_wrapper));

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
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        try {
            mListener = (OnFragmentInteractionListener) activity;
        } catch (ClassCastException e) {
            throw new ClassCastException(activity.toString()
                    + " must implement OnFragmentInteractionListener");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mListener = null;
    }

    @Override
    public void onListItemClick(ListView l, View v, int position, long id) {
        super.onListItemClick(l, v, position, id);

        Toast.makeText(getActivity(), "Test", Toast.LENGTH_SHORT).show();

        if (mListener != null) {
            // Notify the active callbacks interface (the activity, if the
            // fragment is attached to one) that an item has been selected.
            mListener.onFragmentInteraction(DummyContent.ITEMS.get(position).id);
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
    public interface OnFragmentInteractionListener {
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


        for(JsonElement element : jsonArray)
        {
            item = element.getAsJsonObject();
            feedItem = new FeedItem(this.getActivity());
            //temp = element.getAsJsonObject();

            feedItem.setTitle(item.get("title").getAsString());
            feedItem.setPrice(item.get("price").getAsString());
            feedItem.setNumView(item.get("number_of_views").getAsString());
            feedItem.setNumMeh(item.get("number_of_meh").getAsString());
            feedItem.setNumWant(item.get("number_of_want").getAsString());
            feedItem.setNumHold(item.get("number_of_holding").getAsString());

            imageUrlArray = item.get("image_urls").getAsJsonArray();
            imageUrls = new ArrayList<String>();
            for(JsonElement urlElement : imageUrlArray)
            {
                imageUrls.add(urlElement.getAsString());
            }
            feedItem.setImageUrls(imageUrls);


            feedItems.add(feedItem);


            feedItem = null;
            imageUrlArray = null;
            imageUrls = null;
            item = null;
        }

        return feedItems;

    }

    public void deleteItem(){
        Toast.makeText(getActivity(), "You are in the delete Item page", Toast.LENGTH_SHORT).show();

    }


    public static Bitmap getRoundedCornerAndDarkenedBitmap(Bitmap bitmap) {
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
