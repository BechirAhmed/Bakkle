package com.bakkle.bakkle;

import android.content.Context;
import android.net.Uri;
import android.support.v4.view.PagerAdapter;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.MediaController;
import android.widget.VideoView;

import com.squareup.picasso.Picasso;

import java.util.ArrayList;
import java.util.List;

public class ImagePagerAdapter extends PagerAdapter
{
    List<String> urls;
    Context context;

    public ImagePagerAdapter(Context context, List<String> urls)
    {
        this.context = context;
        this.urls = urls;
    }

    public ImagePagerAdapter(Context context)
    {
        this.context = context;
        urls = new ArrayList<>();
    }

    @Override
    public int getCount()
    {
        return urls.size();
    }

    @Override
    public boolean isViewFromObject(View view, Object object)
    {
        return view == object;
    }

    @Override
    public Object instantiateItem(ViewGroup container, int position)
    {
        if (urls.get(position).endsWith(".mp4")) {
            VideoView videoView = new VideoView(context);
            final MediaController vidControl = new MediaController(context, false);
            vidControl.setAnchorView(videoView);
            videoView.setMediaController(vidControl);
            vidControl.hide();
            videoView.setVideoURI(Uri.parse(urls.get(position)));
            videoView.start();
            videoView.setOnClickListener(new View.OnClickListener()
            {
                @Override
                public void onClick(View v)
                {
                    if (((VideoView) v).isPlaying()) {
                        ((VideoView) v).pause();
                        vidControl.hide();
                    } else {
                        ((VideoView) v).start();
                        vidControl.hide();
                    }
                }
            });

            container.addView(videoView, 0);
            return videoView;
        } else { //It's an image
            ImageView imageView = new ImageView(context);
            String path = urls.get(position);
            path = path.startsWith("/") ? "file:" + path : path;
            Picasso.with(context).load(path).fit().centerCrop().into(imageView);
            container.addView(imageView, 0);
            return imageView;
        }
    }

    public void addItem(String url)
    {
        Log.v("URL", url);
        urls.add(url);
        notifyDataSetChanged();
    }

    public String getItem(int position)
    {
        return urls.get(position);
    }

    @Override
    public void destroyItem(ViewGroup container, int position, Object object)
    {
        container.removeView((View) object);
    }
}