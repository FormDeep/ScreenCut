#!/bin/bash

#  执行操作 eg: ./create_release.sh


# 加载 .env 文件
if [ -f .env ]; then
    # 使用 source 或 .
    source .env
else
    echo ".env 文件不存在"
    exit 1
fi

# 检查并解析 TAG 参数
if [ -z "$TAG" ]; then
  echo "Usage: TAG=<$TAG> [ASSET_FILE=<$ASSET_FILE>] $0"
  exit 1
fi

# 将 TAG 的值赋值给 TAG_NAME
TAG_NAME="$TAG"

# 参数设置
ASSET_FILE="${ASSET_FILE:-}"       # 资产文件路径，默认为空
# GITHUB_TOKEN="在.env中获取"  # 你的 GitHub 个人访问令牌
OWNER="VCBSstudio"      # GitHub 用户名或组织名
REPO="ScreenCut"       # GitHub 仓库名
RELEASE_NAME="Release $TAG_NAME"  # Release 的名称
BODY="This is the release notes for $TAG_NAME"  # Release 描述

# GitHub API URL
API_URL="https://api.github.com/repos/$OWNER/$REPO/releases"

# 创建 GitHub Release
create_release() {
    echo "Creating release for tag: $TAG_NAME..."
    response=$(curl -s -X POST "$API_URL" \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Content-Type: application/json" \
        -d @- << EOF
{
  "tag_name": "$TAG_NAME",
  "name": "$RELEASE_NAME",
  "body": "$BODY",
  "draft": false,
  "prerelease": false
}
EOF
    )

    release_id=$(echo "$response" | jq -r '.id // empty')
    if [ -z "$release_id" ]; then
        echo "Error creating release: $(echo "$response" | jq -r '.message')"
        exit 1
    fi
    echo "Release created successfully with ID: $release_id"
}

# 上传资产文件
upload_asset() {
    if [ -n "$ASSET_FILE" ] && [ -f "$ASSET_FILE" ]; then
        asset_name=$(basename "$ASSET_FILE")
        UPLOAD_URL="https://uploads.github.com/repos/$OWNER/$REPO/releases/$release_id/assets?name=$asset_name"
        
        echo "Uploading asset: $asset_name to $UPLOAD_URL..."
        response=$(curl -s -X POST "$UPLOAD_URL" \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Content-Type: application/octet-stream" \
            --data-binary @"$ASSET_FILE")
        
        asset_url=$(echo "$response" | jq -r '.browser_download_url // empty')
        if [ -n "$asset_url" ]; then
            echo "Asset uploaded successfully: $asset_url"
        else
            echo "Error uploading asset: $(echo "$response" | jq -r '.message')"
        fi
    elif [ -z "$ASSET_FILE" ]; then
        echo "No asset file specified, skipping upload."
    else
        echo "Error: File not found: $ASSET_FILE"
        exit 1
    fi
}

# 主流程
create_release
upload_asset
