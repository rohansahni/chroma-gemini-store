from flask import Flask, request, jsonify
from flask_cors import CORS
import google.generativeai as genai
import os
from dotenv import load_dotenv
import json
import requests


load_dotenv()

app = Flask(__name__)
CORS(app)

# Initialize Gemini API
genai.configure(api_key="YOUR_GEMINI_API")
model = genai.GenerativeModel('gemini-1.5-pro')


# Mock user and product data (replace with database in production)
users = [
    {"id": 1, "name": "Alice", "devices": ["smart_tv", "smartphone"], "preferences": ["energy_efficiency", "voice_control"]},
    {"id": 2, "name": "Bob", "devices": ["smartphone", "smart_speaker"], "preferences": ["security", "automation"]}
]

products = [
    {"id": 1, "name": "Smart Thermostat", "category": "climate_control", "compatibility": ["smartphone", "smart_speaker"], "features": ["energy_efficiency", "voice_control"]},
    {"id": 2, "name": "Smart Bulb", "category": "lighting", "compatibility": ["smartphone", "smart_speaker"], "features": ["energy_efficiency", "voice_control"]},
    {"id": 3, "name": "Security Camera", "category": "security", "compatibility": ["smartphone", "smart_tv"], "features": ["security", "automation"]},
    {"id": 4, "name": "Smart Lock", "category": "security", "compatibility": ["smartphone"], "features": ["security", "automation"]},
    {"id": 5, "name": "Robot Vacuum", "category": "cleaning", "compatibility": ["smartphone", "smart_speaker"], "features": ["automation", "energy_efficiency"]}
]


# Assuming the first Flask app is hosted at this URL
ANALYZE_API_URL = 'https://rncfz-20-207-207-133.a.free.pinggy.link/api/analyze'

@app.route('/')
def hello_world():
    return 'Hello from Smart Ecosystem Recommender!'

@app.route('/api/recommend', methods=['POST'])
def recommend():
    user_id = request.json.get('userId')
    user = next((u for u in users if u['id'] == user_id), None)

    if not user:
        return jsonify({"error": "User not found"}), 404

    try:
        user_devices = ', '.join(user['devices'])
        user_preferences = ', '.join(user['preferences'])
        product_list = ', '.join(p['name'] for p in products)
        prompt = f"""
        Given a user with the following smart home devices: {user_devices}
        and preferences: {user_preferences},
        recommend 3 products from this list that would best complement their existing ecosystem: {product_list}.
        Consider device compatibility, user preferences, and potential synergies between devices.
        Provide the recommendations in a JSON format with the following structure for each recommendation:
        {{
            "product": "Product Name",
            "explanation": "Brief explanation of why this product is recommended",
            "compatibility": "How it's compatible with existing devices",
            "benefits": "Key benefits based on user preferences"
        }}
        """

        response = model.generate_content(prompt)
        recommendations = response.text
        # Remove the Markdown code block syntax
        recommendations = recommendations.strip('`json\n')
        # Parse the JSON string
        recommendations_json = json.loads(recommendations)
        return jsonify(recommendations_json)
    except Exception as e:
        print(f"Error calling Gemini API: {str(e)}")
        return jsonify({"error": "Failed to generate recommendations"}), 500




@app.route('/api/user/<int:user_id>')
def get_user(user_id):
    user = next((u for u in users if u['id'] == user_id), None)
    if user:
        return jsonify(user)
    else:
        return jsonify({"error": "User not found"}), 404

@app.route('/api/products')
def get_products():
    return jsonify(products)

@app.route('/api/purchase-timing', methods=['POST'])
def purchase_timing():
    product_id = request.json.get('productId')
    product = next((p for p in products if p['id'] == product_id), None)
    print("#"*10,"Requested Purchased Timing")
    if not product:
        return jsonify({"error": "Product not found"}), 404

    try:
        prompt = f"""
        Analyze the best time to buy the {product['name']} based on the following factors:
        - Current market trends
        - Typical product release cycles
        - Seasonal sales patterns
        - Product category: {product['category']}

        Provide a recommendation on whether to buy now or wait, and explain the reasoning.
        Include any potential risks of waiting (e.g., stock shortages) and benefits of buying now (e.g., immediate use).
        Format the response as a JSON object with 'recommendation' and 'explanation' keys.
        """

        response = model.generate_content(prompt)
        timing_advice = response.text
        # Remove any Markdown code block syntax
        timing_advice = timing_advice.strip('`json\n')
        # Parse the JSON string
        timing_advice_json = json.loads(timing_advice)
        return jsonify(timing_advice_json)
    except Exception as e:
        print(f"Error calling Gemini API: {str(e)}")
        return jsonify({"error": "Failed to generate purchase timing advice"}), 500

@app.route('/api/customer-journey', methods=['POST'])
def customer_journey():
    user_id = request.json.get('userId')
    product_id = request.json.get('productId')
    stage = request.json.get('stage')  # e.g., 'marketing', 'purchase', 'delivery', 'installation', 'support', 'end-of-life'

    user = next((u for u in users if u['id'] == user_id), None)
    product = next((p for p in products if p['id'] == product_id), None)

    if not user or not product:
        return jsonify({"error": "User or product not found"}), 404

    try:
        prompt = f"""
        Create a personalized customer journey plan for {user['name']} regarding the {product['name']}.
        Current stage: {stage}
        User preferences: {', '.join(user['preferences'])}
        Product category: {product['category']}

        Provide specific recommendations to enhance the customer experience at this stage.
        Consider factors such as communication style, channel preferences, and potential pain points.
        Format the response as a JSON object with 'recommendations' (an array of specific actions) and 'explanation' keys.
        """

        response = model.generate_content(prompt)
        journey_plan = response.text
        # Remove any Markdown code block syntax
        journey_plan = journey_plan.strip('`json\n')
        # Parse the JSON string
        journey_plan_json = json.loads(journey_plan)
        return jsonify(journey_plan_json)
    except Exception as e:
        print(f"Error calling Gemini API: {str(e)}")
        return jsonify({"error": "Failed to generate customer journey plan"}), 500


@app.route('/api/forward-analyze', methods=['POST'])
def forward_analyze():
    dummy_response ={
    "analysis": "The data shows a mix of trends. Some users are high-value customers with high transaction frequency and high average transaction value, while others are low-value customers with low transaction frequency and low average transaction value. \n\nHere are some specific trends:\n\n* **High-value customers:** David Dominguez, Heather Garcia, and Julie Mcdaniel are all high-value customers with high total spent and high average transaction value.\n* **Low-value customers:** Mr. Brent Carr DDS is a low-value customer with low total spent and low average transaction value.\n* **High transaction frequency:** Mr. Brent Carr DDS and Heather Garcia have high transaction frequency, indicating they are frequent buyers.\n* **Low transaction frequency:** David Dominguez and Julie Mcdaniel have low transaction frequency, indicating they are less frequent buyers.\n* **Loyalty program membership:** Some users are members of the loyalty program, while others are not. This suggests a difference in engagement and brand loyalty.\n* **Preferred communication channels:** Users have different preferred communication channels, indicating a need for personalized marketing strategies.\n* **Product affinity:** Users have different product affinities, indicating a need for targeted product recommendations.\n\nOverall, the data suggests that there is a diverse customer base with varying levels of engagement, spending habits, and preferences. \n"}
    return jsonify(dummy_response)
    # Extract the input from the request coming from the Flutter app
    # input_data = request.json()

    # Make a request to the first Flask app (analyze API)
    # try:
    #     # analyze_response = requests.post(ANALYZE_API_URL, json=input_data, proxies={})
    #     dummy_response ={
    # "analysis": "The data shows a mix of trends. Some users are high-value customers with high transaction frequency and high average transaction value, while others are low-value customers with low transaction frequency and low average transaction value. \n\nHere are some specific trends:\n\n* **High-value customers:** David Dominguez, Heather Garcia, and Julie Mcdaniel are all high-value customers with high total spent and high average transaction value.\n* **Low-value customers:** Mr. Brent Carr DDS is a low-value customer with low total spent and low average transaction value.\n* **High transaction frequency:** Mr. Brent Carr DDS and Heather Garcia have high transaction frequency, indicating they are frequent buyers.\n* **Low transaction frequency:** David Dominguez and Julie Mcdaniel have low transaction frequency, indicating they are less frequent buyers.\n* **Loyalty program membership:** Some users are members of the loyalty program, while others are not. This suggests a difference in engagement and brand loyalty.\n* **Preferred communication channels:** Users have different preferred communication channels, indicating a need for personalized marketing strategies.\n* **Product affinity:** Users have different product affinities, indicating a need for targeted product recommendations.\n\nOverall, the data suggests that there is a diverse customer base with varying levels of engagement, spending habits, and preferences. \n"}
    #     return jsonify(dummy_response)

    #     # Check if the response from the first API is successful
    #     # if analyze_response.status_code == 200:
    #         # Forward the response from the first API to the Flutter app
    #         # return jsonify(analyze_response.json())
    #     # else:
    #         # return jsonify({"error": "Failed to fetch data from analyze API"}), analyze_response.status_code
    # except requests.exceptions.RequestException as e:
    #     # Handle any connection errors
    #     return jsonify({"error": f"Connection error: {str(e)}"}), 500





@app.route('/api/analyze-customers', methods=['POST'])
def analyze_customers():
    dummy_analysis = {"analysis": '''1. **Low Value, Low Frequency Shopper**:
   - Ashley falls into the Low Value (LV) and Low Frequency (LF) categories, indicating that her purchases are low in value and she shops infrequently. Her total spent is $40.05 with an average transaction value of $13.35 across three transactions.

    2. **Preferred Payment and Purchase Channels**:
       - She prefers using a credit card for transactions and tends to shop online.

    3. **Device and Language Preferences**:
       - Ashley prefers using a desktop computer and prefers Spanish for communication and browsing.

    4. **Email and SMS Engagement**:
       - She has a very high email open rate (84.51%) and an exceptionally high email click rate (59.4%). This suggests that she engages very well with email content.
       - Her SMS click rate is extremely high (92.56%), indicating strong engagement through this medium as well. Despite this, her preferred communication channel is push notifications.

    5. **Shopping and Browsing Behavior**:
       - She spends an average of 27 minutes on the site with 5 page views per session.
       - She has not abandoned any carts and has a reasonable cart conversion rate (58.44%).

    6. **Product and Brand Affinity**:
       - Ashley has shown a preference for products like hoodies, sweaters, dresses, and jeans.
       - She has a low brand loyalty index of 18 and prefers brands like Stone, Garrison, and Black.

    7. **Coupon and Discount Usage**:
       - She uses coupons frequently (9.05%) and has a high discount usage rate (57.38%), indicating that she is highly motivated by discounts for making purchases.

    8. **Engagement and Interaction**:
       - Her social media engagement score is moderate (74), indicating some activity on social platforms.
       - She is a loyalty program member with 1037 loyalty points accumulated.
       - She has interacted with customer service eight times and used live chat moderately (13 times).

    9. **Time and Day Preferences**:
       - The best time to reach her is around 12 PM, particularly on Wednesdays during the fifth week of the month.

    10. **Review and Referral Activity**:
        - Ashley has written 17 reviews with an average rating of 4.46 and has referred 6 new customers.

    11. **Marketing and Campaign Engagement**:
        - Her campaign engagement score is low (12), and her click-through rate is also low (6.49%), suggesting that she doesn't engage much with marketing campaigns.
        - Her conversion rate is moderate (9.16%).
    '''
    }
    return jsonify(dummy_analysis)


# This is needed for PythonAnywhere
application = app
