# Chroma Store

Welcome to **Chroma Store**, a Flutter application designed to provide a seamless shopping experience. This app features a store side and a customer side, each with unique functionalities to enhance user interaction.

## Table of Contents

- Features
- Installation
- Usage
- API Endpoints
- Screenshots
- Contributing
- License

## Features

- **Store Side**: Manage products, view sales analytics, and handle customer orders.
- **Customer Side**: Browse products, make purchases, and view order history.
- **Customer Analysis**: Analyze customer data to understand shopping patterns and preferences.

## Installation

To get started with Chroma Store, follow these steps:

1. **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/chroma-store.git
    cd chroma-store
    ```

2. **Install dependencies**:
    ```bash
    flutter pub get
    ```

3. **Run the app**:
    ```bash
    flutter run
    ```

## Usage

### Store Side

1. Navigate to the **Store Side** page.
2. Manage your products and view sales analytics.

### Customer Side

1. Navigate to the **Customer Side** page.
2. Browse products and make purchases.

### Customer Analysis

1. Navigate to the **Customer Analysis** page.
2. Enter your query and click on **Analyze Customer Data** to get insights.

## API Endpoints

### Analyze Customers

- **Endpoint**: `/api/analyze-customers`
- **Method**: `POST`
- **Description**: Analyzes customer data and returns insights.
- **Request Body**:
    ```json
    {
      "query": "Your customer analysis query"
    }
    ```
- **Response**:
    ```json
    {
      "analysis": "Analysis result",
      "visualization": "Base64 encoded image data"
    }
    ```

## Screenshots

!Store Side
!Customer Side
!Customer Analysis

## Contributing

We welcome contributions! Please follow these steps to contribute:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes and commit them (`git commit -m 'Add new feature'`).
4. Push to the branch (`git push origin feature-branch`).
5. Create a new Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
