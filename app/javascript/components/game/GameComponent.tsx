import * as React from 'react'

interface Individual {
  name: String
}

interface Agreement {
  id: number,
  individual: Individual
}

interface AgreementsProps {
  agreements: Agreement[]
}

export class GameComponent extends React.Component<AgreementsProps>{
  render() {
    return (
      <div>
        <p>Hi {this.props.agreements[0].individual.name}!</p>
        <p>Hi {this.props.agreements[1].individual.name}!</p>
        <a href="/ddd" className="btn btn-primary">Agree</a>
        <a href="/ddd" className="btn btn-primary">Disagree</a>
      </div>
    )
  }
}

export default GameComponent
