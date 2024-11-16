#!/bin/bash

# 配置变量
PROJECT_PATH="./ScreenCut" # 替换为你的项目路径
SCHEME="ScreenCut"                    # 替换为你的项目 Scheme 名称
CONFIGURATION="Release"           # 构建配置，如 Debug 或 Release
OUTPUT_DIR="./ScreenCut/Builds"     # 打包输出目录
DMG_NAME="$OUTPUT_DIR/$SCHEME.dmg" # DMG 文件路径
ZIP_NAME="$OUTPUT_DIR/$SCHEME.zip" # ZIP 文件路径

# 打包项目
echo "开始打包 macOS 项目..."

# 进入项目目录
cd $PROJECT_PATH || { echo "无法进入项目目录 $PROJECT_PATH"; exit 1; }

# 清理项目
# echo "清理项目..."
# xcodebuild clean -scheme $SCHEME -configuration $CONFIGURATION || { echo "清理失败"; exit 1; }

# 构建项目
echo "构建项目..."
xcodebuild build \
  -scheme $SCHEME \
  -configuration $CONFIGURATION \
  -derivedDataPath build || { echo "构建失败"; exit 1; }

# 定位构建输出的 .app 文件
APP_PATH=$(find build -type d -name "$SCHEME.app" | head -n 1)

if [ -z "$APP_PATH" ]; then
  echo "未找到构建的 .app 文件！"
  exit 1
fi

echo "找到 .app 文件：$APP_PATH"

# 创建输出目录
mkdir -p $OUTPUT_DIR

# 打包为 ZIP 文件
echo "打包为 ZIP 文件..."
zip -r "$ZIP_NAME" "$APP_PATH" || { echo "ZIP 打包失败"; exit 1; }
echo "ZIP 文件已生成：$ZIP_NAME"

# 打包为 DMG 文件
echo "创建 DMG 文件..."
hdiutil create -volname "$SCHEME" \
  -srcfolder "$APP_PATH" \
  -ov -format UDZO "$DMG_NAME" || { echo "DMG 创建失败"; exit 1; }
echo "DMG 文件已生成：$DMG_NAME"

echo "打包完成！文件已保存至：$OUTPUT_DIR"
