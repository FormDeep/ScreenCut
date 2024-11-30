#!/bin/bash

# 加载 .env 文件
if [ -f .env ]; then
    # 使用 source 或 .
    source .env
else
    echo ".env 文件不存在"
    exit 1
fi

# 设置变量
REPO_URL="git@github.com:VCBSstudio/homebrew-Tap.git"
LOCAL_DIR="./../homebrew-Tap"
CASK_FILE="Casks/ScreenCut.rb" # 目标文件路径
NEW_VERSION="$TAG"  # 新版本号      
NEW_URL="https://github.com/VCBSstudio/ScreenCut/releases/download/$NEW_VERSION/ScreenCut.dmg" # 新版本的下载链接
COMMIT_MESSAGE="Update ScreenCut to version $NEW_VERSION"

FILE_PATH="$ASSET_FILE"         # 本地文件路径
DOWNLOAD_URL="$NEW_URL"         # 文件下载链接
TEMP_FILE="./temp_download.dmg"  # 临时下载文件存储位置

#  sha256值
if [ -f "$FILE_PATH" ]; then
  echo "Calculating SHA256 for local file: $FILE_PATH"
  SHA256=$(shasum -a 256 "$FILE_PATH" | awk '{print $1}')
else
  echo "Local file not found. Downloading from URL: $DOWNLOAD_URL"
  curl -o "$TEMP_FILE" "$DOWNLOAD_URL"
  if [ $? -eq 0 ]; then
    echo "Download complete. Calculating SHA256..."
    SHA256=$(shasum -a 256 "$TEMP_FILE" | awk '{print $1}')
    rm -f "$TEMP_FILE" # 删除临时文件
  else
    echo "Download failed. Exiting."
    exit 1
  fi
fi
NEW_SHA256="$SHA256"   # 新的 SHA256 值
echo "SHA256: $NEW_SHA256"


# 克隆仓库
if [ ! -d "$LOCAL_DIR" ]; then
  echo "Cloning repository..."
  git clone "$REPO_URL" "$LOCAL_DIR"
else
  echo "Repository already cloned. Pulling latest changes..."
  cd "$LOCAL_DIR" && git pull && cd $OLDPWD
fi

# 修改 cask 文件
echo "Modifying ScreenCut.rb..."
echo "$(dirname "$0")"
cd "$LOCAL_DIR" || exit


echo "Current directory: $(pwd)"
echo "new version : $NEW_VERSION"
echo "NEW_SHA256 : $NEW_SHA256"
echo "NEW_URL : $NEW_URL"
ls -l "$CASK_FILE"


# 更新版本号
sed -i '' "s/version \".*\"/version \"$NEW_VERSION\"/" "$CASK_FILE"
# sed -i '' "s/^    version \".*\"/  version \"$NEW_VERSION\"/" "$CASK_FILE"


# 更新 SHA256
sed -i '' "s/sha256 \".*\"/sha256 \"$NEW_SHA256\"/" "$CASK_FILE"
# sed -i '' "s/^    sha256 \".*\"/  sha256 \"$NEW_SHA256\"/" "$CASK_FILE"

# 更新下载链接
# sed -i '' "s/url \".*\"/url \"$NEW_URL\"/" "$CASK_FILE"
# sed -i '' "s|^    url \".*\"|  url \"$NEW_URL\"|" "$CASK_FILE"
sed -i "" "s|url \"[^\"]*\"|url \"$NEW_URL\"|" $CASK_FILE

# 检查修改
if git diff --quiet; then
  echo "No changes made."
else
  echo "Changes detected. Committing and pushing..."
  
  # 提交和推送更改
  git add "$CASK_FILE"
  git commit -m "$COMMIT_MESSAGE"
  git push
fi

# 返回初始目录
cd ..
