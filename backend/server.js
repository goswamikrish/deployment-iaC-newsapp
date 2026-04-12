const express = require('express');
const cors = require('cors');
const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
// Simple Express proxy on EC2
app.get('/api/news', async (req, res) => {
  const { category, page, pagesize } = req.query;
  const url = `https://newsapi.org/v2/top-headlines?country=us&category=${category}&page=${page}&pageSize=${pagesize}&apiKey=${process.env.NEWS_API_KEY}`;
  const response = await fetch(url);
  const data = await response.json();
  res.json(data);
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});