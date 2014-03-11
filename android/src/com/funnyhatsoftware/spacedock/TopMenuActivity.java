
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
    }

    protected void showCaptainsList() {
        Intent intent = new Intent(this, CaptainsListActivity.class);
        startActivity(intent);
    }

    protected void showCrewList() {
        Intent intent = new Intent(this, CrewListActivity.class);
        startActivity(intent);
    }

    protected void showTalentsList() {
        Intent intent = new Intent(this, TalentsListActivity.class);
        startActivity(intent);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.top_menu, menu);
        return true;
    }

}
