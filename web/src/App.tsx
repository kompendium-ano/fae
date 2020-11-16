import React from 'react';
import logo from './logo.svg';
import './App.css';
import Home from './pages/Home';
import { Web3Provider } from './contexts/Web3Context'
import { BridgeProvider } from './contexts/BridgeContext'

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <Web3Provider>
          <BridgeProvider>
            <Home></Home>
          </BridgeProvider>
        </Web3Provider>
      </header>
    </div>
  );
}

export default App;
