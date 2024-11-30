# 打包和上传Release的步骤  
1. 在 Xcode 中更新 **Version** 和 **Build** 版本号。  <br/>
2. 执行：`move .env_exmaple .env` ,修改.env中文件的变量 <br/>
3. 更新 Tag 版本号，并执行以下命令：   <br/>
   ```bash
   ./build_local.sh && ./create_release.sh
   ``` <br/>
4. 更新信息到brew库，执行 `./brew.sh`




# 项目依赖本地
路径 : Third_lib/xxx  <br/>
[依赖库的图片显示](./2024-11-30 12.38.59.png)
