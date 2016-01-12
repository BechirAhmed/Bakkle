package com.bakkle.bakkle.Selling;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.bakkle.bakkle.GetFeedItem;
import com.bakkle.bakkle.Models.FeedItem;
import com.bakkle.bakkle.R;
import com.github.mikephil.charting.animation.Easing;
import com.github.mikephil.charting.charts.PieChart;
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.data.PieData;
import com.github.mikephil.charting.data.PieDataSet;
import com.github.mikephil.charting.formatter.PercentFormatter;

import java.util.ArrayList;
import java.util.List;

public class AnalyticsFragment extends Fragment
{
    PieChart pieChart;
    PieData  data;
    FeedItem item;

    public AnalyticsFragment()
    {
    }

    public static AnalyticsFragment newInstance()
    {
        return new AnalyticsFragment();
    }

    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void onAttach(Context context)
    {
        super.onAttach(context);
        item = ((GetFeedItem) context).getItem();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState)
    {
        View view = inflater.inflate(R.layout.fragment_analytics, container, false);

        pieChart = (PieChart) view.findViewById(R.id.pieChart);

        pieChart.getLegend().setEnabled(false);
        pieChart.setDescription("");
        pieChart.setVisibility(View.INVISIBLE);

        pieChart.setCenterText("Total Views: " + item.getNumViews());
        pieChart.setCenterTextSize(24f);
        pieChart.setCenterTextColor(getResources().getColor(R.color.colorPrimaryText));

        pieChart.setHoleRadius(45f);
        pieChart.setTransparentCircleRadius(50f);

        List<Entry> entries = new ArrayList<>();
        List<String> xVals = new ArrayList<>();

        xVals.add("Want");
        entries.add(new Entry(item.getNumWant(), 0));
        xVals.add("Hold");
        entries.add(new Entry(item.getNumHolding(), 1));
        xVals.add("Nope");
        entries.add(new Entry(item.getNumNope(), 2));

        PieDataSet dataSet = new PieDataSet(entries, "");

        dataSet.setColors(new int[]{R.color.colorPrimary, R.color.colorHoldBlue, R.color.colorNope},
                          getContext());
        dataSet.setValueTextColor(getResources().getColor(R.color.colorTextAndIcons));
        dataSet.setValueTextSize(18f);
        //dataSet.set

        data = new PieData(xVals, dataSet);
        pieChart.setUsePercentValues(true);
        data.setValueFormatter(new PercentFormatter());

        return view;
    }

    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) //To make sure the chart is animated every time
    {
        super.setUserVisibleHint(isVisibleToUser);
        if (isVisibleToUser) {
            pieChart.setData(data);
            pieChart.setVisibility(View.VISIBLE);
            pieChart.animateXY(1000, 1000, Easing.EasingOption.EaseInSine,
                               Easing.EasingOption.EaseInSine);
        } else {
            if (pieChart != null) {
                pieChart.setVisibility(View.INVISIBLE);
            }
        }
    }
}
