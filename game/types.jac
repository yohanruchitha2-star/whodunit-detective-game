obj ClueSpec {
    has text: str = "";
    has breaks_suspect: str = "";
    has known_by: list[str] = [];
    has unlock_hint: str = "";
}

obj SuspectSpec {
    has name: str = "";
    has role: str = "";
    has personality: str = "";
    has secret: str = "";
    has alibi_lie: str = "";
    has is_culprit: bool = False;
}

obj CaseSpec {
    has title: str = "";
    has setting: str = "";
    has victim: str = "";
    has summary: str = "";
    has truth: str = "";
    has suspects: list[SuspectSpec] = [];
    has clues: list[ClueSpec] = [];
}

obj SuspectOut {
    has reply: str = "";
    has revealed_clue_ids: list[str] = [];
}

obj PublicSuspect {
    has id: str = "";
    has name: str = "";
    has role: str = "";
    has personality: str = "";
    has cracked: bool = False;
}

obj PublicClue {
    has id: str = "";
    has text: str = "";
}

obj PublicCase {
    has case_id: str = "";
    has title: str = "";
    has setting: str = "";
    has summary: str = "";
    has suspects: list[PublicSuspect] = [];
    has found_clues: list[PublicClue] = [];
    has score: int = 0;
    has screen: str = "start";
}

obj ChatTurn {
    has reply: str = "";
    has notebook: list[PublicClue] = [];
    has cracked_now: bool = False;
    has score: int = 0;
}

obj Result {
    has correct: bool = False;
    has final: bool = False;
    has story: str = "";
    has score: int = 0;
    has rank: str = "";
}
