# 打包和上传Release的步骤  
1. 在 Xcode 中更新 **Version** 和 **Build** 版本号。  <br/>
2. 执行：`move .env_exmaple .env` ,修改.env中文件的变量 <br/>
3. 设置编译版本：<br/>
   1）xcode中设置编译版本号: Version版本修改， build的数字+1 <br>
   2）新增加tag标签: git tag v1.1.3 && git push origin --tags <br>
   3）在 .env文件中设置tag的值，和创建的tag版本一样 <br>
4. 执行以下命令：   <br/>
   ```bash
   ./shell/build_local.sh && ./shell/create_release.sh && ./shell/brew.sh
   ``` <br/>
   1) 编译项目 2）创建到release的文件 3）创建brew文件 <br/>




# 项目依赖本地
路径 : Third_lib/xxx  <br/>
[依赖库的图片显示](./2024-11-30 12.38.59.png)


