node Case {
    has title: str = "";
    has setting: str = "";
    has victim: str = "";
    has summary: str = "";
    has truth: str = "";
    has solved: bool = False;
    has score: int = 1000;
    has wrong_accusations: int = 0;
}

node Suspect {
    has name: str = "";
    has role: str = "";
    has personality: str = "";
    has secret: str = "";
    has alibi_lie: str = "";
    has is_culprit: bool = False;
    has cracked: bool = False;
}

node Clue {
    has text: str = "";
    has found: bool = False;
    has unlock_hint: str = "";
}

node ChatLine {
    has speaker: str = "";
    has text: str = "";
}

edge HasSuspect {}
edge HasClue {}
edge Knows {}
edge Breaks {}
edge Said {}
