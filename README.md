[中文文档](./README_ZH.md)

ScreenCut is a screenshot and annotation tool developed for the Mac platform, providing rich screenshot and drawing functions for quick operation and sharing. Here are its main features and how to use it:
---
### Installation
Install ScreenCut using [Homebrew](https://brew.sh/):
```bash
brew tap vcbsstudio/tap 
brew install --cask ScreenCut
```
---
### System
This tool is based on **macOS 15**, compatibility with other macOS versions may require further testing.
`` --- ### Functionality
### Features
1. **Screenshot Function**  
   Directly take a screenshot of the current screen or selected area.
   
2. **Drawing Tools**  
   - Rectangle drawing  
   - Ellipse drawing  
   - Arrow drawing  
   - Freehand drawing  
   
3. **Text Function**  
   - Adding text  
   - Adjusting font size  
   
4. **Text Recognition (OCR)**  
   The text in the checkbox area is automatically recognized, making it easy to extract text information.  
5. **Translation Function**  
   - Currently supports **Chinese to English translation**.  
   - Translation is realized based on a large language model, which needs to be configured by yourself.  
     - Configuration tutorial:[reference link](https://hly-tech.gitbook.io/front-end/front-end/apple/library/coreml/zhi-xing-python-jiao-ben-diao-yong-ai/shi-yong-rest-api)  
     - Configuration code: [translate.py](./backend/translate.py)  
6. **Style customization  
   - Selectable font size and line thickness.  
   - Customizable colors.  
---
### Shortcut Settings
Enter “Preferences” through the menu bar icon in the upper right corner to configure shortcut keys, for example:
- **Control + X**: Trigger translate to English.  
**Control + X**: Trigger the translate to English function.
### Preview of screenshot drawing effect
The following picture shows the effect of ScreenCut's screenshot and drawing functions:
![Screenshot drawing effect](./readmeImgs/image.png)
----
This is a simple and practical tool for developers, designers, and user groups who need to quickly annotate.
---
# developer
[Steps for packaging and uploading Releases](./tech_note/tech_note_ZH.md)


Translated with DeepL.com (free version)

---

###PATH:LICENSE
MIT License

Copyright (c) 2023 vcbsstudio

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
