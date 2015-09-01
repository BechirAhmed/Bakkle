package com.bakkle.bakkle.Activities;

import android.content.pm.PackageManager;
import android.hardware.Camera;
import android.os.Bundle;
import android.os.Environment;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;

import com.bakkle.bakkle.R;
import com.bumptech.glide.Glide;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@SuppressWarnings( "deprecation" )
public class CameraActivity extends AppCompatActivity implements SurfaceHolder.Callback,
        Camera.ShutterCallback, Camera.PictureCallback, Camera.AutoFocusCallback
{
    private static final int PICTURE_SIZE_MAX_WIDTH = 1280;
    private static final int PREVIEW_SIZE_MAX_WIDTH = 640;

    Camera mCamera;
    SurfaceView surfaceView;
    SurfaceHolder surfaceHolder;
    ImageView cancel;
    ImageView switchCamera;
    ImageView pickFromGallery;
    ImageView capture;
    private int mCameraID;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_camera);
        mCameraID = getBackCameraID();
        surfaceView = (SurfaceView) findViewById(R.id.camera_view);
        cancel = (ImageView) findViewById(R.id.cancel);
        switchCamera = (ImageView) findViewById(R.id.switchCamera);
        pickFromGallery = (ImageView) findViewById(R.id.pickFromGallery);
        capture = (ImageView) findViewById(R.id.capture);
        surfaceHolder = surfaceView.getHolder();
        surfaceHolder.addCallback(this);
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
                } else {
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
        mCamera = getCameraInstance(mCameraID);

    }

    private int getFrontCameraID() {
        PackageManager pm = getPackageManager();
        if (pm.hasSystemFeature(PackageManager.FEATURE_CAMERA_FRONT)) {
            return Camera.CameraInfo.CAMERA_FACING_FRONT;
        }

        return getBackCameraID();
    }

    private int getBackCameraID() {
        return Camera.CameraInfo.CAMERA_FACING_BACK;
    }

    private void restartPreview() {
        if (mCamera != null) {
            mCamera.stopPreview();
            mCamera.release();
            mCamera = null;
        }

        mCamera = getCameraInstance(mCameraID);
        startCameraPreview();

    }

    private void startCameraPreview() {
        determineDisplayOrientation();
        //mCamera.setDisplayOrientation(90);
        setupCamera();

        try {
            mCamera.setPreviewDisplay(surfaceHolder);
            mCamera.startPreview();
        } catch (IOException e) {
            Log.d("error", "Can't start camera preview due to IOException " + e);
            e.printStackTrace();
        }
    }

    private void determineDisplayOrientation() {
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
            // the camera image to match the natural orientation of the device
            displayOrientation = (cameraInfo.orientation + degrees) % 360;
            displayOrientation = (360 - displayOrientation) % 360;
        } else {
            displayOrientation = (cameraInfo.orientation - degrees + 360) % 360;
        }

//        mImageParameters.mDisplayOrientation = displayOrientation;
//        mImageParameters.mLayoutOrientation = degrees;

        mCamera.setDisplayOrientation(displayOrientation);
    }

    private void setupCamera() {
        // Never keep a global parameters
        Camera.Parameters parameters = mCamera.getParameters();

        Camera.Size bestPreviewSize = determineBestPreviewSize(parameters);
        Camera.Size bestPictureSize = determineBestPictureSize(parameters);

        List<Camera.Size> sizes = parameters.getSupportedPreviewSizes();

        Camera.Size selected = sizes.get(0);
        parameters.setPreviewSize(selected.width,selected.height);

        parameters.setPreviewSize(bestPreviewSize.width, bestPreviewSize.height);
        parameters.setPictureSize(bestPictureSize.width, bestPictureSize.height);


        // Set continuous picture focus, if it's supported
        if (parameters.getSupportedFocusModes().contains(Camera.Parameters.FOCUS_MODE_CONTINUOUS_PICTURE)) {
            parameters.setFocusMode(Camera.Parameters.FOCUS_MODE_CONTINUOUS_PICTURE);
//            mCamera.autoFocus(this);
        }

        if(parameters.getSupportedSceneModes().contains(Camera.Parameters.SCENE_MODE_STEADYPHOTO)){
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

    private Camera.Size determineBestPreviewSize(Camera.Parameters parameters) {
        return determineBestSize(parameters.getSupportedPreviewSizes(), PREVIEW_SIZE_MAX_WIDTH);
    }

    private Camera.Size determineBestPictureSize(Camera.Parameters parameters) {
        return determineBestSize(parameters.getSupportedPictureSizes(), PICTURE_SIZE_MAX_WIDTH);
    }

    private Camera.Size determineBestSize(List<Camera.Size> sizes, int widthThreshold) {
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

    /** A safe way to get an instance of the Camera object. */
    public static Camera getCameraInstance(int cameraId){
        Camera c = null;
        try {
            c = Camera.open(cameraId); // attempt to get a Camera instance
        }
        catch (Exception e){
            // Camera is not available (in use or does not exist)
        }
        return c; // returns null if mCamera is unavailable
    }

    @Override
    public void surfaceCreated(SurfaceHolder surfaceHolder)
    {
        try {
            startCameraPreview();
        } catch (Exception e) {
            Log.d("error", "Error setting mCamera preview: " + e.getMessage());
        }
    }

    @Override
    public void surfaceChanged(SurfaceHolder surfaceHolder, int i, int i1, int i2)
    {
//        setupCamera();
//
//        mCamera.setDisplayOrientation(90);
//        mCamera.startPreview();
//        // If your preview can change or rotate, take care of those events here.
//        // Make sure to stop the preview before resizing or reformatting it.
//
//        if (surfaceHolder.getSurface() == null){
//            // preview surface does not exist
//            return;
//        }
//
//        // stop preview before making changes
//        try {
//            mCamera.stopPreview();
//        } catch (Exception e){
//            // ignore: tried to stop a non-existent preview
//        }
//
//        // set preview size and make any resize, rotate or
//        // reformatting changes here
//
//        // start preview with new settings
//        try {
//            mCamera.setPreviewDisplay(surfaceHolder);
//            mCamera.startPreview();
//
//        } catch (Exception e){
//            Log.d("error", "Error starting mCamera preview: " + e.getMessage());
//        }
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder surfaceHolder)
    {

    }

    @Override
    public void onPause() {
        super.onPause();
        mCamera.stopPreview();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        mCamera.release();
        Log.d("CAMERA","Destroy");
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
            ImageView image1 = (ImageView) findViewById(R.id.image1);
            Glide.with(this).load(image).into(image1);
        } catch (Exception e) {
            e.printStackTrace();
        }

        camera.startPreview();
    }

    @Override
    public void onShutter()
    {

    }

    @Override
    public void onAutoFocus(boolean b, Camera camera)
    {

    }
}
