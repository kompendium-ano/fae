import * as React from 'react';
import { connect, Dispatch } from 'react-redux';
//import { RootState } from './store';
import { Container, Grid, Header } from 'semantic-ui-react';

type HomeProps = {
  //tokens: Token.AsObject[],
  loading: boolean,
  error: Error | null,
  //selected: Token.AsObject | null,

  fetchTokens: () => void,
  selectTokens: (id: number) => void,
};

class Stories extends React.Component<HomeProps, {}> {

  componentDidMount() {
    this.props.fetchTokens();
  }

  render() {
    return (
      <Container style={{padding: '1em'}} fluid={true}>
        <Header as="h1" dividing={true}>Tokens</Header>

        <Grid columns={2} stackable={true} divided={'vertically'}>
          <Grid.Column width={4}>

          </Grid.Column>

          <Grid.Column width={12} stretched={true}>
          </Grid.Column>
        </Grid>

      </Container>
    );
  }

}

export default Home;
