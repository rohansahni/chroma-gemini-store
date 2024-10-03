from flask import Flask, request, jsonify
from flask_cors import CORS
import google.generativeai as genai
from dotenv import load_dotenv
from langchain.document_loaders import PyPDFLoader,CSVLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter, CharacterTextSplitter
from langchain.vectorstores import Chroma
from langchain.chains import RetrievalQA
from langchain_google_genai import GoogleGenerativeAI
from langchain_google_genai import ChatGoogleGenerativeAI
import langchain_google_genai as genai
from langchain.document_loaders import CSVLoader
from langchain.indexes import VectorstoreIndexCreator
from langchain.vectorstores import DocArrayInMemorySearch
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import base64
from io import BytesIO
import os

load_dotenv()

app = Flask(__name__)
CORS(app)
CORS(app, resources={r"/api/*": {"origins": "*"}})
# Initialize Gemini API
# genai.configure(api_key=os.getenv('GOOGLE_API_KEY'))
# model = genai.GenerativeModel('gemini-1.5-pro')
os.environ["GOOGLE_API_KEY"] = 'YOUR_GEMINI_API'
# Load and process CSV data
file = r'C:\inetpub\wwwroot\chroma-gemini-flask-app\user_attribures_copy.csv'
loader = CSVLoader(file_path=file)
docs = loader.load()

embeddings = genai.GoogleGenerativeAIEmbeddings(model="models/embedding-001")
db = DocArrayInMemorySearch.from_documents(docs, embeddings)
retriever = db.as_retriever()

llm = ChatGoogleGenerativeAI(
    model="gemini-1.5-flash",
    temperature=0,
    max_tokens=None,
    timeout=None,
    max_retries=2,
)

qa_stuff = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=retriever,
    verbose=True
)

df = pd.read_csv(file)

@app.route('/')
def hello_world():
    return 'Hello from Data Analysis and Visualization App!'

@app.route('/api/analyze', methods=['POST'])
def analyze_data():
    query = request.json.get('query')
    if not query:
        return jsonify({"error": "No query provided"}), 400

    try:
        response = qa_stuff.run(query)
        return jsonify({"analysis": response})
    except Exception as e:
        print(f"Error during data analysis: {str(e)}")
        return jsonify({"error": "Failed to analyze data"}), 500

@app.route('/api/visualize', methods=['POST'])
def visualize_data():
    chart_type = request.json.get('chart_type')
    x_column = request.json.get('x_column')
    y_column = request.json.get('y_column')

    if not all([chart_type, x_column, y_column]):
        return jsonify({"error": "Missing required parameters"}), 400

    plt.figure(figsize=(10, 6))

    if chart_type == 'bar':
        sns.barplot(x=x_column, y=y_column, data=df)
    elif chart_type == 'scatter':
        sns.scatterplot(x=x_column, y=y_column, data=df)
    elif chart_type == 'line':
        sns.lineplot(x=x_column, y=y_column, data=df)
    else:
        return jsonify({"error": "Invalid chart type"}), 400

    plt.title(f'{chart_type.capitalize()} Chart: {x_column} vs {y_column}')
    plt.xlabel(x_column)
    plt.ylabel(y_column)

    buffer = BytesIO()
    plt.savefig(buffer, format='png')
    buffer.seek(0)
    image_base64 = base64.b64encode(buffer.getvalue()).decode('utf-8')
    plt.close()

    return jsonify({"chart": image_base64})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8501)


# ./pinggy.exe -p 443 -t -R0:localhost:8501 a.pinggy.io \"r:\"
