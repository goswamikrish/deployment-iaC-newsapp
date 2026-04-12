import React from 'react'
import loading from './loading.gif'
const Spinner = () => {

  return (
    <div className='flex justify-center items-center py-8'>
      <img className="h-10 w-10" src={loading} alt="loading" />
    </div>
  )

}
export default Spinner 
