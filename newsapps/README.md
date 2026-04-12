# React News Application

A modern, responsive React-based news application that fetches top headlines from across the globe in real-time, categorized into various segments like Technology, Business, Sports, Entertainment, and more. 

## Features

- **Real-Time News:** Fetches the latest top headlines via the [NewsAPI](https://newsapi.org).
- **Infinite Scrolling:** Automatically loads more news articles as you scroll down the page using `react-infinite-scroll-component`, offering a seamless reading experience.
- **Categorization:** Read news tailored to your interest by browsing specific categories.
- **Tailwind CSS Styling:** Fully responsive, modern UI built with the utility-first Tailwind CSS framework.
- **Top Loading Bar:** Displays a progress bar across the top of the browser window as news articles are being fetched.

## Tech Stack

- **Frontend:** React (Bootstrapped with Create React App)
- **Styling:** Tailwind CSS
- **Routing:** React Router v7
- **Data Fetching:** Fetch API, NewsAPI
- **Key Packages:**
  - `react-infinite-scroll-component`: For infinite scrolling.
  - `react-top-loading-bar`: Adds a dynamic loading progress bar.
  - `react-router-dom`: Enables client-side navigation.

## Prerequisites

To run this project locally, you will need:
- Node.js installed on your machine.
- A free API key from [NewsAPI](https://newsapi.org).

## Installation and Setup

1. **Clone the repository:**
   If you haven't already, clone the project and navigate to the project directory:
   ```bash
   cd newsapps
   ```

2. **Install the dependencies:**
   Using npm:
   ```bash
   npm install
   ```

3. **Configure Environment Variables:**
   Create a `.env` file in the root directory (alongside `package.json`). Add your NewsAPI key inside this `.env` file like so:
   ```env
   REACT_APP_NEWS_API_KEY=your_api_key_here
   ```
   *Note: This project comes with an example `.env` file already pre-configured by default. Make sure to update it with your own valid key if needed.*

4. **Start the Development Server:**
   ```bash
   npm start
   ```
   Open [http://localhost:3000](http://localhost:3000) to view it in the browser. The page will reload if you make any edits.

## Scripts

In the project directory, you can run the following scripts:

- `npm start`: Runs the app in development mode.
- `npm test`: Launches the test runner in interactive watch mode.
- `npm run build`: Builds the app for production to the `build` folder. It correctly bundles React in production mode and optimizes the build for the best performance.

## License

This project is open-source and free to be used and modified according to your needs.
