import React, { useEffect, useState } from "react";
import NewsItem from "./NewsItem";
import Spinner from "./Spinner";
import PropTypes from "prop-types";
import InfiniteScroll from "react-infinite-scroll-component";

const News = (props) => {
  const [articles, setArticles] = useState([])
  //const [loading,setLoading]=useState(true)
  const [page, setPage] = useState(1)
  const [totalarticles, setTotalarticles] = useState(0)
  const [hasmore, setHasmore] = useState(true)

  //const handleNextclick = async () => {
  // if (
  // this.state.page + 1 >
  // Math.ceil(this.state.totalarticles / props.pageno)
  //) {
  //} else {
  //let url = `https://newsapi.org/v2/top-headlines?country=us&category=${props.category
  // }&apiKey=${process.env.REACT_APP_NEWS_API_KEY}&page=${this.state.page + 1
  // } &pagesize=${props.pageno}`;
  //this.setState({ loading: true });
  //let data = await fetch(url);
  //let parseData = await data.json();
  //onsole.log(parseData);

  //this.setState({
  //page: this.state.page + 1,
  // articles: parseData.articles,
  // loading: false,
  //});
  //}
  //};
  //const handlePrevclick = async () => {
  //let url = `https://newsapi.org/v2/top-headlines?country=us&category=${props.category
  // }&apiKey=${process.env.REACT_APP_NEWS_API_KEY}&page=${this.state.page - 1
  // } &pagesize=${props.pageno}`;
  // this.setState({ loading: true });
  //let data = await fetch(url);
  //let parseData = await data.json();
  //console.log(parseData);

  //this.setState({
  //  page: this.state.page - 1,
  //  articles: parseData.articles,
  //  loading: false,
  // });
  //};
  const fetchMoreData = async () => {
    if (articles.length >= totalarticles) {
      setHasmore(false);
    }
    const url = `/api/news?category=${props.category}&page=${page + 1}&pagesize=${props.pageno}`;
    setPage(page + 1);


    let data = await fetch(url);
    let parseData = await data.json();
    console.log(parseData);
    setArticles(articles.concat(parseData.articles));
    setTotalarticles(parseData.totalResults);

  };

  const updateNews = async () => {
    props.prog(0);
    let url = `/api/news?category=${props.category}&page=1&pagesize=${props.pageno}`;

    let data = await fetch(url);
    props.prog(30);
    let parseData = await data.json();
    //console.log(parseData);
    console.log(articles.length)
    console.log(totalarticles);
    props.prog(100);
    setArticles(parseData.articles);
    setTotalarticles(parseData.totalResults);
    //setLoading(false);

  }
  useEffect(() => {
    updateNews();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  /* ... (imports and state logic remain same) ... */

  return (
    <>
      {/* Adjusted top margin to account for fixed navbar */}
      <h1 className="text-3xl md:text-5xl font-bold text-center text-gray-800 my-10 pt-24 pb-4 border-b-4 border-blue-500 w-fit mx-auto">
        Top Headlines - <span className="text-blue-600 capitalize">{props.heading}</span>
      </h1>

      <div className="text-center">
        {/*{this.state.loading &&<Spinner/>}*/}
      </div>

      <InfiniteScroll
        dataLength={articles.length}
        next={fetchMoreData}
        hasMore={hasmore}
        loader={<Spinner />}
        endMessage={
          <div className="text-center py-8">
            <p className="text-gray-500 font-medium">Yay! You have seen it all</p>
          </div>
        }
        style={{ overflow: 'hidden' }}
      >
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {articles.map((element, index) => {
              return (
                <div key={`${element.url}-${index}`} className="h-full">
                  <NewsItem
                    title={element.title ? element.title.slice(0, 45) + "..." : "No Title Available"}
                    discription={element.description ? element.description.slice(0, 88) + "..." : "No description available for this news article. Click read more to get full details."}
                    imageurl={element.urlToImage}
                    newsurl={element.url}
                    author={element.author}
                    date={element.publishedAt}
                    source={element.source.name}
                  />
                </div>
              );
            })}
          </div>
        </div>
      </InfiniteScroll>
    </>
  );

}
News.defaultProps = {
  country: "us",
  pageno: 8,
  category: "general",
};
News.propTypes = {
  country: PropTypes.string,
  pageno: PropTypes.number,
};

export default News;
