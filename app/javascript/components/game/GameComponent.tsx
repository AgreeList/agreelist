import * as React from 'react'
import { Button, Form } from 'react-bootstrap'
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
  picture_url: string,
  url: string
}
interface Agreement {
  id: number,
  statement: Statement,
  reason: string,
  extent: number // 100 agree; 0 disagree
}

interface AgreementBackendOnSave {
  statement_id: number,
  extent: number
}

interface GameProps {
  agreements: Agreement[],
  individual: Individual,
  loggedIn: boolean
}

interface GameState {
  answers: number[], // 100 agree, 50 skip, 0 disagree
  currentQuestion: number,
  showAnswer: boolean,
  askEmail: boolean,
  email: string,
  loggedIn: boolean
}

export class GameComponent extends React.Component<GameProps, GameState>{
  constructor(props: GameProps) {
    super(props)

    this.state = {
      answers: [],
      currentQuestion: 0,
      showAnswer: false,
      askEmail: true,
      email: "",
      loggedIn: props.loggedIn
    }
  }

  vote = (answer: number) => {
    const { answers, currentQuestion, showAnswer } = this.state
    const { individual, agreements } = this.props
    answers[currentQuestion] = answer
    this.setState({ answers: answers, currentQuestion: currentQuestion, showAnswer: !showAnswer })
    const event_args = {
      name: "vote",
      statement_id: agreements[currentQuestion].statement.id,
      game_individual_id: individual.id,
      extent: answer
    }
    AxiosHelper()
    axios.post('/api/v2/events', event_args)
  }

  renderStatement = () => {
    const { agreements, individual } = this.props
    const { showAnswer, currentQuestion } = this.state
    return (
      <>
        <h5>Vote to see {individual.name}'s opinions:</h5>
        <h2>{currentQuestion + 1}. {agreements[currentQuestion].statement.content}</h2>
      </>
    )
  }

  renderQuestion = () => {
    const { currentQuestion } = this.state
    const { agreements, individual } = this.props
    const end = currentQuestion == agreements.length
    return (
      <>
        {end &&
          <>
            There are no more questions to vote at the moment.
            &nbsp;
            <a href={individual.url}>See all opinions</a>
          </>
        }
        {!end &&
          <>
            {this.renderStatement()}
            <p>Do you agree?</p>
            <Button variant="success" onClick={() => this.vote(100)}>Agree</Button>
            <Button variant="danger" onClick={() => this.vote(0)}>Disagree</Button>
            <Button variant="link" onClick={() => this.vote(50)}>Skip</Button>
          </>
        }
      </>
    )
  }

  renderNext = () => {
    const { currentQuestion, askEmail, loggedIn } = this.state
    const { agreements } = this.props

    const ask = !loggedIn && ((askEmail && currentQuestion == 3) || currentQuestion == agreements.length)
    return(
      <>
        {ask ? this.renderAskEmail() : this.renderQuestion()}
      </>
    )
  }

  handleChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    this.setState({ email: event.target.value })
  }

  agreementsForBackend = (): AgreementBackendOnSave[] => {
    const { agreements } = this.props
    const { answers, currentQuestion } = this.state

    return (
      agreements.slice(0, currentQuestion).map((agreement, index) => {
        return (
          {
            statement_id: agreement.statement.id,
            extent: answers[index]
          }
        )
      })
    )
  }

  renderAskEmail = () => {
    const { individual, agreements } = this.props
    const { email, currentQuestion } = this.state
    const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
    return(
      <Form action="/" method="post">
        <Form.Group>
          <Form.Label>Email address</Form.Label>
          <Form.Control type="email" name="email" placeholder="Enter email" value={email} onChange={this.handleChange} autoFocus />
          <div className="small">By clicking Sign up and save progress, you agree to our <a href="/terms">terms</a> and <a href="/privacy">privacy</a> conditions.</div>
          <input type="hidden" name="agreements" value={JSON.stringify(this.agreementsForBackend())} />
          <input type="hidden" name="source" value="game" />
          <input type="hidden" name="from_individual_id" value={individual.id} />
          <input type="hidden" name="authenticity_token" value={csrfToken} />
          <Button variant="primary" type="submit">
            Sign up and save progress
          </Button>
          {currentQuestion < agreements.length &&
            <Button variant="link" className="small" onClick={() => this.setState({askEmail: false})}>or skip and continue voting</Button>
          }
          <Button variant="link" className="small" onClick={() => window.location.replace("/login")}>or log in</Button>
        </Form.Group>
      </Form>
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
        {this.renderStatement()}
        {individual.name} agrees:
        <div className="opinion">
          <i>{reason}</i>
        </div>
        <Button variant="primary" onClick={() => this.setState({ currentQuestion: currentQuestion + 1, showAnswer: false})}>Next question</Button>
      </>
    )
  }

  render() {
    const { showAnswer } = this.state

    return (
      <div>
        {showAnswer ? this.renderAnswer() : this.renderNext()}
      </div>
    )
  }
}

export default GameComponent
