import torch
from transformers import MarianMTModel, MarianTokenizer

# 下载模型和标记器
model_name = "Helsinki-NLP/opus-mt-en-zh"
tokenizer = MarianTokenizer.from_pretrained(model_name)
model = MarianMTModel.from_pretrained(model_name)

def translate(text):
    # 将输入文本编码
    inputs = tokenizer(text, return_tensors="pt", padding=True, truncation=True)
    
    # 生成翻译
    with torch.no_grad():
        outputs = model.generate(input_ids=inputs['input_ids'], attention_mask=inputs['attention_mask'])
    
    # 解码输出文本
    return tokenizer.decode(outputs[0], skip_special_tokens=True)
