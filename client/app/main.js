import React from 'react';
import ReactDom from 'react-dom';
import Mailing from './components/mailing'

require('./styles/main.scss')

ReactDom.render(
  <Mailing/>,
  document.getElementById('app')
);
