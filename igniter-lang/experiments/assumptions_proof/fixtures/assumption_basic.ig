module Risk.Scoring

assumptions {
  assumption homophily {
    kind :heuristic
    statement "People with similar beliefs interact more often."
    strength 0.7
  }
}

observed contract ScoreInteraction {
  input a: Signal
  input b: Signal
  uses assumptions homophily
  escape profile_source
  compute score = homophily.strength
  output score: Decimal[4] evidence [a, b, homophily]
}
