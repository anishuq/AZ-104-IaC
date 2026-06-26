from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return '<h1>Hello World from az104-linuxwebapp-160980!</h1>'

if __name__ == '__main__':
    app.run()