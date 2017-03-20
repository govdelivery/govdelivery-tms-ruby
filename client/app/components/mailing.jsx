import React from 'react';

class Mailing extends React.Component{
  render(){
    return (
      <div className='mailing'>
        <h1>Hello, world!</h1>
        <h2>It is {new Date().toLocaleTimeString()}.</h2>
      </div>
    );
  }
}

export default Mailing;
