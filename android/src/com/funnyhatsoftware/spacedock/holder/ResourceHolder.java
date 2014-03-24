package com.funnyhatsoftware.spacedock.holder;

import android.content.res.Resources;
import android.view.View;

import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.fragment.DetailsFragment;
import com.funnyhatsoftware.spacedock.data.Resource;
import com.funnyhatsoftware.spacedock.data.Universe;

import java.util.List;

public class ResourceHolder extends SetItemHolder {
    public static final String TYPE_STRING = "Resource";
    static SetItemHolderFactory getFactory() {
        return new SetItemHolderFactory(Resource.class, TYPE_STRING) {
            @Override
            public boolean usesFactions() {
                return false;
            }

            @Override
            public SetItemHolder createHolder(View view) {
                return new ResourceHolder(view);
            }

            @Override
            public List<? extends SetItem> getItemsForFaction(String faction) {
                return Universe.getUniverse().getResources();
            }

            @Override
            public String getDetails(DetailsFragment.DetailDataBuilder builder, String id) {
                Resource resource = Universe.getUniverse().getResource(id);
                builder.addInt("Cost", resource.getCost());
                builder.addString("Ability", resource.getAbility());
                return resource.getTitle();
            }
        };
    }
    private ResourceHolder(View view) {
        super(view);
        mUnique.setVisibility(View.GONE);
    }

    @Override
    public void reinitializeStubViews(Resources res, SetItem item) {}
}
