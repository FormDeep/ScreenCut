#!/bin/bash

# 定义项目路径和参数
PROJECT_PATH="./ScreenCut" # 替换为你的项目路径
SCHEME="ScreenCut"                    # 替换为你的项目 Scheme 名称
CONFIGURATION="Release"           # 构建配置，如 Debug 或 Release
OUTPUT_DIR="./Builds"     # 打包输出目录
ARCHIVE_PATH="$OUTPUT_DIR/$SCHEME.xcarchive" # 存档文件路径
EXPORT_PATH="$OUTPUT_DIR/$SCHEME"            # 导出路径

# 开始打包
echo "开始构建项目..."

# 进入项目目录
cd $PROJECT_PATH || { echo "无法进入项目目录 $PROJECT_PATH"; exit 1; }

# 清理项目
echo "清理项目..."
xcodebuild clean -scheme $SCHEME -configuration $CONFIGURATION || { echo "清理失败"; exit 1; }

# 构建并归档项目
echo "归档项目..."
xcodebuild archive \
  -scheme $SCHEME \
  -configuration $CONFIGURATION \
  -archivePath $ARCHIVE_PATH \
  -derivedDataPath build || { echo "归档失败"; exit 1; }

# 导出 .app 文件
echo "导出项目..."
xcodebuild -exportArchive \
  -archivePath $ARCHIVE_PATH \
  -exportPath $EXPORT_PATH || { echo "导出失败"; exit 1; }

# 打包为 DMG 文件 (可选)
DMG_NAME="$OUTPUT_DIR/$SCHEME.dmg"
echo "创建 DMG 文件..."
hdiutil create -volname $SCHEME \
  -srcfolder "$EXPORT_PATH" \
  -ov -format UDZO $DMG_NAME || { echo "创建 DMG 失败"; exit 1; }

echo "打包完成！输出文件位于 $DMG_NAME"
