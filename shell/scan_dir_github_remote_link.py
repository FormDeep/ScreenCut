
import os
import re

# 扫描的根目录
root_dir = '../third_lib/'  # 这里修改为你的弹幕目录路径

# GitHub 链接的正则表达式
github_pattern = r'https://github\.com/[\w-]+/[\w-]+'

# 用于存储所有的 GitHub 链接
github_links = []

# 查找 GitHub 链接的函数
def find_github_link_in_folder(folder_path):
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            file_path = os.path.join(root, file)
            
            # 只扫描可能包含 GitHub 地址的文件
            if file.lower() in ['readme.md', 'package.json', 'config.json', 'project.json']:
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                        
                        # 查找 GitHub 链接
                        links = re.findall(github_pattern, content)
                        if links:
                            github_links.extend(links)
                except Exception as e:
                    print(f"Error reading file {file_path}: {e}")
            # 如果文件是一个目录，则跳过
            elif os.path.isdir(file_path):
                continue

# 遍历根目录并查找每个子目录中的 GitHub 链接
for folder_name in os.listdir(root_dir):
    folder_path = os.path.join(root_dir, folder_name)
    
    # 确保是一个目录
    if os.path.isdir(folder_path):
        print(f"Scanning folder: {folder_name}")
        find_github_link_in_folder(folder_path)

# 去重并输出所有找到的链接
github_links = list(set(github_links))  # 去重

if github_links:
    print(f"Found {len(github_links)} unique GitHub links:")
    for link in github_links:
        print(link)
else:
    print("No GitHub links found.")