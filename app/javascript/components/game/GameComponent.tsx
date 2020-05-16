import * as React from 'react'

interface Statement {
  id: number,
  content: string
}

interface GameProps {
  statements: Statement[]
}

export class GameComponent extends React.Component<GameProps>{
  render() {
    return (
      <div>
        <p>Hi {this.props.statements[0].content}!</p>
        <a href="/ddd" className="btn btn-primary">Agree</a>
        <a href="/ddd" className="btn btn-primary">Disagree</a>
      </div>
    )
  }
}

export default GameComponent
