
package com.funnyhatsoftware.spacedock.activity;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentPagerAdapter;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Toast;

import com.funnyhatsoftware.spacedock.DataHelper;
import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.SpaceDockApplication;
import com.funnyhatsoftware.spacedock.data.DataLoader;
import com.funnyhatsoftware.spacedock.data.Universe;
import com.funnyhatsoftware.spacedock.fragment.BrowseListFragment;
import com.funnyhatsoftware.spacedock.fragment.BrowseTwoPaneFragment;
import com.funnyhatsoftware.spacedock.fragment.ManageSquadsFragment;

import org.xml.sax.SAXException;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.net.UnknownHostException;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import javax.xml.parsers.ParserConfigurationException;

public class RootTabActivity extends FragmentTabActivity implements
        ManageSquadsFragment.SquadSelectListener {
    private boolean mTwoPane;
    private boolean checkedVersion = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mTwoPane = getResources().getBoolean(R.bool.use_two_pane);

        if (getIntent().getData() != null) {
            DataHelper.loadUniverseDataFromUri(this, getIntent().getData());
        }

        SpaceDockApplication app = (SpaceDockApplication)getApplication();
        if (savedInstanceState == null) {
            checkForUpdates();
        }
    }

    @Override
    public void onSaveInstanceState(Bundle savedInstanceState) {
        super.onSaveInstanceState(savedInstanceState);
        // Save UI state changes to the savedInstanceState.
        // This bundle will be passed to onCreate if the process is
        // killed and restarted.
        savedInstanceState.putBoolean("checkedVersion", checkedVersion);
    }

    @Override
    public void onRestoreInstanceState(Bundle savedInstanceState) {
        super.onRestoreInstanceState(savedInstanceState);
        // Save UI state changes to the savedInstanceState.
        // This bundle will be passed to onCreate if the process is
        // killed and restarted.
        checkedVersion = savedInstanceState.getBoolean("checkedVersion");
    }

    @Override
    protected void onPause() {
        super.onPause();

        DataHelper.saveUniverseData(this);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        super.onCreateOptionsMenu(menu);
        getMenuInflater().inflate(R.menu.menu_root, menu);
        return true;
    }

    @Override
    public boolean onPrepareOptionsMenu(Menu menu) {
        if (Universe.getUniverse().updateAvailable) {
            menu.findItem(R.id.menu_update).setVisible(false);
            menu.findItem(R.id.menu_loadupdate).setVisible(true);
        } else {
            menu.findItem(R.id.menu_update).setVisible(true);
            menu.findItem(R.id.menu_loadupdate).setVisible(false);
        }
        return super.onPrepareOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        final int itemId = item.getItemId();

        if (itemId == R.id.menu_settings) {
            startActivity(new Intent(this, SettingsActivity.class));
            return true;
        }
        if (itemId == R.id.menu_loadupdate) {
            Universe.getUniverse().installUpdate(getApplicationContext(), this);
            return true;
        }
        if (itemId == R.id.menu_update) {
            checkForUpdates(true,false);
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    protected FragmentPagerAdapter createPagerAdapter() {
        return new FragmentPagerAdapter(getSupportFragmentManager()) {
            String[] mTitles = getResources().getStringArray(R.array.root_tab_labels);

            @Override
            public CharSequence getPageTitle(int position) {
                return mTitles[position];
            }

            @Override
            public Fragment getItem(int i) {
                if (i == 0) {
                    return new ManageSquadsFragment();
                } else {
                    return mTwoPane ? new BrowseTwoPaneFragment() : new BrowseListFragment();
                }
            }

            @Override
            public int getCount() {
                return 2;
            }
        };
    }

    @Override
    public void onSquadSelected(String squadUuid) {
        startActivity(SquadTabActivity.getIntent(this, squadUuid));
    }

    public void checkForUpdates() {
        checkForUpdates(false,true);
    }
    public void checkForUpdates(boolean force) {
        checkForUpdates(force, true);
    }

    public void checkForUpdates(boolean force, boolean hidden) {
        SharedPreferences sharedPrefs = PreferenceManager.getDefaultSharedPreferences(getApplicationContext());
        SpaceDockApplication.loadSetPreferences(getApplicationContext());
        if (sharedPrefs.getBoolean("pref_key_check_updates",true)) {
            if (!checkedVersion) {
                VersionCheck versionCheck = new VersionCheck();
                versionCheck.setActivity(this);
                versionCheck.hidden = hidden;
                versionCheck.execute();
            }
        } else if (force) {
            checkedVersion = false;
            VersionCheck versionCheck = new VersionCheck();
            versionCheck.setActivity(this);
            versionCheck.hidden = hidden;
            versionCheck.execute();
        }
    }

    public void updateAvailable() {
        if (!checkedVersion && Universe.getUniverse().updateAvailable) {
            Toast.makeText(getApplicationContext(),"Game Data Update Available",Toast.LENGTH_LONG).show();
        }
        checkedVersion = true;
    }
    private class VersionCheck extends AsyncTask<String,String,String> {
        private RootTabActivity _activity = null;
        public boolean hidden = true;
        ProgressDialog pd;
        public void setActivity(RootTabActivity activity) {
            _activity = activity;
        }

        @Override
        protected void onCancelled() {
            if (pd != null) {
                pd.dismiss();
            }
        }

        @Override
        protected void onPreExecute() {
            if (_activity != null) {
                if (!hidden) {
                    pd = new ProgressDialog(_activity);
                    pd.setMessage("Checking for Updated Game Data");
                    pd.show();
                }
            }
            super.onPreExecute();
        }

        @Override
        protected String doInBackground(String... strings) {
            Universe universe = Universe.getUniverse();
            String newVersion = null;
            try {
                URL url = new URL("http://spacedockapp.org/DataVersion.php");
                URLConnection urlConnection = url.openConnection();
                InputStream in = new BufferedInputStream(urlConnection.getInputStream());
                DataLoader loader = new DataLoader(universe, in);
                loader.versionOnly = true;
                loader.load();

                newVersion = loader.dataVersion;
            } catch (MalformedURLException e) {
                universe.updateAvailable = false;
            } catch (UnknownHostException e) {
                return null;
            } catch (IOException e) {
                universe.updateAvailable = false;
                e.printStackTrace();
            } catch (SAXException e) {
                universe.updateAvailable = false;
                e.printStackTrace();
            } catch (ParserConfigurationException e) {
                universe.updateAvailable = false;
                e.printStackTrace();
            }
            return newVersion;
        }

        @Override
        protected void onPostExecute(String result) {
            Universe universe = Universe.getUniverse();
            if (universe.getVersion() != null && result != null && result.compareTo(universe.getVersion()) > 0) {
                universe.updateAvailable = true;
                _activity.updateAvailable();
            } else {
                universe.updateAvailable = false;
            }
            if (pd != null) {
                pd.dismiss();
                if (_activity != null && result != null) {
                    Toast.makeText(_activity.getApplicationContext(), "Game Data is Up to Date", Toast.LENGTH_LONG).show();
                } else if (_activity != null && result == null) {
                    Toast.makeText(_activity.getApplicationContext(), "Unable to connect to Space Dock sever at this time. Please try again later.", Toast.LENGTH_LONG).show();
                }
            }
        }

    }
}
