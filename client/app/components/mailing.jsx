import React from 'react';

class Mailing extends React.Component{
  render(){
    if(this.props.mailings == undefined){
      return (
        <h3>No emails yet</h3>
      )
    }else{
      return (
        <div className='emails'>
          { this.props.mailings.map(function(email){ 
            return (
              <div className="email">
                <h4> Subject: </h4>
                <h3> { email.subject } </h3>
              </div>
            )
          })}
        </div>
      );
    }
  }
}

export default Mailing;
