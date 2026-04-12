import React from 'react'

const NewsItem = (props) => {
  let { title, discription, imageurl, newsurl, author, date, source } = props;
  return (
    <div className="h-full">
      <div className="bg-white rounded-xl shadow-md overflow-hidden hover:shadow-2xl hover:scale-105 transition-all duration-300 transform h-full flex flex-col relative group border border-gray-100">
        <span className="absolute top-2 right-2 bg-gradient-to-r from-red-600 to-red-500 text-white px-3 py-1 text-xs font-bold rounded-full shadow-sm z-10">
          {source ? source : "Unknown"}
        </span>

        <div className="overflow-hidden relative h-48 w-full">
          <img
            src={imageurl ? imageurl : "https://a4.espncdn.com/combiner/i?img=%2Fi%2Fcricket%2Fcricinfo%2F1219926_1296x729.jpg"}
            className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
            alt="News thumbnail"
          />
          <div className="absolute inset-0 bg-black opacity-0 group-hover:opacity-20 transition-opacity duration-300"></div>
        </div>

        <div className="p-5 flex-1 flex flex-col justify-between">
          <div>
            <h5 className="text-xl font-bold mb-2 text-gray-800 line-clamp-2 hover:text-blue-600 transition-colors">{title}</h5>
            <p className="text-gray-600 text-sm mb-4 line-clamp-3 leading-relaxed">{discription}</p>
          </div>

          <div className="mt-auto">
            <div className="border-t border-gray-100 pt-3 mb-3">
              <p className="text-xs text-gray-500 flex items-center">
                <svg className="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                {date ? new Date(date).toGMTString().slice(0, 16) : "Unknown Date"}
              </p>
              <p className="text-xs text-gray-400 mt-1 italic">
                By {author ? author : "Unknown"}
              </p>
            </div>
            <a href={newsurl} target='_blank' rel="noreferrer" className="block w-full text-center bg-gray-900 text-white font-semibold py-2 px-4 rounded-lg hover:bg-blue-600 transition-colors duration-300 shadow-md hover:shadow-lg">
              Read Full Story
            </a>
          </div>
        </div>
      </div>
    </div>
  )
}

export default NewsItem
