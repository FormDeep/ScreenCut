
import os
import re

# 扫描的根目录
root_dir = '../third_lib/'  # 这里修改为你的弹幕目录路径

# 用于存储所有的 GitHub SSH 链接
github_ssh_links = []

# 获取项目 GitHub SSH 地址的函数
def get_github_ssh_link_from_git_config(folder_path):
    git_config_path = os.path.join(folder_path, '.git', 'config')
    
    if os.path.exists(git_config_path):
        try:
            with open(git_config_path, 'r', encoding='utf-8') as f:
                content = f.read()
                
                # 使用正则匹配 SSH 格式的 URL
                match = re.search(r'url = git@github\.com:([\w-]+)/([\w-]+)\.git', content)
                if match:
                    user = match.group(1)
                    repo = match.group(2)
                    ssh_url = f'git@github.com:{user}/{repo}.git'
                    return ssh_url
        except Exception as e:
            print(f"Error reading {git_config_path}: {e}")
    return None

# 根据目录名推测 GitHub SSH 地址
def get_github_ssh_from_folder_name(folder_name):
    # 假设目录名格式为 'user-repo' 或 'repo'
    # 你可以根据实际情况调整解析规则
    folder_name_parts = folder_name.split('-')
    if len(folder_name_parts) > 1:
        user = folder_name_parts[0]
        repo = '-'.join(folder_name_parts[1:])
        return f'git@github.com:{user}/{repo}.git'
    else:
        # 如果目录名只包含一个部分，推测为仓库名，可以根据实际情况修改规则
        return f'git@github.com:{folder_name}/{folder_name}.git'

# 遍历根目录并查找每个子目录中的 GitHub SSH 地址
for folder_name in os.listdir(root_dir):
    folder_path = os.path.join(root_dir, folder_name)
    
    # 确保是一个目录
    if os.path.isdir(folder_path):
        print(f"Scanning folder: {folder_name}")
        
        # 尝试从 .git/config 文件获取 SSH 地址
        ssh_link = get_github_ssh_link_from_git_config(folder_path)
        
        if not ssh_link:
            # 如果没有找到，尝试根据文件夹名推测 SSH 地址
            ssh_link = get_github_ssh_from_folder_name(folder_name)
        
        if ssh_link:
            github_ssh_links.append(ssh_link)

# 去重并输出所有找到的 GitHub SSH 链接
github_ssh_links = list(set(github_ssh_links))  # 去重

if github_ssh_links:
    print(f"Found {len(github_ssh_links)} unique GitHub SSH links:")
    for link in github_ssh_links:
        print(link)
else:
    print("No GitHub SSH links found.")
