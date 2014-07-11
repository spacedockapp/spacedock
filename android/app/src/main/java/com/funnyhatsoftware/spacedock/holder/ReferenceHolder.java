package com.funnyhatsoftware.spacedock.holder;

import java.util.List;

import android.content.res.Resources;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.data.Reference;
import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.fragment.DetailsFragment;

public class ReferenceHolder extends SetItemHolder {
    public static final String TYPE_STRING = "Reference";
    static SetItemHolderFactory getFactory() {
        return new SetItemHolderFactory(ReferenceHolder.class, TYPE_STRING) {
            @Override
            public boolean usesFactions() {
                return false;
            }

            @Override
            public SetItemHolder createHolder(View view) {
                return new ReferenceHolder(view);
            }

            @Override
            public List<? extends SetItem> getItemsForFaction(String faction) {
                return Universe.getUniverse().getReferenceItems();
            }

            @Override
            public String getDetails(DetailsFragment.DetailDataBuilder builder, String id) {
                Reference reference = Universe.getUniverse().getReference(id);
                builder.addString("Ability", reference.getAbility());
                return reference.getTitle();
            }
        };
    }
    
    private ReferenceHolder(View view) {
        super(view, R.layout.item_reference_values);
        mUnique.setVisibility(View.GONE);
        mCost.setVisibility(View.GONE);
        mType = (TextView) view.findViewById(R.id.referenceType);
    }

    final TextView mType;

    @Override
    public void reinitializeStubViews(Resources res, SetItem item) {
        Reference reference = (Reference) item;
        mType.setText(reference.getType());
    }
}
