node Case {
    has case_id: str = "";
    has title: str = "";
    has where: str = "";
    has what: str = "";
    has goal: str = "";
    has score: int = 1000;
    has wrong_guesses: int = 0;
    has game_over: bool = False;
    has culprit_id: str = "";
    has true_story: str = "";
}

node Suspect {
    has id: str = "";
    has name: str = "";
    has role: str = "";
    has style: str = "";
    has public_alibi: str = "";
    has secret: str = "";
    has lie: str = "";
    has cracked: bool = False;
}

node Clue {
    has id: str = "";
    has title: str = "";
    has text: str = "";
    has found: bool = False;
    has used: bool = False;
}

node ChatLine {
    has who: str = "";
    has text: str = "";
}

edge Knows: Suspect --> Clue {}
edge Breaks: Clue --> Suspect {}
edge Said: ChatLine --> Suspect {}
