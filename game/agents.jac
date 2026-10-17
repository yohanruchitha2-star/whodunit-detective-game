import from game.types { CaseSpec, SuspectOut, Result }

def generate_case() -> CaseSpec by llm();
sem generate_case = "Propose a mystery case specification.";

def suspect_reply(case_id: str, suspect_id: str, text: str, clue_id: str | None, must_crack: bool) -> SuspectOut by llm();
sem suspect_reply = "Propose one suspect's reply using only that suspect's facts and chat history. Reveal only clue ids known by the suspect. Crack only when must_crack is true.";
sem suspect_reply.case_id = "The case identifier.";
sem suspect_reply.suspect_id = "The one suspect being questioned.";
sem suspect_reply.text = "The player's question.";
sem suspect_reply.clue_id = "The clue shown, if any.";
sem suspect_reply.must_crack = "Walker-verified permission for this suspect to crack.";

def give_hint(case_id: str) -> str by llm();
sem give_hint = "Offer one concise nudge without naming the culprit.";
sem give_hint.case_id = "The case identifier.";

def explain_reveal(case_id: str, correct: bool, story: str, score: int) -> Result by llm();
sem explain_reveal = "Explain the already-verified result and true story.";
sem explain_reveal.case_id = "The case identifier.";
sem explain_reveal.correct = "Whether the walker verified the accusation as correct.";
sem explain_reveal.story = "The established true story.";
sem explain_reveal.score = "The score already calculated by the walker.";
