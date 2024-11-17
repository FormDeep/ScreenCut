# Steps for Packaging and Uploading a Release  
1. Update the **Version** and **Build** numbers in Xcode.  <br/>
2. Execute: `move .env_example .env`, modify the variables in the .env file.<br/>
3. Update the tag version and execute the following command:  <br/>
   ```bash
   sh build_local.sh && TAG=v1.1.0 ASSET_FILE=./ScreenCut/Builds/ScreenCut.dmg ./create_release.sh
   ```