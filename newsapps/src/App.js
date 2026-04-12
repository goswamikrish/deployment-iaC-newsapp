
import LoadingBar from "react-top-loading-bar";
import React, { useState } from 'react'
import NavBar from './Components/NavBar';
import News from './Components/News';
import { BrowserRouter, Routes, Route } from 'react-router-dom';

const App = () => {
  const [progress, setProgress] = useState(0);

  const prog = (progress) => {
    setProgress(progress)
  }

  return (
    <div className="min-h-screen bg-gray-50 text-gray-900">
      <BrowserRouter>
        <NavBar />
        <LoadingBar
          color="#2563eb"
          progress={progress}
          height={3}
        />
        <Routes>
          <Route path="/" element={<News prog={prog} pageno={20} category="general" heading="General" />}></Route>
          <Route exact path="/sports" element={<News prog={prog} key="sports" pageno={20} category="sports" heading="Sports" />}></Route>
          <Route exact path="/entertainment" element={<News prog={prog} key="entertainmen" pageno={20} category="entertainment" heading="Entertainment" />}></Route>
          <Route exact path="/business" element={<News prog={prog} key="business" pageno={20} category="business" heading="Business" />}></Route>
          <Route exact path="/science" element={<News prog={prog} key="science" pageno={20} category="science" heading="Science" />}></Route>
        </Routes>

      </BrowserRouter>
    </div>
  )

}
export default App;
