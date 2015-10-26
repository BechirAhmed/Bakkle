package com.bakkle.bakkle.Activities;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.widget.MediaController;
import android.widget.VideoView;

import com.bakkle.bakkle.R;

public class WatchVideo extends AppCompatActivity
{

    VideoView videoView;
    
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_watch_video);
        MediaController vidControl = new MediaController(this);
        videoView = (VideoView) findViewById(R.id.video);
        vidControl.setAnchorView(videoView);
        videoView.setMediaController(vidControl);
        videoView.setVideoPath(getIntent().getStringExtra("filepath"));
        videoView.start();
    }
    
}
