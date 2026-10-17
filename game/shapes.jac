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
