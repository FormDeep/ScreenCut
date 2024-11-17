# Steps for Packaging and Uploading a Release  
1. Update the **Version** and **Build** numbers in Xcode.  <br/>
2. Execute: `move .env_example .env`, modify the variables in the .env file.<br/>
3. Update the tag version and execute the following command:  <br/>
   ```bash
   ./build_local.sh &&  ./create_release.sh
   ``` <br/>
4. Update information to the brew repository, execute ./brew.sh
