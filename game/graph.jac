# Graph model. One Case node per game hangs off root; everything else hangs off the Case.
node Case {
    has case_id: str = "";
    has title: str = "";
    has place: str = "";
    has what: str = "";
    has goal: str = "Find who did it.";
    has difficulty: str = "normal";
    has score: int = 1000;
    has wrong_guesses: int = 0;
    has hints_used: int = 0;
    has seq: int = 0;
    has game_over: bool = False;
    has used_backup: bool = False;
    has culprit_id: str = "";
    has true_story: str = "";
}

node Suspect {
    has sid: str = "";
    has name: str = "";
    has role: str = "";
    has style: str = "";
    has public_alibi: str = "";
    has secret: str = "";
    has lie: str = "";
    has cracked: bool = False;
}

node Clue {
    has cid: str = "";
    has title: str = "";
    has text: str = "";
    has found: bool = False;
    has used: bool = False;
}

node ChatLine {
    has suspect_id: str = "";
    has speaker: str = "";
    has text: str = "";
    has n: int = 0;
}

edge HasSuspect: Case --> Suspect {}
edge HasClue: Case --> Clue {}
edge HasChat: Case --> ChatLine {}
edge Knows: Suspect --> Clue {}
edge Breaks: Clue --> Suspect {}
edge Said: ChatLine --> Suspect {}
