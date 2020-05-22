import * as React from 'react'
import { Button } from 'react-bootstrap'
import axios from 'axios';
import { AxiosResponse } from 'axios';
import AxiosHelper from '../utils/AxiosHelper'

interface Statement {
  id: number,
  content: string
}

interface Individual {
  id: number,
  name: string,
  picture_url: string
}
interface Agreement {
  id: number,
  statement: Statement,
  reason: string,
  extent: number // 100 agree; 0 disagree
}

interface GameProps {
  agreements: Agreement[],
  individual: Individual
}

interface GameState {
  answers: number[], // 100 agree, 50 skip, 0 disagree
  currentQuestion: number,
  showAnswer: boolean
}

export class GameComponent extends React.Component<GameProps, GameState>{
  constructor(props: GameProps) {
    super(props)

    this.state = {
      answers: [],
      currentQuestion: 0,
      showAnswer: false
    }
  }

  vote = (answer: number) => {
    const { answers, currentQuestion, showAnswer } = this.state
    const { individual, agreements } = this.props
    answers[currentQuestion] = answer
    this.setState({ answers: answers, currentQuestion: currentQuestion + 1, showAnswer: !showAnswer })
    const event_args = {
      name: "vote",
      statement_id: agreements[currentQuestion].statement.id,
      game_individual_id: individual.id,
      extent: answer
    }
    AxiosHelper()
    axios.post('/api/v2/events', event_args)
  }

  renderQuestion = () => {
    return (
      <>
        <p>Do you agree?</p>
        <Button variant="success" className="game-agree" onClick={() => this.vote(100)}>Agree</Button>
        <Button variant="danger" onClick={() => this.vote(0)}>Disagree</Button>
        <Button variant="link" onClick={() => this.vote(50)}>Skip</Button>
      </>
    )
  }

  renderAnswer = () => {
    const { agreements, individual } = this.props
    const { currentQuestion } = this.state
    const agreement = agreements[currentQuestion]
    const reason = agreement.reason

    const agreesOrDisagrees = agreement.extent == 100 ? 'agrees' : 'disagrees'

    return (
      <>
        {individual.name} agrees:
        <div className="opinion">
          <i>{reason}</i>
        </div>
        <Button variant="primary" onClick={() => this.setState({ currentQuestion: currentQuestion + 1, showAnswer: false})}>Next question</Button>
      </>
    )
  }

  render() {
    const { agreements, individual } = this.props
    const { showAnswer, currentQuestion } = this.state

    const count = agreements.length
    return (
      <div>
        <h5>Vote to see {individual.name}'s opinions:</h5>
        <h2>{agreements[currentQuestion].statement.content}</h2>
        {showAnswer ? this.renderAnswer() : this.renderQuestion()}
      </div>
    )
  }
}

export default GameComponent
