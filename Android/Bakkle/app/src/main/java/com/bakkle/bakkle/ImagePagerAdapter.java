package com.bakkle.bakkle;

import android.content.Context;
import android.net.Uri;
import android.support.v4.view.PagerAdapter;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.MediaController;
import android.widget.VideoView;

import com.squareup.picasso.Picasso;

public class ImagePagerAdapter extends PagerAdapter
{
    String[] urls;
    Context context;

    public ImagePagerAdapter(Context context, String[] urls)
    {
        this.context = context;
        this.urls = urls;
    }

    @Override
    public int getCount()
    {
        return urls.length;
    }

    @Override
    public boolean isViewFromObject(View view, Object object)
    {
        return view == object;
    }

    @Override
    public Object instantiateItem(ViewGroup container, int position)
    {
        if (urls[position].endsWith(".jpg")) {
            ImageView imageView = new ImageView(context);
            Picasso.with(context).load(urls[position]).fit().centerCrop().into(imageView);
            container.addView(imageView, 0);
            return imageView;
        } else { //It's a video
            VideoView videoView = new VideoView(context);
            final MediaController vidControl = new MediaController(context, false);
            vidControl.setAnchorView(videoView);
            videoView.setMediaController(vidControl);
            vidControl.hide();
            videoView.setVideoURI(Uri.parse(urls[position]));
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
        }
    }

    @Override
    public void destroyItem(ViewGroup container, int position, Object object)
    {
        container.removeView((View) object);
    }
}