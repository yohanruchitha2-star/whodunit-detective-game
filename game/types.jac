# Public shapes returned to the browser. Secrets (culprit, lies, secrets, unfound clues) never appear here
# until the game is over.
obj PublicSuspect {
    has id: str = "";
    has name: str = "";
    has role: str = "";
    has style: str = "";
    has cracked: bool = False;
}

obj PublicClue {
    has id: str = "";
    has title: str = "";
    has text: str = "";
}

obj PublicCase {
    has case_id: str = "";
    has title: str = "";
    has place: str = "";
    has what: str = "";
    has goal: str = "";
    has difficulty: str = "normal";
    has suspects: list[PublicSuspect] = [];
    has score: int = 0;
    has hint_cost: int = 100;
    has hints_left: int = -1;
    has chances_left: int = 1;
    has multiplier: float = 1.0;
    has used_backup: bool = False;
    has error: str = "";
}

obj QuestionOut {
    has reply: str = "";
    has new_clues: list[PublicClue] = [];
    has cracked: bool = False;
    has already_cracked: bool = False;
    has score: int = 0;
    has error: str = "";
}

obj HintOut {
    has hint: str = "";
    has hints_left: int = -1;
    has score: int = 0;
    has error: str = "";
}

obj Culprit {
    has id: str = "";
    has name: str = "";
}

obj AccuseOut {
    has correct: bool = False;
    has game_over: bool = False;
    has chances_left: int = 0;
    has score: int = 0;
    has rank: str = "";
    has difficulty: str = "normal";
    has multiplier: float = 1.0;
    has culprit: Culprit | None = None;
    has story: str = "";
    has proof_clues: list[str] = [];
    has error: str = "";
}
