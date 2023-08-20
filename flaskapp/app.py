from flask import Flask

app = Flask(__name__)

@app.route('/test')
def hello_world():
    return 'Hello, World! RJE'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
