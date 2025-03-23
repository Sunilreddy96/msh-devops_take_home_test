import json
from flask import Request

def simple_hello_world(request: Request):
    name = request.args.get('name', 'world')
    response = { "message": f"Hello, {name}! Thanks for visiting this page", "status": "success"}
    return (json.dumps(response), 200, {"Content-Type": "application/json"})