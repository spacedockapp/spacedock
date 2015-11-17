package com.funnyhatsoftware.spacedock.activity;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Spinner;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.DataHelper;
import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.adapter.ResourceSpinnerAdapter;
import com.funnyhatsoftware.spacedock.data.Resource;
import com.funnyhatsoftware.spacedock.data.Squad;
import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.fragment.DisplaySquadFragment;
import com.funnyhatsoftware.spacedock.fragment.EditSquadFragment;
import com.funnyhatsoftware.spacedock.fragment.EditSquadTwoPaneFragment;
import com.funnyhatsoftware.spacedock.fragment.SetItemListFragment;

import java.util.ArrayList;

public class SquadTabActivity extends FragmentTabActivity implements
        ResourceSpinnerAdapter.ResourceSelectListener {
    private static final String EXTRA_SQUAD_UUID = "squadUuid";
    private boolean mTwoPane;
    private String mSquadUuid;

    public static Intent getIntent(Context context, String squadUuid) {
        if (squadUuid == null) throw new IllegalArgumentException();

        Intent intent = new Intent(context, SquadTabActivity.class);
        intent.putExtra(EXTRA_SQUAD_UUID, squadUuid);
        return intent;
    }

    public void updateTitleAndCost() {
        Squad squad = Universe.getUniverse().getSquadByUUID(mSquadUuid);

        getActionBar().setTitle(squad.getName());
        String cost = Integer.toString(squad.calculateCost());
        getActionBar().setSubtitle(cost + " total points");

        TextView resourceAttributesTextView = (TextView) getWindow().getDecorView().findViewById(R.id.resource_attributes_textview);
        if (resourceAttributesTextView != null) {
            if (squad.getResourceAttributes() != null && squad.getResourceAttributes().length() > 0) {
                resourceAttributesTextView.setText("Factions: " + squad.getResourceAttributes());
                resourceAttributesTextView.setVisibility(View.VISIBLE);
            } else {
                resourceAttributesTextView.setText("");
                resourceAttributesTextView.setVisibility(View.GONE);
            }
        }
        FragmentPagerAdapter pagerAdapter = getPagerAdapter();
        if (pagerAdapter != null){
            DisplaySquadFragment displayFrag = (DisplaySquadFragment)getPagerAdapter().getItem(0);
            if (displayFrag.isInLayout()) {
                displayFrag.updateSquad();
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mTwoPane = getResources().getBoolean(R.bool.use_two_pane);
        mSquadUuid = getIntent().getStringExtra(EXTRA_SQUAD_UUID);
        if (mSquadUuid == null) {
            throw new IllegalArgumentException("Squad uuid required for squad");
        }
        updateTitleAndCost();
    }

    @Override
    protected void onPause() {
        super.onPause();
        DataHelper.saveUniverseData(this);
    }

    @Override
    protected FragmentPagerAdapter createPagerAdapter() {
        return new FragmentPagerAdapter(getSupportFragmentManager()) {
            String[] mTitles = getResources().getStringArray(R.array.squad_tab_labels);

            @Override
            public CharSequence getPageTitle(int position) {
                return mTitles[position];
            }

            @Override
            public Fragment getItem(int i) {
                if (i == 0) {
                    return DisplaySquadFragment.newInstance(mSquadUuid);
                } else {
                    return mTwoPane ? EditSquadTwoPaneFragment.newInstance(mSquadUuid)
                            : EditSquadFragment.newInstance(mSquadUuid);
                }
            }

            @Override
            public int getCount() {
                return 2;
            }
        };
    }

    public void notifyEditSquadFragment(FragmentManager manager) {
        for (Fragment fragment : manager.getFragments()) {
            if (fragment instanceof EditSquadFragment) {
                ((EditSquadFragment) fragment).notifyDataSetChanged();
            } else if (fragment instanceof SetItemListFragment) {
                // Remove SetItemListFragment, as it may be stale/invalid
                manager.beginTransaction().remove(fragment).commit();
                // TODO: have editSquadFragment understand/maintain its selection ID correctly
                // across data modification. Currently, WAR by just removing the select fragment,
                // so that we don't show inconsistent selection options.
            } else if (fragment instanceof EditSquadTwoPaneFragment) {
                notifyEditSquadFragment(fragment.getChildFragmentManager());
            }
        }
    }

    @Override
    public void onResourceChanged(Resource previousResource, Resource selectedResource) {
        final Squad squad = Universe.getUniverse().getSquadByUUID(mSquadUuid);
        if (previousResource != null && previousResource.equippedIntoSquad(squad)
                || selectedResource != null && selectedResource.equippedIntoSquad(squad)) {
            // one of the resources changes the ships/upgrades displayed. notify the edit fragment.
            notifyEditSquadFragment(getSupportFragmentManager());
        }
        if (previousResource != null && previousResource.isOfficerExchangeProgram()) {
            squad.setResourceAttributes(null);
        }
        if (selectedResource != null && selectedResource.isOfficerExchangeProgram()) {
            if (squad.getResourceAttributes() == null) {
                AlertDialog.Builder oepDialog = new AlertDialog.Builder(this);
                LayoutInflater layoutInflater = LayoutInflater.from(this);
                View oepView = layoutInflater.inflate(R.layout.oep_picker, null);
                oepDialog.setTitle("Officer Exchange Program");
                oepDialog.setView(oepView);
                ArrayList<String> factions = Universe.getUniverse().getAllFactions();

                final Spinner spinner1 = (Spinner) oepView.findViewById(R.id.oep_faction_spinner1);
                final Spinner spinner2 = (Spinner) oepView.findViewById(R.id.oep_faction_spinner2);

                ArrayAdapter spinnerArrayAdapter1 = new ArrayAdapter(this,
                        android.R.layout.simple_spinner_dropdown_item,
                        factions);
                ArrayAdapter spinnerArrayAdapter2 = new ArrayAdapter(this,
                        android.R.layout.simple_spinner_dropdown_item,
                        factions);

                spinner1.setAdapter(spinnerArrayAdapter1);
                spinner2.setAdapter(spinnerArrayAdapter2);

                String faction1 = spinner1.getSelectedItem().toString();
                String faction2 = spinner2.getSelectedItem().toString();

                if (faction1.equals(faction2)) {
                    int itemPosition = spinner2.getSelectedItemPosition();
                    itemPosition++;
                    if (itemPosition < spinner2.getCount() - 1) {
                        spinner2.setSelection(itemPosition);
                    } else {
                        itemPosition -= 2;
                        if (itemPosition >= 0) {
                            spinner2.setSelection(itemPosition);
                        }
                    }
                }

                spinner1.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
                    @Override
                    public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {
                        String faction1 = spinner1.getSelectedItem().toString();
                        String faction2 = spinner2.getSelectedItem().toString();

                        if (faction1.equals(faction2)) {
                            int itemPosition = spinner2.getSelectedItemPosition();
                            itemPosition++;
                            if (itemPosition < spinner2.getCount() - 1) {
                                spinner2.setSelection(itemPosition);
                            } else {
                                itemPosition -= 2;
                                if (itemPosition >= 0) {
                                    spinner2.setSelection(itemPosition);
                                }
                            }
                        }
                    }

                    @Override
                    public void onNothingSelected(AdapterView<?> adapterView) {

                    }
                });

                spinner2.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
                    @Override
                    public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {
                        String faction1 = spinner1.getSelectedItem().toString();
                        String faction2 = spinner2.getSelectedItem().toString();

                        if (faction2.equals(faction1)) {
                            int itemPosition = spinner1.getSelectedItemPosition();
                            itemPosition++;
                            if (itemPosition < spinner1.getCount() - 1) {
                                spinner1.setSelection(itemPosition);
                            } else {
                                itemPosition -= 2;
                                if (itemPosition >= 0) {
                                    spinner1.setSelection(itemPosition);
                                }
                            }
                        }
                    }

                    @Override
                    public void onNothingSelected(AdapterView<?> adapterView) {

                    }
                });
                oepDialog.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        squad.setResource(null);
                        squad.setResourceAttributes(null);
                        updateTitleAndCost();
                    }
                });
                oepDialog.setPositiveButton("Okay", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        String attributes = spinner1.getSelectedItem().toString() + " & " + spinner2.getSelectedItem().toString();
                        squad.setResourceAttributes(attributes);
                        updateTitleAndCost();
                    }
                });
                oepDialog.show();
            }
        }
        updateTitleAndCost();
    }

    // TODO: The following are temporary, and should be cleaned up when convenient
    public void onShipSelected() {
        for (Fragment fragment : getSupportFragmentManager().getFragments()) {
            if (fragment instanceof EditSquadTwoPaneFragment) {
                for (Fragment subFragment : fragment.getChildFragmentManager().getFragments()) {
                    if (subFragment instanceof SetItemListFragment) {
                        fragment.getChildFragmentManager().beginTransaction()
                                .remove(subFragment)
                                .commit();
                    }
                }
            }
        }
    }

    public void onSquadMembershipChange() {
        updateTitleAndCost();
    }
}
