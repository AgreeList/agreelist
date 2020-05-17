import * as React from 'react'
import { Button } from 'react-bootstrap'

interface Statement {
  id: number,
  content: string
}

interface Individual {
  id: number,
  name: string,
  picture_url: string
}

interface GameProps {
  statements: Statement[],
  individual: Individual
}

interface GameState {
  answers: number[] // 100 agree, 50 skip, 0 disagree
  currentQuestion: number
}

export class GameComponent extends React.Component<GameProps, GameState>{
  constructor(props: GameProps) {
    super(props)

    this.state = {
      answers: [],
      currentQuestion: 0
    }
  }

  vote = (answer: number) => {
    const { answers, currentQuestion } = this.state
    answers[currentQuestion] = answer
    this.setState({ answers: answers, currentQuestion: currentQuestion + 1 })
  }

  render() {
    const { statements, individual } = this.props
    const { currentQuestion } = this.state

    const count = statements.length
    return (
      <div>
        <div className="game-wrap">
          <div className="game-picture">
            <img src={individual.picture_url} alt={`${individual.name} photo`} />
          </div>
          <div className="game-question">
            <h1>Do you agree with {individual.name}?</h1>
          </div>
        </div>
        <h5>Vote {count} statements to find out! At the end we'll let you know which statements {individual.name} agrees and why.</h5>
        <h2>{currentQuestion + 1}. {statements[currentQuestion].content}</h2>
        <p>Do you agree?</p>
        <Button variant="success" className="game-agree" onClick={() => this.vote(100)}>Agree</Button>
        <Button variant="danger" onClick={() => this.vote(0)}>Disagree</Button>
        <Button variant="link" onClick={() => this.vote(50)}>Skip</Button>
      </div>
    )
  }
}

export default GameComponent
