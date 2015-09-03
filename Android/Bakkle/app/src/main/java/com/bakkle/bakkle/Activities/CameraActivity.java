package com.bakkle.bakkle.Activities;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.hardware.Camera;
import android.media.MediaRecorder;
import android.media.ThumbnailUtils;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.MotionEvent;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.bakkle.bakkle.R;
import com.bumptech.glide.Glide;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@SuppressWarnings ("deprecation")
public class CameraActivity extends AppCompatActivity implements SurfaceHolder.Callback,
        Camera.ShutterCallback, Camera.PictureCallback, Camera.AutoFocusCallback
{
    private static final int PICTURE_SIZE_MAX_WIDTH = 1280;
    private static final int PREVIEW_SIZE_MAX_WIDTH = 640;

    Camera        mCamera;
    MediaRecorder mRecorder;
    SurfaceView   surfaceView;
    SurfaceHolder surfaceHolder;
    ImageView     cancel;
    TextView      next;
    ImageView     switchCamera;
    ImageView     pickFromGallery;
    ImageView     capture;
    ProgressBar   progressBar;
    private int mCameraID;
    int       imageCount;
    ImageView imageViews[];
    ImageView deletePictureViews[];
    boolean   occupied[];
    boolean isLongPressed      = false;
    boolean currentlyRecording = false;
    ArrayList<ImageTaken> pics;
    CountDownTimer        timer;
    File video = null;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_camera);
        imageCount = 0;
        pics = new ArrayList<>();
        mCameraID = getBackCameraID();
        occupied = new boolean[4]; //all automatically initialized to false
        deletePictureViews = new ImageView[4];
        imageViews = new ImageView[4];
        imageViews[0] = (ImageView) findViewById(R.id.image1);
        imageViews[1] = (ImageView) findViewById(R.id.image2);
        imageViews[2] = (ImageView) findViewById(R.id.image3);
        imageViews[3] = (ImageView) findViewById(R.id.image4);
        deletePictureViews[0] = (ImageView) findViewById(R.id.x1);
        deletePictureViews[1] = (ImageView) findViewById(R.id.x2);
        deletePictureViews[2] = (ImageView) findViewById(R.id.x3);
        deletePictureViews[3] = (ImageView) findViewById(R.id.x4);
        surfaceView = (SurfaceView) findViewById(R.id.camera_view);
        progressBar = (ProgressBar) findViewById(R.id.progress);
        progressBar.getProgressDrawable().setColorFilter(Color.RED, PorterDuff.Mode.SRC_IN);
        cancel = (ImageView) findViewById(R.id.cancel);
        next = (TextView) findViewById(R.id.next);
        switchCamera = (ImageView) findViewById(R.id.switchCamera);
        pickFromGallery = (ImageView) findViewById(R.id.pickFromGallery);
        capture = (ImageView) findViewById(R.id.capture);
        surfaceHolder = surfaceView.getHolder();
        surfaceHolder.addCallback(this);
        next.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {
                Intent intent = new Intent();
                int y = 0;
                for (ImageTaken taken : pics) {
                    if (taken.isBeingUsed()) {
                        intent.putExtra("pic" + y++, taken.getFile().getAbsolutePath());
                    }
                }
                intent.putExtra("num", y);
                setResult(-1, intent);
                finish();
            }
        });
        cancel.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {
                finish();
            }
        });
        switchCamera.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {
                if (mCameraID == Camera.CameraInfo.CAMERA_FACING_FRONT) {
                    mCameraID = getBackCameraID();
                }
                else {
                    mCameraID = getFrontCameraID();
                }
                restartPreview();

            }
        });
        pickFromGallery.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {

            }
        });
        capture.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {
                mCamera.takePicture(CameraActivity.this, null, null, CameraActivity.this);
            }
        });
        capture.setOnLongClickListener(new View.OnLongClickListener()
        {
            @Override
            public boolean onLongClick(View view)
            {
                isLongPressed = true;
                currentlyRecording = true;
                initRecorder();
                progressBar.setVisibility(View.VISIBLE);
                progressBar.setMax(15);
                progressBar.setProgress(0);
                timer = new CountDownTimer(15000, 500)
                {
                    @Override
                    public void onTick(long leftTimeInMilliseconds)
                    {
                        long seconds = leftTimeInMilliseconds / 1000;
                        progressBar.setProgress(15 - (int) seconds);
                    }

                    @Override
                    public void onFinish()
                    {
                        currentlyRecording = false;
                        stopRecording();
                        progressBar.setVisibility(View.GONE);
                        progressBar.setProgress(0);
                        addVideoToList();
                    }

                }.start();
                beginRecording();
                return true;
            }
        });
        capture.setOnTouchListener(new View.OnTouchListener()
        {
            @Override
            public boolean onTouch(View view, MotionEvent motionEvent)
            {
                if (motionEvent.getAction() == MotionEvent.ACTION_UP) {
                    if (isLongPressed) {
                        if (currentlyRecording) {
                            currentlyRecording = false;
                            stopRecording();
                            timer.cancel();
                            progressBar.setVisibility(View.GONE);
                            progressBar.setProgress(0);
                            addVideoToList();
                        }
                        isLongPressed = false;
                    }
                }
                return false;
            }
        });
        mCamera = getCameraInstance(mCameraID);


    }

    private void addVideoToList()
    {
        Bitmap bMap = ThumbnailUtils.createVideoThumbnail(video.getAbsolutePath(), MediaStore.Video.Thumbnails.MICRO_KIND);
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String imageFileName = "BakkleTN_" + timeStamp + "_";
        File storageDir = Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_PICTURES);
        File image = null;
        try {
            image = File.createTempFile(
                    imageFileName,  /* prefix */
                    ".jpg",         /* suffix */
                    storageDir      /* directory */
            );
            FileOutputStream out = new FileOutputStream(image);
            bMap.compress(Bitmap.CompressFormat.JPEG, 90, out);
            out.flush();
            out.close();
        }
        catch (IOException e) {
            e.printStackTrace();
        }
        loadPicIntoView(new ImageTaken(image, true, imageCount++, true));
    }

    private int getFrontCameraID()
    {
        PackageManager pm = getPackageManager();
        if (pm.hasSystemFeature(PackageManager.FEATURE_CAMERA_FRONT)) {
            return Camera.CameraInfo.CAMERA_FACING_FRONT;
        }

        return getBackCameraID();
    }

    private int getBackCameraID()
    {
        return Camera.CameraInfo.CAMERA_FACING_BACK;
    }

    private void restartPreview()
    {
        if (mCamera != null) {
            mCamera.stopPreview();
            mCamera.release();
            mCamera = null;
        }

        mCamera = getCameraInstance(mCameraID);
        startCameraPreview();

    }

    private void startCameraPreview()
    {
        determineDisplayOrientation();
        setupCamera();

        try {
            mCamera.setPreviewDisplay(surfaceHolder);
            mCamera.startPreview();
        }
        catch (IOException e) {
            Log.d("error", "Can't start camera preview due to IOException " + e);
            e.printStackTrace();
        }
    }

    private void determineDisplayOrientation()
    {
        Camera.CameraInfo cameraInfo = new Camera.CameraInfo();
        Camera.getCameraInfo(mCameraID, cameraInfo);

        // Clockwise rotation needed to align the window display to the natural position
        int rotation = getWindowManager().getDefaultDisplay().getRotation();
        int degrees = 0;

        switch (rotation) {
            case Surface.ROTATION_0: {
                degrees = 0;
                break;
            }
            case Surface.ROTATION_90: {
                degrees = 90;
                break;
            }
            case Surface.ROTATION_180: {
                degrees = 180;
                break;
            }
            case Surface.ROTATION_270: {
                degrees = 270;
                break;
            }
        }

        int displayOrientation;

        // CameraInfo.Orientation is the angle relative to the natural position of the device
        // in clockwise rotation (angle that is rotated clockwise from the natural position)
        if (cameraInfo.facing == Camera.CameraInfo.CAMERA_FACING_FRONT) {
            // Orientation is angle of rotation when facing the camera for
            // the camera imageViews to match the natural orientation of the device
            displayOrientation = (cameraInfo.orientation + degrees) % 360;
            displayOrientation = (360 - displayOrientation) % 360;
        }
        else {
            displayOrientation = (cameraInfo.orientation - degrees + 360) % 360;
        }

//        mImageParameters.mDisplayOrientation = displayOrientation;
//        mImageParameters.mLayoutOrientation = degrees;

        mCamera.setDisplayOrientation(displayOrientation);
    }

    private void setupCamera()
    {
        // Never keep a global parameters
        Camera.Parameters parameters = mCamera.getParameters();

        Camera.Size bestPreviewSize = determineBestPreviewSize(parameters);
        Camera.Size bestPictureSize = determineBestPictureSize(parameters);

        List<Camera.Size> sizes = parameters.getSupportedPreviewSizes();

        Camera.Size selected = sizes.get(0);
        parameters.setPreviewSize(selected.width, selected.height);

        parameters.setPreviewSize(bestPreviewSize.width, bestPreviewSize.height);
        parameters.setPictureSize(bestPictureSize.width, bestPictureSize.height);


        // Set continuous picture focus, if it's supported
        if (parameters.getSupportedFocusModes().contains(Camera.Parameters.FOCUS_MODE_CONTINUOUS_PICTURE)) {
            parameters.setFocusMode(Camera.Parameters.FOCUS_MODE_CONTINUOUS_PICTURE);
        }

        if (parameters.getSupportedSceneModes().contains(Camera.Parameters.SCENE_MODE_STEADYPHOTO)) {
            parameters.setSceneMode(Camera.Parameters.SCENE_MODE_STEADYPHOTO);
        }

//        final View changeCameraFlashModeBtn = findViewById(R.id.flash);
//        List<String> flashModes = parameters.getSupportedFlashModes();
//        if (flashModes != null && flashModes.contains(mFlashMode)) {
//            parameters.setFlashMode(mFlashMode);
//            changeCameraFlashModeBtn.setVisibility(View.VISIBLE);
//        } else {
//            changeCameraFlashModeBtn.setVisibility(View.INVISIBLE);
//        }

        // Lock in the changes
        mCamera.setParameters(parameters);
    }

    private Camera.Size determineBestPreviewSize(Camera.Parameters parameters)
    {
        return determineBestSize(parameters.getSupportedPreviewSizes(), PREVIEW_SIZE_MAX_WIDTH);
    }

    private Camera.Size determineBestPictureSize(Camera.Parameters parameters)
    {
        return determineBestSize(parameters.getSupportedPictureSizes(), PICTURE_SIZE_MAX_WIDTH);
    }

    private Camera.Size determineBestSize(List<Camera.Size> sizes, int widthThreshold)
    {
        Camera.Size bestSize = null;
        Camera.Size size;
        int numOfSizes = sizes.size();
        for (int i = 0; i < numOfSizes; i++) {
            size = sizes.get(i);
            boolean isDesireRatio = (size.width / 4) == (size.height / 3);
            boolean isBetterSize = (bestSize == null) || size.width > bestSize.width;

            if (isDesireRatio && isBetterSize) {
                bestSize = size;
            }
        }

        if (bestSize == null) {
            Log.d("error", "cannot find the best camera size");
            return sizes.get(sizes.size() - 1);
        }

        return bestSize;
    }

    /**
     * A safe way to get an instance of the Camera object.
     */
    public static Camera getCameraInstance(int cameraId)
    {
        Camera c = null;
        try {
            c = Camera.open(cameraId); // attempt to get a Camera instance
        }
        catch (Exception e) {
            // Camera is not available (in use or does not exist)
        }
        return c; // returns null if mCamera is unavailable
    }

    @Override
    public void surfaceCreated(SurfaceHolder surfaceHolder)
    {
        try {
            startCameraPreview();
            initRecorder();
        }
        catch (Exception e) {
            Log.d("error", "Error setting mCamera preview: " + e.getMessage());
        }
    }

    @Override
    public void surfaceChanged(SurfaceHolder surfaceHolder, int i, int i1, int i2)
    {

    }

    @Override
    public void surfaceDestroyed(SurfaceHolder surfaceHolder)
    {

    }

    @Override
    public void onPause()
    {
        super.onPause();
        //mCamera.release();
        mCamera.stopPreview();
    }

    @Override
    public void onDestroy()
    {
        super.onDestroy();
        mCamera.release();
        Log.d("CAMERA", "Destroy");
    }

    @Override
    public void onPictureTaken(byte[] bytes, Camera camera)
    {
        try {
            String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
            String imageFileName = "Bakkle_" + timeStamp + "_";
            File storageDir = Environment.getExternalStoragePublicDirectory(
                    Environment.DIRECTORY_PICTURES);
            File image = File.createTempFile(
                    imageFileName,  /* prefix */
                    ".jpg",         /* suffix */
                    storageDir      /* directory */
            );
            FileOutputStream out = new FileOutputStream(image);
            out.write(bytes);
            out.flush();
            out.close();
            ImageTaken taken = new ImageTaken(image, true, imageCount++);
            pics.add(taken);
            loadPicIntoView(taken);
            int j = 0;
            for (int i = 0; i < pics.size(); i++) {
                if (pics.get(i).isBeingUsed())
                    j++;
            }
            if (j == 4) {
                mCamera.stopPreview();
                pickFromGallery.setVisibility(View.INVISIBLE);
                switchCamera.setVisibility(View.INVISIBLE);
                capture.setVisibility(View.INVISIBLE);
            }
            else if (j > 0)
                next.setVisibility(View.VISIBLE);
            //Glide.with(this).load(imageViews).into(image1);
        }
        catch (Exception e) {
            e.printStackTrace();
        }

        camera.startPreview();
    }

    private void initRecorder()
    {
        if (mRecorder != null)
            return;
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String videoFileName = "Bakkle_" + timeStamp + "_";
        File storageDir = Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_MOVIES);
        String mOutputFileName = null;
        try {
            video = File.createTempFile(
                    videoFileName,  /* prefix */
                    ".mp4",         /* suffix */
                    storageDir      /* directory */
            );
            mOutputFileName = video.getPath();
        }
        catch (IOException e) {
            e.printStackTrace();
        }

        try {
            mCamera.unlock();
            mRecorder = new MediaRecorder();
            mRecorder.setCamera(mCamera);

            mRecorder.setAudioSource(MediaRecorder.AudioSource.CAMCORDER);
            mRecorder.setVideoSource(MediaRecorder.VideoSource.CAMERA);
            mRecorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4);
            mRecorder.setVideoSize(176, 144);
            mRecorder.setVideoFrameRate(15);
            mRecorder.setVideoEncoder(MediaRecorder.VideoEncoder.MPEG_4_SP);
            mRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);
            mRecorder.setMaxDuration(15000); // limit to 7 seconds
            mRecorder.setPreviewDisplay(surfaceHolder.getSurface());
            mRecorder.setOutputFile(mOutputFileName);

            mRecorder.prepare();
            Log.v("Error", "MediaRecorder initialized");
        }
        catch (Exception e) {
            Log.v("Error", "MediaRecorder failed to initialize");
            e.printStackTrace();

        }
    }

    private void beginRecording()
    {
        mRecorder.start();
        Toast.makeText(this, "Recording!", Toast.LENGTH_SHORT).show();

    }

    private void stopRecording()
    {
        if (mRecorder != null) {
            try {
                mRecorder.stop();
                try {
                    mCamera.reconnect();
                }
                catch (IOException e) {
                    e.printStackTrace();
                }
            }
            catch (IllegalStateException e) {
                Log.v("Error", e.getMessage());
            }
            releaseRecorder();
        }
    }

    private void loadPicIntoView(final ImageTaken imageTaken)
    {
        for (int i = 0; i < 4; i++) {
            final int j = i;
            if (!occupied[i]) {
                Glide.with(this)
                        .load(imageTaken.getFile())
                        .into(imageViews[i]);
                occupied[i] = true;
                deletePictureViews[i].setVisibility(View.VISIBLE);
                deletePictureViews[i].setOnClickListener(new View.OnClickListener()
                {
                    @Override
                    public void onClick(View view)
                    {
                        occupied[j] = false; //TODO: Maybe instead of all this junk, the isBeingUsed pics are put into another array. They can be taken out when the X is clicked, and that way it will maintain the order of the pictures too
                        imageTaken.setBeingUsed(false);
                        deletePictureViews[j].setVisibility(View.INVISIBLE);
                        imageViews[j].setImageDrawable(null);
                        occupied = new boolean[4];
                        int y = 0;
                        for (int x = 0; x < pics.size(); x++) {
                            ImageTaken taken = pics.get(x);
                            if (taken.isBeingUsed()) {
                                Glide.with(CameraActivity.this)
                                        .load(taken.getFile())
                                        .into(imageViews[y]);
                                deletePictureViews[y].setVisibility(View.VISIBLE);
                                deletePictureViews[y++].setOnClickListener(this);
                            }
                        }
                        //Glide.clear(imageViews[j]);
                    }
                });
                break;
            }
        }
    }





    private void releaseRecorder()
    {
        if (mRecorder != null) {
            mRecorder.release();
            mRecorder = null;
        }
    }

    @Override
    public void onAutoFocus(boolean b, Camera camera)
    {
    }

    @Override
    public void onShutter()
    {
    }

    private class ImageTaken
    {
        File    file;
        boolean beingUsed;
        boolean videoThumbnail;
        int     rank;

        public ImageTaken(File file, boolean beingUsed, int rank)
        {
            this.file = file;
            this.beingUsed = beingUsed;
            this.rank = rank;
            videoThumbnail = false;
        }

        public ImageTaken(File file, boolean beingUsed, int rank, boolean videoThumbnail)
        {
            this.file = file;
            this.beingUsed = beingUsed;
            this.rank = rank;
            this.videoThumbnail = videoThumbnail;
        }

        public File getFile()
        {
            return file;
        }

        public boolean isBeingUsed()
        {
            return beingUsed;
        }

        public void setBeingUsed(boolean beingUsed)
        {
            this.beingUsed = beingUsed;
        }

        public int getRank()
        {
            return rank;
        }

        public boolean isVideoThumbnail()
        {
            return videoThumbnail;
        }
    }
}
