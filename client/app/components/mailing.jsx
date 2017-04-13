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
          { this.props.mailings.map((email) => { 
            return (
              <div className="email" key="{ email.id }">
                <h4> Subject: { email.subject } </h4>
              </div>
            )
          })}
        </div>
      );
    }
  }
}

export default Mailing;
