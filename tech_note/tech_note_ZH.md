# 打包和上传Release的步骤  
1. 在 Xcode 中更新 **Version** 和 **Build** 版本号。  <br/>
2. 执行：`move .env_exmaple .env` ,修改.env中文件的变量 <br/>
3. 更新 Tag 版本号，并执行以下命令：   <br/>
   ```bash
   sh build_local.sh && TAG=v1.1.0 ASSET_FILE=./ScreenCut/Builds/ScreenCut.dmg ./create_release.sh
   ```
