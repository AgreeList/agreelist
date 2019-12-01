interface Individual {
  name: String
}

interface Agreement {
  id: Integer,
  individual: Individual
}

interface AgreementsProps {
  agreement: Agreement[]
}

class GameComponent extends React.Component<AgreementsProps>{
  render() {
    return (
      <div>
        <p>Hi {this.props.agreements[0].individual.name}!</p>
        <a href="/ddd" class="btn btn-primary">Agree</a>
        <a href="/ddd" class="btn btn-primary">Disagree</a>
      </div>
    )
  }
}
