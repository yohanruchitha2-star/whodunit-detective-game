import from game.walkers { new_case as build_case, question as ask_suspect, hint as make_hint, accuse as judge }
import from game.types { PublicCase, ChatTurn, Result, PublicClue }

def:pub new_case() -> PublicCase {
    return build_case();
}

def:pub question(case_id: str, suspect_id: str, text: str, clue_id: str | None = None) -> ChatTurn {
    return ask_suspect(case_id, suspect_id, text, clue_id);
}

def:pub hint(case_id: str) -> str {
    return make_hint(case_id);
}

def:pub accuse(case_id: str, suspect_id: str, reason: str) -> Result {
    return judge(case_id, suspect_id, reason);
}

def:pub get_notebook(case_id: str) -> list[PublicClue] {
    return [];
}
