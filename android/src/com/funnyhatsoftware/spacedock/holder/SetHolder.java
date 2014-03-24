package com.funnyhatsoftware.spacedock.holder;

import android.content.res.Resources;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.fragment.DetailsFragment;
import com.funnyhatsoftware.spacedock.data.Set;
import com.funnyhatsoftware.spacedock.data.Universe;

import java.util.List;

public class SetHolder extends ItemHolder {
    public static final String TYPE_STRING = "Set";
    static ItemHolderFactory getFactory() {
        return new ItemHolderFactory(Set.class, TYPE_STRING) {
            @Override
            public boolean usesFactions() {
                return false;
            }

            @Override
            public ItemHolder createHolder(View view) {
                return new SetHolder(view);
            }

            @Override
            public List<?> getItemsForFaction(String faction) {
                return Universe.getUniverse().getSets();
            }

            @Override
            public String getDetails(DetailsFragment.DetailDataBuilder builder, String id) {
                return null;
            }
        };
    }

    final TextView mTitle;

    private SetHolder(View view) {
        mTitle = (TextView) view.findViewById(R.id.title);
        view.findViewById(R.id.unique).setVisibility(View.GONE);
        view.findViewById(R.id.cost).setVisibility(View.GONE);
    }

    @Override
    public void reinitialize(Resources res, Object item) {
        Set set = (Set) item;
        mTitle.setText(set.getProductName());
    }
}
