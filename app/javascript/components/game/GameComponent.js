var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
import * as React from 'react';
import { Button, Form } from 'react-bootstrap';
import axios from 'axios';
import AxiosHelper from '../utils/AxiosHelper';
var GameComponent = /** @class */ (function (_super) {
    __extends(GameComponent, _super);
    function GameComponent(props) {
        var _this = _super.call(this, props) || this;
        _this.vote = function (answer) {
            var _a = _this.state, answers = _a.answers, currentQuestion = _a.currentQuestion, showAnswer = _a.showAnswer;
            var _b = _this.props, individual = _b.individual, agreements = _b.agreements;
            answers[currentQuestion] = answer;
            _this.setState({ answers: answers, currentQuestion: currentQuestion, showAnswer: !showAnswer });
            var event_args = {
                statement_id: agreements[currentQuestion].statement.id,
                game_individual_id: individual.id,
                extent: answer,
                source: "game"
            };
            AxiosHelper();
            axios.post('/ag', event_args);
        };
        _this.renderStatement = function () {
            var _a = _this.props, agreements = _a.agreements, individual = _a.individual;
            var _b = _this.state, showAnswer = _b.showAnswer, currentQuestion = _b.currentQuestion;
            return (React.createElement(React.Fragment, null,
                React.createElement("h5", null,
                    "Vote to see ",
                    individual.name,
                    "'s opinions:"),
                React.createElement("h2", null,
                    currentQuestion + 1,
                    ". ",
                    agreements[currentQuestion].statement.content)));
        };
        _this.renderQuestion = function () {
            var currentQuestion = _this.state.currentQuestion;
            var _a = _this.props, agreements = _a.agreements, individual = _a.individual;
            var end = currentQuestion == agreements.length;
            return (React.createElement(React.Fragment, null,
                end &&
                    React.createElement(React.Fragment, null,
                        "There are no more questions to vote at the moment. \u00A0",
                        React.createElement("a", { href: individual.url }, "See all opinions")),
                !end &&
                    React.createElement(React.Fragment, null,
                        _this.renderStatement(),
                        React.createElement("p", null, "Do you agree?"),
                        React.createElement(Button, { variant: "success", onClick: function () { return _this.vote(100); } }, "Agree"),
                        React.createElement(Button, { variant: "danger", onClick: function () { return _this.vote(0); } }, "Disagree"),
                        React.createElement(Button, { variant: "link", onClick: function () { return _this.vote(50); } }, "Skip"))));
        };
        _this.renderNext = function () {
            var _a = _this.state, currentQuestion = _a.currentQuestion, askEmail = _a.askEmail, loggedIn = _a.loggedIn;
            var agreements = _this.props.agreements;
            var ask = !loggedIn && ((askEmail && currentQuestion == 5) || currentQuestion == agreements.length);
            return (React.createElement(React.Fragment, null, ask ? _this.renderAskEmail() : _this.renderQuestion()));
        };
        _this.handleChange = function (event) {
            _this.setState({ email: event.target.value });
        };
        _this.agreementsForBackend = function () {
            var agreements = _this.props.agreements;
            var _a = _this.state, answers = _a.answers, currentQuestion = _a.currentQuestion;
            return (agreements.slice(0, currentQuestion).map(function (agreement, index) {
                return ({
                    statement_id: agreement.statement.id,
                    extent: answers[index]
                });
            }));
        };
        _this.renderAskEmail = function () {
            var _a = _this.props, individual = _a.individual, agreements = _a.agreements;
            var _b = _this.state, email = _b.email, currentQuestion = _b.currentQuestion;
            var csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
            return (React.createElement(Form, { action: "/", method: "post" },
                React.createElement(Form.Group, null,
                    React.createElement(Form.Label, null, "Email address"),
                    React.createElement(Form.Control, { type: "email", name: "email", placeholder: "Enter email", value: email, onChange: _this.handleChange, autoFocus: true }),
                    React.createElement("div", { className: "small" },
                        "By clicking Sign up and save progress, you agree to our ",
                        React.createElement("a", { href: "/terms" }, "terms"),
                        " and ",
                        React.createElement("a", { href: "/privacy" }, "privacy"),
                        " conditions."),
                    React.createElement("input", { type: "hidden", name: "agreements", value: JSON.stringify(_this.agreementsForBackend()) }),
                    React.createElement("input", { type: "hidden", name: "source", value: "game" }),
                    React.createElement("input", { type: "hidden", name: "from_individual_id", value: individual.id }),
                    React.createElement("input", { type: "hidden", name: "authenticity_token", value: csrfToken }),
                    React.createElement(Button, { variant: "primary", type: "submit" }, "Sign up and save progress"),
                    currentQuestion < agreements.length &&
                        React.createElement(Button, { variant: "link", className: "small", onClick: function () { return _this.setState({ askEmail: false }); } }, "or skip and continue voting"),
                    React.createElement(Button, { variant: "link", className: "small", onClick: function () { return window.location.replace("/login"); } }, "or log in"))));
        };
        _this.renderAnswer = function () {
            var _a = _this.props, agreements = _a.agreements, individual = _a.individual;
            var currentQuestion = _this.state.currentQuestion;
            var agreement = agreements[currentQuestion];
            var reason = agreement.reason;
            var agreesOrDisagrees = agreement.extent == 100 ? 'agrees' : 'disagrees';
            return (React.createElement(React.Fragment, null,
                _this.renderStatement(),
                individual.name,
                " agrees:",
                React.createElement("div", { className: "opinion" },
                    React.createElement("i", null, reason)),
                React.createElement(Button, { variant: "primary", onClick: function () { return _this.setState({ currentQuestion: currentQuestion + 1, showAnswer: false }); } }, "Next question")));
        };
        _this.state = {
            answers: [],
            currentQuestion: 0,
            showAnswer: false,
            askEmail: true,
            email: "",
            loggedIn: props.loggedIn
        };
        return _this;
    }
    GameComponent.prototype.render = function () {
        var showAnswer = this.state.showAnswer;
        return (React.createElement("div", null, showAnswer ? this.renderAnswer() : this.renderNext()));
    };
    return GameComponent;
}(React.Component));
export { GameComponent };
export default GameComponent;
//# sourceMappingURL=GameComponent.js.map