import os
import xml.etree.ElementTree as ET
from datetime import datetime

def get_file_size(file_path):
    return os.path.getsize(file_path)

def create_item(app_name, version, download_url, release_notes_url, file_path):
    file_size = get_file_size(file_path)
    
    item = ET.Element('item')
    
    title = ET.SubElement(item, 'title')
    title.text = f"{app_name} {version}"

    version_element = ET.SubElement(item, 'sparkle:version')
    version_element.text = version

    release_notes_element = ET.SubElement(item, 'sparkle:releaseNotesLink')
    release_notes_element.text = release_notes_url

    # 动态生成当前日期
    pub_date = ET.SubElement(item, 'pubDate')
    pub_date.text = datetime.utcnow().strftime('%a, %d %b %Y %H:%M:%S GMT')

    enclosure = ET.SubElement(item, 'enclosure')
    enclosure.set('url', download_url)
    enclosure.set('sparkle:version', version)
    enclosure.set('length', str(file_size))
    enclosure.set('type', 'application/octet-stream')

    return item

# 示例使用
app_name = "ScreenCut"
version = "1.0.1"
download_url = "https://github.com/VCBSstudio/ScreenCut/releases/download/1.0.1/ScreenCut.1.0.1.dmg"
release_notes_url = "https://github.com/VCBSstudio/ScreenCut/releases/tag/1.0.1"
file_path = "/Users/helinyu/workspace/GitHub/dmg_dir/ScreenCut 1.0.1.dmg"  # 替换为实际路径

item_element = create_item(app_name, version, download_url, release_notes_url, file_path)

# 将生成的 XML 输出到 appcast.xml
appcast = ET.Element('rss', xmlns='http://www.andymatuschak.org/xml-namespaces/sparkle')
channel = ET.SubElement(appcast, 'channel')
channel.append(item_element)

tree = ET.ElementTree(appcast)
tree.write('test_appcast.xml', encoding='utf-8', xml_declaration=True)
