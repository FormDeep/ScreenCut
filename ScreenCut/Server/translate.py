from flask import Flask, request, jsonify
import translator

app = Flask(__name__)

@app.route('/translate', methods=['POST'])
def translate():
    print("Received request data:", request.json)
    text = request.json['text']
    # 进行翻译逻辑
    translated_text = translator.translate(text)
    return jsonify({'translated_text': translated_text})

if __name__ == '__main__':
    app.run( port=5000)
    