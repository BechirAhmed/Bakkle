package com.bakkle.bakkle;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;


public class LoginActivity extends Activity implements OnClickListener {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        getActionBar().hide();
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        ((Button)findViewById(R.id.btnSignUpFacebook)).setOnClickListener(this);
        ((Button)findViewById(R.id.btnSignIn)).setOnClickListener(this);
        ((Button)findViewById(R.id.btnSignUpEmail)).setOnClickListener(this);

    }

    @Override
    public void onClick(View v) {
        // TODO: Handle button actions
        switch(v.getId()){
            case R.id.btnSignUpFacebook:
                break;
            case R.id.btnSignUpEmail:
                break;
            case R.id.btnSignIn:
                Intent intent = new Intent(this, SignInActivity.class);
                startActivity(intent);
                break;

        }
    }
}
