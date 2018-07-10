import React, { Component } from 'react';
import logo from './logo.svg';
import './App.css';
import { BrowserRouter, Route } from 'react-router-dom'
import Taskbar from './Taskbar';
import Login from './Login';

const About = () => (
  <div>
    <h2>About</h2>
  </div>
);

class App extends Component {
  render() {
    return (
      <BrowserRouter>
        <div className="App">
          <header className="App-header">
            <img src={logo} className="App-logo" alt="logo" />
            <h1 className="App-title">Welcome to React</h1>
          </header>
          <Taskbar />

          <div>
            <Route path="/login" component={Login}/>
          </div>

          <div>
            <Route path="/about" component={About}/>
          </div>

        </div>
      </BrowserRouter>
    );
  }
}


export default App;
