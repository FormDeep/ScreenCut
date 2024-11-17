ScreenCut 是一个针对 Mac 平台开发的截图和标注工具，提供了丰富的截图及绘制功能，方便用户进行快速操作和分享。以下是它的主要功能和使用方法：

---

### 安装方法
使用 [Homebrew](https://brew.sh/) 安装 ScreenCut：
```bash
brew tap vcbsstudio/tap 
brew install --cask ScreenCut
```

---

### 适用系统
该工具开发基于 **macOS 15**，适配其他 macOS 版本的兼容性可能需要进一步测试。

---

### 功能特性

1. **截图功能**  
   直接截图当前屏幕或选定区域。
   
2. **绘制工具**  
   - 矩形框绘制  
   - 椭圆形绘制  
   - 箭头绘制  
   - 自由涂鸦绘制  
   
3. **文本功能**  
   - 添加文本  
   - 调整字体大小  
   
4. **文字识别 (OCR)**  
   选框区域内的文字自动识别，方便提取文字信息。  

5. **翻译功能**  
   - 目前支持 **中文翻译为英文**  
   - 基于大语言模型实现翻译，需要自行配置。  
     - 配置教程：[参考链接](https://hly-tech.gitbook.io/front-end/front-end/apple/library/coreml/zhi-xing-python-jiao-ben-diao-yong-ai/shi-yong-rest-api)  
     - 配置代码：[translate.py](./backend/translate.py)  

6. **样式自定义**  
   - 可选择字体大小与线条粗细。  
   - 自定义颜色。  

---

### 快捷键设置
通过右上角菜单栏图标，进入“偏好设置”进行快捷键配置，例如：
- **Control + X**：触发翻译为英文功能。  

---

### 截图绘制效果预览
下图展示了 ScreenCut 的截图和绘制功能效果：

![截图绘制的效果](./readmeImgs/image.png)

---

这是一个简洁实用的工具，适合开发者、设计师以及需要快速标注的用户群体。

---

# 开发者
[打包和上传Release的步骤](./tech_note/tech_note_ZH.md)


### PATH:LICENSE
MIT License

Copyright (c) 2023 vcbsstudio

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
   