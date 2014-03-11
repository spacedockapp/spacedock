
package com.funnyhatsoftware.spacedock;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;
import android.widget.Button;

public class TopMenuActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_top_menu);
        Button shipsButton = (Button) findViewById(R.id.ships_button);
        shipsButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                showShipsList();
            }
        });
        Button captainsButton = (Button) findViewById(R.id.captains_button);
        captainsButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                showCaptainsList();
            }
        });
        Button crewButton = (Button) findViewById(R.id.crew_button);
        crewButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                showCrewList();
            }
        });
        Button talentsButton = (Button) findViewById(R.id.talents_button);
        talentsButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                showTalentsList();
            }
        });
        Button techButton = (Button) findViewById(R.id.tech_button);
        techButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                showTechList();
            }
        });
        Button weaponsButton = (Button) findViewById(R.id.weapons_button);
        weaponsButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                showWeaponsList();
            }
        });
        Button resourcesButton = (Button) findViewById(R.id.resources_button);
        resourcesButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                showResourcesList();
            }
        });
    }

    protected void showShipsList() {
        Intent intent = new Intent(this, ShipListActivity.class);
        startActivity(intent);
    }

    protected void showCaptainsList() {
        Intent intent = new Intent(this, CaptainsListActivity.class);
        startActivity(intent);
    }

    protected void showCrewList() {
        Intent intent = new Intent(this, UpgradeListActivity.class);
        intent.putExtra("upType", "Crew");
        startActivity(intent);
    }

    protected void showTalentsList() {
        Intent intent = new Intent(this, UpgradeListActivity.class);
        intent.putExtra("upType", "Talent");
        startActivity(intent);
    }

    protected void showTechList() {
        Intent intent = new Intent(this, UpgradeListActivity.class);
        intent.putExtra("upType", "Tech");
        startActivity(intent);
    }

    protected void showWeaponsList() {
        Intent intent = new Intent(this, WeaponListActivity.class);
        intent.putExtra("upType", "Weapon");
        startActivity(intent);
    }

    protected void showResourcesList() {
        Intent intent = new Intent(this, ResourceListActivity.class);
        startActivity(intent);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.top_menu, menu);
        return true;
    }

}
