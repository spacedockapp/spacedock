package com.funnyhatsoftware.spacedock.holder;

import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.util.Log;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.activity.ExpansionDetailsActivity;
import com.funnyhatsoftware.spacedock.data.Set;
import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.fragment.DetailsFragment;

import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class ExpansionHolder extends SetItemHolder {
    // Set wrapper, used to make sets look like SetItems
    private static class Expansion extends SetItem {
        Set mSet;
        Expansion(Set set) {
            mSet = set;
        }

        @Override
        public String getTitle() {
            return mSet.getProductName();
        }

        @Override
        public String getExternalId() {
            return mSet.getExternalId();
        }
    }

    public static final String TYPE_STRING = "Expansion";
    static SetItemHolderFactory getFactory() {
        return new SetItemHolderFactory(ExpansionHolder.class, TYPE_STRING) {
            @Override
            public boolean usesFactions() {
                return false;
            }

            @Override
            public SetItemHolder createHolder(View view) {
                return new ExpansionHolder(view);
            }

            @Override
            public List<? extends SetItem> getItemsForFaction(String faction) {
                List<Set> setList = Universe.getUniverse().getSetsForSection(faction);
                Collections.sort(setList, new Set.SetComparator());
                List<Expansion> list = new ArrayList<Expansion>();
                for (Set set : setList) {
                    list.add(new Expansion(set));
                }
                return list;
            }

            @Override
            public Intent getDetailsIntent(Context context, String id) {
                return ExpansionDetailsActivity.getIntent(context, id);
            }

            @Override
            public String getDetails(DetailsFragment.DetailDataBuilder builder, String id) {
                throw new IllegalStateException();
            }
        };
    }

    private ExpansionHolder(View view) {
        super(view, R.layout.item_expansion_values);
        mUnique.setVisibility(View.GONE);
        mCost.setVisibility(View.GONE);
        mReleaseDate = (TextView) view.findViewById(R.id.releaseDate);
        mOverallSetName = (TextView) view.findViewById(R.id.overallSetName);
    }

    final TextView mReleaseDate;
    final TextView mOverallSetName;

    @Override
    public void reinitializeStubViews(Resources res, SetItem item) {
        Set set = ((Expansion) item).mSet;
        String dateString = DateFormat.getDateInstance().format(set.getReleaseDate());
        //mReleaseDate.setText(dateString);
        //mOverallSetName.setText(set.getWave());
    }
}
