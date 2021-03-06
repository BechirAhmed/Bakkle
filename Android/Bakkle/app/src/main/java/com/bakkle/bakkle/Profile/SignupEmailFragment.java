package com.bakkle.bakkle.Profile;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.content.Context;
import android.os.Bundle;
import android.support.design.widget.TextInputLayout;
import android.support.v4.app.Fragment;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.bakkle.bakkle.API;
import com.bakkle.bakkle.Constants;
import com.bakkle.bakkle.Prefs;
import com.bakkle.bakkle.R;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class SignupEmailFragment extends Fragment
{
    // UI references.
    private EditText emailEditText;
    private EditText passwordEditText;
    private EditText confirmPasswordEditText;
    private EditText nameEditText;

    private TextInputLayout emailInputLayout;
    private TextInputLayout passwordInputLayout;
    private TextInputLayout confirmPasswordInputLayout;
    private TextInputLayout nameInputLayout;

    private View progressView;
    private View loginFormView;
    private boolean started = false;

    public SignupEmailFragment()
    {
        // Required empty public constructor
    }

    public static SignupEmailFragment newInstance()
    {
        return new SignupEmailFragment();
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
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_signup_email, container, false);

        // Set up the login form.
        emailEditText = (EditText) view.findViewById(R.id.email);
        passwordEditText = (EditText) view.findViewById(R.id.password);
        confirmPasswordEditText = (EditText) view.findViewById(R.id.password_confirm);
        nameEditText = (EditText) view.findViewById(R.id.name);

        emailInputLayout = (TextInputLayout) view.findViewById(R.id.emailInput);
        passwordInputLayout = (TextInputLayout) view.findViewById(R.id.passwordInput);
        confirmPasswordInputLayout = (TextInputLayout) view.findViewById(
                R.id.confirm_password_input);
        nameInputLayout = (TextInputLayout) view.findViewById(R.id.nameInput);

        Button mEmailSignInButton = (Button) view.findViewById(R.id.email_sign_in_button);

        //TODO: Ability to change profile picture (Where to upload picture on server?)

        passwordEditText.setOnEditorActionListener(new TextView.OnEditorActionListener()
        {
            @Override
            public boolean onEditorAction(TextView textView, int id, KeyEvent keyEvent)
            {
                if (id == R.id.login || id == EditorInfo.IME_NULL) {
                    attemptLogin();
                    return true;
                }
                return false;
            }
        });

        mEmailSignInButton.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View view)
            {
                attemptLogin();
            }
        });

        loginFormView = view.findViewById(R.id.login_form);
        progressView = view.findViewById(R.id.login_progress);

        return view;
    }

    @Override
    public void onAttach(Context context)
    {
        super.onAttach(context);

        if (context instanceof RegisterActivity) {
            ((RegisterActivity) context).getSupportActionBar().show();
            ((RegisterActivity) context).getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }
    }

    @Override
    public void onDetach()
    {
        super.onDetach();
    }

    /**
     * Attempts to sign in or register the account specified by the login form.
     * If there are form errors (invalid email, missing fields, etc.), the
     * errors are presented and no actual login attempt is made.
     */
    private void attemptLogin()
    {
        if (started) {
            return;
        }
        started = true;

        // Reset errors.
        emailInputLayout.setErrorEnabled(false);
        passwordInputLayout.setErrorEnabled(false);
        nameInputLayout.setErrorEnabled(false);
        confirmPasswordInputLayout.setErrorEnabled(false);

        // Store values at the time of the login attempt.
        String name = nameEditText.getText().toString();
        String email = emailEditText.getText().toString();
        String password = passwordEditText.getText().toString();
        String password_confirm = confirmPasswordEditText.getText().toString();

        boolean cancel = false;
        View focusView = null;

        // Check for a valid password, if the user entered one.
        if (TextUtils.isEmpty(name)) {
            nameInputLayout.setError(getString(R.string.error_field_required));
            focusView = nameEditText;
            cancel = true;
        } else if (TextUtils.isEmpty(email)) {
            emailInputLayout.setError(getString(R.string.error_field_required));
            focusView = emailEditText;
            cancel = true;
        } else if (!isEmailValid(email)) {
            emailInputLayout.setError(getString(R.string.error_invalid_email));
            focusView = emailEditText;
            cancel = true;
        } else if (TextUtils.isEmpty(password) || !isPasswordValid(password)) {
            passwordInputLayout.setError(getString(R.string.error_invalid_password));
            focusView = passwordEditText;
            cancel = true;
        } else if (!TextUtils.equals(password, password_confirm)) {
            confirmPasswordInputLayout.setError(getString(R.string.error_password_mismatch));
            focusView = confirmPasswordEditText;
            cancel = true;
        }

        if (cancel) {
            // There was an error; don't attempt login and focus the first
            // form field with an error.
            focusView.requestFocus();
            started = false;
        } else {
            // Show a progress spinner, and kick off a background task to
            // perform the user login attempt.
            showProgress(true);
            API.getInstance(getContext())
                    .getEmailUserId(email, new EmailIdListener(name, password));
            //TODO: How do you submit the password to the server?
        }
    }

    private boolean isEmailValid(String email)
    {
        //return Patterns.EMAIL_ADDRESS.matcher(email).matches();
        String ePattern = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\])|(([a-zA-Z\\-0-9]+\\.)+[a-zA-Z]{2,}))$";
        Pattern p = Pattern.compile(ePattern);
        Matcher m = p.matcher(email);
        return m.matches();
    }

    private boolean isPasswordValid(String password)
    {
        return password.length() >= 6;
    }

    /**
     * Shows the progress UI and hides the login form.
     */
    private void showProgress(final boolean show)
    {
        int shortAnimTime = getResources().getInteger(android.R.integer.config_shortAnimTime);

        loginFormView.setVisibility(show ? View.GONE : View.VISIBLE);
        loginFormView.animate()
                .setDuration(shortAnimTime)
                .alpha(show ? 0 : 1)
                .setListener(new AnimatorListenerAdapter()
                {
                    @Override
                    public void onAnimationEnd(Animator animation)
                    {
                        loginFormView.setVisibility(show ? View.GONE : View.VISIBLE);
                    }
                });

        progressView.setVisibility(show ? View.VISIBLE : View.GONE);
        progressView.animate()
                .setDuration(shortAnimTime)
                .alpha(show ? 1 : 0)
                .setListener(new AnimatorListenerAdapter()
                {
                    @Override
                    public void onAnimationEnd(Animator animation)
                    {
                        progressView.setVisibility(show ? View.VISIBLE : View.GONE);
                    }
                });
    }

    private class EmailIdListener implements Response.Listener<JSONObject>
    {
        private String name;
        private String password;

        public EmailIdListener(String name, String password)
        {
            this.name = name;
            this.password = password;
        }

        @Override
        public void onResponse(JSONObject response)
        {
            try {
                if (response.getInt("status") == 1) {
                    Prefs.getInstance().setUserId(response.getString("userid"));
                    API.getInstance(getContext())
                            .setPassword(password, new PasswordListener(),
                                    new PasswordErrorListener());
                } else {
                    Toast.makeText(getContext(), "There was error signing up", Toast.LENGTH_SHORT)
                            .show();
                    showProgress(false);
                    started = false;
                }
            } catch (JSONException e) {
                Toast.makeText(getContext(), "There was error signing up", Toast.LENGTH_SHORT)
                        .show();
                showProgress(false);
                started = false;
            }
        }

        private class PasswordListener implements Response.Listener<JSONObject>
        {
            @Override
            public void onResponse(JSONObject response)
            {
                try {
                    if (response.getInt("status") == 1) {
                        API.getInstance(getContext()).registerFacebook(new LoginListener());
                    } else {
                        Toast.makeText(getContext(), "There was error signing up",
                                Toast.LENGTH_SHORT).show();
                        showProgress(false);
                        started = false;
                    }
                } catch (JSONException e) {
                    Toast.makeText(getContext(), "There was an error signing up", Toast.LENGTH_LONG)
                            .show();
                    showProgress(false);
                    started = false;
                }
            }
        }

        private class PasswordErrorListener implements Response.ErrorListener
        {
            @Override
            public void onErrorResponse(VolleyError error)
            {
                showProgress(false);
                Toast.makeText(getContext(), "There was error setting password", Toast.LENGTH_SHORT)
                        .show();
                error.printStackTrace();
            }
        }

        private class LoginListener implements
                                    Response.Listener<JSONObject> //TODO: Extract the listeners to another file
        {
            @Override
            public void onResponse(JSONObject response)
            {
                try {
                    if (response.has("status") && response.getInt("status") == 1) {
                        Prefs prefs = Prefs.getInstance(getContext());
                        prefs.setAuthToken(response.getString("auth_token"));
                        prefs.setAuthenticated(true);
                        prefs.setLoggedIn(true);
                        prefs.setGuest(false);
                        showProgress(false);
                        prefs.setUsername(name);
                        prefs.setName(name);
                        String[] split = name.split(" ");
                        if (split.length >= 2) {
                            prefs.setFirstName(split[0]);
                            prefs.setLastName(split[split.length - 1]);
                        } else {
                            prefs.setFirstName(name);
                            prefs.setLastName("");
                        }

                        getActivity().setResult(Constants.REUSLT_CODE_OK);
                        getActivity().finish();
                    } else {
                        Toast.makeText(getContext(), "There was error signing up",
                                Toast.LENGTH_SHORT).show();
                        showProgress(false);
                        started = false;
                    }
                } catch (JSONException e) {
                    Toast.makeText(getContext(), "There was error signing up", Toast.LENGTH_SHORT)
                            .show();
                    showProgress(false);
                    started = false;
                }
            }
        }
    }
}
