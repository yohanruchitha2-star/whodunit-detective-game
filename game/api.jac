import from game.types { PublicCase, ChatTurn, Result, PublicClue }

def:pub new_case() -> PublicCase {
    return PublicCase();
}

def:pub question(case_id: str, suspect_id: str, text: str, clue_id: str | None = None) -> ChatTurn {
    return ChatTurn();
}

def:pub hint(case_id: str) -> str {
    return "";
}

def:pub accuse(case_id: str, suspect_id: str, reason: str) -> Result {
    return Result();
}

def:pub get_notebook(case_id: str) -> list[PublicClue] {
    return [];
}
