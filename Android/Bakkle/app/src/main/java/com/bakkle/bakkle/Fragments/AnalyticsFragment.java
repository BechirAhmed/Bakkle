package com.bakkle.bakkle.Fragments;


import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.bakkle.bakkle.R;

import java.util.ArrayList;

import lecho.lib.hellocharts.model.PieChartData;
import lecho.lib.hellocharts.model.SliceValue;
import lecho.lib.hellocharts.view.PieChartView;

public class AnalyticsFragment extends Fragment
{
    private String numWant;
    private String numHold;
    private String numMeh;
    private String numView;


    public static AnalyticsFragment newInstance(String numView, String numWant, String numHold, String numMeh)
    {
        AnalyticsFragment fragment = new AnalyticsFragment();
        Bundle args = new Bundle();
        args.putString("numView", numView);
        args.putString("numWant", numWant);
        args.putString("numHold", numHold);
        args.putString("numMeh", numMeh);
        fragment.setArguments(args);
        return fragment;
    }
    
    public AnalyticsFragment() {}
    
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            Bundle args = getArguments();
            numView = args.getString("numView");
            numWant = args.getString("numWant");
            numHold = args.getString("numHold");
            numMeh = args.getString("numMeh");
        }
    }
    
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState)
    {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_analytics, container, false);

        PieChartView pieChartView = (PieChartView) view.findViewById(R.id.piechart);
        pieChartView.setInteractive(false);
        ArrayList<SliceValue> values = new ArrayList<>();
        values.add(new SliceValue(Float.parseFloat(numWant), getResources().getColor(R.color.green)));
        values.add(new SliceValue(Float.parseFloat(numHold), getResources().getColor(R.color.blue)));
        values.add(new SliceValue(Float.parseFloat(numMeh), getResources().getColor(R.color.red)));
        PieChartData pieChartData = new PieChartData(values);
        pieChartData.setCenterText1("Views");
        pieChartData.setCenterText1FontSize(24);
        pieChartData.setCenterText2(numView);
        pieChartData.setCenterText1Color(getResources().getColor(R.color.green));
        pieChartData.setCenterText2FontSize(24);
        pieChartData.setCenterText2Color(getResources().getColor(R.color.green));
        pieChartData.setHasCenterCircle(true);
        pieChartData.setHasLabels(true);
        pieChartData.setValueLabelsTextColor(Color.WHITE);
        pieChartData.setValueLabelTextSize(22);
        pieChartData.setValueLabelBackgroundEnabled(false);
        pieChartView.setPieChartData(pieChartData);


//        PieChart pieChart = (PieChart) view.findViewById(R.id.piechart);
//
//        pieChart.setDescription("");
//        pieChart.setRotationEnabled(false);
//        pieChart.setTouchEnabled(false);
//        pieChart.setCenterTextColor(getResources().getColor(R.color.green));
//        pieChart.setCenterTextSize(22f);
//        pieChart.setUsePercentValues(true);
//        pieChart.setTransparentCircleColor(Color.WHITE);
//        pieChart.setTransparentCircleAlpha(255);
//        pieChart.setCenterText("Views \n" + numView);
//        pieChart.setHoleRadius(0.5f);
//        pieChart.getLegend().setEnabled(false);
//        pieChart.setData(generatePieData());

        return view;
    }

//    public PieData generatePieData()
//    {
//        String titles[] = {"Want", "Hold", "Nope"};
//        String stats[] = {numWant, numHold, numMeh};
//        ArrayList<Entry> entries = new ArrayList<>();
//        entries.add(new Entry(Float.parseFloat(numWant), 0));
//        entries.add(new Entry(Float.parseFloat(numHold), 1));
//        entries.add(new Entry(Float.parseFloat(numMeh), 2));
//        PieDataSet pieDataSet = new PieDataSet(entries, "");
//        pieDataSet.addColor(getResources().getColor(R.color.green));
//        pieDataSet.addColor(getResources().getColor(R.color.blue));
//        pieDataSet.addColor(getResources().getColor(R.color.red));
//        PieData pieData = new PieData(titles, pieDataSet);
//
//        return pieData;
//    }

//    @Override
//    public void onResume() {
//        super.onResume();
//    }
    
    
}
