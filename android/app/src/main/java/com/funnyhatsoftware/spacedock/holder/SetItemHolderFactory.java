package com.funnyhatsoftware.spacedock.holder;

import android.content.Context;
import android.content.Intent;
import android.support.v4.util.ArrayMap;
import android.view.View;

import com.funnyhatsoftware.spacedock.data.Borg;
import com.funnyhatsoftware.spacedock.data.Crew;
import com.funnyhatsoftware.spacedock.data.Officer;
import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.data.Squadron;
import com.funnyhatsoftware.spacedock.data.Talent;
import com.funnyhatsoftware.spacedock.data.Tech;
import com.funnyhatsoftware.spacedock.fragment.DetailsFragment;

import java.util.List;
import java.util.Set;

/**
 * Class that wraps the static portion of SetItem display - A SetItemHolderFactory can be acquired
 * from a SetItem's type, and can be used to create an ListAdapter for displaying SetItems as
 * SetItemHolder-managed ListView views.
 */
public abstract class SetItemHolderFactory {
    private static final ArrayMap<Class, SetItemHolderFactory> sFactoriesForClass =
            new ArrayMap<Class, SetItemHolderFactory>();
    private static final ArrayMap<String, SetItemHolderFactory> sFactoriesForType =
            new ArrayMap<String, SetItemHolderFactory>();

    public static Set<String> getFactoryTypes() {
        return sFactoriesForType.keySet();
    }

    public static SetItemHolderFactory getHolderFactory(String key) {
        if (!sFactoriesForType.containsKey(key)) {
            throw new IllegalStateException("factory of type " + key + " missing");
        }
        return sFactoriesForType.get(key);
    }

    public static SetItemHolderFactory getHolderFactory(Class key) {
        if (!sFactoriesForClass.containsKey(key)) {
            throw new IllegalStateException("factory of type " + key + " missing");
        }
        return sFactoriesForClass.get(key);
    }

    private static void registerHolderFactory(SetItemHolderFactory factory) {
        String factoryType = factory.getType();
        if (sFactoriesForType.containsKey(factoryType)) {
            throw new IllegalArgumentException(
                    "Error: factory with type " + factoryType + " already exists");
        }
        sFactoriesForClass.put(factory.getItemClass(), factory);
        sFactoriesForType.put(factory.getType(), factory);
    }

    public static void initialize() {
        if (!sFactoriesForType.isEmpty()) throw new IllegalStateException("double init attempted");
        registerHolderFactory(CaptainHolder.getFactory());
        registerHolderFactory(ShipHolder.getFactory());
        registerHolderFactory(FlagshipHolder.getFactory());
        registerHolderFactory(FleetCaptainHolder.getFactory());
        registerHolderFactory(AdmiralHolder.getFactory());
        registerHolderFactory(WeaponHolder.getFactory());
        registerHolderFactory(ResourceHolder.getFactory());
        registerHolderFactory(ReferenceHolder.getFactory());
        registerHolderFactory(ExpansionHolder.getFactory());
        registerHolderFactory(UpgradeHolder.getFactory(Crew.class, UpgradeHolder.TYPE_STRING_CREW));
        registerHolderFactory(UpgradeHolder.getFactory(Talent.class, UpgradeHolder.TYPE_STRING_TALENT));
        registerHolderFactory(UpgradeHolder.getFactory(Tech.class, UpgradeHolder.TYPE_STRING_TECH));
        registerHolderFactory(UpgradeHolder.getFactory(Borg.class, UpgradeHolder.TYPE_STRING_BORG));
        registerHolderFactory(UpgradeHolder.getFactory(Squadron.class,UpgradeHolder.TYPE_STRING_SQUADRON));
        registerHolderFactory(UpgradeHolder.getFactory(Officer.class,UpgradeHolder.TYPE_STRING_OFFICER));
    }

    private final Class mClazz;
    private final String mType;

    public SetItemHolderFactory(Class clazz, String type) {
        mClazz = clazz;
        mType = type;
    }

    public Class getItemClass() { return mClazz; }
    public String getType() { return mType; }
    public boolean usesFactions() { return true; }
    public abstract SetItemHolder createHolder(View view);
    public abstract List<? extends SetItem> getItemsForFaction(String faction);
    public abstract String getDetails(DetailsFragment.DetailDataBuilder builder, String id);
    public Intent getDetailsIntent(Context context, String id) { return null; }
}
