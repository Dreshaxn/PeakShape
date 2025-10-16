import os
import time
import requests
from flask import Flask, request, jsonify
from dotenv import load_dotenv

load_dotenv()
app = Flask(__name__)

CLIENT_ID = os.getenv("CLIENT_ID")
CLIENT_SECRET = os.getenv("CLIENT_SECRET")

# Simple in-memory cache for token
token_cache = {"access_token": None, "expires_at": 0}

def get_access_token():
    """Get a fresh access token from FatSecret OAuth endpoint"""
    now = time.time()
    if token_cache["access_token"] and now < token_cache["expires_at"]:
        return token_cache["access_token"]

    url = "https://oauth.fatsecret.com/connect/token"
    data = {"grant_type": "client_credentials", "scope": "basic"}
    auth = (CLIENT_ID, CLIENT_SECRET)

    res = requests.post(url, data=data, auth=auth)
    res.raise_for_status()
    json_data = res.json()

    token_cache["access_token"] = json_data["access_token"]
    token_cache["expires_at"] = now + json_data["expires_in"] - 60
    return token_cache["access_token"]

@app.route("/searchFood", methods=["GET"])
def search_food():
    """Search for foods using the FatSecret API"""
    query = request.args.get("q")
    if not query:
        return jsonify({"error": "Missing ?q parameter"}), 400

    try:
        token = get_access_token()
        url = "https://platform.fatsecret.com/rest/server.api"
        payload = {
            "method": "foods.search",
            "search_expression": query,
            "format": "json"
        }
        headers = {"Authorization": f"Bearer {token}"}

        res = requests.post(url, data=payload, headers=headers)
        res.raise_for_status()
        return jsonify(res.json())
    except requests.exceptions.RequestException as e:
        return jsonify({"error": f"API request failed: {str(e)}"}), 500
    except Exception as e:
        return jsonify({"error": f"Server error: {str(e)}"}), 500

@app.route("/getFood", methods=["GET"])
def get_food():
    """Get detailed information about a specific food by ID"""
    food_id = request.args.get("id")
    if not food_id:
        return jsonify({"error": "Missing ?id parameter"}), 400

    try:
        token = get_access_token()
        url = "https://platform.fatsecret.com/rest/server.api"
        payload = {
            "method": "food.get",
            "food_id": food_id,
            "format": "json"
        }
        headers = {"Authorization": f"Bearer {token}"}

        res = requests.post(url, data=payload, headers=headers)
        res.raise_for_status()
        return jsonify(res.json())
    except requests.exceptions.RequestException as e:
        return jsonify({"error": f"API request failed: {str(e)}"}), 500
    except Exception as e:
        return jsonify({"error": f"Server error: {str(e)}"}), 500

@app.route("/health", methods=["GET"])
def health_check():
    """Health check endpoint"""
    return jsonify({"status": "healthy", "timestamp": time.time()})

if __name__ == "__main__":
    app.run(port=3000, debug=True)
