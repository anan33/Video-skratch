#!/bin/bash
# ينشئ هيكل مشروع أندرويد كاملاً من الملفات المسطحة
set -e
cat > ".gitignore" <<'END_OF_FILE_XYZ'
.gradle/
build/
local.properties

END_OF_FILE_XYZ
mkdir -p "app"
cat > "app/build.gradle" <<'END_OF_FILE_XYZ'
plugins {
    id 'com.android.application'
}

android {
    namespace 'com.school.schoolday'
    compileSdk 34

    defaultConfig {
        applicationId "com.school.schoolday"
        minSdk 24
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }

    androidResources {
        noCompress += ['mp4']
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
}

END_OF_FILE_XYZ
mkdir -p "app/src/main"
cat > "app/src/main/AndroidManifest.xml" <<'END_OF_FILE_XYZ'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <application
        android:icon="@drawable/ic_launcher"
        android:roundIcon="@drawable/ic_launcher"
        android:label="@string/app_name"
        android:supportsRtl="true"
        android:theme="@style/AppTheme">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:screenOrientation="sensorLandscape"
            android:configChanges="orientation|screenSize|keyboardHidden|screenLayout|smallestScreenSize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>

END_OF_FILE_XYZ
mkdir -p "app/src/main/java/com/school/schoolday"
cat > "app/src/main/java/com/school/schoolday/MainActivity.java" <<'END_OF_FILE_XYZ'
package com.school.schoolday;

import android.app.Activity;
import android.app.AlertDialog;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.VideoView;

public class MainActivity extends Activity {

    private View menuLayout, playerLayout, controlsBar;
    private VideoView video;
    private Button btnPlayPause;
    private boolean finished = false;
    private final Handler handler = new Handler(Looper.getMainLooper());
    private final Runnable hideControls = new Runnable() {
        @Override public void run() { controlsBar.setVisibility(View.GONE); }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        setContentView(R.layout.activity_main);

        menuLayout = findViewById(R.id.menuLayout);
        playerLayout = findViewById(R.id.playerLayout);
        controlsBar = findViewById(R.id.controlsBar);
        video = findViewById(R.id.videoView);
        btnPlayPause = findViewById(R.id.btnPlayPause);

        video.setVideoURI(Uri.parse("android.resource://" + getPackageName() + "/" + R.raw.story));
        video.setOnCompletionListener(mp -> {
            finished = true;
            btnPlayPause.setText(R.string.btn_play);
            showControls(false);
        });

        findViewById(R.id.btnStart).setOnClickListener(v -> startStory());
        findViewById(R.id.btnAbout).setOnClickListener(v -> showAbout());
        findViewById(R.id.btnReplay).setOnClickListener(v -> startStory());
        findViewById(R.id.btnMenu).setOnClickListener(v -> backToMenu());

        btnPlayPause.setOnClickListener(v -> {
            if (finished) {
                startStory();
            } else if (video.isPlaying()) {
                video.pause();
                btnPlayPause.setText(R.string.btn_play);
            } else {
                video.start();
                btnPlayPause.setText(R.string.btn_pause);
                showControls(true);
            }
        });

        video.setOnClickListener(v -> {
            if (controlsBar.getVisibility() == View.VISIBLE) {
                controlsBar.setVisibility(View.GONE);
            } else {
                showControls(video.isPlaying());
            }
        });
    }

    private void startStory() {
        finished = false;
        menuLayout.setVisibility(View.GONE);
        playerLayout.setVisibility(View.VISIBLE);
        btnPlayPause.setText(R.string.btn_pause);
        video.seekTo(0);
        video.start();
        showControls(true);
    }

    private void showControls(boolean autoHide) {
        controlsBar.setVisibility(View.VISIBLE);
        handler.removeCallbacks(hideControls);
        if (autoHide) handler.postDelayed(hideControls, 3000);
    }

    private void backToMenu() {
        video.pause();
        handler.removeCallbacks(hideControls);
        playerLayout.setVisibility(View.GONE);
        menuLayout.setVisibility(View.VISIBLE);
    }

    private void showAbout() {
        new AlertDialog.Builder(this)
                .setTitle(R.string.about_title)
                .setMessage(R.string.about_text)
                .setPositiveButton(R.string.btn_close, null)
                .show();
    }

    @Override
    public void onBackPressed() {
        if (playerLayout.getVisibility() == View.VISIBLE) {
            backToMenu();
        } else {
            super.onBackPressed();
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (playerLayout.getVisibility() == View.VISIBLE && video.isPlaying()) {
            video.pause();
            btnPlayPause.setText(R.string.btn_play);
            showControls(false);
        }
    }

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
        if (hasFocus) {
            getWindow().getDecorView().setSystemUiVisibility(
                    View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                            | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                            | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                            | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                            | View.SYSTEM_UI_FLAG_FULLSCREEN
                            | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
        }
    }
}

END_OF_FILE_XYZ
mkdir -p "app/src/main/res/drawable"
cat > "app/src/main/res/drawable/btn_bg.xml" <<'END_OF_FILE_XYZ'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <solid android:color="#FFB300"/>
    <corners android:radius="28dp"/>
</shape>

END_OF_FILE_XYZ
mkdir -p "app/src/main/res/drawable"
cat > "app/src/main/res/drawable/ic_launcher.xml" <<'END_OF_FILE_XYZ'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <path android:fillColor="#1E88E5" android:pathData="M0,0h108v108h-108z"/>
    <path android:fillColor="#FFFFFF" android:pathData="M24,34h26c3,0 4,1 4,4v38c0,-2 -1,-3 -4,-3h-26z"/>
    <path android:fillColor="#FFFFFF" android:pathData="M84,34h-26c-3,0 -4,1 -4,4v38c0,-2 1,-3 4,-3h26z"/>
    <path android:fillColor="#FFB300" android:pathData="M45,44l22,10l-22,10z"/>
</vector>

END_OF_FILE_XYZ
mkdir -p "app/src/main/res/layout"
cat > "app/src/main/res/layout/activity_main.xml" <<'END_OF_FILE_XYZ'
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="#000000">

    <LinearLayout
        android:id="@+id/menuLayout"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:background="@color/menu_bg"
        android:gravity="center"
        android:orientation="vertical"
        android:padding="24dp">

        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="@string/story_title"
            android:textColor="#FFFFFF"
            android:textSize="44sp"
            android:textStyle="bold" />

        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="8dp"
            android:layout_marginBottom="28dp"
            android:text="@string/story_subtitle"
            android:textColor="#E3F2FD"
            android:textSize="18sp" />

        <Button
            android:id="@+id/btnStart"
            android:layout_width="260dp"
            android:layout_height="56dp"
            android:background="@drawable/btn_bg"
            android:text="@string/btn_start"
            android:textColor="#212121"
            android:textSize="20sp"
            android:textStyle="bold" />

        <Button
            android:id="@+id/btnAbout"
            android:layout_width="260dp"
            android:layout_height="56dp"
            android:layout_marginTop="12dp"
            android:background="@drawable/btn_bg"
            android:text="@string/btn_about"
            android:textColor="#212121"
            android:textSize="20sp"
            android:textStyle="bold" />
    </LinearLayout>

    <FrameLayout
        android:id="@+id/playerLayout"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:background="#000000"
        android:visibility="gone">

        <VideoView
            android:id="@+id/videoView"
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            android:layout_gravity="center" />

        <LinearLayout
            android:id="@+id/controlsBar"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:layout_gravity="bottom"
            android:background="#99000000"
            android:gravity="center"
            android:orientation="horizontal"
            android:padding="8dp">

            <Button
                android:id="@+id/btnPlayPause"
                android:layout_width="wrap_content"
                android:layout_height="44dp"
                android:layout_margin="4dp"
                android:background="@drawable/btn_bg"
                android:paddingLeft="20dp"
                android:paddingRight="20dp"
                android:text="@string/btn_pause"
                android:textColor="#212121" />

            <Button
                android:id="@+id/btnReplay"
                android:layout_width="wrap_content"
                android:layout_height="44dp"
                android:layout_margin="4dp"
                android:background="@drawable/btn_bg"
                android:paddingLeft="20dp"
                android:paddingRight="20dp"
                android:text="@string/btn_replay"
                android:textColor="#212121" />

            <Button
                android:id="@+id/btnMenu"
                android:layout_width="wrap_content"
                android:layout_height="44dp"
                android:layout_margin="4dp"
                android:background="@drawable/btn_bg"
                android:paddingLeft="20dp"
                android:paddingRight="20dp"
                android:text="@string/btn_menu"
                android:textColor="#212121" />
        </LinearLayout>
    </FrameLayout>
</FrameLayout>

END_OF_FILE_XYZ
mkdir -p "app/src/main/res/values"
cat > "app/src/main/res/values/colors.xml" <<'END_OF_FILE_XYZ'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="menu_bg">#1E88E5</color>
</resources>

END_OF_FILE_XYZ
mkdir -p "app/src/main/res/values"
cat > "app/src/main/res/values/strings.xml" <<'END_OF_FILE_XYZ'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">يوم دراسي</string>
    <string name="story_title">يوم دراسي</string>
    <string name="story_subtitle">قصة من الخروج من البيت إلى العودة</string>
    <string name="btn_start">ابدأ القصة</string>
    <string name="btn_about">عن التطبيق</string>
    <string name="btn_pause">إيقاف مؤقت</string>
    <string name="btn_play">تشغيل</string>
    <string name="btn_replay">إعادة القصة</string>
    <string name="btn_menu">القائمة</string>
    <string name="about_title">عن التطبيق</string>
    <string name="about_text">إعداد الطالب: ........\nإشراف المعلم: ........\nالمدرسة: ........\nالعام الدراسي: ........</string>
    <string name="btn_close">إغلاق</string>
</resources>

END_OF_FILE_XYZ
mkdir -p "app/src/main/res/values"
cat > "app/src/main/res/values/styles.xml" <<'END_OF_FILE_XYZ'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="AppTheme" parent="@android:style/Theme.Material.Light.NoActionBar">
        <item name="android:windowBackground">@android:color/black</item>
        <item name="android:windowFullscreen">true</item>
    </style>
</resources>

END_OF_FILE_XYZ
cat > "build.gradle" <<'END_OF_FILE_XYZ'
plugins {
    id 'com.android.application' version '8.3.2' apply false
}

END_OF_FILE_XYZ
cat > "gradle.properties" <<'END_OF_FILE_XYZ'
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=false
android.nonTransitiveRClass=true

END_OF_FILE_XYZ
cat > "settings.gradle" <<'END_OF_FILE_XYZ'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "SchoolDayApp"
include ':app'

END_OF_FILE_XYZ
mkdir -p app/src/main/res/raw
mv ./*.mp4 app/src/main/res/raw/story.mp4
echo "setup done"
