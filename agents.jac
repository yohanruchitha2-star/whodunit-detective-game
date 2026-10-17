# Shared data shapes + the 4 AI agents.
# NOTE: keep this file at the project root, with the types defined next to the agents. byllm 0.6.19 / jaclang 0.16.7
# crashes ("'str' object has no attribute 'fields'") when the `by llm` functions live in a sub-package such as game/.
# Other modules should do: import from agents { CaseSpec, SuspectOut, ... }

obj ClueSpec {
    has id: str;
    has title: str;
    has text: str;
    has breaks: str | None;
}

obj SuspectSpec {
    has id: str;
    has name: str;
    has role: str;
    has style: str;
    has public_alibi: str;
    has secret: str;
    has lie: str | None;
    has knows: list[str];
}

obj CaseSpec {
    has title: str;
    has where: str;
    has what: str;
    has culprit_id: str;
    has true_story: str;
    has suspects: list[SuspectSpec];
    has clues: list[ClueSpec];
}

obj ClueInfo {
    has id: str;
    has title: str;
    has text: str;
}

obj SuspectOut {
    has reply: str;
    has proposed_clue_ids: list[str];
}

obj RevealOut {
    has story: str;
    has proof_clues: list[str];
}

# Field descriptions the model sees (sem, not docstrings)
sem CaseSpec.title = "Short case title, e.g. 'The Stolen Necklace'.";
sem CaseSpec.where = "Sri Lankan location of the crime, e.g. 'A wedding hall in Kandy'.";
sem CaseSpec.what = "Two sentences: what happened, when, and the locked-room or puzzle detail. No names of the culprit.";
sem CaseSpec.culprit_id = "Id of the single guilty suspect. Must be one of s1, s2, s3, s4.";
sem CaseSpec.true_story = "Full explanation of how the culprit did it and how the clues prove it. Revealed only at game end.";
sem CaseSpec.suspects = "Exactly 4 suspects with ids s1, s2, s3, s4.";
sem CaseSpec.clues = "Between 3 and 6 clues with ids k1, k2, k3, ...";
sem SuspectSpec.id = "s1, s2, s3 or s4.";
sem SuspectSpec.name = "Sri Lankan first name, unique.";
sem SuspectSpec.role = "Job or relation to the event, one or two words.";
sem SuspectSpec.style = "Speaking style: one of calm, nervous, rude, chatty. Use at least three different styles across the suspects.";
sem SuspectSpec.public_alibi = "What the suspect openly claims they were doing.";
sem SuspectSpec.secret = "What the suspect is really hiding or really did. The culprit's secret is the theft/crime itself.";
sem SuspectSpec.lie = "The false claim this suspect tells (usually their alibi), or None if they do not lie. The culprit MUST lie. At least one innocent suspect MUST also lie (a red herring).";
sem SuspectSpec.knows = "Ids of clues this suspect can reveal when questioned. Never include a clue that breaks this suspect's own lie.";
sem ClueSpec.id = "k1, k2, k3, ...";
sem ClueSpec.title = "Two to four word clue title.";
sem ClueSpec.text = "One short sentence stating the evidence.";
sem ClueSpec.breaks = "Id of the suspect whose lie this clue disproves, or None if it only supports the story. The clue must be known by a DIFFERENT suspect (a witness).";
sem ClueInfo.id = "Clue id.";
sem ClueInfo.title = "Clue title.";
sem ClueInfo.text = "Clue evidence text.";
sem SuspectOut.reply = "The suspect's in-character answer, 1 to 3 short sentences.";
sem SuspectOut.proposed_clue_ids = "Ids of clues the suspect lets slip in this reply. Only ids from the suspect's own known clues, else empty.";
sem RevealOut.story = "One short paragraph telling how the crime happened and how the clues prove the culprit.";
sem RevealOut.proof_clues = "Ids of the clues that prove the culprit's guilt.";


# ---------------------------------------------------------------------------
# Agent 1: Game Master
# ---------------------------------------------------------------------------
def game_master(theme: str) -> CaseSpec by llm(temperature=0.9);
sem game_master = "You are the Game Master of a detective game set in Sri Lanka. Invent a brand new mystery for the given theme. Use Sri Lankan names and places. Exactly 4 suspects (s1-s4), exactly one culprit. Build it in this order. (1) Pick the culprit and write the true story. (2) The culprit has a lie, and at least one clue that breaks it. (3) A different innocent suspect also has a lie with a breaking clue (a red herring the player can crack early). (4) Every clue must appear in the 'knows' list of at least one suspect. HARD RULE: if a clue has breaks = X, its id must be in the 'knows' list of some suspect OTHER than X (a witness) and must NEVER be in X's own 'knows' list. Before answering, check each clue against this rule and fix violations by moving the clue id to a witness. Suspects who do not lie are the natural witnesses. Keep every text short. Never reveal the culprit outside culprit_id and true_story.";
sem game_master.theme = "Setting theme, for example: wedding, office, temple festival, tea estate, train journey.";

# ---------------------------------------------------------------------------
# Agent 2: Suspect
# ---------------------------------------------------------------------------
def suspect_reply(
    suspect: SuspectSpec,
    known_clues: list[ClueInfo],
    history: list[str],
    question: str,
    shown_clue: ClueInfo | None,
    cracked: bool
) -> SuspectOut by llm(temperature=0.7);
sem suspect_reply = "Role-play ONE suspect in a detective interrogation, in first person, 1 to 3 short sentences. Match the speaking style: calm = polite full sentences; nervous = hesitant ('Uh... I mean...'); rude = short and annoyed; chatty = over-shares and gossips. If cracked is False, keep to your lie and public alibi, deflect, and NEVER confess or reveal your secret; if a clue is shown, shrug it off or explain it away. If cracked is True, the shown clue has exposed your lie: admit it and give the truth about what you hid, but still do not accuse anyone you have no evidence against. You may let slip a clue only from known_clues when it fits the question, and list its id in proposed_clue_ids; otherwise return an empty list. Never invent clue ids. Never name who the culprit is.";
sem suspect_reply.suspect = "The suspect being played: name, role, speaking style, public alibi, secret and lie. Never reveal the secret unless cracked is True.";
sem suspect_reply.known_clues = "The only clues this suspect knows and may reveal.";
sem suspect_reply.history = "Earlier lines of this conversation, oldest first, as 'Player: ...' and 'Name: ...'.";
sem suspect_reply.question = "What the player just said or asked. May be empty when a clue is shown.";
sem suspect_reply.shown_clue = "A clue the player is confronting the suspect with, or None.";
sem suspect_reply.cracked = "True only when the game engine verified the shown clue breaks this suspect's lie.";

# ---------------------------------------------------------------------------
# Agent 3: Hint
# ---------------------------------------------------------------------------
def give_hint(
    found_clues: list[ClueInfo],
    unfound_titles: list[str],
    cracked_names: list[str]
) -> str by llm(temperature=0.5);
sem give_hint = "Give the detective ONE short nudge sentence about what to investigate next: timing, places, a contradiction, or a suspect worth pressing again. NEVER name or point at the culprit and never state a conclusion. You may mention the titles of undiscovered clues only as vague topics.";
sem give_hint.found_clues = "Clues the player already has.";
sem give_hint.unfound_titles = "Titles only of clues not yet found.";
sem give_hint.cracked_names = "Names of suspects whose lies are already broken.";

# ---------------------------------------------------------------------------
# Agent 4: Reveal
# ---------------------------------------------------------------------------
def reveal_story(spec: CaseSpec, found_ids: list[str]) -> RevealOut by llm(temperature=0.4);
sem reveal_story = "The game is over. Write a short paragraph (3 to 5 sentences) explaining how the culprit committed the crime and how the clues prove it, staying consistent with true_story. List in proof_clues the ids of the clues that prove guilt, preferring ones the player found.";
sem reveal_story.spec = "The full case including the culprit and true story.";
sem reveal_story.found_ids = "Clue ids the player discovered during play.";
