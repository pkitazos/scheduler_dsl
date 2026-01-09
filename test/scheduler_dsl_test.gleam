import gleeunit/should
import library/lexer.{lex}
import library/token

pub fn lex_simple_interval_test() {
  lex("every 5 minutes")
  |> should.equal(Ok([token.Every, token.Integer(5), token.Minutes]))
}

pub fn lex_time_test() {
  lex("at 09:30")
  |> should.equal(Ok([token.At, token.TimeLiteral(9, 30)]))
}

pub fn lex_combined_test() {
  lex("daily at 09:00 on weekdays")
  |> should.equal(
    Ok([
      token.Daily,
      token.At,
      token.TimeLiteral(9, 0),
      token.On,
      token.Weekdays,
    ]),
  )
}
