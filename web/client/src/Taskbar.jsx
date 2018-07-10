import React from 'react';
import { Input, Menu } from 'semantic-ui-react'
import { Link } from 'react-router-dom'

const defaultProps = {

};

const defaultState = {

};

export default class Taskbar extends React.Component {
  constructor(props) {
    super(props);
    this.state = defaultState;
  }

  handleItemClick = (e, { name }) => this.setState({ activeItem: name });

  render() {
    const { activeItem } = this.state;

    return (
      <Menu secondary>
        <Menu.Item name='home' active={activeItem === 'home'} onClick={this.handleItemClick} />
        <Menu.Item
          name='messages'
          active={activeItem === 'messages'}
          onClick={this.handleItemClick}
        />
        <Menu.Item
          name='friends'
          active={activeItem === 'friends'}
          onClick={this.handleItemClick}
        />
        <Menu.Menu position='right'>
          <Menu.Item>
            <Input icon='search' placeholder='Search...' />
          </Menu.Item>

          <Link to="/auth">Login</Link>
          <Link to="/about">About</Link>

        </Menu.Menu>
      </Menu>
    );
  }
}

Taskbar.defaultProps = defaultProps;