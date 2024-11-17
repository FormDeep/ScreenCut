# ScreenCut: Screenshot Tool for Mac

ScreenCut is a screenshot and annotation tool for macOS, offering various features for quick operations and sharing. Below are its key functionalities and usage instructions:

---

[中文文档](./README_ZH.md)

---

### Installation

Install ScreenCut using [Homebrew](https://brew.sh/):

```bash
brew tap vcbsstudio/tap
brew install --cask ScreenCut
```

---

### Supported System

Developed specifically for **macOS 15**. Compatibility with other macOS versions may require additional testing.

---

### Features

1. **Screenshot**  
   Capture the current screen or a selected area.

2. **Drawing Tools**  
   - Rectangle drawing  
   - Ellipse drawing  
   - Arrow drawing  
   - Freehand drawing  

3. **Text Features**  
   - Add text  
   - Adjust font size  

4. **Text Recognition (OCR)**  
   Automatically extract text from a selected area.

5. **Translation**  
   - Currently supports **Chinese to English** translation.  
   - Based on large language models, requires manual configuration.  
     - Configuration guide: [Reference Link](https://hly-tech.gitbook.io/front-end/front-end/apple/library/coreml/zhi-xing-python-jiao-ben-diao-yong-ai/shi-yong-rest-api)  
     - Configuration code: [translate.py](./backend/translate.py)  

6. **Custom Styling**  
   - Choose font size and line thickness.  
   - Customize colors.  

---

### Shortcut Settings

Set up shortcuts via the menu bar icon → Preferences → Shortcut Keys. Example:  
- **Control + X**: Trigger the translation feature to translate text to English.

---

### Screenshot and Annotation Preview

Below is an example showcasing the screenshot and drawing features of ScreenCut:

![Screenshot and Drawing Example](./readmeImgs/image.png)

---

This is a simple yet powerful tool suitable for developers, designers, and anyone needing quick annotations. For further questions or feedback, refer to its documentation or contact the developer community.

---

# Developer
[Steps for Packaging and Uploading a Release ](./tech_note/tech_note.md)

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
